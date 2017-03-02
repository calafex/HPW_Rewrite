if SERVER then
	-- Debug
	util.AddNetworkString("hpwrewrite_DebugPlayer_Server")
	util.AddNetworkString("hpwrewrite_DebugPlayer_Client")
	util.AddNetworkString("hpwrewrite_DInfoClear")
	util.AddNetworkString("hpwrewrite_DInfoClear2")
	util.AddNetworkString("hpwrewrite_DebugServerReceive")
	util.AddNetworkString("hpwrewrite_DebugServerReceive2")

	-- Fightings
	util.AddNetworkString("hpwrewrite_Fight")
	util.AddNetworkString("hpwrewrite_HUDF")

	-- Main requests
	util.AddNetworkString("hpwrewrite_vm_wm")
	util.AddNetworkString("hpwrewrite_DefSkin")
	util.AddNetworkString("hpwrewrite_GivI")
	util.AddNetworkString("hpwrewrite_nfy")
	util.AddNetworkString("hpwrewrite_Snd")
	util.AddNetworkString("hpwrewrite_SplA")
	util.AddNetworkString("hpwrewrite_SplR")
	util.AddNetworkString("hpwrewrite_SpA")
	util.AddNetworkString("hpwrewrite_SpR")
	util.AddNetworkString("hpwrewrite_SpCl")
	util.AddNetworkString("hpwrewrite_Lrn")
	util.AddNetworkString("hpwrewrite_LrnS") -- two receivers
	util.AddNetworkString("hpwrewrite_ClientsidePrimaryAttack")

	util.AddNetworkString("hpwrewrite_Chng")
	util.AddNetworkString("hpwrewrite_RemSpell")
	util.AddNetworkString("hpwrewrite_LrnSt")
	util.AddNetworkString("hpwrewrite_UpdSpells")

	-- Requests
	util.AddNetworkString("hpwrewrite_ClientRequest")
	util.AddNetworkString("hpwrewrite_AdminFunctions")
	util.AddNetworkString("hpwrewrite_clBlack")
	util.AddNetworkString("hpwrewrite_clAdm")
	util.AddNetworkString("hpwrewrite_updatespells_request")

	-- Visual effects
	util.AddNetworkString("hpwrewrite_Dim")
	util.AddNetworkString("hpwrewrite_EDim")
	util.AddNetworkString("hpwrewrite_BSODFAKESTART")
	util.AddNetworkString("hpwrewrite_BSODFAKESTOP")
	util.AddNetworkString("hpwrewrite_Win10")
	util.AddNetworkString("hpwrewrite_EWin10")
	util.AddNetworkString("hpwrewrite_Hell")
	util.AddNetworkString("hpwrewrite_EHell")

	-- Misc
	util.AddNetworkString("hpwrewrite_Congrats")
	util.AddNetworkString("hpwrewrite_Congrats2")
end

HpwRewrite:IncludeFolder("hpwrewrite/net", true)