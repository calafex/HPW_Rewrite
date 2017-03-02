local Spell = { }
Spell.LearnTime = 720
Spell.ApplyFireDelay = 0.45
Spell.Category = { HpwRewrite.CategoryNames.Healing, HpwRewrite.CategoryNames.Special }
Spell.OnlyIfLearned = { "Vulnera Sanentur" }
Spell.AccuracyDecreaseVal = 0.2
Spell.Description = [[
	Healing spores that will
	completely heal anything
	you're looking at.

	Hold self-cast key to heal
	yourself.
]]

Spell.ForceAnim = { ACT_VM_PRIMARYATTACK_3 }
Spell.NodeOffset = Vector(-487, 314, 0)
Spell.SpriteColor = Color(0, 255, 0)
Spell.DoSparks = true

function Spell:OnFire(wand)
	local ent = wand:HPWGetAimEntity(350)

	if IsValid(ent) then
		ent:SetHealth(ent:GetMaxHealth())
	end

	sound.Play("hpwrewrite/spells/hillium.wav", wand:GetPos(), 70)
end

HpwRewrite:AddSpell("Hillium", Spell)