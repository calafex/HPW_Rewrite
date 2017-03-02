local Spell = { }
Spell.LearnTime = 60
Spell.ApplyFireDelay = 0.4
Spell.Category = HpwRewrite.CategoryNames.Special
Spell.Description = [[
	Recharges combine health
	and armor stations.
]]

Spell.CanSelfCast = false
Spell.AccuracyDecreaseVal = 0
Spell.NodeOffset = Vector(191, -406, 0)

function Spell:OnFire(wand)
	local ent = wand:HPWGetAimEntity(450)

	local ef = EffectData()
	ef:SetEntity(self.Owner)
	local col = Color(255, 255, 255)
	ef:SetStart(Vector(col.r, col.g, col.b))
	ef:SetScale(0.23)
	util.Effect("EffectHpwRewriteSparks", ef, true, true)

	if IsValid(ent) then
		if ent:GetClass() == "item_healthcharger" then
			local new = ents.Create("item_healthcharger")
			new:SetPos(ent:GetPos())
			new:SetAngles(ent:GetAngles())
			new:Spawn()
			new:Activate()
			new:EmitSound("items/suitchargeok1.wav")

			undo.ReplaceEntity(ent, new)
			cleanup.ReplaceEntity(ent, new)

			ent:Remove()
		elseif ent:GetClass() == "item_suitcharger" then
			ent:Fire("Recharge")
		end
	end
end

HpwRewrite:AddSpell("Rechargio", Spell)
