local Spell = { }
Spell.LearnTime = 120
Spell.ApplyFireDelay = 0.4
Spell.Description = [[
	A hex used to make the 
	target's shoes stick to 
	the ground.
]]

Spell.NodeOffset = Vector(-717, -231, 0)
Spell.AccuracyDecreaseVal = 0.1

local model = Model("models/weapons/w_bugbait.mdl")

function Spell:OnFire(wand)
	local ent = wand:HPWGetAimEntity(400)

	if IsValid(ent) and (ent:IsPlayer()) then
		local tName = "hpwrewrite_colloshoo_handler" .. ent:EntIndex()

		if not timer.Exists(tName) then
			local a1 = ents.Create("base_anim")
			a1:SetPos(ent:GetPos())
			a1:SetModel(model)
			a1:SetColor(Color(0, 255, 0))
			a1:SetModelScale(4, 0)
			a1:Spawn()
			a1:Activate()

			local bone = ent:LookupBone("ValveBiped.Bip01_L_Foot")
			if bone then a1:FollowBone(ent, bone) end

			local a2 = ents.Create("base_anim")
			a2:SetPos(ent:GetPos())
			a2:SetModel(model)
			a2:SetColor(Color(0, 255, 0))
			a2:SetModelScale(4, 0)
			a2:Spawn()
			a2:Activate()

			local bone = ent:LookupBone("ValveBiped.Bip01_R_Foot")
			if bone then a2:FollowBone(ent, bone) end

			local old1 = ent:GetWalkSpeed()
			local old2 = ent:GetRunSpeed()
			local old3 = ent:GetJumpPower()

			ent:SetWalkSpeed(20)
			ent:SetRunSpeed(20)
			ent:SetJumpPower(0)

			timer.Create(tName, 15, 1, function()
				if ent:IsValid() then
					ent:SetWalkSpeed(old1)
					ent:SetRunSpeed(old2)
					ent:SetJumpPower(old3)
				end

				SafeRemoveEntity(a1)
				SafeRemoveEntity(a2)
			end)

			sound.Play("npc/antlion/idle3.wav", ent:GetPos(), 60, math.random(240, 255))
		end
	end

	sound.Play("npc/antlion/idle3.wav", wand:GetPos(), 60, math.random(240, 255))
end

HpwRewrite:AddSpell("Colloshoo", Spell)