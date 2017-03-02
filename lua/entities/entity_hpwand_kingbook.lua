AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "entity_hpwand_bookbase"
ENT.PrintName = "Archmage book"
ENT.Category = "Harry Potter Spell Packs"
ENT.Author = "Wand"
ENT.AdminOnly = true

ENT.Model = "models/hpwrewrite/books/book1.mdl"

ENT.Spawnable =  true

function ENT:GiveSpells(activator, caller)
	for k, v in pairs(HpwRewrite:GetSpells()) do
		HpwRewrite:PlayerGiveLearnableSpell(activator, k, true)
	end

	return true
end