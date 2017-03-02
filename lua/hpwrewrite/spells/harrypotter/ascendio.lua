local Spell = { }
Spell.LearnTime = 30
Spell.ApplyFireDelay = 0.5
Spell.ForceAnim = { ACT_VM_PRIMARYATTACK_4 }
Spell.CanSelfCast = false
Spell.Description = [[
	Used to lift the caster high 
	into the air from water.
]]

Spell.NodeOffset = Vector(-1070, -112, 0)
Spell.AccuracyDecreaseVal = 0

function Spell:OnFire(wand)
	self.Toggled = CurTime() + 4
end

function Spell:Think(wand)
	if self.Toggled and CurTime() < self.Toggled and self.Owner:WaterLevel() >= 2 then
		if self.Owner:GetVelocity().z < 300 then
			self.Owner:SetVelocity(Vector(0, 0, 200))
		end
	else
		self.Toggled = nil
	end
end

HpwRewrite:AddSpell("Ascendio", Spell)