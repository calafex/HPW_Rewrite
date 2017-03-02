local Spell = { }
Spell.LearnTime = 720
Spell.ApplyFireDelay = 0.45

Spell.OnlyIfLearned = { "Obscuro" }
Spell.Description = [[
	Completely blinds your
	opponent.

	Works only on players.
]]

Spell.WhatToSay = "Conjunctivitis"
Spell.AccuracyDecreaseVal = 0.45
Spell.NodeOffset = Vector(-534, -1295, 0)

if SERVER then
	util.AddNetworkString("hpwrewrite_conjunctivitis_handler")
else
	local val = 18

	net.Receive("hpwrewrite_conjunctivitis_handler", function()
		local endtime = CurTime() + val

		surface.PlaySound("hpwrewrite/spells/spellimpact.wav")

		hook.Add("HUDPaint", "hpwrewrite_conjunctivitis_handler", function()
			if CurTime() > endtime then hook.Remove("HUDPaint", "hpwrewrite_conjunctivitis_handler") return end
			draw.RoundedBox(0, 0, 0, ScrW(), ScrH(), color_black)
		end)
	end)
end

function Spell:OnFire(wand)
	local ent = wand:HPWGetAimEntity(500, Vector(-2, -2, -2), Vector(2, 2, 2))
	if not IsValid(ent) or not ent:IsPlayer() then return end

	net.Start("hpwrewrite_conjunctivitis_handler")
	net.Send(ent)
end

HpwRewrite:AddSpell("Conjunctivitis Curse", Spell)