local Spell = { }
Spell.LearnTime = 900
Spell.ApplyFireDelay = 0.45
Spell.Category = HpwRewrite.CategoryNames.Special
Spell.Description = [[
	Puts a magic effect on your
	eyes so you can see everyone
	who is behind walls. Magic
	effect ends in 4 seconds
]]

Spell.OnlyIfLearned = { "Conjunctivitis Curse" }
Spell.AccuracyDecreaseVal = 0.3
Spell.CanSelfCast = false
Spell.ForceAnim = { ACT_VM_HITCENTER }
Spell.NodeOffset = Vector(-489, -1148, 0)

if SERVER then
	util.AddNetworkString("hpwrewrite_acriea_handler")
else
	local mat = Material("effects/combineshield/comshieldwall2faded")
	local mat2 = Material("effects/combine_binocoverlay")
	local mat3 = Material("effects/flashlight/caustics")

	local val = 4

	net.Receive("hpwrewrite_acriea_handler", function()
		local endtime = CurTime() + val

		surface.PlaySound("hpwrewrite/spells/spellimpact.wav")
		surface.PlaySound("hpwrewrite/magicchimes01.wav")

		local coef = 0
		local reverse = false

		hook.Add("RenderScreenspaceEffects", "hpwrewrite_acriea_handler", function()
			local eff_tab = {
				["$pp_colour_addr"] = 0.1 * coef,
				["$pp_colour_addg"] = -0.5 * coef,
				["$pp_colour_addb"] = 0.25 * coef,
				["$pp_colour_brightness"] = -0.01 * coef,
				["$pp_colour_contrast"] = 2 * coef,
				["$pp_colour_colour"] = 1 - 0.9 * coef,
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

			if CurTime() > endtime - val * 0.15 and not reverse then 
				surface.PlaySound("hpwrewrite/magicchimes01.wav")
				reverse = true 
			end
			
			DrawColorModify(eff_tab)
		end)

		hook.Add("PostDrawOpaqueRenderables", "hpwrewrite_acriea_handler", function()
			if CurTime() > endtime then 
				hook.Remove("PostDrawOpaqueRenderables", "hpwrewrite_acriea_handler") 
				hook.Remove("RenderScreenspaceEffects", "hpwrewrite_acriea_handler")
				surface.PlaySound("hpwrewrite/spells/spellimpact.wav")
				return 
			end

			local tab = { }
			table.Add(tab, ents.FindByClass("drone_*"))
			table.Add(tab, ents.FindByClass("dronesrewrite_*"))
			table.Add(tab, ents.FindByClass("prop_physics"))
			table.Add(tab, ents.FindByClass("npc_*"))
			table.Add(tab, player.GetAll())
			
			for k, v in pairs(tab) do
				render.ClearStencil()
				render.SetStencilEnable(true)
				
				render.SetStencilWriteMask(255)
				render.SetStencilTestMask(255)
				render.SetStencilReferenceValue(15)
					
				render.SetStencilFailOperation(STENCILOPERATION_KEEP)
				render.SetStencilZFailOperation(STENCILOPERATION_REPLACE)
				render.SetStencilPassOperation(STENCILOPERATION_KEEP)
				render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_ALWAYS)
					
				render.SetBlend(0)
				v:SetModelScale(1 + math.abs(math.sin(CurTime())) * 0.01, 0)
				v:DrawModel()
				v:SetModelScale(1, 0)
				render.SetBlend(1)
					
				render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_EQUAL)

				render.SetMaterial(mat)
				render.DrawScreenQuad()

				render.SetMaterial(mat2)
				render.DrawScreenQuad()

				render.SetMaterial(mat3)
				render.DrawScreenQuad()
					
				v:DrawModel()
				
				render.SetStencilEnable(false)
			end
		end)
	end)
end

function Spell:OnFire(wand)
	net.Start("hpwrewrite_acriea_handler")
	net.Send(self.Owner)

	sound.Play("hpwrewrite/spells/hillium.wav", wand:GetPos(), 70)
end

HpwRewrite:AddSpell("Acriea", Spell)