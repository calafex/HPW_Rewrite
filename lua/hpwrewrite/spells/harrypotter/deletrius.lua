local Spell = { }
Spell.LearnTime = 750
Spell.Description = [[
	Used to disintegrate your
	target.
]]

Spell.FlyEffect = "hpw_deletrius_main"
Spell.ApplyDelay = 0.5
Spell.AccuracyDecreaseVal = 0.4
Spell.ForceAnim = { ACT_VM_PRIMARYATTACK_5 }

Spell.NodeOffset = Vector(972, -385, 0)

function Spell:OnSpellSpawned(wand, spell)
	wand:PlayCastSound()
end

function Spell:OnFire(wand)
	return true
end

function Spell:AfterCollide(spell, data)
	local ent = data.HitEntity

	local d = DamageInfo()
	d:SetDamage(ent:Health())
	d:SetAttacker(self.Owner)

	local wand = HpwRewrite:GetWand(self.Owner)
	if not wand:IsValid() then wand = self.Owner end
	
	d:SetInflictor(wand)
	//d:SetDamage(ent:Health())
	d:SetDamageType(DMG_DISSOLVE)
	d:SetDamageForce(Vector(1, 1, 1))
	ent:TakeDamageInfo(d)
end

HpwRewrite:AddSpell("Deletrius", Spell)