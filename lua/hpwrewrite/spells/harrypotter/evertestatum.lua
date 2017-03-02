local Spell = { }
Spell.LearnTime = 60
Spell.Category = HpwRewrite.CategoryNames.Physics
Spell.Description = [[
	Causes opponent to fly back 
	several feet. Being casted
	on object will push it away.

	Note that it doesn't deal 
	any damage!
]]

Spell.ApplyDelay = 0.4
Spell.FlyEffect = "hpw_confringo_main"
Spell.OnlyIfLearned = { "Alarte Ascendare" }
Spell.ForceAnim = { ACT_VM_PRIMARYATTACK_5 }
Spell.SpriteColor = Color(255, 165, 0)

Spell.NodeOffset = Vector(309, 214, 0)
Spell.LeaveParticles = true

function Spell:Draw(spell)
	--self:DrawGlow(spell)
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
		local a, b, c, d = HpwRewrite:ThrowEntity(ent, spell:GetFlyDirection(), 3000, 2)
		if d then hook.Remove("EntityTakeDamage", d) end
		if IsValid(a) then sound.Play("weapons/crossbow/bolt_fly4.wav", data.HitPos, 70, 80) end

		if IsValid(ent:GetPhysicsObject()) and not ent:IsPlayer() and not ent:IsNPC() then
			if ent:GetModelRadius() > 400 then return end

			local phys = ent:GetPhysicsObject()
			local mass = phys:GetMass()
			if mass > 2000 then return end

			phys:ApplyForceCenter(vector_up * mass * 100)
			phys:ApplyForceOffset(spell:GetFlyDirection() * mass * 600, spell:GetPos())
		end
	end
end

HpwRewrite:AddSpell("Everte Statum", Spell)