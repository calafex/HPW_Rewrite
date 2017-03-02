local Spell = { }
Spell.LearnTime = 90
Spell.ApplyFireDelay = 0.3
Spell.Description = [[
	Makes an object that you're
	looking on unbreakable
	(Explosives not explodeable,
	glass not breakable and etc).

	Note that it won't work with
	NPCs and players.
]]

Spell.CanSelfCast = false
Spell.ForceAnim = { ACT_VM_PRIMARYATTACK_3 }
Spell.NodeOffset = Vector(775, 334, 0)
Spell.ShouldSay = false
Spell.AccuracyDecreaseVal = 0.2

local undereff = { }

if SERVER then
	hook.Add("EntityTakeDamage", "hpwrewrite_unbreakablecharm_handler", function(ent, dmg)
		if undereff[ent] then 
			dmg:SetDamage(0)
		end
	end)
end

function Spell:OnFire(wand)
	local ent, tr = wand:HPWGetAimEntity(600)

	if IsValid(ent) and not ent:IsPlayer() and not ent:IsNPC() then
		if undereff[ent] then 
			undereff[ent] = nil
			sound.Play("hpwrewrite/magicchimes02.wav", ent:GetPos(), 70)
		else
			undereff[ent] = true
			sound.Play("hpwrewrite/magicchimes01.wav", ent:GetPos(), 70)
		end
	end
end

HpwRewrite:AddSpell("Unbreakable Charm", Spell)