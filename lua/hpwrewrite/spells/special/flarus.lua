local Spell = { }
Spell.LearnTime = 30
Spell.ApplyFireDelay = 0.4
Spell.Category = { HpwRewrite.CategoryNames.Physics, HpwRewrite.CategoryNames.Special }
Spell.Description = [[
	Pushes closest things away
	from you.
]]

Spell.OnlyIfLearned = { "Speedavec" }
Spell.ForceAnim = { ACT_VM_PRIMARYATTACK_4 }
Spell.NodeOffset = Vector(474, 184, 0)

function Spell:OnFire(wand)
	sound.Play("hpwrewrite/wand/spellcast02.wav", wand:GetPos(), 65)

	local count = 0

	--for i = 1, 4 do
		local ef = EffectData()
		ef:SetNormal(vector_up)
		ef:SetScale(120)
		ef:SetOrigin(self.Owner:GetPos() + vector_up * 30)
		util.Effect("ThumperDust", ef, true, true)
	--end

	for k, v in pairs(ents.FindInSphere(self.Owner:GetPos(), 180)) do
		local valid = false

		if v:IsPlayer() or v:IsNPC() then
			if v != self.Owner then 
				v:SetVelocity(((v:GetPos() - self.Owner:GetPos()):GetNormal() * 500) + vector_up * 300) 
				valid = true
			end
		else
			if IsValid(v:GetPhysicsObject()) then 
				v:GetPhysicsObject():SetVelocity(((v:GetPos() - self.Owner:GetPos()):GetNormal() * 800) + vector_up * 300) 
				valid = true
			end
		end

		if valid then
			if count > 6 then continue end

			sound.Play("hpwrewrite/spells/lumos.wav", v:GetPos(), 65, math.random(90, 110))

			local dir = (v:GetPos() - self.Owner:EyePos())
			local pos = self.Owner:EyePos() + dir:GetNormal() * 50

			HpwRewrite.MakeEffect("hpw_dragoner_ring", pos, dir:Angle())

			count = count + 1
		end
	end	
end

HpwRewrite:AddSpell("Flarus", Spell)
