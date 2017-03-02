local Spell = { }
Spell.LearnTime = 240
Spell.ApplyFireDelay = 0.45

Spell.Description = [[
	Used to conjure a blindfold 
	over the eyes of the victim, 
	therefore obstructing their 
	view of their surroundings.

	Works only on players.
]]

Spell.AccuracyDecreaseVal = 0.3
Spell.NodeOffset = Vector(-622, -1160, 0)

if SERVER then
	util.AddNetworkString("hpwrewrite_obscuro_handler")
else
	local val = 15

	net.Receive("hpwrewrite_obscuro_handler", function()
		local endtime = CurTime() + val

		surface.PlaySound("hpwrewrite/spells/spellimpact.wav")
		surface.PlaySound("hpwrewrite/magicchimes01.wav")

		local coef = 0
		local reverse = false

		hook.Add("RenderScreenspaceEffects", "hpwrewrite_obscuro_handler", function()
			if CurTime() > endtime then 
				hook.Remove("RenderScreenspaceEffects", "hpwrewrite_obscuro_handler")
				surface.PlaySound("hpwrewrite/spells/spellimpact.wav")
				return 
			end

			local eff_tab = {
				["$pp_colour_addr"] = 0,
				["$pp_colour_addg"] = 0,
				["$pp_colour_addb"] = 0,
				["$pp_colour_brightness"] = -0.6 * coef,
				["$pp_colour_contrast"] = 0.2 * coef,
				["$pp_colour_colour"] =1 -1 * coef,
				["$pp_colour_mulr"] = 0,
				["$pp_colour_mulg"] = 0,
				["$pp_colour_mulb"] = 0
			}

			local dt = FrameTime() * 3

			if reverse then
				coef = math.Approach(coef, 0, dt)
			else
				coef = math.Approach(coef, 1, dt)
			end

			if CurTime() > endtime - val * 0.1 and not reverse then 
				surface.PlaySound("hpwrewrite/magicchimes01.wav")
				reverse = true 
			end
			
			DrawColorModify(eff_tab)
			DrawToyTown(5, ScrH())
		end)
	end)
end

function Spell:OnFire(wand)
	local ent = wand:HPWGetAimEntity(800, Vector(-2, -2, -2), Vector(2, 2, 2))
	if not IsValid(ent) or not ent:IsPlayer() then return end

	net.Start("hpwrewrite_obscuro_handler")
	net.Send(ent)
end

HpwRewrite:AddSpell("Obscuro", Spell)