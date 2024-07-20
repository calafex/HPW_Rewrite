if SERVER then return end

local fonts = {
	"Harry P",
	"Cloister Black",
	"GregorianFLF",
	"Gnuolane Rg",
	"Tahoma"
}

local languages = {
	["English"] = "en",
	["Russian"] = "ru",
	["Chinese"] = "cn"
}

local function ChangeKey(btn, name, cvar)
	timer.Simple(RealFrameTime(), function()
		if not IsValid(btn) then return end

		btn:SetText("PRESS ANY KEY")

		hook.Add("Think", "hpwrewrite_keywait", function()
			for k, v in pairs(HpwRewrite.BM.Keys) do
				if k >= 107 and input.IsMouseDown(k) or input.IsKeyDown(k) then
					hook.Remove("Think", "hpwrewrite_keywait")
					RunConsoleCommand(cvar, tostring(k))

					btn:SetText(name .. v)
				end
			end
		end)
	end)
end

local function setup(p)
	-- HUD
	p:AddControl("Label", { Text = "HUD Settings" })
	p:AddControl("CheckBox", { Label = "Disable HUD drawing", Command = "hpwrewrite_cl_nohud"})
	p:AddControl("CheckBox", { Label = "Don't draw spell name if there is icon", Command = "hpwrewrite_cl_notexticon"})
	p:AddControl("CheckBox", { Label = "Draw spell bar", Command = "hpwrewrite_cl_drawspellbar"})
	p:AddControl("CheckBox", { Label = "Draw icons", Command = "hpwrewrite_cl_drawicons"})
	p:AddControl("CheckBox", { Label = "Draw spell name", Command = "hpwrewrite_cl_drawspname"})
	p:AddControl("CheckBox", { Label = "Draw Current spell", Command = "hpwrewrite_cl_drawcurspell"})
	p:AddControl("CheckBox", { Label = "Fantasy RPG HUD design", Command = "hpwrewrite_cl_mmorpgstyle"})

	local font = vgui.Create("DComboBox", p)
	font:SetText("Main font: " .. HpwRewrite.CVars.FontName:GetString())
	for k, v in SortedPairsByValue(fonts) do font:AddChoice(v) end
	
	font.OnSelect = function(p, index, val)
		val = tostring(val)
		font:SetText("Main font: " .. val)
		RunConsoleCommand("hpwrewrite_cl_fontname", val)
	end

	p:AddItem(font)

	-- Hints, stuff
	p:AddControl("Label", { Text = "" })
	p:AddControl("Label", { Text = "Hints, stuff" })
	p:AddControl("CheckBox", { Label = "Draw 'To feel...' hint", Command = "hpwrewrite_cl_drawhint"})
	p:AddControl("CheckBox", { Label = "Draw 'Choose spell...' hint", Command = "hpwrewrite_cl_drawhint2"})
	p:AddControl("CheckBox", { Label = "Disable popup hints", Command = "hpwrewrite_cl_disablemsg"})

	-- Other
	p:AddControl("Label", { Text = "" })
	p:AddControl("Label", { Text = "Other client settings" })
	p:AddControl("CheckBox", { Label = "Disable spell choosing by context menu", Command = "hpwrewrite_cl_nochoosing"})
	p:AddControl("CheckBox", { Label = "Use white smoke in Apparition", Command = "hpwrewrite_cl_appwhitesmoke"})
	p:AddControl("CheckBox", { Label = "Draw name and icon over books", Command = "hpwrewrite_cl_drawbooktext"})
	p:AddControl("CheckBox", { Label = "Disable binds", Command = "hpwrewrite_cl_disablebinds"})
	p:AddControl("CheckBox", { Label = "Use binds to instant attack", Command = "hpwrewrite_cl_instantattack"})
	p:AddControl("CheckBox", { Label = "Leave left mouse button for a bind\n(It's useful only with 'Use binds to instant attack')", Command = "hpwrewrite_cl_blockleftmouse"})
	p:AddControl("CheckBox", { Label = "Hide spell tree", Command = "hpwrewrite_cl_hidetree"})
	p:AddControl("CheckBox", { Label = "Hide magic sparks", Command = "hpwrewrite_cl_hidesparks"})
	p:AddControl("CheckBox", { Label = "Close menu after selecting spell", Command = "hpwrewrite_cl_closeonselect"})


	p:AddControl("Label", { Text = "" })
	p:AddControl("Label", { Text = "Restart your game to apply language changes" })
	local lang = vgui.Create("DComboBox", p)
	lang:SetText("Language: " .. (table.KeyFromValue(languages, HpwRewrite.CVars.Language:GetString()) or "invalid"))
	for k, v in SortedPairsByValue(languages) do lang:AddChoice(k) end
	
	lang.OnSelect = function(p, index, val)
		val = tostring(val)
		lang:SetText("Language: " .. val)
		RunConsoleCommand("hpwrewrite_cl_language", languages[val])
	end

	p:AddItem(lang)

	-- Dangerous zone
	p:AddControl("Label", { Text = "" })
	local lab = vgui.Create("DLabel", p)
	lab:SetText("Dangerous zone !!! We do not recommend to\nchange something below")
	lab:SetColor(HpwRewrite.Colors.Red)
	lab:SizeToContents()
	p:AddItem(lab)

	p:AddControl("CheckBox", { Label = "Disable all popup messages", Command = "hpwrewrite_cl_disableallmsgs"})

	p:AddControl("Label", { Text = "X and Y are zeroes by default" })

	local slider = vgui.Create("DNumSlider", p)
	slider:SetSize(150, 32)
	slider:SetText("HUD X offset")
	slider:SetMin(-ScrW())
	slider:SetMax(ScrW())
	slider:SetDecimals(1)
	slider:SetConVar("hpwrewrite_cl_xoffset")
	p:AddItem(slider)

	local slider = vgui.Create("DNumSlider", p)
	slider:SetSize(150, 32)
	slider:SetText("HUD Y offset")
	slider:SetMin(-ScrH()-20)
	slider:SetMax(135)
	slider:SetDecimals(1)
	slider:SetConVar("hpwrewrite_cl_yoffset")
	p:AddItem(slider)

	p:AddControl("Label", { Text = "Defaults: Main menu - Mouse Right; Self-cast - Backspace" })

	local name = "Change Main menu key: "
	local btn = HpwRewrite.VGUI:CreateButton(name .. (HpwRewrite.BM.Keys[HpwRewrite.CVars.MenuKey:GetInt()] or "NONE"), 0, 0, 150, 30, p, function(btn)
		ChangeKey(btn, name, "hpwrewrite_cl_mmenukey")
	end)
	p:AddItem(btn)

	local name = "Change Self-cast key: "
	local btn = HpwRewrite.VGUI:CreateButton(name .. (HpwRewrite.BM.Keys[HpwRewrite.CVars.SelfCastKey:GetInt()] or "NONE"), 0, 0, 150, 30, p, function(btn)
		ChangeKey(btn, name, "hpwrewrite_cl_selfcastkey")
	end)
	p:AddItem(btn)
end

hook.Add("PopulateToolMenu", "hpwrewrite_options_client", function() 
	spawnmenu.AddToolMenuOption("Options", "Wand Settings", "hpwrewrite_options_client", "Client", "", "", setup) 
end)

HpwRewrite.VGUI.CreateClientOptions = setup