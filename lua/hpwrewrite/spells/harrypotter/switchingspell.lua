local Spell = { }
Spell.LearnTime = 300
Spell.Base = "Welding Charm"
Spell.Description = [[
	Swaps two objects.

	Usage: cast on some object,
	then cast on another object.

	Also, works on players and 
	NPCs.
]]
Spell.ShouldSay = false
Spell.NodeOffset = Vector(1730, -1051, 0)

Spell.SpriteColor = Color(255, 255, 255)
Spell.FlyEffect = "hpw_sectumsemp_main"
Spell.ImpactEffect = "hpw_white_impact"

Spell.AccuracyDecreaseVal = 0.5

Spell.CheckFunction = function(self, ent)
	-- ent.Base checks for sent
	if ent:GetClass() != "prop_physics" and not ent.Base and not (ent:IsPlayer() or ent:IsNPC()) then return false end
	return true
end

function Spell:ToolCallback()
	local pos1 = self.Entity1:GetPos()
	self.Entity1:SetPos(self.Entity2:GetPos())
	self.Entity2:SetPos(pos1)

	local a = self.Entity1:GetBoneCount()
	if a then
		for i = 1, a - 1 do
			if i % 2 != 0 then continue end
			local pos, ang = self.Entity1:GetBonePosition(i)
			if pos and ang then HpwRewrite.MakeEffect("hpw_white_impact", pos, ang) end
		end
	end

	a = self.Entity2:GetBoneCount()
	if a then
		for i = 1, self.Entity2:GetBoneCount() - 1 do
			if i % 2 != 0 then continue end
			local pos, ang = self.Entity2:GetBonePosition(i)
			if pos and ang then HpwRewrite.MakeEffect("hpw_white_impact", pos, ang) end
		end
	end
end

HpwRewrite:AddSpell("Switching Spell", Spell)