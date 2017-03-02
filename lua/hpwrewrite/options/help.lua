if SERVER then 
	util.AddNetworkString("hpwrewrite_achievement1")

	net.Receive("hpwrewrite_achievement1", function(len, ply)
		HpwRewrite:SaveAndGiveSpell(ply, "Cineres Comet")
	end)

	return 
end

local runegg = false

-- Localizing
local cos = math.cos
local sin = math.sin
local drawText = draw.SimpleText
local camStart = cam.Start3D2D
local camEnd = cam.End3D2D
local approach = math.Approach
local random = math.random
local insert = table.insert

local function easterEgg()
	if runegg then return end

	local ent

	local codeLines = { }
	local hex = { }
	local alpha = 255

	local hudalpha = 0
	local reverse = false
	hook.Add("RenderScreenspaceEffects", "hpwrewrite_easteregg1_hud", function()
		if reverse then
			hudalpha = approach(hudalpha, 0, 26 * FrameTime())
		else
			hudalpha = approach(hudalpha, 255, 100 * FrameTime())
			if hudalpha >= 255 then 
				local pos = LocalPlayer():GetPos()

				ent = ClientsideModel("models/dav0r/hoverball.mdl", RENDERGROUP_OPAQUE_BRUSH)
				ent:SetPos(pos)
				ent:Spawn()

				ParticleEffectAttach("hpw_easteregg", PATTACH_POINT_FOLLOW, ent, 0)

				local file = string.Explode("\n", file.Read("hpwrewrite/spellmanager.lua", "LUA"))

				hook.Add("PostDrawOpaqueRenderables", "hpwrewrite_easteregg1", function()
					-- Codelines
					if random(1, 6) == 1 then
						local vec = VectorRand()
						vec.z = vec.z * 0.1
						insert(codeLines, { 
							pos = pos + Vector(cos(random(0, 360)) * 220, sin(random(0, 360)) * 220, 70) + vec * 120 + Vector(0, 0, -10), 
							force = vec * 0.2 + Vector(0, 0, math.Rand(-0.1, 0.7)), 
							num = table.Random(file), 
							alpha = 255 
						})
					end

					for k, v in pairs(codeLines) do
						if v.alpha <= 0 then codeLines[k] = nil continue end
						v.alpha = approach(v.alpha, 0, 0.7)

						local ang = (v.pos - EyePos()):Angle()
						camStart(v.pos, Angle(0, ang.y - 90, -ang.p + 90), 0.04)
							drawText(v.num, "HPW_GnuolaneDefault", 0, 0, Color(255, 255, 255, v.alpha), TEXT_ALIGN_CENTER)
						camEnd()

						v.pos = v.pos + v.force
					end

					-- Hex, credits
					if random(1, 12) == 1 then 
						insert(hex, { 
							pos = pos + Vector(cos(random(0, 360)) * 180, sin(random(0, 360)) * 180, 70) + VectorRand() * 110, 
							force = VectorRand() * 0.3 + Vector(0, 0, 0.16),
							num = "0x" .. Format("%x", random(10000, 100000)):upper(),
							alpha = 255
						}) 
					end

					for k, v in pairs(hex) do
						if v.alpha <= 0 then hex[k] = nil continue end
						v.alpha = approach(v.alpha, 0, 0.5)

						if random(1, 8) == 1 then v.num = "0x" .. Format("%x", random(40000, 60000)):upper() end

						local ang = (v.pos - EyePos()):Angle()
						camStart(v.pos, Angle(0, ang.y - 90, -ang.p + 90), 0.1)
							drawText(v.num, "HPW_GnuolaneDefault", 0, 0, Color(255, 255, 255, v.alpha), TEXT_ALIGN_CENTER)
						camEnd()

						v.pos = v.pos + v.force
					end

					-- Credits
					local ct = CurTime() * 0.08
					local pos = pos + Vector(cos(ct) * 200, sin(ct) * 200, 180 + sin(ct * 3.5) * 8)
					local ang = (pos - EyePos()):Angle()

					alpha = approach(alpha, 0, FrameTime() * 3) -- uhm uhm uhm
					local color = Color(255, 255, 255, alpha)

					camStart(pos, Angle(0, ang.y - 90, 90), 0.25)
						drawText("Harry Potter Magic Wand Rewrite", "HPW_GnuolaneDefault", 0, 0, color, TEXT_ALIGN_CENTER)
						drawText("Made by G-P.R.O Team", "HPW_GnuolaneDefault", 0, 90, color, TEXT_ALIGN_CENTER)
						drawText("Mr. Mind", "HPW_GnuolaneDefault", 0, 180, color, TEXT_ALIGN_CENTER)
						drawText("EgrOnWire", "HPW_GnuolaneDefault", 0, 270, color, TEXT_ALIGN_CENTER)
						drawText("ProfessorBear", "HPW_GnuolaneDefault", 0, 360, color, TEXT_ALIGN_CENTER)
					camEnd()
				end)

				surface.PlaySound("music/hl2_song10.mp3")

				reverse = true 
			end
		end

		local a = hudalpha / 255
		local eff_tab = {
			["$pp_colour_addr"] = a * 0.3,
			["$pp_colour_addg"] = 0,
			["$pp_colour_addb"] = a * 0.4,
			["$pp_colour_brightness"] = a,
			["$pp_colour_contrast"] = 1 - a * -0.4,
			["$pp_colour_colour"] = 1.3 - a * 0.3,
			["$pp_colour_mulr"] = a * -0.4,
			["$pp_colour_mulg"] = 0,
			["$pp_colour_mulb"] = a
		}
				
		DrawToyTown(a * 8, ScrH())
		DrawColorModify(eff_tab)
	end)

	surface.PlaySound("ambient/wind/wind_snippet3.wav")
	for i = 1, random(2, 3) do
		timer.Simple(i + math.Rand(-0.5, 1), function()
			util.ScreenShake(LocalPlayer():GetPos(), 30, 7, 4, 1000)
			surface.PlaySound("physics/concrete/boulder_impact_hard" .. math.random(1, 4) .. ".wav")
		end)
	end

	-- Ending

	timer.Simple(36, function() 
		SafeRemoveEntity(ent) 
		hook.Remove("PostDrawOpaqueRenderables", "hpwrewrite_easteregg1")
		hook.Remove("RenderScreenspaceEffects", "hpwrewrite_easteregg1_hud")

		-- Giving spell for finding this easter egg
		net.Start("hpwrewrite_achievement1")
		net.SendToServer()

		runegg = false
	end)

	runegg = true
end

local function setup(p)
	-- TODO: add thread links

	local icon = vgui.Create("DImageButton")
	icon:SetImage("vgui/hpwrewrite/misc/art1")
	icon.DoClick = function()
		easterEgg()
	end
	p:AddItem(icon)

	local old = icon.PerformLayout
	icon.PerformLayout = function(self, w, h)
		old(self, w, h)
		self:SetSize(w, w * 0.8)
	end

	local btn = HpwRewrite.VGUI:CreateButton("Online help", 0, 0, 150, 30, p, function() 
		--gui.OpenURL("") 
	end)
	p:AddItem(btn)

	local btn = HpwRewrite.VGUI:CreateButton("Having issue? Let us know", 0, 0, 150, 30, p, function() 
		--gui.OpenURL("") 
	end)
	p:AddItem(btn)

	local btn = HpwRewrite.VGUI:CreateButton("F.A.Q and other offline help", 0, 0, 150, 30, p, function() 
		local win = HpwRewrite.VGUI:OpenNewSpellManager()
		if IsValid(win) and IsValid(win.Sheet) then
			win.Sheet:SwitchToName("Settings / Help")
		end
	end)
	p:AddItem(btn)

	local btn = HpwRewrite.VGUI:CreateButton("Print F.A.Q into console", 0, 0, 150, 30, p, function() 
		HpwRewrite.Manuals.PrintFAQ()
	end)
	p:AddItem(btn)

	local btn = HpwRewrite.VGUI:CreateButton("Get Debug info", 0, 0, 150, 30, p, function() 
		HpwRewrite.VGUI:OpenDebugInfoWindow()
	end)
	p:AddItem(btn)
end

hook.Add("PopulateToolMenu", "hpwrewrite_options_help", function() 
	spawnmenu.AddToolMenuOption("Options", "Wand Settings", "hpwrewrite_options_help", "Online help", "", "", setup) 
end)