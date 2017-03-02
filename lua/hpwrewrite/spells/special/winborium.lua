local Spell = { }
Spell.LearnTime = 900
Spell.Description = [[
	Rips your target's
	body with demonic harpoons.

	100% brutal.
]]
Spell.FlyEffect = "hpw_dragoner_main"
Spell.ApplyDelay = 0.6
Spell.AccuracyDecreaseVal = 0.4
Spell.Category = HpwRewrite.CategoryNames.Special
Spell.SpriteColor = Color(155, 255, 155)
Spell.NodeOffset = Vector(-332, -890, 0)

Spell.ForceAnim = { ACT_VM_PRIMARYATTACK_5 }

if SERVER then
	util.AddNetworkString("hpwrewrite_winborium_handler")
else
	local max = 2^32

	local function spawn(mdl, pos, dir)
		util.PrecacheModel(mdl)
			
		local myPos = pos + VectorRand() * 25
		local prop = ents.CreateClientProp()
		prop:SetModel(mdl)
		prop:SetPos(myPos)
		prop:SetAngles((pos - myPos):Angle())
		prop:Spawn()
		prop:PhysicsInit(SOLID_VPHYSICS)
		prop:SetSolid(SOLID_VPHYSICS)
		prop:SetMoveType(MOVETYPE_VPHYSICS)
		prop:SetRenderMode(RENDERMODE_TRANSALPHA)

		local decay = math.random(400, 800)
		local alpha = 255
		local dir = AngleRand()

		local name = "hpwrewrite_winborium_handler" .. math.random(-max, max)
		hook.Add("Think", name, function()
			if not IsValid(prop) then hook.Remove("Think", name) return end

			prop:SetPos(prop:GetPos() + (dir and prop:GetForward() or prop:GetUp()) * FrameTime() * 350)
			prop:SetAngles(prop:GetAngles() + dir * FrameTime() * 7)
			prop:SetColor(Color(255, 0, 0, alpha))
				
			alpha = alpha - FrameTime() * decay

			if alpha <= 0 then prop:Remove() end
		end)
	end

	net.Receive("hpwrewrite_winborium_handler", function()
		local pos = net.ReadVector()

		for i = 1, 20 do
			spawn("models/weapons/w_knife_t.mdl", pos)
		end

		for i = 1, 8 do
			spawn("models/props_junk/harpoon002a.mdl", pos, true)
		end
	end)
end

function Spell:Draw(spell)
	self:DrawGlow(spell)
end

function Spell:OnSpellSpawned(wand, spell)
	wand:PlayCastSound()
end

function Spell:OnFire(wand)
	return true
end

function Spell:AfterCollide(spell, data, doef)
	local dir = IsValid(spell) and spell:GetFlyDirection() or vector_origin

	local ent = data.HitEntity
	local rag, func, tName, hName = HpwRewrite:ThrowEntity(ent, -dir, 3000, 3, self.Owner)

	if IsValid(rag) then
		if hName then hook.Remove("EntityTakeDamage", hName) end

		net.Start("hpwrewrite_winborium_handler")
			net.WriteVector(rag:GetPos() - dir * 100)
		net.Broadcast()

		local name = "hpwrewrite_winborium_handler" .. rag:EntIndex()
		timer.Create(name, 0.2, 1, function()
			if IsValid(rag) then
				net.Start("hpwrewrite_winborium_handler")
					net.WriteVector(rag:GetPos())
				net.Broadcast()

				sound.Play("physics/flesh/flesh_bloody_break.wav", rag:GetPos(), 70)
				for i = 0, rag:GetBoneCount() - 1 do
					local pos, ang = rag:GetBonePosition(i)

					local ef = EffectData()
					ef:SetOrigin(pos)
					util.Effect("BloodImpact", ef, true, true)

					if math.random(1, 2) == 1 then
						sound.Play("physics/flesh/flesh_squishy_impact_hard" .. math.random(1, 4) .. ".wav", pos, 69)
					end
				end

				local newEnt = func()

				if IsValid(newEnt) then
					if newEnt:IsNPC() then
						newEnt:Remove()
					elseif newEnt:IsPlayer() then
						newEnt:TakeDamage(newEnt:Health(), self.Owner, HpwRewrite:GetWand(self.Owner))
						SafeRemoveEntity(newEnt:GetRagdollEntity())
					end
				end
			end
		end)
	else
		if doef == nil then doef = true end
		if doef then
			local ef = EffectData()
			ef:SetOrigin(data.HitPos)
			ef:SetNormal(data.HitNormal)
			util.Effect("EffectHpwRewriteSmoke", ef, true, true)
		end
	end
end

HpwRewrite:AddSpell("Winborium", Spell)




-- Duo

local Spell = { }

Spell.Base = "Winborium"
Spell.LearnTime = 1020
Spell.OnlyIfLearned = { "Winborium", "Gonfiare" }
Spell.NodeOffset = Vector(-227, -993, 0)
Spell.ForceAnim = { ACT_VM_PRIMARYATTACK_1 }
Spell.DoSparks = true

Spell.Description = [[
	Rips bodies of everyone
	who is close to spell impact.

	100% brutal.
]]

function Spell:AfterCollide(spell, data)
	local ef = true
	for k, v in pairs(ents.FindInSphere(data.HitPos, 200)) do
		if not (v:IsNPC() or v:IsPlayer()) then continue end 
		
		data.HitEntity = v
		self.BaseClass.AfterCollide(self, spell, data, ef)
		ef = false
	end
end

HpwRewrite:AddSpell("Winborium Duo", Spell)



-- Holy shit

local Spell = { }

Spell.Base = "Winborium"
Spell.LearnTime = 1350
Spell.OnlyIfLearned = { "Winborium Duo" }
Spell.NodeOffset = Vector(-214, -1124, 0)
Spell.ForceAnim = { ACT_VM_PRIMARYATTACK_4 }
Spell.DoSparks = true

Spell.Description = [[
	Kills everyone around you
	in a big radius.
]]

function Spell:OnFire()
	for k, v in pairs(ents.FindInSphere(self.Owner:GetPos(), 500)) do
		if v == self.Owner or not (v:IsNPC() or v:IsPlayer()) then continue end

		local data = { }
		data.HitPos = v:GetPos()
		data.HitNormal = vector_origin
		data.HitEntity = v

		self.BaseClass.AfterCollide(self, nil, data)
	end
end

HpwRewrite:AddSpell("Winborium Maxima", Spell)
