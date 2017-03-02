local Spell = { }
Spell.LearnTime = 150
Spell.ApplyFireDelay = 0.5
Spell.Category = HpwRewrite.CategoryNames.Physics
Spell.Description = [[
	Used to make heavy objects 
	lighter in terms of weight.
]]

Spell.ForceAnim = { ACT_VM_PRIMARYATTACK_3 }
Spell.ShouldSay = false
Spell.NodeOffset = Vector(438, 768, 0)
Spell.CanSelfCast = false
Spell.AccuracyDecreaseVal = 0.25

function Spell:OnFire(wand)
	local ent = wand:HPWGetAimEntity(1000, Vector(-10, -10, -4), Vector(10, 10, 4))

	if IsValid(ent) then
		if not ent:IsPlayer() and not ent:IsNPC() then
			local phys = ent:GetPhysicsObject()
			if phys:IsValid() then
				local mass = phys:GetMass()
				local newMass = math.max(10, math.floor(mass * 0.7))

				phys:SetMass(newMass)
				sound.Play("", wand:GetPos(), 55)
			end
		end
	end
end

HpwRewrite:AddSpell("Feather-light Charm", Spell)