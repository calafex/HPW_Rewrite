AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "entity_hpwand_bookbase"
ENT.PrintName = HpwRewrite.CategoryNames.Unforgivable
ENT.Category = "Harry Potter Spell Packs"
ENT.Author = "Wand"
ENT.AdminOnly = true

ENT.Model = "models/hpwrewrite/books/book2.mdl"

ENT.Spawnable =  true

local cat = HpwRewrite.CategoryNames.Unforgivable

function ENT:GiveSpells(activator, caller)
	for k, v in pairs(HpwRewrite:GetSpells()) do
		if istable(v.Category) then
			if table.HasValue(v.Category, cat) then
				HpwRewrite:PlayerGiveLearnableSpell(activator, k, true)
			end
		elseif v.Category == cat then
			HpwRewrite:PlayerGiveLearnableSpell(activator, k, true)
		end
	end

	return true
end