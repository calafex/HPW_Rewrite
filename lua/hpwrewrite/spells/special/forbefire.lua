local Spell = { }
Spell.LearnTime = 1800
Spell.Description = [[
	Explosive spell. Can be
	very dangerous in duels.

	More powerful version of
	Dragoner spell.
]]

Spell.FlyEffect = "hpw_forbefire_main"
Spell.ImpactEffect = "hpw_forbefire_impact"
Spell.ApplyDelay = 0.6
Spell.AccuracyDecreaseVal = 0.8
Spell.Category = { HpwRewrite.CategoryNames.DestrExp, HpwRewrite.CategoryNames.Special }

Spell.ForceAnim = { ACT_VM_PRIMARYATTACK_5 }
Spell.SpriteColor = Color(180, 255, 155)

Spell.NodeOffset = Vector(-448, 76, 0)
Spell.OnlyIfLearned = { "Dragoner" }

Spell.DoSparks = true

function Spell:Draw(spell)
	//self:DrawGlow(spell, nil, 128)
end

function Spell:OnSpellSpawned(wand, spell)
	wand:PlayCastSound()
end

function Spell:OnFire(wand)
	return true
end

function Spell:OnCollide(spell, data)
	HpwRewrite.BlastDamage(self.Owner, data.HitPos, 300, 850)

	sound.Play("ambient/explosions/explode_8.wav", data.HitPos, 100, math.random(90, 110))
	sound.Play("ambient/explosions/explode_9.wav", data.HitPos, 100, math.random(90, 110))

	util.ScreenShake(data.HitPos, 1000, 1000, 1, 1000)
	//util.Decal("HpwForbefire", data.HitPos - data.HitNormal, data.HitPos + data.HitNormal)
end

HpwRewrite:AddSpell("Forbefire", Spell)