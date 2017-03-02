local Spell = { }
Spell.LearnTime = 30
Spell.ApplyFireDelay = 0.4
Spell.Category = HpwRewrite.CategoryNames.Healing
Spell.Description = [[
	This spell can heal someone
	you're looking at that is
	not farther than 400 units.

	Hold self-cast key to heal
	yourself.
]]

Spell.NodeOffset = Vector(-695, 628, 0)
Spell.AccuracyDecreaseVal = 0.05

function Spell:OnFire(wand)
	local ent = wand:HPWGetAimEntity(400)

	if IsValid(ent) and (ent:IsPlayer() or ent:IsNPC()) then
		ent:SetHealth(math.min(ent:GetMaxHealth(), ent:Health() + 4))
	end

	sound.Play("npc/antlion/idle3.wav", wand:GetPos(), 55, math.random(240, 255))
end

HpwRewrite:AddSpell("Episkey", Spell)