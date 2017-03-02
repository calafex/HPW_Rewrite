local Spell = { }
Spell.LearnTime = 120
Spell.ApplyFireDelay = 0.4
Spell.SpriteColor = Color(0, 255, 0)
Spell.ForceAnim = { ACT_VM_PRIMARYATTACK_3 }
Spell.FlyEffect = "hpw_tarantal_main"
Spell.Description = [[
	Used to force another 
	person's legs to begin 
	dancing uncontrollably.
]]

Spell.AccuracyDecreaseVal = 0.2
Spell.LeaveParticles = true
Spell.NodeOffset = Vector(-538, -777, 0)

local commands = {
	"act dance",
	"act muscle"
}

function Spell:OnSpellSpawned(wand, spell)
	wand:PlayCastSound()
end

function Spell:OnFire(wand)
	return true
end

function Spell:OnCollide(spell, data)
	local ent = data.HitEntity

	if IsValid(ent) and ent:IsPlayer() then
		ent:ConCommand(table.Random(commands))
	end

	sound.Play("npc/antlion/idle3.wav", ent:GetPos(), 55, math.random(240, 255))
end

HpwRewrite:AddSpell("Tarantallegra", Spell)