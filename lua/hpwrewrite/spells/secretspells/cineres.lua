local Spell = { }
Spell.Description = [[
	Dark space energy collapsed 
	into a ball form to serve your 
	wish. Can dissolve things.
]]
Spell.FlyEffect = "hpw_cineres_main"
Spell.ImpactEffect = "hpw_cineres_impact"
Spell.ApplyDelay = 0.4
Spell.SpriteColor = Color(255, 0, 255)

Spell.CreateEntity = false
Spell.SecretSpell = true
Spell.AbsoluteSecret = true
Spell.Category = HpwRewrite.CategoryNames.Special
Spell.WhatToSay = "Cineres"
Spell.AccuracyDecreaseVal = 0.4

Spell.ForceAnim = { ACT_VM_PRIMARYATTACK_5 }

Spell.NodeOffset = Vector(-916, -1176, 0)

function Spell:OnFire(wand)
	return true
end

function Spell:OnSpellSpawned(wand)
	wand:PlayCastSound()
end

function Spell:OnCollide(spell, data)
	for k, v in pairs(ents.FindInSphere(data.HitPos, 200)) do
		local d = DamageInfo()
		d:SetDamage((200 - data.HitPos:Distance(v:GetPos())) / 2)
		d:SetAttacker(self.Owner)

		local wand = HpwRewrite:GetWand(self.Owner)
		if not wand:IsValid() then wand = self.Owner end
		
		d:SetInflictor(wand)
		d:SetDamageType(DMG_DISSOLVE)
		v:TakeDamageInfo(d)
	end

	sound.Play("ambient/energy/weld" .. math.random(1, 2) .. ".wav", data.HitPos, 80, 120)
end

HpwRewrite:AddSpell("Cineres Comet", Spell)