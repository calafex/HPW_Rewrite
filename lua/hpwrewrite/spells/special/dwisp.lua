local Spell = { }
Spell.LearnTime = 240
Spell.Description = [[
	More dangerous damaging 
	spell.
]]
Spell.FlyEffect = "hpw_tarantal_main"
Spell.ImpactEffect = "hpw_dwisp_impact"
Spell.ApplyDelay = 0.33
Spell.AccuracyDecreaseVal = 0.03
Spell.Category = { HpwRewrite.CategoryNames.Fight, HpwRewrite.CategoryNames.Special }
Spell.AnimSpeedCoef = 1.8
Spell.ForceDelay = 0.2
Spell.AutoFire = true
Spell.ShouldSay = false
Spell.LeaveParticles = true
Spell.OnlyIfLearned = { "Mostro", "Arrow-shooting spell" }

Spell.ForceAnim = { ACT_VM_PRIMARYATTACK_7 }
Spell.SpriteColor = Color(55, 255, 55)
Spell.NodeOffset = Vector(799, -930, 0)

function Spell:OnSpellSpawned(wand, spell)
	wand:PlayCastSound()
end

function Spell:Draw(spell)
	self:DrawGlow(spell)
end

function Spell:OnFire(wand)
	return true
end

function Spell:OnCollide(spell, data)
	local ent = data.HitEntity
	
	if IsValid(ent) then
		ent:TakeDamage(14, self.Owner, HpwRewrite:GetWand(self.Owner))
	end
end

HpwRewrite:AddSpell("Dwisp", Spell)