local Spell = { }
Spell.LearnTime = 270
Spell.ApplyFireDelay = 0.3
Spell.Category = { HpwRewrite.CategoryNames.Special, HpwRewrite.CategoryNames.Physics }
Spell.Description = [[
	Pushes you to your
	eyes direction.

	Hold self-cast key to
	push someone or something.
]]

Spell.OnlyIfLearned = { "Alarte Ascendare" }
Spell.DoSelfCastAnim = false
Spell.ShouldReverseSelfCast = true
Spell.ForceAnim = { ACT_VM_PRIMARYATTACK_4 }
Spell.NodeOffset = Vector(434, 315, 0)

function Spell:OnFire(wand)
	local ent = wand:HPWGetAimEntity(250)

	if IsValid(ent) then
		local vec = self.Owner:GetAimVector() * 600

		if ent:IsPlayer() or ent:IsNPC() then
			ent:SetVelocity(vec)
		else
			local phys = ent:GetPhysicsObject()
			if IsValid(phys) then phys:SetVelocity(vec) end
		end
	end
end

HpwRewrite:AddSpell("Speedavec", Spell)