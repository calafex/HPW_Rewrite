if SERVER then return end
if not HpwRewrite then return end
if not HpwRewrite.DM then return end

HpwRewrite.BM = HpwRewrite.BM or { }

HpwRewrite.BM.LastBindFileName = "hpwrewrite/client/lastbindtree.txt"
HpwRewrite.BM.CurTree = "Alpha"
if file.Exists(HpwRewrite.BM.LastBindFileName, "DATA") then
	HpwRewrite.BM.CurTree = file.Read(HpwRewrite.BM.LastBindFileName, "DATA")
end

HpwRewrite.BM.Binds = { }

function HpwRewrite.BM:EmptyCurrentBinds()
	table.Empty(self.Binds)
	self.CurTree = "Alpha"
end

function HpwRewrite.BM:Load(data)
	table.Empty(self.Binds)

	for k, v in pairs(data) do
		self.Binds[v.Index] = v
	end
end

function HpwRewrite.BM:CreateTree(name)
	local data, filename = HpwRewrite.DM:ReadBinds()

	if data and not data[name] then
		data[name] = { } 
		file.Write(filename, util.TableToJSON(data))
	end

	return data, filename
end

function HpwRewrite.BM:RemoveTree(name)
	local data, filename = HpwRewrite.DM:ReadBinds()

	if data and data[name] then
		data[name] = nil
		file.Write(filename, util.TableToJSON(data))
	end

	return data, filename
end

function HpwRewrite.BM:AddBindSpell(spell, key, tree)
	tree = tree or "Alpha"
	local data, filename = HpwRewrite.DM:ReadBinds()

	if data then
		if not data[tree] then 
			data[tree] = { } 
		else
			for k, v in pairs(data[tree]) do if v.Key == key then return end end
		end

		-- Looking for empty space
		local indexes = { }
		local val = 1
		for k, v in pairs(data[tree]) do 
			if v.Index > val then val = v.Index end
			indexes[v.Index] = v.Index
		end
		
		for i = 1, (val + 1) do
			if not indexes[i] then val = i break end
		end

		local tab = { Spell = spell, Key = key, Index = val }

		table.insert(data[tree], tab)
		file.Write(filename, util.TableToJSON(data))

		if tree == self.CurTree then self:Load(data[tree]) end
	end

	return data, filename
end

function HpwRewrite.BM:RemoveBindSpell(key, tree)
	tree = tree or "Alpha"
	local data, filename = HpwRewrite.DM:ReadBinds()
	
	if data and data[tree] then
		for k, v in pairs(data[tree]) do if v.Key == key then table.remove(data[tree], k) end end
		file.Write(filename, util.TableToJSON(data))

		if tree == self.CurTree then self:Load(data[tree]) end
	end

	return data, filename
end

function HpwRewrite.BM:LoadBinds(tree)
	tree = tree or "Alpha"
	local data, filename = HpwRewrite.DM:ReadBinds()

	if data and data[tree] then
		self.CurTree = tree
		self:Load(data[tree])

		file.Write(HpwRewrite.BM.LastBindFileName, self.CurTree)
	end
end

-- Swap binds or moves to empty cell
function HpwRewrite.BM:MoveBindTo(bind1, bind2, tree)
	tree = tree or "Alpha"
	local data, filename = HpwRewrite.DM:ReadBinds()

	if data and data[tree] then
		local first, second

		for k, v in pairs(data[tree]) do
			if v.Index == bind1 then first = k end
			if v.Index == bind2 then second = k end
		end

		-- Swapping binds
		if first and second then
			local old = data[tree][first].Index
			data[tree][first].Index = data[tree][second].Index
			data[tree][second].Index = old

			file.Write(filename, util.TableToJSON(data))
			if tree == self.CurTree then self:Load(data[tree]) end
		end

		-- Moving to empty cell
		if first and not second then
			data[tree][first].Index = bind2

			file.Write(filename, util.TableToJSON(data))
			if tree == self.CurTree then self:Load(data[tree]) end
		end
	end
end

HpwRewrite.BM:LoadBinds(HpwRewrite.BM.CurTree)

HpwRewrite.BM.Keys = {
	[0] = "???",
	[1] = "0",
	[2] = "1",
	[3] = "2",
	[4] = "3",
	[5] = "4",
	[6] = "5",
	[7] = "6",
	[8] = "7",
	[9] = "8",
	[10] = "9",
	[11] = "A",
	[12] = "B",
	[13] = "C",
	[14] = "D",
	[15] = "E",
	[16] = "F",
	[17] = "G",
	[18] = "H",
	[19] = "I",
	[20] = "J",
	[21] = "K",
	[22] = "L",
	[23] = "M",
	[24] = "N",
	[25] = "O",
	[26] = "P",
	[27] = "Q",
	[28] = "R",
	[29] = "S",
	[30] = "T",
	[31] = "U",
	[32] = "V",
	[33] = "W",
	[34] = "X",
	[35] = "Y",
	[36] = "Z",
	[37] = "KP 0",
	[38] = "KP 1",
	[39] = "KP 2",
	[40] = "KP 3",
	[41] = "KP 4",
	[42] = "KP 5",
	[43] = "KP 6",
	[44] = "KP 7",
	[45] = "KP 8",
	[46] = "KP 9",
	[47] = "KP /",
	[48] = "KP *",
	[49] = "KP -",
	[50] = "KP +",
	[51] = "KP Enter",
	[52] = "KP Del",
	[53] = "[",
	[54] = "]",
	[55] = ";",
	[56] = '"',
	[57] = "`",
	[58] = ",",
	[59] = ".",
	[60] = "/",
	[61] = "\\",
	[62] = "-",
	[63] = "=",
	[64] = "Enter",
	[65] = "Space",
	[66] = "Backspace",
	[67] = "Tab",
	[68] = "Caps Lock",
	[69] = "Num Lock",
	[71] = "Scroll Lock",
	[72] = "Insert",
	[73] = "Delete",
	[74] = "Home",
	[75] = "End",
	[76] = "Page Up",
	[78] = "Break",
	[79] = "Shift",
	[80] = "Shift Left",
	[81] = "ALT",
	[82] = "ALT Right",
	[83] = "Ctrl",
	[84] = "Ctrl Right",
	[88] = "Arrow Up",
	[89] = "Arrow Left",
	[90] = "Arrow Down",
	[91] = "Arrow Right",
	[92] = "F1",
	[93] = "F2",
	[94] = "F3",
	[95] = "F4",
	[96] = "F5",
	[97] = "F6",
	[98] = "F7",
	[99] = "F8",
	[100] = "F9",
	[101] = "F10",
	[102] = "F11",
	[103] = "F12",
	[107] = "Mouse 1",
	[108] = "Mouse 2",
	[109] = "Mouse 3",
	[110] = "Mouse 4",
	[111] = "Mouse 5",
	
	[112] = "Mouse W Up", -- 112 - 113 not working
	[113] = "Mouse W Down"
}

function HpwRewrite.BM:GetKeyIndex(key)
	return table.KeyFromValue(self.Keys, key)
end

local keys = { }
for i = 0, 113 do
	keys[i] = false
end

hook.Add("Think", "hpwrewrite_binds", function()
	if HpwRewrite.CVars.DisableBinds:GetBool() then return end
	if vgui.CursorVisible() then return end

	local wep = LocalPlayer():GetActiveWeapon()

	if HpwRewrite.IsValidWand(wep) then
		for k, v in pairs(HpwRewrite.BM.Binds) do
			local key = v.Key

			local oldpressed = keys[key]
			keys[key] = key >= 107 and input.IsMouseDown(key) or input.IsKeyDown(key)

			if oldpressed != keys[key] then 
				if keys[key] then
					HpwRewrite:RequestSpell(v.Spell, true)
					HpwRewrite:LogDebug("Requested " .. v.Spell .. " | key " .. v.Key)
				end
			end
		end
	end

	-- Self casting key
	local key = HpwRewrite.CVars.SelfCastKey:GetInt()
	local oldpressed = keys[key]
	keys[key] = key >= 107 and input.IsMouseDown(key) or input.IsKeyDown(key)

	if oldpressed != keys[key] then
		HpwRewrite._IsHoldingSelfCast = keys[key]

		net.Start("HpwRewriteSendSelfCast")
			net.WriteBit(keys[key])
		net.SendToServer()
	end
end)




