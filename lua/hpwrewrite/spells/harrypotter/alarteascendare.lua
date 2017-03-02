local Spell = { }
Spell.LearnTime = 60
Spell.ApplyFireDelay = 0.4
Spell.Category = HpwRewrite.CategoryNames.Physics
Spell.OnlyIfLearned = { "Arresto Momentum" }
Spell.SpriteColor = Color(255, 0, 0)
Spell.Description = [[
	Used to launch the object up 
	into the air.
]]

Spell.NodeOffset = Vector(283, 361, 0)

function Spell:OnFire(wand)
	local ent = wand:HPWGetAimEntity(1000, Vector(-10, -10, -4), Vector(10, 10, 4))

	if IsValid(ent) then
		if ent:IsPlayer() or ent:IsNPC() then
			ent:SetVelocity(Vector(0, 0, 500))
		else
			local phys = ent:GetPhysicsObject()
			if phys:IsValid() then
				phys:ApplyForceCenter(vector_up * phys:GetMass() * (math.max(0, 500 - ent:GetModelRadius())))
			end
		end
	end

	sound.Play("npc/antlion/idle3.wav", wand:GetPos(), 55, math.random(240, 255))
end

HpwRewrite:AddSpell("Alarte Ascendare", Spell)