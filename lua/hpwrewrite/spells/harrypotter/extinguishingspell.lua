local Spell = { }
Spell.LearnTime = 15
Spell.ApplyFireDelay = 0.4
Spell.Description = [[
	Used to put off fires.
]]

Spell.AccuracyDecreaseVal = 0
Spell.ShouldSay = false
Spell.NodeOffset = Vector(-1270, 60, 0)

function Spell:OnFire(wand)
	local ent = wand:HPWGetAimEntity(300, Vector(-2, -2, -2), Vector(2, 2, 2))
	if IsValid(ent) then 
		ent:Extinguish() 
	end
end

HpwRewrite:AddSpell("Extinguishing Spell", Spell)