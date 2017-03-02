local Spell = { }
Spell.LearnTime = 90
Spell.Category = HpwRewrite.CategoryNames.Physics
Spell.Description = [[
	Forces target to move 
	downwards.
]]

Spell.ApplyFireDelay = 0.4
Spell.OnlyIfLearned = { "Accio" }
Spell.NodeOffset = Vector(302, 549, 0)
Spell.SpriteColor = Color(50, 80, 255)

function Spell:OnFire(wand)
	local ent, eyeTr = wand:HPWGetAimEntity(1800)
	
	if IsValid(ent) then
		local radius = ent:GetModelRadius()
		if radius > 400 then return end

		local phys = ent:GetPhysicsObject()
		if not phys:IsValid() then return end

		if not ent:IsPlayer() and not phys:IsValid() then return end
		if phys:GetMass() > 2000 then return end

		local center = ent:OBBCenter()
		local stPos = ent:LocalToWorld(center)

		local tr = util.TraceLine({
			start = stPos,
			endpos = stPos - Vector(0, 0, radius * 1.2),
			filter = ent
		})

		if tr.Hit then 
			sound.Play("hpwrewrite/spells/spellimpact.wav", ent:GetPos(), 70, 120)

			phys:Sleep()
			phys:EnableMotion(false)

			for i = 1, 8 do
				local pos = Vector(math.sin(i), math.cos(i), 0) * radius * 0.75
				HpwRewrite.MakeEffect("hpw_reducto_impact_stone", tr.HitPos + pos, Angle(0, 0, 0))
			end

			timer.Create("hpwrewrite_descendo_handler" .. ent:EntIndex(), 0.05, 40, function()
				if not ent:IsValid() then return end
				if not phys:IsValid() then return end

				ent:SetPos(ent:GetPos() - Vector(0, 0, 1))
				util.ScreenShake(stPos, 3, 3, 0.1, 200)

				if math.random(0, 4) == 1 then
					sound.Play("physics/concrete/boulder_impact_hard" .. math.random(1, 4) .. ".wav", stPos, 69, 80)
				end
			end)

			timer.Simple(2.05, function()
				if not ent:IsValid() then return end
				if not phys:IsValid() then return end
			end)
		elseif eyeTr then
			phys:ApplyForceOffset(Vector(0, 0, -1) * phys:GetMass() * 200, eyeTr.HitPos)
		end
	end
end

HpwRewrite:AddSpell("Descendo", Spell)