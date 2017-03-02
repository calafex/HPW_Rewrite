if not HpwRewrite then return end

HpwRewrite.FM = HpwRewrite.FM or { }

function HpwRewrite.FM:GetValue(ply)
	if CLIENT then return self.FightingValue end
	return ply.HpwRewrite.InFighting
end

if CLIENT then
	HpwRewrite.FM.FightingValue = false

	net.Receive("hpwrewrite_Fight", function(args)
		HpwRewrite.FM.FightingValue = tobool(net.ReadBit())
	end)

	net.Receive("hpwrewrite_HUDF", function()
		local remove = net.ReadBit()
		if remove and tobool(remove) then
			hook.Remove("HUDPaint", "hpwrewrite_fighting_hud")
			return
		end

		local red = 0
		
		hook.Add("HUDPaint", "hpwrewrite_fighting_hud", function()
			local w, h = ScrW(), ScrH()
			local x, y = w / 2, h - 300
			
			local val = red / 255
			local mat = Matrix()
			mat:Translate(Vector(x, y))
			mat:Scale(Vector(0.7, 0.7, 0.7) + Vector(1, 1, 1) * math.abs(math.sin(CurTime() * 16 + (val * 16)) * ((val * 0.03) + 0.05)))
			mat:Translate(-Vector(x, y))
			
			red = math.Approach(red, 0, 10)
			local color = Color(255, 255 - red, 255 - red, 255)
			
			if LocalPlayer():KeyPressed(IN_ATTACK) then
				red = 255
			end
			
			cam.PushModelMatrix(mat)
				draw.SimpleText("CLICK LEFT MOUSE BUTTON", "HPW_font2", x, y, color, TEXT_ALIGN_CENTER)
			cam.PopModelMatrix()
		end)
	end)

	return
end

HpwRewrite.FM.Fightings = { }

function HpwRewrite.FM:SetValue(ply, val)
	ply.HpwRewrite.InFighting = val

	net.Start("hpwrewrite_Fight")
		net.WriteBit(val)
	net.Send(ply)
end

function HpwRewrite.FM:SetupPlayer(ply)
	self:SetValue(ply, true)

	net.Start("hpwrewrite_HUDF")
		net.WriteBit(false)
	net.Send(ply)

	ply.HpwRewrite.OldSpeed = ply:GetWalkSpeed()
	ply.HpwRewrite.OldSprintSpeed = ply:GetRunSpeed()
	ply.HpwRewrite.OldJumpPower = ply:GetJumpPower()

	ply:SetWalkSpeed(50)
	ply:SetRunSpeed(50)
	ply:SetJumpPower(0)

	local wand = HpwRewrite:GetWand(ply)
	ply.HpwRewrite.OldHoldType = wand:GetHoldType()
	wand:SetHoldType("revolver")
end

function HpwRewrite.FM:DestroyPlayer(ply)
	self:SetValue(ply, false)

	net.Start("hpwrewrite_HUDF")
		net.WriteBit(true)
	net.Send(ply)

	ply:SetWalkSpeed(ply.HpwRewrite.OldSpeed)
	ply:SetRunSpeed(ply.HpwRewrite.OldSprintSpeed)
	ply:SetJumpPower(ply.HpwRewrite.OldJumpPower)

	local wand = HpwRewrite:GetWand(ply)
	if wand:IsValid() then 
		wand:RequestSprite("", Color(0, 0, 0, 0), 1000, 0.1, true) 
		wand:SetHoldType(ply.HpwRewrite.OldHoldType)
		
		wand:SetNextPrimaryFire(CurTime() + 0.2)
	end
end

-- Checks if player1 can fight with player2
function HpwRewrite.FM:CheckFighting(ply1, ply2)
	if ply1 == ply2 then return false end
	if not IsValid(ply1) then return false end
	if not IsValid(ply2) then return false end
	if not ply1:IsPlayer() then return false end
	if not ply2:IsPlayer() then return false end

	local wep = ply1:GetActiveWeapon()
	if not HpwRewrite.IsValidWand(wep) then return false, ply2 end

	local wep = ply2:GetActiveWeapon()
	if not HpwRewrite.IsValidWand(wep) then return false, ply1 end

	if ply1:GetPos():Distance(ply2:GetPos()) > 1100 then return false end

	return true
end

local randAnims = { ACT_VM_PRIMARYATTACK_2, ACT_VM_PRIMARYATTACK_3 }
function HpwRewrite.FM:StartFighting(ply1, ply2, spell1, spell2, oldSpellPos)
	if not spell1.Fightable or not spell2.Fightable then return end
	if not self:CheckFighting(ply1, ply2) then return end

	if self:GetValue(ply1) then return end
	if self:GetValue(ply2) then return end

	self:SetupPlayer(ply1)
	self:SetupPlayer(ply2)

	local tab = { }
	tab.ID = #self.Fightings + 1
	tab.LastKey1 = false
	tab.LastKey2 = false
	tab.Ply1 = ply1
	tab.Ply2 = ply2
	tab.Spell1 = spell1 -- Player1 spell (will act on ply2 if ply1 wins)
	tab.Spell2 = spell2 -- Player2 spell (will act on ply1 if ply2 wins)
	tab.OldSpellPos = oldSpellPos -- Where spells hit
	tab.NewSpellPos = oldSpellPos 
	tab.ForceCoefficient = 0
	tab.AnimWait = 0

	if spell1.SpriteColor then HpwRewrite:GetWand(ply1):RequestSprite("", spell1.SpriteColor, 0, 1.2, true) end
	if spell2.SpriteColor then HpwRewrite:GetWand(ply2):RequestSprite("", spell2.SpriteColor, 0, 1.2, true) end

	-- Spawning
	local e = ents.Create("info_hpwand_fightingeffect")
	e:SetPos(tab.NewSpellPos)
	e:Spawn()
	e:Activate()

	e:SetFirstPlayer(ply1)
	e:SetSecondPlayer(ply2)

	e:SetFirstSpell(spell1.Name)
	e:SetSecondSpell(spell2.Name)

	tab.EffectHandler = e

	hook.Add("Think", "hpwrewrite_fighting" .. tab.ID, function()
		if not e:IsValid() then self:EndFighting(tab.ID, nil) return end

		local check, winner = self:CheckFighting(ply1, ply2)
		if not check then self:EndFighting(tab.ID, winner) return end

		-- Would be better to split this code in a function
		-- TODO;

		if ply1:KeyDown(IN_ATTACK2) then self:EndFighting(tab.ID, ply2) return end
		if ply2:KeyDown(IN_ATTACK2) then self:EndFighting(tab.ID, ply1) return end

		local pos1 = ply1:LocalToWorld(ply1:OBBCenter())
		local pos2 = ply2:LocalToWorld(ply2:OBBCenter())

		if CurTime() > tab.AnimWait then
			local wand1 = HpwRewrite:GetWand(ply1)
			if wand1:IsValid() then wand1:HPWSendAnimation(ACT_VM_PRIMARYATTACK_3) end

			local wand2 = HpwRewrite:GetWand(ply2)
			if wand2:IsValid() then wand2:HPWSendAnimation(ACT_VM_PRIMARYATTACK_3) end

			tab.AnimWait = CurTime() + 0.1
		end

		if tab.NewSpellPos:Distance(pos1) <= 60 and tab.ForceCoefficient > 0 then self:EndFighting(tab.ID, ply2) return end
		if tab.NewSpellPos:Distance(pos2) <= 60 and tab.ForceCoefficient < 0 then self:EndFighting(tab.ID, ply1) return end

		if ply1:KeyDown(IN_ATTACK) then 
			if not tab.LastKey1 then
				tab.ForceCoefficient = tab.ForceCoefficient - 0.0015

				local wand = HpwRewrite:GetWand(ply1)
				wand:HPWSendAnimation(table.Random(randAnims))

				tab.LastKey1 = true
			end
		else
			tab.LastKey1 = false
		end

		if ply2:KeyDown(IN_ATTACK) then 
			if not tab.LastKey2 then
				tab.ForceCoefficient = tab.ForceCoefficient + 0.0015

				local wand = HpwRewrite:GetWand(ply2)
				wand:HPWSendAnimation(table.Random(randAnims))

				tab.LastKey2 = true
			end
		else
			tab.LastKey2 = false
		end

		tab.NewSpellPos = LerpVector(math.abs(tab.ForceCoefficient), tab.NewSpellPos, tab.ForceCoefficient > 0 and pos1 or pos2)

		local filt = { ply1, ply2, tab.EffectHandler }
		local shPos = ply1:GetShootPos()
		local aimPos = util.TraceLine({
			start = shPos,
			endpos = shPos + ply1:GetAimVector() * tab.NewSpellPos:Distance(shPos),
			filter = filt
		}).HitPos

		tab.NewSpellPos = LerpVector(0.007, tab.NewSpellPos, aimPos)

		local filt = { ply2, tab.EffectHandler }
		local shPos = ply2:GetShootPos()
		local aimPos = util.TraceLine({
			start = shPos,
			endpos = shPos + ply2:GetAimVector() * tab.NewSpellPos:Distance(shPos),
			filter = filt
		}).HitPos
		
		tab.NewSpellPos = LerpVector(0.007, tab.NewSpellPos, aimPos)

		--print((ply2:GetPos() - ply1:EyePos()):GetNormal():Dot(ply1:EyeAngles():Forward()))

		if tab.EffectHandler:IsValid() then
			local a = CurTime() * 5
			local sin = math.sin(a) * 5
			local cos = math.cos(a) * 5

			tab.EffectHandler:SetPos(tab.NewSpellPos + Vector(sin, cos, cos + sin))
		end
	end)

	self.Fightings[tab.ID] = tab

	HpwRewrite:LogDebug(ply1:Name() .. " and " .. ply2:Name() .. " started fighting!")
end

function HpwRewrite.FM:EndFighting(id, winner)
	local tab = self.Fightings[id]
	if not tab then return end

	SafeRemoveEntity(tab.EffectHandler)

	hook.Remove("Think", "hpwrewrite_fighting" .. id)

	self:DestroyPlayer(tab.Ply1)
	self:DestroyPlayer(tab.Ply2)

	-- loosoerr1!!1!!

	local loser
	local spell

	if winner == tab.Ply1 then 
		loser = tab.Ply2 
		spell = tab.Spell1
	elseif winner == tab.Ply2 then
		loser = tab.Ply1 
		spell = tab.Spell2
	end

	if IsValid(winner) and IsValid(loser) and spell then
		local data = { }

		data.HitEntity = loser
		data.HitPos = loser:LocalToWorld(loser:OBBCenter())
		data.Speed = 0
		data.HitNormal = Vector(0, 0, 0)

		local ent = ents.Create("entity_hpwand_flyingspell")
		ent:SetOwner(winner)
		ent:SetPos(data.HitPos)
		ent:SetSpellData(spell)
		ent:SetupOwner(winner)
		ent:Spawn()

		ent:PhysicsCollide(data, ent:GetPhysicsObject())

		HpwRewrite:LogDebug(winner:Name() .. " and " .. loser:Name() .. " ended fighting!")
	end

	self.Fightings[id] = nil
end