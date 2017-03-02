if not HpwRewrite then return end
if not HpwRewrite.DM then return end

HpwRewrite.Spells = HpwRewrite.Spells or { }

HpwRewrite.PlayerSpellsInfo = HpwRewrite.PlayerSpellsInfo or { }
HpwRewrite.PlayerLearnSpellsInfo = HpwRewrite.PlayerLearnSpellsInfo or { }
HpwRewrite.SpellCache = HpwRewrite.SpellCache or { } -- Store removed by PlayerRemoveSpell spells here

HpwRewrite.Blacklist = HpwRewrite.Blacklist or { }
HpwRewrite.AdminOnly = HpwRewrite.AdminOnly or { }

HpwRewrite.NumOfSpells = HpwRewrite.NumOfSpells or 0
HpwRewrite.NumOfSkins = HpwRewrite.NumOfSkins or 0

HpwRewrite.DefaultSkin = HpwRewrite.DefaultSkin or "Wand"

if CLIENT then 
	HpwRewrite.Categories = HpwRewrite.Categories or { }
	HpwRewrite.PlyNumOfSpells = HpwRewrite.PlyNumOfSpells or 0

	function HpwRewrite:GetCategories()
		return self.Categories
	end

	function HpwRewrite:AddCategory(name)
		self.Categories[name] = true
	end

	HpwRewrite:AddCategory(HpwRewrite.Language:GetWord("#favcategory"))

	-- Change current spell clientside request
	function HpwRewrite:RequestSpell(name, checkCvar)
		if checkCvar and HpwRewrite.CVars.InstantAttack:GetBool() then
			net.Start("hpwrewrite_Chng")
				net.WriteString(name)
				net.WriteBit(true)
			net.SendToServer()
		else
			surface.PlaySound("hpwrewrite/select.wav")
			
			net.Start("hpwrewrite_Chng")
				net.WriteString(name)
			net.SendToServer()
		end
	end

	local spellcellMat = Material("vgui/hpwrewrite/spellcell")
	local spellcellempty = Material("vgui/hpwrewrite/spellcellempty")
	local white = HpwRewrite.Colors.White
	local black = HpwRewrite.Colors.Black

	-- Draws default spell rect that appears on HUD basing on RPG cvar
	-- Use this function to draw spell
	function HpwRewrite:DrawSpellRect(spell, key, x, y, w, h)
		local mmorpg = HpwRewrite.CVars.MmorpgStyle:GetBool()
		local wand = self:GetWand(LocalPlayer())
	
		if mmorpg then
			local color = white
			if spell and not self:CanUseSpell(LocalPlayer(), spell) then color = Color(255, 110, 110) end

			surface.SetMaterial(spellcellMat)
			surface.SetDrawColor(color)
			surface.DrawTexturedRect(x - 3, y - 3, w + 6, h + 6)
		else
			draw.RoundedBox(0, x, y, w, h, Color(0, 0, 0, 200))

			if wand:IsValid() then
				if spell == wand:GetWandCurrentSpell() then
					surface.SetDrawColor(Color(0, 140, 255))
					surface.DrawOutlinedRect(x - 1, y - 1, w + 2, h + 2)
				end

				if spell == wand:GetWandCurrentSkin() then
					surface.SetDrawColor(Color(0, 255, 0))
					surface.DrawOutlinedRect(x - 1, y - 1, w + 2, h + 2)
				end
			end

			if spell and not self:CanUseSpell(LocalPlayer(), spell) then draw.RoundedBox(0, x, y, w, h, Color(255, 0, 0, 50)) end
		end

		-- Everything below should be drawn for a bind only
		if not spell or not key then return end

		local alpha = 255
		local mat = self:GetSpellIcon(spell)

		if self.CVars.DrawIcons:GetBool() then
			if not mat:IsError() then
				local color = self:CanUseSpell(LocalPlayer(), spell) and Color(255, 255, 255, 230) or Color(255, 100, 100, 230)

				surface.SetMaterial(mat)
				surface.SetDrawColor(color)

				local x = x + 1
				local y = y + 1
				
				local w = w - 2
				local h = h - 2

				surface.DrawTexturedRect(x, y, w, h)

				alpha = 200
			end
		end

		if mmorpg then
			surface.SetMaterial(spellcellempty)

			local color = white
			if wand:IsValid() then
				if spell == wand:GetWandCurrentSpell() then color = Color(110, 190, 255) end
				if spell == wand:GetWandCurrentSkin() then color = Color(110, 255, 110) end
			end

			if not self:CanUseSpell(LocalPlayer(), spell) then color = Color(110, 110, 110) end

			surface.SetDrawColor(color)
			surface.DrawTexturedRect(x - 3, y - 3, w + 6, h + 6)
		end

		if not (self.CVars.NoTextIfIcon:GetBool() and not mat:IsError()) and self.CVars.DrawSpellName:GetBool() then
			local pos = 4
			local font = "HPW_fontSpells"
			if string.len(spell) > 4 then
				font = "HPW_fontSpells1"
			end

			if string.len(spell) > 6 then
				font = "HPW_fontSpells2"
			end
			
			local x = x + w * 0.5

			local function DrawRestricted(str)
				local new = string.sub(str, 1, 8)
				draw.SimpleText(new, font, x + 1, y + pos + 1, black, TEXT_ALIGN_CENTER)
				draw.SimpleText(new, font, x, y + pos, white, TEXT_ALIGN_CENTER)

				pos = pos + 14

				if string.len(str) > 8 then
					DrawRestricted(string.sub(str, 9))
					return
				end
			end

			for k, str in pairs(string.Explode(" ", spell)) do 
				DrawRestricted(str) 
			end
		end

		if key then
			--[[if mmorpg then
				local x = x + w * 0.95
				local y = y + h * 0.76
			
				draw.SimpleText(self.BM.Keys[key], "HPW_font1", x + 1, y + 1, black, TEXT_ALIGN_RIGHT)
				draw.SimpleText(self.BM.Keys[key], "HPW_font1", x, y, white, TEXT_ALIGN_RIGHT)
			else]]
				local x = x + w * 0.5
				local y = y + h * 0.7
			
				draw.SimpleText(self.BM.Keys[key], "HPW_font1", x + 1, y + 1, black, TEXT_ALIGN_CENTER)
				draw.SimpleText(self.BM.Keys[key], "HPW_font1", x, y, white, TEXT_ALIGN_CENTER)
			--end
		end
	end
end

function HpwRewrite:GetSpells() 
	return self.Spells 
end

function HpwRewrite:GetSpell(name)
	return self.Spells[name]
end

function HpwRewrite:GetSpellById(id)
	for k, v in pairs(HpwRewrite:GetSpells()) do
		if v.UniqueID == id then return v end
	end
end

local badMaterial = Material("debug/debugempty")
function HpwRewrite:GetSpellIcon(name)
	local spell = HpwRewrite:GetSpell(name)
	if not spell or not spell.IconMat then return badMaterial end
	
	return spell.IconMat
end

--[[
	You can find creating spell guide 
	here: 
]]

local addedSomeSpells = false

local glowMat = Material("hpwrewrite/sprites/magicsprite")

local defaultValues = {
	PreFire = function() return true end,
	OnFire = function() return false end,
	OnSelect = function() return true end,
	PhysicsThink = function() return nil, nil, false end,
	OnStartLearn = function() return true end,
	OnPreLearn = function() return true end,
	PreSkinSelect = function() return true end,
	GetSpellPosition = function(self, wand, oldpos) return oldpos end,
	OnSpellGiven = function() return true end,

	OnWandDeploy = function() end,
	OnHolster = function() end,
	OnWandHolster = function() end,
	OnSpellSpawned = function() end,
	Draw = function() end,
	SpellThink = function() end,
	OnCollide = function() end,	
	AfterCollide = function() end,
	OnRemove = function() end,
	Think = function() end,	
	OnPostLearn = function() end,
	OnStopLearn = function() end,
	PostDrawViewModel = function() end,
	DrawWorldModel = function() end,
	OnSkinSelect = function() end,
	OnSkinHolster = function() end,
	OnSpellRemoved = function() end,
	OnDataReceived = function() end,
	DrawMagicSprite = function() end,
	GetCastSound = function() end,
	GetAnimations = function() end,

	DoImpactSound = function(self, spell, data)
		sound.Play("hpwrewrite/spells/spellimpact.wav", data.HitPos, 70, math.random(90, 110))
	end,

	DrawGlow = function(self, spell, color, size)
		color = color or self.SpriteColor
		size = size or 64

		if not spell.GlowSize then
			spell.GlowSize = size * 0.1
		end

		spell.GlowSize = math.Approach(spell.GlowSize, size, size * FrameTime() * 6)

		local dlight = DynamicLight(spell:EntIndex())
		if dlight then
			dlight.pos = spell:GetPos()
			dlight.r = color.r
			dlight.g = color.g
			dlight.b = color.b
			dlight.brightness = 3
			dlight.Decay = 1000
			dlight.Size = 128
			dlight.DieTime = CurTime() + 1
		end

		size = spell.GlowSize + math.sin(CurTime() * 4) * 10

		render.SetMaterial(glowMat)
		render.DrawSprite(spell:GetPos(), size, size, color)
		render.DrawSprite(spell:GetPos(), size * 2, size * 0.75, color)	
	end,

	NodeDraw = function() end,
	NodeDrawOpti = function() end,
	NodeEdgeDraw = function() end,
	NodeEdgeToParentDraw = function() end,

	ShouldReverseSelfCast = false,
	DoSelfCastAnim = true,
	PlayAnimation = true,
	ShouldSay = true,
	ShowInSpawnmenu = true,
	CreateEntity = true,
	ShouldCount = true,
	SecretSpell = false,
	CanSelfCast = true,
	ShouldRenderBookIcon = true,

	Description = [[
		No description available.
		This spell may do nothing.
	]],

	Category = HpwRewrite.CategoryNames.Generic,
	AccuracyDecreaseVal = 0.05,
}

local queue = { }
local loaded = false

-- You must call this function in shared realm
function HpwRewrite:AddSpell(name, tab)
	-- Still can have custom icons
	if not tab.IconMat then
		tab.IconMat = Material("vgui/entities/entity_hpwand_spell_" .. string.lower(string.Replace(name, " ", "_")), "noclamp smooth")
	end

	if tab.Base then
		if queue[name] then
			setmetatable(tab, { 
				__index = function(curTab, key) 
					local spell = self:GetSpell(curTab.Base)

					if spell then
						if key == "BaseClass" then
							return spell
						end

						return spell[key]
					end
				end
			})
		else
			queue[name] = tab

			if loaded then
				HpwRewrite:LoadChildrens()
			end

			return
		end
	end

	if tab.Fightable and not tab.FightingEffect then
		tab.Fightable = false
		print(name .. " is not a valid fightable spell! Fightable spell must contain FightingEffect function")
	end

	tab.Name = name
	tab.__index = tab

	function tab:__tostring()
		return self.Name
	end

	-- New instance of a spell
	-- better, faster and more optimized way than copying whole table for an instance
	function tab.New(owner)
		local new = setmetatable({ }, tab)
		new.Owner = owner
		return new
	end

	-- Setting up default values if not found
	for k, v in pairs(defaultValues) do
		if tab[k] == nil then tab[k] = v end
	end

	if not tab.LearnTime then tab.InstantLearn = true tab.LearnTime = 0 end
	if not tab.CreateEntity then tab.ShowInSpawnmenu = false end

	if tab.IsSkin then tab.CanSelfCast = false end
	if tab.ImpactEffect then PrecacheParticleSystem(tab.ImpactEffect) end
	if tab.FlyEffect then PrecacheParticleSystem(tab.FlyEffect) end

	if tab.SecretSpell then
		tab.ShowInSpawnmenu = false
		tab.ShouldCount = false

		if tab.OnlyIfLearned then
			print(name .. " must not have a tree! Removing OnlyIfLearned...")
			tab.OnlyIfLearned = nil
		end

		if tab.DoCongrats == nil then tab.DoCongrats = true end
		if tab.DoCongrats then
			local old = tab.OnPostLearn
			function tab:OnPostLearn(ply)
				old(self, ply)
				
				net.Start("hpwrewrite_Congrats")
				net.Send(ply)
			end
		end
	end

	if CLIENT then 
		if type(tab.Category) == "table" then
			for k, v in pairs(tab.Category) do self:AddCategory(v) end
		else
			self:AddCategory(tab.Category) 
		end
	end

	-- Creating spell book / wand box
	if tab.CreateEntity then
		local ENT = { }
		
		ENT.Type = "anim"
		ENT.Base = "entity_hpwand_bookbase"
		ENT.PrintName = name
		ENT.Category = (tab.IsSkin and "Harry Potter Skins" or "Harry Potter Spell Books")
		ENT.Author = "Wand"
		ENT.Spawnable =  tab.ShowInSpawnmenu

		ENT.Model = tab.Models and Model(table.Random(tab.Models)) or (tab.IsSkin and Model("models/hpwrewrite/wandbox/boxclosed.mdl") or Model("models/hpwrewrite/books/book2.mdl"))
		
		if CLIENT and tab.ShouldRenderBookIcon then
			-- Materials are not available while lua loads
			timer.Simple(1, function() ENT.CustomIcon = self:GetSpellIcon(name) end)
		end

		function ENT:GiveSpells(activator, caller)
			local complete, reason = HpwRewrite:PlayerGiveLearnableSpell(activator, self.PrintName)
			if not complete then 
				HpwRewrite:DoNotify(activator, reason or "Unknown error!") 
				return false
			end

			return true
		end

		local nicename = ("entity_hpwand_spell_" .. string.lower(string.Replace(name, " ", "_")))
		scripted_ents.Register(ENT, nicename)

		tab.NiceName = nicename -- Class name, to spawn spell book having only spell tab
	end

	local old = self:GetSpells()[name]

	self:GetSpells()[name] = tab.New(NULL)
	self:LogDebug(name .. " has been added!")

	-- These unique ids are unique only when the spells are properly loaded on startup
	tab.UniqueID = table.Count(self:GetSpells())

	-- Updating this spell
	if old != nil then
		tab.UniqueID = old.UniqueID -- Otherwise it will be wrong

		if SERVER then
			timer.Simple(0, function()
				for k, v in pairs(player.GetAll()) do
					if self:PlayerHasSpell(v, name) then
						local save = false
						local wand = HpwRewrite:GetWand(v)
						if wand:IsValid() and wand:GetWandCurrentSpell() == name then save = true end

						self:PlayerRemoveSpell(v, name)
						self:RemoveFromCache(v, name) -- Preventing from loading from cache
						self:PlayerGiveSpell(v, name)

						if save then
							wand:HPWSetCurrentSpell(name)
						end
					end
				end
			end)
		end
	else
		if tab.ShouldCount then
			if tab.IsSkin then
				self.NumOfSkins = self.NumOfSkins + 1
			else
				self.NumOfSpells = self.NumOfSpells + 1 
			end
		end

		if tab.CreateEntity then
			addedSomeSpells = true
		end
	end
end

HpwRewrite:IncludeFolder("hpwrewrite/spells", true)
HpwRewrite:LoadFile("hpwrewrite/skinmanager.lua")

function HpwRewrite:LoadChildrens()
	for k, v in pairs(queue) do
		HpwRewrite:AddSpell(k, v)
		queue[k] = nil
	end
end

HpwRewrite:LoadChildrens()

if CLIENT and addedSomeSpells and IsValid(g_SpawnMenu) then
	print("[Wand] Reloading spawnmenu...")
	RunConsoleCommand("spawnmenu_reload")
end

-- Here we finish spell loading
loaded = true



function HpwRewrite:GetLearnedSpells(ply)
	if CLIENT then
		return self.PlayerSpellsInfo
	else
		if not IsValid(ply) or not ply:IsPlayer() then return end
		if not self.PlayerSpellsInfo[ply] then self.PlayerSpellsInfo[ply] = { } end

		return self.PlayerSpellsInfo[ply]
	end
end

function HpwRewrite:GetLearnableSpells(ply)
	if CLIENT then
		return self.PlayerLearnSpellsInfo
	else
		if not IsValid(ply) or not ply:IsPlayer() then return end
		if not self.PlayerLearnSpellsInfo[ply] then self.PlayerLearnSpellsInfo[ply] = { } end

		return self.PlayerLearnSpellsInfo[ply]
	end
end

-- Returns player spell table
function HpwRewrite:GetPlayerSpell(ply, name)
	return self:GetLearnedSpells(ply)[name]
end

function HpwRewrite:GetPlayerLearnableSpell(ply, name)
	return self:GetLearnableSpells(ply)[name]
end

function HpwRewrite:PlayerHasSpell(ply, name)
	if self:GetPlayerSpell(ply, name) then return true end
	return false
end

function HpwRewrite:PlayerHasLearnableSpell(ply, name)
	if self:GetPlayerLearnableSpell(ply, name) then return true end
	return false
end

function HpwRewrite:PlayerNumSpells(ply)
	return (CLIENT and self.PlyNumOfSpells or ply.HpwRewrite.NumOfSpells) or 0
end

function HpwRewrite:GetNumOfSpells()
	return self.NumOfSpells
end

function HpwRewrite:SkillLevel(ply)
	if self:PlayerNumSpells(ply) > self:GetNumOfSpells() then return 1 end -- should never happen
	return self:PlayerNumSpells(ply) / self:GetNumOfSpells()
end

function HpwRewrite:IsSpellInAdminOnly(name) 
	if self.AdminOnly[name] then return true end
	return false
end

function HpwRewrite:IsSpellInBlacklist(name) 
	if self.Blacklist[name] then return true end
	return false
end

-- Checks if player can learn spell
local function CheckLearned(ply, spell)
	if spell.OnlyIfLearned then
		for k, v in pairs(spell.OnlyIfLearned) do
			if not HpwRewrite:PlayerHasSpell(ply, v) then
				return false
			end
		end
	end

	return true
end

function HpwRewrite:CanLearn(ply, name)
	local spell = HpwRewrite:GetPlayerLearnableSpell(ply, name)
	if not spell then return false end
	
	return CheckLearned(ply, spell)
end

-- General function to check if some player can use some spell
function HpwRewrite:CanUseSpell(ply, name)
	if self:IsSpellInBlacklist(name) then return false end

	local spell = self:GetPlayerSpell(ply, name)
	if not spell then return false end

	if not spell.IsSkin then
		local wand = self:GetWand(ply)
		if not wand:IsValid() then return false end

		local skinname = wand:GetWandCurrentSkin()
		local skin = self:GetPlayerSkin(ply, skinname)
		if not skin then return false end
		
		if skin.SpellFilter and table.HasValue(skin.SpellFilter, name) then return false end
		if skin.OnlyTheseSpells and not table.HasValue(skin.OnlyTheseSpells, name) then return false end
		if spell.OnlyWithSkin and not table.HasValue(spell.OnlyWithSkin, skinname) then return false end
	end

	-- Why not use CheckLearned?
	if spell.OnlyIfLearned then
		for k, v in pairs(spell.OnlyIfLearned) do 
			if not self:PlayerHasSpell(ply, v) then 
				return false 
			end 
		end
	end
	
	return true
end

if SERVER then
	-- Initializing blacklisted and adminonly spells
	local data, path = HpwRewrite.DM:ReadConfig()

	if data then
		for k, v in pairs(data.Blacklist) do
			HpwRewrite.Blacklist[v] = true
		end

		for k, v in pairs(data.AdminOnly) do
			HpwRewrite.AdminOnly[v] = true
		end

		local skin = HpwRewrite:GetSkin(data.DefaultSkin)
		if skin then
			HpwRewrite.DefaultSkin = data.DefaultSkin
		else
			HpwRewrite:LogDebug("Invalid default skin name " .. data.DefaultSkin .. "! Writing 'Wand' as default skin!")

			data.DefaultSkin = HpwRewrite.DefaultSkin
			file.Write(path, util.TableToJSON(data))
		end
	end

	local function WriteToBlacklist(name, val)
		HpwRewrite.Blacklist[name] = val

		net.Start("hpwrewrite_clBlack")
			net.WriteString(name)
			net.WriteBit(val)
		net.Broadcast()
	end

	local function WriteToAdminOnly(name, val)
		HpwRewrite.AdminOnly[name] = val
		
		net.Start("hpwrewrite_clAdm")
			net.WriteString(name)
			net.WriteBit(val)
		net.Broadcast()
	end
	
	function HpwRewrite:CleanEverything()
		table.Empty(self.AdminOnly)
		table.Empty(self.Blacklist)

		for k, v in pairs(player.GetAll()) do 
			self:EmptyTables(v)
			table.Empty(self.SpellCache)

			self:UpdatePlayerInfo(v)
		end
	end

	function HpwRewrite:SaveToCache(ply, spell)
		local cache = self.SpellCache
		if not cache[ply] then cache[ply] = { } end

		if cache[ply][spell.Name] then cache[ply][spell.Name] = nil end
		cache[ply][spell.Name] = spell

		self:LogDebug("Saving to cache " .. spell.Name .. " for " .. ply:Name())
	end

	function HpwRewrite:RemoveFromCache(ply, spell)
		if self.SpellCache[ply] and self.SpellCache[ply][spell] then
			self.SpellCache[ply][spell] = nil
		end
	end

	function HpwRewrite:LoadFromCache(ply, name)
		local cache = self.SpellCache
		if not cache[ply] then cache[ply] = { } end

		local valRet = cache[ply][name]
		if valRet then self:LogDebug("Loading from cache " .. name .. " for " .. ply:Name()) end

		return valRet
	end

	function HpwRewrite:SetDefaultSkin(name)
		if not self:GetSkin(name) then return end

		self:LogDebug("Changing default skin to " .. name .. "...")

		local data, path = self.DM:ReadConfig()
		if not data then return end

		data.DefaultSkin = name

		if table.HasValue(data.Blacklist, name) then 
			WriteToBlacklist(name, false) 
			table.RemoveByValue(data.Blacklist, name)
		end

		file.Write(path, util.TableToJSON(data))

		self.DefaultSkin = name

		net.Start("hpwrewrite_DefSkin")
			net.WriteString(name)
		net.Broadcast()

		for k, v in pairs(player.GetAll()) do
			self:EmptyTables(v)
			self:LoadSpells(v)

			self:DoNotify(v, name .. " has been set as default skin!")
		end
	end

	-- This function looks for player's wand and removes current spell/skin if player cannot use it
	function HpwRewrite:CheckSpellUseable(ply, name)
		local wep = self:GetWand(ply)
		if wep:IsValid() then return wep:CheckSpellUseable(name) end

		return false
	end

	-- Removes or adds to blacklist
	-- Blacklist means that player cannot use spell at all
	-- He only can learn it but nothing more
	function HpwRewrite:SpellToBlacklist(name)
		local data, path = self.DM:ReadConfig()
		if not data then return end

		local val = true

		if not table.HasValue(data.Blacklist, name) then
			-- We can't add default skin to something restricted
			if name == self.DefaultSkin then return end

			WriteToBlacklist(name, true)
			table.insert(data.Blacklist, name)

			for k, v in pairs(player.GetAll()) do self:CheckSpellUseable(v, name) end

			self:LogDebug(name .. " has been added to blacklist")
		else
			WriteToBlacklist(name, false)
			table.RemoveByValue(data.Blacklist, name)
			val = false

			self:LogDebug(name .. " has been removed from blacklist")
		end

		file.Write(path, util.TableToJSON(data))

		return true, val
	end

	-- Removes or adds to adminonly
	-- Adminonly means that player cannot spawn spell book
	-- But he can learn adminonly spell and use it
	function HpwRewrite:SpellToAdminOnly(name)
		local data, path = self.DM:ReadConfig()
		if not data then return end

		local val = true

		if not table.HasValue(data.AdminOnly, name) then
			WriteToAdminOnly(name, true)
			table.insert(data.AdminOnly, name)

			self:LogDebug(name .. " has been added to adminonly")
		else
			WriteToAdminOnly(name, false)
			table.RemoveByValue(data.AdminOnly, name)
			val = false

			self:LogDebug(name .. " has been removed from adminonly")
		end

		file.Write(path, util.TableToJSON(data))

		return val
	end

	-- Data fast access functions
	function HpwRewrite:WriteSpell(ply, name)
		local data, filename = self.DM:LoadDataFile(ply)
		if not data then return end

		if not table.HasValue(data.Spells, name) then 
			table.insert(data.Spells, name) 
			file.Write(filename, util.TableToJSON(data))
		end

		return data, filename
	end

	function HpwRewrite:EraseSpell(ply, name)
		local data, filename = self.DM:LoadDataFile(ply)
		if not data then return end

		if table.HasValue(data.Spells, name) then
			table.RemoveByValue(data.Spells, name)
			file.Write(filename, util.TableToJSON(data))
		end

		return data, filename
	end

	function HpwRewrite:WriteLearnableSpell(ply, name)
		local data, filename = self.DM:LoadDataFile(ply)
		if not data then return end

		if not table.HasValue(data.LearnableSpells, name) then 
			table.insert(data.LearnableSpells, name) 
			file.Write(filename, util.TableToJSON(data))
		end

		return data, filename
	end

	function HpwRewrite:EraseLearnableSpell(ply, name)
		local data, filename = self.DM:LoadDataFile(ply)
		if not data then return end

		if table.HasValue(data.LearnableSpells, name) then
			table.RemoveByValue(data.LearnableSpells, name)
			file.Write(filename, util.TableToJSON(data))
		end

		return data, filename
	end

	function HpwRewrite:EraseDataFile(ply)
		local data, filename = self.DM:LoadDataFile(ply)

		if data then
			table.Empty(data.Spells)
			table.Empty(data.LearnableSpells)

			file.Write(filename, util.TableToJSON(data))
		end

		return data, filename
	end

	-- Gives learnable spell and saves it in data file
	function HpwRewrite:PlayerGiveLearnableSpell(ply, name, skipskin)
		if self:PlayerHasSpell(ply, name) then return false, Format(HpwRewrite.Language:GetWord("#alreadyhavespell"), name) end

		local spell = self:GetSpell(name)
		if not spell then return end

		if spell.SecretSpell then
			return false, HpwRewrite.Language:GetWord("#cantlearnsecret")
		end

		if spell.IsSkin and skipskin then return false, "" end

		if (spell.IsSkin and not spell.ShouldLearn) or spell.InstantLearn or spell.LearnTime == 0 then
			return HpwRewrite:SaveAndGiveSpell(ply, name)
		end

		if self:PlayerHasLearnableSpell(ply, name) then 
			return false, Format(HpwRewrite.Language:GetWord("#alreadyhavebook"), name) 
		end

		self:LogDebug("Giving learnable " .. name .. " to " .. ply:Name())

		net.Start("hpwrewrite_SplA")
			--net.WriteString(name)
			net.WriteUInt(spell.UniqueID, 9)
		net.Send(ply)

		self:GetLearnableSpells(ply)[name] = spell.New(ply)
		local data, filename = self:WriteLearnableSpell(ply, name)

		return data, filename
	end

	-- Removes learnable spell also removes it from data file
	function HpwRewrite:PlayerRemoveLearnableSpell(ply, name)
		if not self:PlayerHasLearnableSpell(ply, name) then return end

		self:LogDebug("Removing learnable " .. name .. " from " .. ply:Name())

		local spell = self:GetLearnableSpells(ply)[name]

		net.Start("hpwrewrite_SplR")
			--net.WriteString(name)
			net.WriteUInt(spell.UniqueID, 9)
		net.Send(ply)

		self:GetLearnableSpells(ply)[name] = nil
		local data, filename = self:EraseLearnableSpell(ply, name)

		return data, filename
	end

	-- Gives spell to current session
	-- copy is table we should copy
	-- forceadd will skip every check, its necessary for default skins
	function HpwRewrite:PlayerGiveSpell(ply, name, copy, forceadd, shouldCopy_force)
		if self:PlayerHasSpell(ply, name) then return end

		local shouldCopy = true

		if not copy then
			copy = self:LoadFromCache(ply, name)
			shouldCopy = false

			if not copy then 
				copy = self:GetSpell(name) 
				shouldCopy = true
			end

			if not copy then return end
		end

		if shouldCopy_force == nil then shouldCopy_force = true end

		if shouldCopy and shouldCopy_force then
			copy = copy.New(ply)
		end

		-- TODO: replace this check somehow
		if not copy:OnSpellGiven(ply) then 
			if not forceadd then return end
		end

		self:LogDebug("Giving " .. name .. " to " .. ply:Name())

		if not copy.IsSkin and copy.ShouldCount then
			if not ply.HpwRewrite.NumOfSpells then ply.HpwRewrite.NumOfSpells = 0 end
			ply.HpwRewrite.NumOfSpells = ply.HpwRewrite.NumOfSpells + 1
		end

		net.Start("hpwrewrite_SpA")
			--net.WriteString(name)
			net.WriteUInt(copy.UniqueID, 9)
		net.Send(ply)

		self:GetLearnedSpells(ply)[name] = copy
	end

	-- Removes spell from current session
	function HpwRewrite:PlayerRemoveSpell(ply, name, skipNet)
		if not skipNet then
			self:LogDebug("Removing " .. name .. " from " .. ply:Name()) -- Not net, but skiping too...

			local wep = self:GetWand(ply)
			if wep:IsValid() then
				if wep:GetWandCurrentSkin() == name then wep:HPWSetWandSkin(self.DefaultSkin) end
				if wep:GetWandCurrentSpell() == name then wep:HPWRemoveCurSpell() end
			end
		end

		local spell = self:GetPlayerSpell(ply, name)
		if not spell then return end

		if not spell.IsSkin and spell.ShouldCount then
			if not ply.HpwRewrite.NumOfSpells then ply.HpwRewrite.NumOfSpells = 0 end
			ply.HpwRewrite.NumOfSpells = ply.HpwRewrite.NumOfSpells - 1
		end

		spell:OnSpellRemoved(ply)

		self:SaveToCache(ply, spell)

		if not skipNet then
			net.Start("hpwrewrite_SpR")
				--net.WriteString(name)
				net.WriteUInt(spell.UniqueID, 9)
			net.Send(ply)
		end

		self:GetLearnedSpells(ply)[name] = nil
	end

	-- Removes from learned spells completely
	function HpwRewrite:PlayerUnlearnSpell(ply, name)
		local data, filename = self:EraseSpell(ply, name)
		self:PlayerRemoveSpell(ply, name)
		self:RemoveFromCache(ply, name)

		return data, filename
	end

	-- Deletes spell from player
	function HpwRewrite:PlayerDeleteSpell(ply, name)
		local data, filename = self:PlayerUnlearnSpell(ply, name)
		self:PlayerRemoveLearnableSpell(ply, name)

		return data, filename
	end

	-- Completely deletes everything
	function HpwRewrite:DeletePlayerSpells(ply)
		local data, filename = self:EraseDataFile(ply)
		self:EmptyTables(ply)

		self.SpellCache[ply] = nil

		return data, filename
	end

	-- Gives spell and saves it in data file
	function HpwRewrite:SaveAndGiveSpell(ply, name, skiptree)
		if self:PlayerHasSpell(ply, name) then return end

		local shouldCopy = false
		local spell = self:GetPlayerLearnableSpell(ply, name)

		if not spell then 
			spell = self:GetSpell(name) 
			shouldCopy = true 
		end

		if not spell then return end

		if shouldCopy then
			spell = spell.New(ply)
		end

		if not skiptree and not CheckLearned(ply, spell) then spell = nil return end
		if not spell:OnStartLearn(ply) then spell = nil return end
		if not spell:OnPreLearn(ply) then spell = nil return end

		-- Stop learning it
		if name == ply.HpwRewrite.LearningSpellName then self:PlayerStopLearning(ply) end

		self:LogDebug("Saving and giving " .. name .. " to " .. ply:Name())

		local data, filename = self:WriteSpell(ply, name)
		self:PlayerGiveSpell(ply, name, spell, false, false)
		self:PlayerRemoveLearnableSpell(ply, name)

		spell:OnPostLearn(ply)
		hook.Run("HPW_SpellLearned", ply, spell)

		return data, filename
	end

	-- Similar to SaveAndGiveSpell() but with timer
	-- Learn spell if player has it in learnable list
	function HpwRewrite:PlayerStartLearning(ply, name)
		if self.CVars.NoLearning:GetBool() then return end

		self:LogDebug(ply:Name() .. " attempts to learn " .. name)

		if self:PlayerHasSpell(ply, name) then self:DoNotify(ply, Format(HpwRewrite.Language:GetWord("#alreadyhavespell"), name)) return end
		if ply.HpwRewrite.AlreadyLearning then return end

		local spell = self:GetPlayerLearnableSpell(ply, name)
		if not spell then return end

		if (spell.IsSkin and not spell.ShouldLearn) or spell.InstantLearn or spell.LearnTime == 0 or self.CVars.NoTimer:GetBool() then
			return self:SaveAndGiveSpell(ply, name)
		end

		spell.Owner = ply

		if not CheckLearned(ply, spell) then spell = nil return end
		if not spell:OnStartLearn(ply) then spell = nil return end

		ply.HpwRewrite.AlreadyLearning = true
		ply.HpwRewrite.LearningSpell = spell -- What we've started learning?
		ply.HpwRewrite.LearningSpellName = name

		-- Zzz...
		timer.Create("hpwrewrite_learnspell" .. ply:EntIndex(), spell.LearnTime, 1, function()
			if not IsValid(ply) then return end

			ply.HpwRewrite.AlreadyLearning = false
			ply.HpwRewrite.LearningSpell = nil
			ply.HpwRewrite.LearningSpellName = nil

			net.Start("hpwrewrite_LrnS")
				net.WriteBit(true)
			net.Send(ply)

			if not spell then return end

			if spell:OnPreLearn(ply) then
				self:WriteSpell(ply, name)
				self:PlayerGiveSpell(ply, name, spell, false, false)
				self:PlayerRemoveLearnableSpell(ply, name)

				spell:OnPostLearn(ply)
				hook.Run("HPW_SpellLearned", ply, spell)

				net.Start("hpwrewrite_Snd")
					net.WriteString("hpwrewrite/notify.wav")
				net.Send(ply)

				self:DoNotify(ply, Format(HpwRewrite.Language:GetWord("#justlearned"), name))

				self:LogDebug(ply:Name() .. " has learned " .. name)
			else
				self:DoNotify(ply, Format(HpwRewrite.Language:GetWord("#faillearning"), name), 1)
				self:LogDebug(ply:Name() .. " failed learning " .. name)
				spell = nil
			end
		end)

		net.Start("hpwrewrite_Lrn")
			--net.WriteString(name)
			net.WriteUInt(spell.UniqueID, 9)
		net.Send(ply)

		-- We've started learning successfully
		return true
	end

	-- Stops learning process if exists
	function HpwRewrite:PlayerStopLearning(ply)
		if not ply.HpwRewrite.AlreadyLearning then return end

		local spell = ply.HpwRewrite.LearningSpell
		if spell then spell:OnStopLearn(ply) end

		timer.Remove("hpwrewrite_learnspell" .. ply:EntIndex())

		ply.HpwRewrite.AlreadyLearning = false
		ply.HpwRewrite.LearningSpell = nil
		ply.HpwRewrite.LearningSpellName = nil
		spell = nil

		net.Start("hpwrewrite_LrnS")
			net.WriteBit(false)
		net.Send(ply)

		return true
	end

	-- Cleans current data state
	function HpwRewrite:EmptyTables(ply)
		net.Start("hpwrewrite_SpCl")
		net.Send(ply)

		for k, v in pairs(self:GetLearnedSpells(ply)) do 
			self:PlayerRemoveSpell(ply, k, true) -- Third param to skip useless net
		end

		table.Empty(self:GetLearnableSpells(ply))

		local wep = self:GetWand(ply)
		if wep:IsValid() then
			wep:HPWSetWandSkin(self.DefaultSkin)
			wep:HPWRemoveCurSpell()
		end

		if ply and ply.HpwRewrite then ply.HpwRewrite.NumOfSpells = 0 end

		self:LogDebug("Removed spells for current session for " .. ply:Name())
	end

	-- Sends blacklist/adminonly info
	function HpwRewrite:SendConfig(ply)
		for k, v in pairs(self.Blacklist) do
			net.Start("hpwrewrite_clBlack")
				net.WriteString(k)
				net.WriteBit(v)
			net.Send(ply)
		end

		for k, v in pairs(self.AdminOnly) do
			net.Start("hpwrewrite_clAdm")
				net.WriteString(k)
				net.WriteBit(v)
			net.Send(ply)
		end

		net.Start("hpwrewrite_DefSkin")
			net.WriteString(self.DefaultSkin)
		net.Send(ply)

		self:LogDebug("Sended config to " .. ply:Name())
	end

	function HpwRewrite:LoadSpells(ply)
		if self.CVars.NoLearning:GetBool() then
			self:LogDebug("Server has NoLearning option, giving all spells to " .. ply:Name())

			-- If server has no learning option we give all spells to player
			local spells = self:GetSpells()

			local data, filename = self.DM:LoadDataFile(ply)
			for k, v in pairs(spells) do
				if not (data and v.AbsoluteSecret and not table.HasValue(data.Spells, k)) then 
					self:PlayerGiveSpell(ply, k) 
				end
			end
		else
			self:LogDebug("Loading spells for " .. ply:Name())
			
			-- Giving spells from file
			local data, filename = self.DM:LoadDataFile(ply)
			if data then
				for k, v in pairs(data.Spells) do
					self:PlayerGiveSpell(ply, v)
				end

				for k, v in pairs(data.LearnableSpells) do
					self:PlayerGiveLearnableSpell(ply, v)
				end
			end

			for k, v in pairs(HpwRewrite:GetSpells()) do if v.AlwaysHave then self:PlayerGiveSpell(ply, k) end end
		end

		-- Removing from current spell
		local wep = self:GetWand(ply)
		if wep:IsValid() then
			if not self:PlayerHasSpell(ply, wep:GetWandCurrentSpell()) then wep:HPWRemoveCurSpell() end
			if not self:PlayerHasSpell(ply, wep:GetWandCurrentSkin()) then wep:HPWSetWandSkin(self.DefaultSkin) end
		end

		self:LogDebug("Loaded spells for " .. ply:Name())
	end

	function HpwRewrite:ReloadSpells(ply)
		self:EmptyTables(ply) -- Removing existing data
		self:LoadSpells(ply) 

		self:LogDebug(ply:Name() .. "'s spells have been reloaded!")
	end

	-- Updating players spells
	function HpwRewrite:UpdatePlayerInfo(ply)
		self:ReloadSpells(ply)
		self:SendConfig(ply) -- Sending blacklisted/adminonly spells to player

		self:LogDebug(ply:Name() .. "'s info has been updated")
	end

	-- Hooks, handlers
	hook.Add("PlayerInitialSpawn", "hpwrewrite_updatespells", function(ply)
		if not ply.HpwRewrite then 
			ply.HpwRewrite = { } 
			HpwRewrite:LogDebug(ply:Name() .. " HpwRewrite namespace has been initialized in hpwrewrite_updatespells hook")
		end

		-- Replaced with clientside auto request
		--HpwRewrite:UpdatePlayerInfo(ply)

		-- If we didn't receive client message (packet loss)
		timer.Simple(3, function()
			if IsValid(ply) then
				if not ply.HpwRewrite then
					ply.HpwRewrite = { }
					ErrorNoHalt("Table was initialized in checker timer")
				end

				if not ply.HpwRewrite.UpdatedSpells then
					HpwRewrite:UpdatePlayerInfo(ply)
				end
			end
		end)
	end)

	-- TODO: check if this hook is good
	hook.Add("PlayerDeath", "hpwrewrite_stoplearning", function(ply)
		HpwRewrite:PlayerStopLearning(ply)
	end)

	hook.Add("EntityRemoved", "hpwrewrite_cachesaver", function(ply)
		-- Prevent from bypassing some data stuff
		if ply and ply:IsPlayer() then HpwRewrite:EmptyTables(ply) end
	end)

	hook.Add("HPW_SpellLearned", "hpwrewrite_congratulations", function(ply, spell)
		if spell.ShouldCount and not spell.IsSkin and HpwRewrite:SkillLevel(ply) >= 1 then
			net.Start("hpwrewrite_Congrats2")
			net.Send(ply)
		end
	end)

	-- I hope this is useless
	timer.Create("HpwRewrite_CheckTabs", 3, 2, function()
		local changed = false

		for k, v in pairs(player.GetAll()) do
			if not v.HpwRewrite then 
				v.HpwRewrite = { } 
				HpwRewrite:LogDebug("WARNING !!! " .. v:Name() .. " HpwRewrite namespace has been initialized in HpwRewrite_CheckTabs timer")

				changed = true
			end
		end

		if changed then
			for k, v in pairs(player.GetAll()) do
				if HpwRewrite.CheckAdmin(v) then
					for i = 1, 3 do
						timer.Simple(i, function()
							HpwRewrite:DoNotify(v, "WARNING !!! Someone's HpwRewrite namespace has been initialized in checker", 1, 10 + i * 3)
						end)
					end

					HpwRewrite:DoNotify(v, "Harry Potter Wand might not work correctly !!!", 1, 24)
					HpwRewrite:DoNotify(v, "Trying to force 'hpwrewrite_sv_usesaver' CVar to 1 ...", 1, 24)
					HpwRewrite:DoNotify(v, "Please contact addon's developers", 1, 24)
				end
			end

			-- game.ConsoleCommand("hpwrewrite_sv_usesaver 1\n")
			RunConsoleCommand("hpwrewrite_sv_usesaver", "1")
		end
	end)
end

