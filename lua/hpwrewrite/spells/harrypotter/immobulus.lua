local Spell = { }
Spell.LearnTime = 390
Spell.Category = HpwRewrite.CategoryNames.Fight
Spell.ApplyFireDelay = 0.6
Spell.Description = [[
	Immobilises living targets.
]]

Spell.AccuracyDecreaseVal = 0.2

Spell.OnlyIfLearned = { "Everte Statum" }
Spell.ForceAnim = { ACT_VM_PRIMARYATTACK_5 }
Spell.NodeOffset = Vector(257, 72, 0)
Spell.SpriteColor = Color(50, 100, 255)

function Spell:OnFire(wand)
	local ent = wand:HPWGetAimEntity(700, Vector(-10, -10, -10), Vector(10, 10, 10))
	
	local rag, func, name = HpwRewrite:ThrowEntity(ent, self.Owner:GetAimVector() + vector_up, 600, 15, self.Owner)

	if IsValid(rag) then
		local count = rag:GetPhysicsObjectCount()
		for i = 1, count - 1 do
			local phys = rag:GetPhysicsObjectNum(i)
			if phys:IsValid() then
				phys:EnableGravity(false)
			end
		end
	end

	sound.Play("hpwrewrite/spells/godivillio.wav", wand:GetPos(), 65, 255)
end

HpwRewrite:AddSpell("Immobulus", Spell)