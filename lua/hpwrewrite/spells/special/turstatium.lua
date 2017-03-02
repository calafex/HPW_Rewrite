local Spell = { }
Spell.LearnTime = 120
Spell.Description = [[
	Transforms combine turret
	prop into a NPC that fights
	on your side against players
	and bad NPCs.

	Also can make combine turret
	NPC fight on your side.
]]
Spell.FlyEffect = "hpw_blue_main"
Spell.ImpactEffect = "hpw_blue_impact"
Spell.ApplyDelay = 0.5
Spell.AccuracyDecreaseVal = 0.1
Spell.Category = HpwRewrite.CategoryNames.Special

Spell.ForceAnim = { ACT_VM_PRIMARYATTACK_5 }
Spell.SpriteColor = Color(0, 0, 255)

Spell.NodeOffset = Vector(-216, -551, 0)

function Spell:Draw(spell)
	self:DrawGlow(spell, nil, 32)
end

function Spell:OnSpellSpawned(wand, spell)
	wand:PlayCastSound()
end

function Spell:OnFire(wand)
	return true
end

local EnemyNames = {
	npc_antlion = true, npc_antlionguard = true, npc_antlionguardian = true, npc_barnacle = true, 
	npc_breen = true, npc_clawscanner = true, npc_combine_s = true, npc_cscanner = true, npc_fastzombie = true, 
	npc_fastzombie_torso = true, npc_headcrab = true, npc_headcrab_fast = true, npc_headcrab_poison = true, 
	npc_hunter = true, npc_metropolice = true, npc_manhack = true, npc_poisonzombie = true, 
	npc_strider = true, npc_stalker = true, npc_zombie = true, npc_zombie_torso = true, npc_zombine = true
}

local FriendlyNames = {
	npc_alyx = true, npc_barney = true, npc_citizen = true, npc_dog = true, npc_eli = true, 
	npc_fisherman = true, npc_gman = true, npc_kleiner = true, npc_magnusson = true, 
	npc_monk = true, npc_mossman = true, npc_odessa = true, npc_vortigaunt = true
}

local mdl = "models/combine_turrets/floor_turret.mdl"
function Spell:AfterCollide(spell, data)
	local ent = data.HitEntity
	
	if IsValid(ent) then
		if ent:GetClass() == "prop_physics" and ent:GetModel() == mdl then
			local pos = ent:GetPos()
			local ang = ent:GetAngles()
			local color = ent:GetColor()
			local skin = ent:GetSkin()

			local npc = ents.Create("npc_turret_floor")
			undo.ReplaceEntity(ent, npc)
			cleanup.ReplaceEntity(ent, npc)

			ent:Remove()

			npc:SetPos(pos)
			npc:SetAngles(ang)
			npc:SetColor(color)
			npc:SetSkin(skin)
			npc:Spawn()

			for k, v in pairs(EnemyNames) do npc:AddRelationship(k .. " D_HT 99") end
			for k, v in pairs(FriendlyNames) do npc:AddRelationship(k .. " D_LI 99") end
			npc:AddEntityRelationship(self.Owner, D_LI, 9999)

			npc:EmitSound("npc/turret_floor/active.wav", 70)
		elseif ent:GetClass() == "npc_turret_floor" then
			for k, v in pairs(EnemyNames) do ent:AddRelationship(k .. " D_HT 99") end
			for k, v in pairs(FriendlyNames) do ent:AddRelationship(k .. " D_LI 99") end
			ent:AddEntityRelationship(self.Owner, D_LI, 9999)

			ent:EmitSound("npc/turret_floor/active.wav", 70)
		end
	end
end

HpwRewrite:AddSpell("Locomotor Turret", Spell)