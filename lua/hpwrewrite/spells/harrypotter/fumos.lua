local Spell = { }
Spell.LearnTime = 40
Spell.Description = [[
	Produces black
	smoke effect.
]]

Spell.AccuracyDecreaseVal = 0.0025
Spell.Category = { HpwRewrite.CategoryNames.Fight }
Spell.ForceDelay = 0.015
Spell.AutoFire = true
Spell.ShouldSay = false

Spell.SpriteColor = Color(255, 255, 0)
Spell.NodeOffset = Vector(-622, -510, 0)

function Spell:OnFire(wand)
	if self.Owner:GetActiveWeapon().HpwRewrite.Accuracy < 1 and wand:GetWandCurrentSkin() ~= "Fork" then
		local ef = EffectData()
		ef:SetEntity(self.Owner)
		util.Effect("EffectHpwRewriteFumos", ef, true, true)
	end
end

HpwRewrite:AddSpell("Fumos", Spell)