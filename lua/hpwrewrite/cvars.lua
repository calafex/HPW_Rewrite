if not HpwRewrite then return end

HpwRewrite.CVars = HpwRewrite.CVars or { }

if SERVER then
	function HpwRewrite:UseSaver(bool)
		if bool then
			hook.Add("PlayerSpawn", "hpwrewrite_saverfortables", function(ply)
				if not ply.HpwRewrite then 
					ply.HpwRewrite = { } 
					HpwRewrite:LogDebug(ply:Name() .. " HpwRewrite namespace has been initialized in SAVER - hpwrewrite_saverfortables hook")
				end

				HpwRewrite:UpdatePlayerInfo(ply)
			end)
		else
			hook.Remove("PlayerSpawn", "hpwrewrite_saverfortables")
		end

		HpwRewrite:LogDebug("Loaded saver! Status: " .. tostring(bool))	
	end
end

HpwRewrite.CVars.Installed = CreateConVar("hpwrewrite_installed", 1, {
	FCVAR_ARCHIVE,
	FCVAR_NOTIFY,
	FCVAR_REPLICATED,
	FCVAR_SERVER_CAN_EXECUTE
}, "")

HpwRewrite.CVars.Version = CreateConVar("hpwrewrite_version", HpwRewrite.Version, {
	FCVAR_ARCHIVE,
	FCVAR_NOTIFY,
	FCVAR_REPLICATED,
	FCVAR_SERVER_CAN_EXECUTE
}, "")

-- Serverside cvars
HpwRewrite.CVars.DebugMode = CreateConVar("hpwrewrite_sv_debugmode", "0", { FCVAR_ARCHIVE, FCVAR_REPLICATED, FCVAR_NOTIFY })

local value = "0"
if game.SinglePlayer() then value = "1" end
HpwRewrite.CVars.NoLearning = CreateConVar("hpwrewrite_sv_nolearning", value, { FCVAR_ARCHIVE, FCVAR_REPLICATED, FCVAR_NOTIFY })
HpwRewrite.CVars.GiveWand = CreateConVar("hpwrewrite_sv_givewand", value, { FCVAR_ARCHIVE, FCVAR_NOTIFY })

HpwRewrite.CVars.DisableThrowing = CreateConVar("hpwrewrite_sv_nothrowing", "0", { FCVAR_ARCHIVE })
HpwRewrite.CVars.NoAccuracy = CreateConVar("hpwrewrite_sv_noaccuracy", "0", { FCVAR_ARCHIVE })
HpwRewrite.CVars.NoSay = CreateConVar("hpwrewrite_sv_nosay", "0", { FCVAR_ARCHIVE })
HpwRewrite.CVars.NoTimer = CreateConVar("hpwrewrite_sv_notimer", "0", { FCVAR_ARCHIVE })
HpwRewrite.CVars.AlwaysCenter = CreateConVar("hpwrewrite_sv_spawncenter", "0", { FCVAR_ARCHIVE })
HpwRewrite.CVars.AnimSpeed = CreateConVar("hpwrewrite_sv_animspeed", "1", { FCVAR_ARCHIVE, FCVAR_REPLICATED })

-- Notifying
HpwRewrite.CVars.ErrorNotify = CreateConVar("hpwrewrite_sv_error_notify", "0", { FCVAR_ARCHIVE })

cvars.AddChangeCallback("hpwrewrite_sv_nolearning", function(cvar, old, new)
	if SERVER then for k, v in pairs(player.GetAll()) do HpwRewrite:UpdatePlayerInfo(v) end end
end)

HpwRewrite.CVars.UseSaver = CreateConVar("hpwrewrite_sv_usesaver", "0", { FCVAR_ARCHIVE })
cvars.AddChangeCallback("hpwrewrite_sv_usesaver", function(cvar, old, new)
	if SERVER then HpwRewrite:UseSaver(tobool(new)) end
end)

if SERVER then HpwRewrite:UseSaver(HpwRewrite.CVars.UseSaver:GetBool()) end


-- Clientside cvars
if CLIENT then
	HpwRewrite.CVars.NoHud = CreateClientConVar("hpwrewrite_cl_nohud", "0", true, false)
	HpwRewrite.CVars.NoChoosing = CreateClientConVar("hpwrewrite_cl_nochoosing", "0", true, false)
	HpwRewrite.CVars.NoTextIfIcon = CreateClientConVar("hpwrewrite_cl_notexticon", "0", true, false)

	HpwRewrite.CVars.MmorpgStyle = CreateClientConVar("hpwrewrite_cl_mmorpgstyle", "1", true, false)
	HpwRewrite.CVars.DrawIcons = CreateClientConVar("hpwrewrite_cl_drawicons", "1", true, false)
	HpwRewrite.CVars.DrawSpellName = CreateClientConVar("hpwrewrite_cl_drawspname", "1", true, false)
	HpwRewrite.CVars.DrawHint = CreateClientConVar("hpwrewrite_cl_drawhint", "1", true, false)
	HpwRewrite.CVars.DrawSelHint = CreateClientConVar("hpwrewrite_cl_drawhint2", "1", true, false)
	HpwRewrite.CVars.DrawCurrentSpell = CreateClientConVar("hpwrewrite_cl_drawcurspell", "1", true, false)
	HpwRewrite.CVars.DrawSpellBar = CreateClientConVar("hpwrewrite_cl_drawspellbar", "1", true, false)

	HpwRewrite.CVars.DrawBookText = CreateClientConVar("hpwrewrite_cl_drawbooktext", "1", true, false)
	HpwRewrite.CVars.DisableBinds = CreateClientConVar("hpwrewrite_cl_disablebinds", "0", true, false)
	HpwRewrite.CVars.DisableMsg = CreateClientConVar("hpwrewrite_cl_disablemsg", "0", true, false)
	HpwRewrite.CVars.DisableAllMsgs = CreateClientConVar("hpwrewrite_cl_disableallmsgs", "0", true, false)
	HpwRewrite.CVars.InstantAttack = CreateClientConVar("hpwrewrite_cl_instantattack", "0", true, false)
	HpwRewrite.CVars.HideSparks = CreateClientConVar("hpwrewrite_cl_hidesparks", "0", true, false)
	HpwRewrite.CVars.CloseOnSelect = CreateClientConVar("hpwrewrite_cl_closeonselect", "1", true, false)
	
	HpwRewrite.CVars.BlockLeftMouse = CreateClientConVar("hpwrewrite_cl_blockleftmouse", "0", true, true)
	cvars.AddChangeCallback("hpwrewrite_cl_blockleftmouse", function(cvar, old, new)
		HpwRewrite:DoNotify(Format("Left mouse has been %s! Changes will be made after your death", tobool(new) and "blocked" or "unblocked"))
	end)

	HpwRewrite.CVars.HideTree = CreateClientConVar("hpwrewrite_cl_hidetree", "0", true, false)
	cvars.AddChangeCallback("hpwrewrite_cl_hidetree", function(cvar, old, new)
		HpwRewrite.VGUI:UpdateVgui()
	end)

	HpwRewrite.CVars.XOffset = CreateClientConVar("hpwrewrite_cl_xoffset", "0", true, false)
	HpwRewrite.CVars.YOffset = CreateClientConVar("hpwrewrite_cl_yoffset", "0", true, false)

	HpwRewrite.CVars.UseWhiteSmoke = CreateClientConVar("hpwrewrite_cl_appwhitesmoke", "0", true, true)

	-- 66 is a code of backspace key, 108 is a code of mouse right
	HpwRewrite.CVars.SelfCastKey = CreateClientConVar("hpwrewrite_cl_selfcastkey", "66", true, false)
	HpwRewrite.CVars.MenuKey = CreateClientConVar("hpwrewrite_cl_mmenukey", "108", true, false)

	HpwRewrite.CVars.FontName = CreateClientConVar("hpwrewrite_cl_fontname", "Harry P", true, false)
	cvars.AddChangeCallback("hpwrewrite_cl_fontname", function(cvar, old, new)
		HpwRewrite:LoadFonts()
		HpwRewrite.VGUI.ShouldUpdate = true
	end)

	HpwRewrite.CVars.Language = CreateClientConVar("hpwrewrite_cl_language", "en", true, false)

	concommand.Add("hpwrewrite_cl_updatevgui", function(ply)
		HpwRewrite.VGUI:UpdateVgui()
	end, nil, "Updates main VGUI")

	concommand.Add("hpwrewrite_cl_cleardebug", function(ply)
		table.Empty(HpwRewrite.DebugInfo)
	end, nil, "Cleans debug info array") 
end




-- Console commands
concommand.Add("hpwrewrite_dumpdata", function(ply)
	if CLIENT then return end
	
	local white = HpwRewrite.Colors.White
	local col2 = HpwRewrite.Colors.Blue

	MsgC(white, "Dumping players' data files...\n")
	local plys = player.GetAll()
	for k, v in pairs(plys) do
		local data, filen = HpwRewrite.DM:LoadDataFile(v)

		MsgC(white, v:Name(), " ", filen, " ...\n")
		MsgC(white, "SteamID ", col2, data.SteamID, "\n")
		MsgC(white, "Learned spells ", col2, table.concat(data.Spells, ", "), "\n")
		MsgC(white, "Learnable spells ", col2, table.concat(data.LearnableSpells, ", "), "\n")

		if next(plys, k) != nil then Msg("\n") end
	end
	Msg("\n")

	MsgC(white, "Dumping config...\n")
	local data, filen = HpwRewrite.DM:ReadConfig()
	MsgC(white, "AdminOnly ", col2, table.concat(data.AdminOnly, ", "), "\n")
	MsgC(white, "Blacklist ", col2, table.concat(data.Blacklist, ", "), "\n")
	MsgC(white, "Default skin ", col2, data.DefaultSkin, "\n")
end, nil, "") 

concommand.Add("hpwrewrite_admin_updatespells", function(ply)
	if CLIENT then return end
	if not HpwRewrite.CheckAdminError(ply) then return end

	for k, v in pairs(player.GetAll()) do 
		HpwRewrite:UpdatePlayerInfo(v) 
		HpwRewrite:DoNotify(ply, "Spells for " .. v:Name() .. " has been updated!", 4)
	end

	HpwRewrite:LogDebug(ply:Name() .. " has updated spells for everyone!")
end, nil, "Updates spells for every player") 

concommand.Add("hpwrewrite_admin_cleardebug", function(ply)
	if CLIENT then return end
	if not HpwRewrite.CheckAdminError(ply) then return end

	table.Empty(HpwRewrite.DebugInfo)
end, nil, "Cleans debug info array") 

concommand.Add("hpwrewrite_admin_cleaneverything", function(ply)
	if CLIENT then return end
	if not HpwRewrite.CheckAdminError(ply) then return end

	HpwRewrite:CleanEverything()
end, nil, "Cleans debug info array") 


