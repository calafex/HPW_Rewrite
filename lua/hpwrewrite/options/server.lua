if SERVER then
	net.Receive("hpwrewrite_UpdSpells", function(len, ply)
		ply:ConCommand("hpwrewrite_admin_updatespells")
	end)

	return
end

local function setup(p)
	p:AddControl("Label", { Text = "If these options won't work, try using console (~) or admin mod\nList of CVars can be found in the wand's main menu" })
	p:AddControl("Label", { Text = "" })
	p:AddControl("Label", { Text = "Global settings" })
	p:AddControl("CheckBox", { Label = "Disable accuracy decreasing", Command = "hpwrewrite_sv_noaccuracy"})
	p:AddControl("CheckBox", { Label = "Disable learning (Makes books useless and gives all spells to everyone)", Command = "hpwrewrite_sv_nolearning"})
	p:AddControl("CheckBox", { Label = "Disable spell learning time", Command = "hpwrewrite_sv_notimer"})
	p:AddControl("CheckBox", { Label = "Disable throwing NPCs/Players\n(Warning: it will also make spells such as Crucio and Stupefy useless)", Command = "hpwrewrite_sv_nothrowing"})
	p:AddControl("CheckBox", { Label = "Disable chat spell name saying", Command = "hpwrewrite_sv_nosay"})
	p:AddControl("CheckBox", { Label = "Spawn casted spells always in the center\nof caster's view", Command = "hpwrewrite_sv_spawncenter"})
	p:AddControl("CheckBox", { Label = "Give a wand to the player on spawn", Command = "hpwrewrite_sv_givewand"})

	p:AddControl("Label", { Text = "" })
	p:AddControl("Label", { Text = "Other server settings" })

	p:AddControl("Label", { Text = "Notify: Default animation speed value is 1.0" })
	local slider = vgui.Create("DNumSlider", p)
	slider:SetSize(150, 32)
	slider:SetText("Animation speed")
	slider:SetMin(0.1)
	slider:SetMax(10)
	slider:SetDecimals(1)
	slider:SetConVar("hpwrewrite_sv_animspeed")

	p:AddItem(slider)

	p:AddControl("Label", { Text = "In debug mode it will print stuff into your console about addon's working and help finding bugs, also it will enable Admin panel in singleplayer" })
	p:AddControl("CheckBox", { Label = "Debug mode", Command = "hpwrewrite_sv_debugmode"})

	p:AddControl("Label", { Text = "Use it if players don't receive spells when they join your server. It also might help you if it says that Wand might not working correctly when you spawn" })
	p:AddControl("CheckBox", { Label = "Use spell loading protection", Command = "hpwrewrite_sv_usesaver"})

	local btn = HpwRewrite.VGUI:CreateButton("Update spells for everyone", 0, 0, 150, 30, p, function() 
		net.Start("hpwrewrite_UpdSpells")
		net.SendToServer()
	end)
	p:AddItem(btn)
end

hook.Add("PopulateToolMenu", "hpwrewrite_options_server", function() 
	spawnmenu.AddToolMenuOption("Options", "Wand Settings", "hpwrewrite_options_server", "Server", "", "", setup) 
end)

HpwRewrite.VGUI.CreateServerOptions = setup