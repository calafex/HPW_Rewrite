local Spell = { }
Spell.LearnTime = 30
Spell.ApplyFireDelay = 0.45
Spell.Category = HpwRewrite.CategoryNames.Special
Spell.Description = [[
	Increases mouse sensitivity
	of your opponent.

	Works only on players.
]]

Spell.ForceAnim = { ACT_VM_PRIMARYATTACK_3 }
Spell.NodeOffset = Vector(1087, 314, 0)

if SERVER then
	util.AddNetworkString("hpwrewrite_heyedillio_handler")
else
	local switch = false
	net.Receive("hpwrewrite_heyedillio_handler", function()
		switch = not switch

		if switch then
			hook.Add("AdjustMouseSensitivity", "hpwrewrite_heyedillio_handler", function(def)
				return 6
			end)
		else
			hook.Remove("AdjustMouseSensitivity", "hpwrewrite_heyedillio_handler")
		end
	end)
end

function Spell:OnFire(wand)
	local ent = wand:HPWGetAimEntity(650)

	if IsValid(ent) then
		if ent:IsPlayer() then
			local name = "hpwrewrite_heyedillio_handler" .. ent:EntIndex()

			if not timer.Exists(name) then
				net.Start("hpwrewrite_heyedillio_handler")
				net.Send(ent)

				timer.Create(name, 15, 1, function()
					if IsValid(ent) then
						net.Start("hpwrewrite_heyedillio_handler")
						net.Send(ent)
					end
				end)
			end
		end
	end

	sound.Play("hpwrewrite/spells/hillium.wav", wand:GetPos(), 70)
end

HpwRewrite:AddSpell("Heyedillio", Spell)