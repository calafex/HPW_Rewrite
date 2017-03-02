local Spell = { }
Spell.LearnTime = 90
Spell.Category = HpwRewrite.CategoryNames.Physics
Spell.Description = [[
	Banishes anything from you.

	Also, this spell can
	knockback your enemy
	and break glass objects.
]]

Spell.ApplyDelay = 0.5
Spell.AccuracyDecreaseVal = 0.15
Spell.FlyEffect = "hpw_flipendo_main"
Spell.OnlyIfLearned = { "Depulso" }
Spell.ForceAnim = { ACT_VM_PRIMARYATTACK_3 }
Spell.SpriteColor = Color(255, 165, 0)
Spell.LeaveParticles = true
Spell.NodeOffset = Vector(-57, 352, 0)

function Spell:Draw(spell)
	self:DrawGlow(spell, Color(255, 120, 0, 50))
end

function Spell:OnSpellSpawned(wand, spell)
	wand:PlayCastSound()
end

function Spell:OnFire(wand)
	return true
end

function Spell:AfterCollide(spell, data)
	local ent = data.HitEntity
	if IsValid(ent) then
		HpwRewrite:ThrowEntity(ent, spell:GetFlyDirection(), 1200, 2, self.Owner)

		if IsValid(ent:GetPhysicsObject()) and not ent:IsPlayer() and not ent:IsNPC() then
			if ent:GetModelRadius() > 400 then return end

			local phys = ent:GetPhysicsObject()
			local mass = phys:GetMass()
			if mass > 2000 then return end

			if ent:GetMaterialType() == MAT_GLASS then
				ent:TakeDamage(ent:Health())
				return
			end

			phys:ApplyForceCenter(vector_up * mass * 100)

			sound.Play("ambient/wind/wind_snippet2.wav", ent:GetPos(), 75, 255)

			phys:ApplyForceOffset(spell:GetFlyDirection() * mass * 600, spell:GetPos())
		end
	end
end

HpwRewrite:AddSpell("Flipendo", Spell)