if CLIENT then return end

-- Spell changing
net.Receive("hpwrewrite_Chng", function(len, ply)
	local wep = HpwRewrite:GetWand(ply)
	if wep:IsValid() then
		local name = net.ReadString()

		local skin = HpwRewrite:GetSkin(name)
		if skin then 
			wep:HPWSetWandSkin(name) 
		else 
			local instant = net.ReadBit()
			if instant and tobool(instant) then 
				wep:PrimaryAttack(name) 
			else
				wep:HPWSetCurrentSpell(name) 
			end
		end
	end
end)

net.Receive("hpwrewrite_updatespells_request", function(args, ply)
	if not ply.HpwRewrite then ply.HpwRewrite = { } end
	if ply.HpwRewrite.UpdatedSpells then return end

	HpwRewrite:UpdatePlayerInfo(ply)
	ply.HpwRewrite.UpdatedSpells = true
end)

net.Receive("hpwrewrite_RemSpell", function(args, ply)
	local wep = HpwRewrite:GetWand(ply)
	if wep:IsValid() then
		wep:HPWRemoveCurSpell()
	end
end)

net.Receive("hpwrewrite_LrnS", function(len, ply)
	local name = net.ReadString()

	if HpwRewrite:PlayerStartLearning(ply, name) then 
		net.Start("hpwrewrite_Snd")
			net.WriteString("hpwrewrite/learnstart.wav")
		net.Send(ply)
	end
end)

net.Receive("hpwrewrite_LrnSt", function(len, ply)
	if HpwRewrite:PlayerStopLearning(ply) then 
		net.Start("hpwrewrite_Snd")
			net.WriteString("hpwrewrite/learnstop.wav")
		net.Send(ply)
	end
end)

local function GetString(time)
	return Format("You have to wait before another update request! %i seconds left", time - CurTime())
end

-- Update requests
net.Receive("hpwrewrite_ClientRequest", function(len, ply)
	local msg = net.ReadUInt(5)

	if msg < 4 then
		if not ply.HpwRewrite.WaitBeforeClientUpdate then 
			ply.HpwRewrite.WaitBeforeClientUpdate = 0 
		end

		if CurTime() > ply.HpwRewrite.WaitBeforeClientUpdate then
			if msg == 1 then -- UpdD
				HpwRewrite:DoNotify(ply, "Update request has been received! Updating your info...")
				HpwRewrite:SendConfig(ply)
			elseif msg == 2 then -- UpdE
				HpwRewrite:DoNotify(ply, "Update request has been received! Updating your info...")
				HpwRewrite:EmptyTables(ply)
			elseif msg == 3 then -- RemAll
				HpwRewrite:DeletePlayerSpells(ply)
				HpwRewrite:DoNotify(ply, "Your spells has been completely deleted!")
			end

			ply.HpwRewrite.WaitBeforeClientUpdate = CurTime() + 6
		else
			HpwRewrite:DoNotify(ply, GetString(ply.HpwRewrite.WaitBeforeClientUpdate), 1)
		end
	else
		if not ply.HpwRewrite.WaitBeforeClientUpdate1 then 
			ply.HpwRewrite.WaitBeforeClientUpdate1 = 0 
		end

		if CurTime() > ply.HpwRewrite.WaitBeforeClientUpdate1 then
			if msg == 4 then -- Upd
				HpwRewrite:DoNotify(ply, "Update request has been received! Updating your info...")
				HpwRewrite:UpdatePlayerInfo(ply)
			elseif msg == 5 then -- UpdLo
				HpwRewrite:DoNotify(ply, "Update request has been received! Updating your info...")
				HpwRewrite:LoadSpells(ply)
			end

			ply.HpwRewrite.WaitBeforeClientUpdate1 = CurTime() + 20
		else
			HpwRewrite:DoNotify(ply, GetString(ply.HpwRewrite.WaitBeforeClientUpdate1), 1)
		end
	end
end)

--- Admin functions
local function CheckAdmin(ply)
	if not HpwRewrite.CheckAdmin then return false end -- ???
	if not HpwRewrite.CheckAdmin(ply) then HpwRewrite:DoNotify(ply, "You're not admin!", 1) return false end

	return true
end

HpwRewrite.CheckAdminError = CheckAdmin

net.Receive("hpwrewrite_AdminFunctions", function(len, ply)
	if not CheckAdmin(ply) then return end

	local msg = net.ReadUInt(5)

	if msg == 1 then -- setdsk
		HpwRewrite:SetDefaultSkin(net.ReadString())
	elseif msg == 2 then -- AddSp1, give spell without saving
		local spell = net.ReadString()
		if not spell then return end

		local sel = net.ReadEntity()
		if not IsValid(sel) or not sel:IsPlayer() then return end

		HpwRewrite:PlayerGiveSpell(sel, spell)
	elseif msg == 3 then -- AddSp2, give spell with saving
		local spell = net.ReadString()
		if not spell then return end

		local sel = net.ReadEntity()
		if not IsValid(sel) or not sel:IsPlayer() then return end

		HpwRewrite:SaveAndGiveSpell(sel, spell, true)
	elseif msg == 4 then -- AddSp3, give spell to learnables with saving
		local spell = net.ReadString()
		if not spell then return end

		local sel = net.ReadEntity()
		if not IsValid(sel) or not sel:IsPlayer() then return end

		HpwRewrite:PlayerGiveLearnableSpell(sel, spell)
	elseif msg == 5 then -- PInfo, list of players who has sended spell
		local spell = net.ReadString()
		if not spell then return end

		local players = { }

		for k, v in pairs(player.GetAll()) do
			if HpwRewrite:PlayerHasSpell(v, spell) then table.insert(players, v:Name()) end
		end

		ply:ChatPrint("Players who has got '" .. spell .. "': " .. table.concat(players, ", "))
	elseif msg == 6 then -- PInfo2
		local spell = net.ReadString()
		if not spell then return end

		local players = { }

		ply:ChatPrint("Reading data files...")

		for k, v in pairs(player.GetAll()) do
			local data, filename = HpwRewrite.DM:LoadDataFile(v)
			if data then
				if table.HasValue(data.Spells, spell) then table.insert(players, v:Name()) end
			else
				HpwRewrite:LogDebug("PInfo2: data file for " .. v:Name() .. " not found!")
			end
		end

		ply:ChatPrint("Players who has got '" .. spell .. "': " .. table.concat(players, ", "))
	elseif msg == 7 then -- UnAl, unlearns spell from everyone
		local spell = net.ReadString()
		if not spell then return end

		for k, v in pairs(player.GetAll()) do
			HpwRewrite:PlayerUnlearnSpell(v, spell)
		end
	elseif msg == 8 then -- RemSp
		local spell = net.ReadString()
		if not spell then return end

		local sel = net.ReadEntity()
		if not IsValid(sel) or not sel:IsPlayer() then return end

		local data, filename = HpwRewrite:PlayerUnlearnSpell(sel, spell)
		if not data then return end

		local Spells = table.concat(data.Spells, "%")
		local LearnableSpells = table.concat(data.LearnableSpells, "%")

		net.Start("hpwrewrite_GivI")
			net.WriteString(Spells)
			net.WriteString(LearnableSpells)
		net.Send(ply)
	elseif msg == 9 then -- RemSpl
		local spell = net.ReadString()
		if not spell then return end

		local sel = net.ReadEntity()
		if not IsValid(sel) or not sel:IsPlayer() then return end

		local data, filename = HpwRewrite:PlayerRemoveLearnableSpell(sel, spell)
		if not data then return end

		local Spells = table.concat(data.Spells or { }, "%")
		local LearnableSpells = table.concat(data.LearnableSpells or { }, "%")

		net.Start("hpwrewrite_GivI")
			net.WriteString(Spells)
			net.WriteString(LearnableSpells)
		net.Send(ply)
	elseif msg == 10 then -- AupdI
		local sel = net.ReadEntity()
		if not IsValid(sel) or not sel:IsPlayer() then return end

		local data, f = HpwRewrite.DM:LoadDataFile(sel)

		if data then
			local Spells = table.concat(data.Spells, "%")
			local LearnableSpells = table.concat(data.LearnableSpells, "%")

			net.Start("hpwrewrite_GivI")
				net.WriteString(Spells)
				net.WriteString(LearnableSpells)
			net.Send(ply)
		end
	elseif msg == 11 then -- Black
		local name = net.ReadString()
		local a, b = HpwRewrite:SpellToBlacklist(name)
		if not a then HpwRewrite:DoNotify(ply, "Cannot add " .. name .. " to blacklist", 1) end
	elseif msg == 12 then -- Admin
		HpwRewrite:SpellToAdminOnly(net.ReadString())
	elseif msg == 13 then -- Info
		local data, path = HpwRewrite.DM:ReadConfig()

		if data then
			local blacklist = table.concat(data.Blacklist, ", ")
			local adminonly = table.concat(data.AdminOnly, ", ")

			ply:ChatPrint("Blacklisted: " .. blacklist)
			ply:ChatPrint("Adminonly: " .. adminonly)
			ply:ChatPrint("Default skin: In config file - " .. data.DefaultSkin .. "; currently - " .. HpwRewrite.DefaultSkin)
		end
	elseif msg == 14 then -- LearnAll
		if not ply:IsSuperAdmin() then return end

		for k, v in pairs(HpwRewrite:GetSpells()) do
			HpwRewrite:SaveAndGiveSpell(ply, k, true)
		end
	end
end)
