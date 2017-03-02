local Spell = { }
Spell.LearnTime = 390
Spell.Description = [[
	Blasts the target apart with 
	a burst of blue light.
]]
Spell.Category = HpwRewrite.CategoryNames.Fight
Spell.FlyEffect = "hpw_expulso_main"
Spell.ImpactEffect = "hpw_expulso_impact"
Spell.ApplyDelay = 0.35
Spell.AccuracyDecreaseVal = 0.15

Spell.ForceAnim = { ACT_VM_PRIMARYATTACK_1 }
Spell.SpriteColor = Color(115, 170, 196)

Spell.OnlyIfLearned = { "Stupefy" }
Spell.NodeOffset = Vector(-190, 452, 0)

function Spell:OnSpellSpawned(wand, spell)
	sound.Play("ambient/wind/wind_snippet2.wav", spell:GetPos(), 75, 255)
	wand:PlayCastSound()
end

function Spell:OnFire(wand)
	return true
end

function Spell:AfterCollide(spell, data)
	local ent = data.HitEntity
	
	HpwRewrite:ThrowEntity(ent, spell:GetFlyDirection(), 4500, 2, self.Owner)

	sound.Play("ambient/levels/citadel/weapon_disintegrate4.wav", data.HitPos, 70, 110)
	util.BlastDamage(spell, IsValid(self.Owner) and self.Owner or spell, data.HitPos, 80, 15)
	if IsValid(ent) and ent.Extinguish then ent:Extinguish() end
end

HpwRewrite:AddSpell("Expulso", Spell)