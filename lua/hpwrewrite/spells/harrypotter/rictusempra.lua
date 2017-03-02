local Spell = { }
Spell.LearnTime = 180
Spell.Description = [[
	Knocks down your opponent.
	Useful in duels.
]]
Spell.Category = HpwRewrite.CategoryNames.Fight
Spell.FlyEffect = "hpw_sectumsemp_main"
Spell.ImpactEffect = "hpw_white_impact"
Spell.ApplyDelay = 0.5
Spell.ForceAnim = { ACT_VM_PRIMARYATTACK_1, ACT_VM_PRIMARYATTACK_2 }
Spell.SpriteColor = Color(255, 255, 255)
Spell.NodeOffset = Vector(-960, -317, 0)

function Spell:OnSpellSpawned(wand, spell)
	sound.Play("ambient/wind/wind_snippet2.wav", spell:GetPos(), 75, 255)
	wand:PlayCastSound()
end

function Spell:OnFire(wand)
	return true
end

function Spell:AfterCollide(spell, data)
	local ent = HpwRewrite:ThrowEntity(data.HitEntity, spell:GetFlyDirection(), nil, 0.7, self.Owner)

	if IsValid(ent) then 
		sound.Play("npc/zombie/claw_strike" .. math.random(1, 3) .. ".wav", ent:GetPos(), 70, math.random(90, 110))

		local phys = ent:GetPhysicsObject()
		if phys:IsValid() then
			phys:AddAngleVelocity(Vector(0, 30000, 0))
		end
	end
end

HpwRewrite:AddSpell("Rictusempra", Spell)	