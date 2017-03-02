if not HpwRewrite then return end

HpwRewrite.DM = HpwRewrite.DM or { }

if not file.Exists("hpwrewrite", "DATA") then
	file.CreateDir("hpwrewrite")
	print("hpwrewrite folder has been created")
end

if CLIENT then 
	-- Binds
	if not file.Exists("hpwrewrite/client", "DATA") then
		file.CreateDir("hpwrewrite/client")
		print("hpwrewrite/client folder has been created")
	end

	if not file.Exists("hpwrewrite/client/binds.txt", "DATA") then
		local data = { ["Alpha"] = { } }
		file.Write("hpwrewrite/client/binds.txt", util.TableToJSON(data))
		print("hpwrewrite/client/binds.txt has been created")
	end

	function HpwRewrite.DM:ReadBinds()
		local newfile = file.Read("hpwrewrite/client/binds.txt")
		if not newfile then return end

		local data = util.JSONToTable(newfile)
		if not data then return end

		-- Hotfix for numbers
		for k, v in pairs(data) do
			data[k] = nil
			data[tostring(k)] = v
		end

		return data, "hpwrewrite/client/binds.txt"
	end


	-- Favourite spells
	local name = "hpwrewrite/client/favourites.txt"

	function HpwRewrite.DM:ReadFavourites()
		local fav = file.Read(name)

		if fav then 
			local spells = string.Explode("¤", fav)
			return spells, name
		end
	end

	function HpwRewrite.DM:AddToFavourites(spellName)
		local fav = file.Read(name)

		if fav then 
			file.Write(name, fav .. "¤" .. spellName)
			HpwRewrite.FavouriteSpells[spellName] = true
		end
	end

	function HpwRewrite.DM:RemoveFromFavourites(spellName)
		local fav = file.Read(name)

		if fav then 
			local target = "¤" .. spellName
			file.Write(name, string.Replace(fav, target, ""))
			HpwRewrite.FavouriteSpells[spellName] = false
		end
	end

	if not file.Exists(name, "DATA") then
		local data = ""
		file.Write(name, data)
		print("hpwrewrite/client/favourites.txt has been created")
	else
		local fav = HpwRewrite.DM:ReadFavourites()
		if fav then 
			for k, v in pairs(fav) do
				HpwRewrite.FavouriteSpells[v] = true
			end
		end
	end

	return 
end

-- Config
if not file.Exists("hpwrewrite/cfg", "DATA") then
	file.CreateDir("hpwrewrite/cfg")
	print("hpwrewrite/cfg folder has been created")
end

if not file.Exists("hpwrewrite/cfg/config.txt", "DATA") then
	local data = {
		AdminOnly = { },
		Blacklist = { },
		DefaultSkin = "Wand"
	}

	file.Write("hpwrewrite/cfg/config.txt", util.TableToJSON(data))
	print("hpwrewrite/cfg/config.txt has been created")
end

function HpwRewrite.DM:ReadConfig()
	local newfile = file.Read("hpwrewrite/cfg/config.txt")
	if not newfile then return end

	local data = util.JSONToTable(newfile)
	if not data then return end

	return data, "hpwrewrite/cfg/config.txt"
end

-- Spells data
-- Learned and learnable
function HpwRewrite.DM:GetFilenameID(ply)
	if ply.HpwRewrite.FILE_ID then 
		HpwRewrite:LogDebug("[Data] returning " .. ply.HpwRewrite.FILE_ID .. " for " .. ply:Name())
		return ply.HpwRewrite.FILE_ID 
	end

	local files, dirs = file.Find("hpwrewrite/*", "DATA")

	for k, v in pairs(files) do
		local path = "hpwrewrite/" .. v
		local newfile = file.Read(path)

		if newfile then
			local data = util.JSONToTable(newfile)

			if not data then
				file.Delete(path)
				continue
			end

			if data.SteamID == ply:SteamID() then
				ply.HpwRewrite.FILE_ID = path
				return path
			end
		end
	end

	local data = {
		SteamID = ply:SteamID(),
		Spells = { },
		LearnableSpells = { }
	}

	local nicesteamid = string.gsub(ply:SteamID(), "[^%d]", "") .. "_" .. table.Count(files)
	local filename = "hpwrewrite/" .. nicesteamid .. ".txt"
	file.Write(filename, util.TableToJSON(data))

	ply.HpwRewrite.FILE_ID = filename

	HpwRewrite:LogDebug("[Data] " .. ply:Name() .. " has got filename id - " .. filename)

	return filename
end

function HpwRewrite.DM:LoadDataFile(ply)
	local filename = self:GetFilenameID(ply)
	
	local getfile = file.Read(filename, "DATA")
	if not getfile then
		if not ply.HpwRewrite.Attempts then ply.HpwRewrite.Attempts = 0 end
		ply.HpwRewrite.Attempts = ply.HpwRewrite.Attempts + 1

		-- No recursion?
		if ply.HpwRewrite.Attempts > 5 then
			ErrorNoHalt("[ERROR] HPW: DATA FILE FOR " .. ply:Name() .. " CANNOT BE CREATED!\n")
			return
		end

		ErrorNoHalt("[ERROR] HPW: DATA FILE FOR " .. ply:Name() .. " NOT FOUND! CREATING ANOTHER ONE... [Attempt: " .. ply.HpwRewrite.Attempts .. "]\n")
		ply.HpwRewrite.FILE_ID = nil

		return self:LoadDataFile(ply)
	end

	local data = util.JSONToTable(getfile)
	if not data then
		ErrorNoHalt("[ERROR] HPW: CAN'T READ DATA FILE (" .. filename .. ") FOR " .. ply:Name() .. "!\n")
		ply.HpwRewrite.FILE_ID = nil

		return nil, filename
	end

	if data.SteamID != ply:SteamID() then 
		ErrorNoHalt("[ERROR] HPW: UNEXPECTED STEAM ID: EXPECTED " .. data.SteamID .. ", GOT " .. ply:SteamID() .. " PLAYER " .. ply:Name() .. "\n")
		ply.HpwRewrite.FILE_ID = nil

		return nil, filename 
	end

	ply.HpwRewrite.Attempts = 0

	return data, filename
end











