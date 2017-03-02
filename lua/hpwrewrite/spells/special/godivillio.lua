local Spell = { }
Spell.LearnTime = 600
Spell.ApplyFireDelay = 0.4
Spell.Category = { HpwRewrite.CategoryNames.Protecting, HpwRewrite.CategoryNames.Special }
Spell.Description = [[
	Makes an unbreakable shield
	around player or anything.
]]

Spell.OnlyIfLearned = { "Vulnera Sanentur", "Protego" }
Spell.ForceAnim = { ACT_VM_PRIMARYATTACK_4 }
Spell.NodeOffset = Vector(-688, 274, 0)
Spell.DoSelfCastAnim = false
Spell.SpriteColor = Color(255, 255, 200)

if SERVER then
	util.AddNetworkString("hpwrewrite_godivillio_handler")
else
	local switch = false
	net.Receive("hpwrewrite_godivillio_handler", function()
		local ent = net.ReadEntity()

		if IsValid(ent) then
			if ent == LocalPlayer() then return end

			local mdl = ClientsideModel(ent:GetModel(), RENDERGROUP_TRANSLUCENT)
			mdl:SetPos(ent:GetPos())
			mdl:SetAngles(ent:GetAngles())
			mdl:SetMaterial(ent:GetMaterial())
			mdl:SetSkin(ent:GetSkin())
			mdl:Spawn()

			mdl:SetRenderMode(RENDERMODE_TRANSALPHA)
			mdl:SetColor(Color(0, 255, 0, 200))

			mdl:SetModelScale(ent:GetModelScale() * 1.02, 0)
			if not ent:IsPlayer() then mdl:SetParent(ent) end

			local snd = CreateSound(ent, "items/suitcharge1.wav")
			snd:Play()
			snd:ChangePitch(70, 0)
			snd:FadeOut(3)

			local name = "hpwrewrite_godivillio_handlermdl" .. mdl:EntIndex()
			hook.Add("Think", name, function()
				if not IsValid(mdl) or not IsValid(ent) then 
					SafeRemoveEntity(mdl) 
					hook.Remove("Think", name) 

					return 
				end

				if ent:IsPlayer() then
					mdl:SetPos(ent:GetPos())
					mdl:SetAngles(Angle(0, ent:GetAngles().y, 0))
				end

				mdl:SetSequence(ent:GetSequence())
				mdl:FrameAdvance(1)
			end)

			timer.Simple(3, function() SafeRemoveEntity(mdl) end)

			return
		end

		switch = not switch

		if switch then
			hook.Add("RenderScreenspaceEffects", "hpwrewrite_godivillio_handler", function()
				DrawMaterialOverlay( "effects/flicker_256", math.sin(CurTime()*3)*0.02)
				DrawMaterialOverlay( "particle/warp3_warp_noz", math.sin(CurTime()*3)*0.02)
			end)
		else
			hook.Remove("RenderScreenspaceEffects", "hpwrewrite_godivillio_handler")
		end
	end)
end

function Spell:GetAnimations(wand)
	if self.NotAvailable then return ACT_VM_PRIMARYATTACK_3 end
end

local undereff = { }

local function DoEffect(ent)
	local count = ent:GetBoneCount()

	if count then
		for i = 1, count - 1 do
			local pos, ang = ent:GetBonePosition(i)
			if pos and ang then HpwRewrite.MakeEffect("hpw_stupefy_impact", pos, ang) end
		end

		HpwRewrite.MakeEffect("hpw_stupefy_impact", ent:GetPos(), Angle(0, 0, 0))
	end
end

function Spell:OnFire(wand)
	local ent = wand:HPWGetAimEntity(700)

	if IsValid(ent) and IsValid(ent:GetPhysicsObject()) and not ent:IsWorld() and not undereff[ent] then
		if self.NotAvailable then
			sound.Play("weapons/physcannon/energy_bounce" .. math.random(1, 2) .. ".wav", wand:GetPos(), 75, 130)
			return
		end

		self.NotAvailable = true
		timer.Create("hpwrewrite_godivillio_nerf" .. self.Owner:EntIndex(), math.random(9, 11), 1, function()
			self.NotAvailable = false
		end)

		local func = function() end

		DoEffect(ent)

		if ent:IsPlayer() then
			ent:GodEnable()
			net.Start("hpwrewrite_godivillio_handler")
			net.Send(ent)

			func = function(ent)
				ent:GodDisable()
				net.Start("hpwrewrite_godivillio_handler")
				net.Send(ent)
			end
		else
			local name = "hpwrewrite_godivillio_handler" .. ent:EntIndex()
			hook.Add("EntityTakeDamage", name, function(victim, dmg)
				if not IsValid(ent) then hook.Remove("EntityTakeDamage", name) return end
				if victim == ent then return true end
			end)

			func = function()
				hook.Remove("EntityTakeDamage", name)
			end
		end

		undereff[ent] = true

		net.Start("hpwrewrite_godivillio_handler")
			net.WriteEntity(ent)
		net.Broadcast()

		timer.Create("hpwrewrite_godivillio_handler" .. ent:EntIndex(), 3, 1, function()
			if IsValid(ent) then
				func(ent)
				sound.Play("hpwrewrite/spells/godivillio.wav", ent:GetPos(), 75)
				DoEffect(ent)
			end

			undereff[ent] = nil
		end)

		for i = 1, 7 do
			sound.Play("items/battery_pickup.wav", ent:GetPos(), 74, math.random(70, 230))
		end
	end
end

HpwRewrite:AddSpell("Godivillio", Spell)