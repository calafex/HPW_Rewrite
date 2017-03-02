local Spell = { }

Spell.Base = "Lumos"
Spell.SpriteColor = ColorRand()
Spell.OnlyIfLearned = { "Lumos", "Colovaria" }

Spell.Description = [[
	Random colored lumos.
]]

Spell.NodeOffset = Vector(-101, -20, 0)

function Spell:OnFire(wand)
	local res = self.BaseClass.OnFire(self, wand)
	if not self.Toggled then self.SpriteColor = ColorRand() end
	
	return res
end

HpwRewrite:AddSpell("Color lumos", Spell)