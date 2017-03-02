local Spell = { }
Spell.LearnTime = 30
Spell.ApplyFireDelay = 0.2
Spell.Category = HpwRewrite.CategoryNames.Physics
Spell.Description = [[
	Banishes anything from you.
]]
Spell.CanSelfCast = false
Spell.ForceAnim = { ACT_VM_PRIMARYATTACK_2 }
Spell.SpriteColor = Color(255, 255, 255)

Spell.NodeOffset = Vector(-15, 494, 0)

function Spell:OnFire(wand)
	sound.Play("ambient/wind/wind_hit" .. math.random(1, 2) .. ".wav", wand:GetPos(), 65, math.random(180, 255))

	local maxDist = 2500
	local ent = wand:HPWGetAimEntity(maxDist, Vector(-6, -6, -4), Vector(6, 6, 4))
	
	if IsValid(ent) and IsValid(ent:GetPhysicsObject()) and not ent:IsPlayer() and not ent:IsNPC() then
		if ent:GetModelRadius() > 400 then return end

		local phys = ent:GetPhysicsObject()
		local mass = phys:GetMass()
		if mass > 2000 then return end
		phys:ApplyForceCenter(vector_up * mass * 100)

		sound.Play("ambient/wind/wind_snippet2.wav", ent:GetPos(), 75, 255)

		local dist = ent:GetPos():Distance(self.Owner:GetPos())
		phys:ApplyForceCenter((ent:GetPos() - self.Owner:GetPos()):GetNormal() * mass * math.max(0, maxDist - dist) * 0.7)
	end
end

HpwRewrite:AddSpell("Depulso", Spell)