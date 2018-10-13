if not HpwRewrite then return end

if SERVER then return end
if not HpwRewrite.BM then return end

HpwRewrite.VGUI = HpwRewrite.VGUI or { }

local infohelp

local WindowColor = Color(80, 80, 80)

local PlayerSpells = { }
local PlayerLSpells = { }
local ReceivedInfo = false
net.Receive("hpwrewrite_GivI", function()
	table.Empty(PlayerSpells)
	table.Empty(PlayerLSpells)

	local lrn = net.ReadString()
	local lrnbl = net.ReadString()

	if lrn and lrn != "" then PlayerSpells = string.Explode("%", lrn) end
	if lrnbl and lrnbl != "" then PlayerLSpells = string.Explode("%", lrnbl) end

	ReceivedInfo = true
end)

local SpellLearning = false
local progress = 0

hook.Add("Think", "hpwrewrite_progressbarhandler", function()
	if SpellLearning != HpwRewrite.Learning then
		SpellLearning = HpwRewrite.Learning
		if not SpellLearning then progress = 0 end
	end

	if SpellLearning then
		if HpwRewrite.LearningSpell then
			progress = math.Approach(progress, HpwRewrite.LearningSpell.LearnTime, FrameTime())
		end
	end
end)

local cross = Material("vgui/hpwrewrite/cross")
function HpwRewrite.VGUI:CreateWindow(w, h, vis)
	local win = vgui.Create("DFrame")
	win:SetSize(w, h)
	win:Center()
	win:SetTitle("")
	win:ShowCloseButton(false)
	win:MakePopup()

	win.Paint = function(self, w, h)
		draw.RoundedBox(0, 0, 0, w, h, WindowColor)
		draw.RoundedBox(0, 0, 0, w, 25, HpwRewrite.Colors.DarkGrey)
	end

	win.PaintOver = function(self, w, h)
		surface.SetDrawColor(HpwRewrite.Colors.DarkGrey)
		surface.DrawOutlinedRect(0, 0, w, h)
	end
	
	win.OnCloseButton = function(self) end

	local old = win.Close
	win.Close = function(win)
		win:OnCloseButton()
		if vis then
			RememberCursorPosition()
			win:SetVisible(false)
		else
			old(win)
		end
	end

	win.SetupCloseButton = function(win) 
		if IsValid(win.CloseBtn) then 
			win.CloseBtn:SetPos(win:GetWide() - 25, 0)
			return
		end

		local close = self:CreateButton("", win:GetWide() - 25, 0, 25, 25, win, function()
			win:Close()
		end)

		close.DoSound = false

		close.Paint = function(self, w, h)
			surface.SetMaterial(cross)
			surface.SetDrawColor(HpwRewrite.Colors.White)
			surface.DrawTexturedRect(0, 0, w, h)
		end

		win.CloseBtn = close
	end

	win:SetupCloseButton()

	return win
end

function HpwRewrite.VGUI:CreateButton(text, x, y, w, h, win, func)
	local btn = vgui.Create("DButton", win)

	btn.EnterAlpha = 0
	btn.DoSound = true
	btn.DrawDiff = true
	btn.EnterColor = HpwRewrite.Colors.Blue

	btn.OnCursorEntered = function(self) 
		if self.DoSound then surface.PlaySound("hpwrewrite/enterbtn.wav") end 
		self.entered = true 
		self.EnterAlpha = 255
	end

	local old = btn.Think
	btn.Think = function(btn)
		if old then old(btn) end

		-- Preventing OnCursorExited bug
		local x, y = btn:LocalCursorPos()
		if btn.entered and not (x >= 0 and y >= 0 and x <= btn:GetWide() and y <= btn:GetTall()) then
			btn.entered = false
		end
	end

	btn.MainColor = HpwRewrite.Colors.DarkGrey2
	btn.Paint = function(self, w, h)
		local color = self.DrawDiff and (self.entered and self.EnterColor or self.MainColor) or self.MainColor
		draw.RoundedBox(0, 0, 0, w, h, self.MainColor)

		if self.DrawDiff then
			local col = self.EnterColor
			local color = Color(col.r, col.g, col.b, self.EnterAlpha)
			draw.RoundedBox(0, 0, 0, w, h, color)

			if not self.entered then
				self.EnterAlpha = math.Approach(self.EnterAlpha, 0, RealFrameTime() * 4000)
			end
		end

		draw.RoundedBox(0, 0, 0, w, h*0.4, Color(255, 255, 255, 1))
	end

	func = func or function() end
	btn.DoClick = function(self)
		surface.PlaySound("hpwrewrite/clickbtn.wav")
		func(self)
	end

	btn:SetText(text)
	btn:SetFont("HPW_gui1")
	btn:SetPos(x, y)
	btn:SetSize(w, h)
	btn:SetColor(HpwRewrite.Colors.White)

	return btn
end

local arrow = Material("vgui/hpwrewrite/arrow")
function HpwRewrite.VGUI:CreateScrollPanel(x, y, w, h, parent)
	parent = parent or self.Window
	if not IsValid(parent) then return end

	local panel = vgui.Create("DScrollPanel", parent)
	panel:SetPos(x, y)
	panel:SetSize(w, h)

	local bar = panel:GetVBar()
	bar:SetWide(14)

	local wval = 14
	local Entered = false

	bar.Paint = function(self, w, h)
		draw.RoundedBox(0, w - wval, 0, wval, h, Color(20, 20, 20, (wval - 7) * 5))
	end

	bar.btnUp.Paint = function(self, w, h)
		surface.SetMaterial(arrow)
		surface.SetDrawColor(HpwRewrite.Colors.White)
		surface.DrawTexturedRectRotated(w - wval + wval * 0.5, h * 0.5, 7, 7, 90)
	end

	bar.btnDown.Paint = function(self, w, h)
		surface.SetMaterial(arrow)
		surface.SetDrawColor(HpwRewrite.Colors.White)
		surface.DrawTexturedRectRotated(w - wval + wval * 0.5, h * 0.5, 7, 7, -90)
	end

	local old = bar.Think
	bar.Think = function(self)
		old(self)

		local w, h = self:GetWide(), self:GetTall()
		local x, y = self:LocalCursorPos()

		Entered = (x > 0 and x < w and y > 0 and y < h) or self.Dragging
		wval = math.Approach(wval, Entered and w or w * 0.5, RealFrameTime() * 120)
	end

	local color = Color(0, 0, 0, 150)
	bar.btnGrip.Paint = function(self, w, h)
		draw.RoundedBox(0, w - wval, 0, wval, h, color)
	end

	local old = panel.PerformLayout
	panel.PerformLayout = function(self, w, h)
		old(self, w, h)
		self.pnlCanvas:SetWide(self:GetWide())
	end

	panel.HPWColorDraw = HpwRewrite.Colors.DarkGrey
	panel.Paint = function(self, w, h)
		draw.RoundedBox(4, 0, 0, w, h, self.HPWColorDraw)
	end

	return panel
end

function HpwRewrite.VGUI:CreateSheet(x, y, w, h, parent)
	parent = parent or self.Window
	if not IsValid(parent) then return end

	local sheet = vgui.Create("DPropertySheet", parent)
	sheet.tabScroller:SetOverlap(-1)

	sheet.tabScroller.btnLeft.Paint = function(self, w, h) 
		surface.SetMaterial(arrow)
		surface.SetDrawColor(HpwRewrite.Colors.White)
		surface.DrawTexturedRectRotated(w / 2, h / 2, w, h, 180)
	end

	sheet.tabScroller.btnRight.Paint = function(self, w, h) 
		surface.SetMaterial(arrow)
		surface.SetDrawColor(HpwRewrite.Colors.White)
		surface.DrawTexturedRectRotated(w / 2, h / 2, w, h, 0)
	end

	local old = sheet.tabScroller.PerformLayout
	sheet.tabScroller.PerformLayout = function(self, w, h)
		old(self, w, h)

		self.btnRight:AlignBottom(12)
		self.btnLeft:AlignBottom(12)
	end

	sheet.tabScroller:DockMargin(0, 0, 0, 0)

	sheet:SetPos(x, y)
	sheet:SetSize(w, h)
	sheet:SetShowIcons(false)

	return sheet
end

function HpwRewrite.VGUI:SetupSheetDrawing(sheet, activecolor)
	local sizes = 0
	activecolor = activecolor or WindowColor
	local innactivecolor = Color(activecolor.r * 1.1, activecolor.g * 1.1, activecolor.b * 1.1)

	for k, v in pairs(sheet.Items) do
		v.Tab.Paint = function(self, w, h)
			local color = self.Active and activecolor or HpwRewrite.Colors.DarkGrey2
			if self.entered and not self.Active then color = innactivecolor end
			h = h - 6
			draw.RoundedBox(0, 0, 0, w, h, color)
		end

		v.Tab.OnCursorEntered = function(self) surface.PlaySound("hpwrewrite/enterbtn.wav") self.entered = true end
		v.Tab.OnCursorExited = function(self) self.entered = false end

		local old = v.Tab.DoClick
		v.Tab.DoClick = function(self)
			surface.PlaySound("hpwrewrite/clickbtn.wav") 
			old(self)
		end

		v.Tab:SetFont("HPW_gui1")

		local w, h = v.Tab:GetContentSize()
		v.Tab:SetSize(w + 10, h + 18)

		v.Tab.ApplySchemeSettings = function(self)
			self.Active = self:GetPropertySheet():GetActiveTab() == self
			self:SetColor((self.Active and activecolor == HpwRewrite.Colors.White) and HpwRewrite.Colors.DarkGrey2 or HpwRewrite.Colors.White)
		end

		local old = v.Tab.PerformLayout
		v.Tab.PerformLayout = function(self, w, h)
			old(self, w, h)

			if self.Image then
				self.Image:SetPos(5, 4)
			end
		end

		v.Panel:SetPos(sheet:GetPadding(), 28 + sheet:GetPadding())
	end

	sheet.Paint = function(self, w, h)
		draw.RoundedBox(4, 0, 0, w, h, activecolor)
		draw.RoundedBox(0, 0, 0, w, 28, HpwRewrite.Colors.DarkGrey)
	end
end

function HpwRewrite.VGUI:CreateLabel(text, x, y, parent)
	parent = parent or self.Window
	if not IsValid(parent) then return end

	local lab = vgui.Create("DLabel", parent)
	lab:SetPos(x, y)
	lab:SetText(text)
	lab:SetFont("HPW_gui1")
	lab:SizeToContents()
	lab:SetColor(HpwRewrite.Colors.White)

	return lab
end

--[[
function HpwRewrite.VGUI:OpenSwapMenu(name)
	HpwRewrite.BM:LoadBinds(name)

	local Dragging
	local Waiting

	local PosX = 0
	local PosY = 0

	local x = 5
	local y = 29
	local w, h = 86, 86

	local win = self:CreateWindow(w * 9.7, h * 1.6)
	win:SetTitle("Swap menu. Drag'n'Drop spells to change their positions")
	win.lblTitle:SetFont("HPW_gui1")

	local panels = { }

	local function Load()
		for k, v in pairs(panels) do if IsValid(v) then v:Remove() end end
		table.Empty(panels)

		for i = 1, 9 do
			local x = x + (i - 1) * (w + 4)

			local p = vgui.Create("Panel", win)
			p:SetPos(x, y)
			p:SetSize(w+16, h+16)

			p.Index = i
			p.Bind = HpwRewrite.BM.Binds[i]

			local shift = 10
			
			p.Paint = function() end
			p.PaintOver = function(p)
				local spell, key

				if p.Bind then
					spell = p.Bind.Spell
					key = p.Bind.Key
				end

				HpwRewrite:DrawSpellRect(spell, key, 8, 8, w, h)
				
				local w = w - 4
				local h = h - 4
				
				local color

				if p == Dragging then
					color = Color(0, 0, 0, 200)
				end

				if Dragging and Waiting == p.Index then
					color = Color(0, 255, 0, 100)
				elseif Waiting == p.Index then
					color = Color(0, 155, 255, 100)
				end
				
				if color then 
					draw.RoundedBox(6, shift, shift, w, h, color) 
				end
			end
			
			if p.Bind then
				p.OnMousePressed = function(p, ms)
					if ms == 107 then 
						Dragging = p 
						PosX, PosY = p:LocalCursorPos()
					end
				end
			end

			p.OnCursorEntered = function(p)
				Waiting = p.Index
			end

			p.OnCursorExited = function(p)
				Waiting = nil
			end

			table.insert(panels, p)
		end
	end

	Load()

	hook.Add("DrawOverlay", "hpwrewrite_dragndrophandler", function()
		if not IsValid(win) then hook.Remove("DrawOverlay", "hpwrewrite_dragndrophandler") return end

		if Dragging then
			local x, y = gui.MouseX(), gui.MouseY()
			x = x - PosX
			y = y - PosY

			HpwRewrite:DrawSpellRect(Dragging.Bind.Spell, Dragging.Bind.Key, x, y, w, h)
		end
	end)

	win.OnCloseButton = function() hook.Remove("DrawOverlay", "hpwrewrite_dragndrophandler") end

	local oldThink = win.Think
	win.Think = function(win)
		oldThink(win)

		if Dragging then
			if not input.IsMouseDown(107) then 
				if Waiting then
					HpwRewrite.BM:MoveBindTo(Dragging.Index, Waiting, name)
					Load()
				end

				Dragging = nil 
			end
		end
	end
end]]

local options = {
	["Give and don't save to player's data file"] = function(ply, spell)
		net.Start("hpwrewrite_AdminFunctions")
			net.WriteUInt(2, 5)
			net.WriteString(spell)
			net.WriteEntity(ply)
		net.SendToServer()
	end,

	["Give and save to player's data file"] = function(ply, spell)
		net.Start("hpwrewrite_AdminFunctions")
			net.WriteUInt(3, 5)
			net.WriteString(spell)
			net.WriteEntity(ply)
		net.SendToServer()
	end,

	["Give to player's learnable spells"] = function(ply, spell)
		net.Start("hpwrewrite_AdminFunctions")
			net.WriteUInt(4, 5)
			net.WriteString(spell)
			net.WriteEntity(ply)
		net.SendToServer()
	end
}

local options2 = {
	["Who has this? (From current session)"] = function(spell)
		net.Start("hpwrewrite_AdminFunctions")
			net.WriteUInt(5, 5)
			net.WriteString(spell)
		net.SendToServer()
	end,

	["Who has this? (From data files)"] = function(spell)
		net.Start("hpwrewrite_AdminFunctions")
			net.WriteUInt(6, 5)
			net.WriteString(spell)
		net.SendToServer()
	end,

	["Unlearn from everyone"] = function(spell)
		net.Start("hpwrewrite_AdminFunctions")
			net.WriteUInt(7, 5)
			net.WriteString(spell)
		net.SendToServer()
	end
}




----------------------
-- Main window code --
----------------------

local rememberSpell, rembemberTab
local closedTabs = { }

-- wont use any database table
local fName = "hpwrewrite/client/closedtabs.txt"
if not file.Exists(fName, "DATA") then
	file.Write(fName, "")
else
	local tabs = string.Explode("¤", file.Read(fName))
	if tabs then 
		for k, v in pairs(tabs) do
			closedTabs[v] = true
		end
	end
end

-- Saving closed spell categories tabs to not annoy player next game
hook.Add("ShutDown", "hpwrewrite_saveclosedtabs", function()
	local data = ""
	if next(closedTabs) != nil then for k, v in pairs(closedTabs) do if v then data = data .. "¤" .. k end end end
	file.Write(fName, data)
end)

local function GetTime(total)
	local hours = math.floor(total / 3600)
	local mins = math.floor(total / 60 % 60)
	local seconds = math.floor(total % 60)

	return Format("%02d:%02d:%02d", hours, mins, seconds)
end

function HpwRewrite.VGUI:UpdateVgui()
	if IsValid(self.Window) then
		self.Window:Close()
		self.Window = nil
	end
end

local gradient = Material("gui/center_gradient")
local sheetWidth = 572

local function yesno(bool) 
	return bool and HpwRewrite.Language:GetWord("#yes") or HpwRewrite.Language:GetWord("#no") 
end

function HpwRewrite.VGUI:OpenNewSpellManager()
	if IsValid(self.Window) then 
		self.Window:SetVisible(true)
		RestoreCursorPosition()

		return self.Window
	end

	local win = self:CreateWindow(816, 600, true)
	self.Window = win

	local old = win.Paint
	win.Paint = function(self, w, h)
		old(self, w, h)
		surface.SetDrawColor(HpwRewrite.Colors.DarkGrey)

		local x = w - 228
		surface.DrawLine(x, 0, x, h) -- Separating line
	end

	local desc = self:CreateScrollPanel(597, 33, 210, 559, win) -- That right info panel
	local sheet = self:CreateSheet(0, 25, 588, 575)

	win.SpellWindow = desc
	win.Sheet = sheet

	--[[local old = win.PerformLayout
	win.PerformLayout = function(win, w, h)
		win.Sheet:SetSize(w - 212, h - 25)

		win.SpellWindow:SetPos(w - 203, 33)
		win.SpellWindow:SetSize(195, h - 41)

		win.ProgressBar:SetSize(w - 25, 24)

		win:SetupCloseButton()
	end]]

	sheet:SetFadeTime(0)

	-- Spell learning aka skillz progress bar
	do
		local bar = vgui.Create("DProgress", win)
		bar:SetPos(0, 0)
		bar:SetSize(784, 24)

		win.ProgressBar = bar

		local text = HpwRewrite.Language:GetWord("#progress")
		local lab = self:CreateLabel(text .. "0%", 10, 4, bar)

		bar.Think = function(self)
			local fr = self:GetFraction()
			local skill = HpwRewrite:SkillLevel()

			if fr != skill then
				self:SetFraction(Lerp(RealFrameTime(), fr, skill))

				lab:SetText(text .. math.Round(fr * 100) .. "%")
				lab:SetColor(HpwRewrite.Colors.White)
				lab:SizeToContents()
			end
		end

		bar.Paint = function(self, w, h)
			draw.RoundedBox(0, 0, 0, w, h, HpwRewrite.Colors.DarkGrey2)
			draw.RoundedBox(0, 0, 0, (w - 1) * self:GetFraction(), h, HpwRewrite.Colors.Blue)
		end
	end

	local function AddSpells() end -- Prototype

	-- Creates info about some spell or skin
	local infopanel
	local function CreateInfoPanel(k)
		local spell = HpwRewrite:GetSpell(k)
		if not spell then return end

		rememberSpell = k

		if IsValid(infopanel) then infopanel:Remove() end

		infopanel = vgui.Create("DPanel", desc)
		infopanel.Paint = function() end

		local pos = 0

		local function createLab(text)
			pos = pos + 16
			return text != "" and self:CreateLabel(text, 10, pos, infopanel) or nil
		end

		local icon = HpwRewrite:GetSpellIcon(k)
		if not icon:IsError() then
			local img = icon:GetName()

			icon = vgui.Create("DImage", infopanel)
			icon:SetPos(16, 16)
			icon:SetImage(img)
			icon:SetSize(171, 171)

			local old = icon.Paint
			icon.Paint = function(self, w, h)
				old(self, w, h)

				-- Border
				surface.SetDrawColor(HpwRewrite.Colors.DarkGrey)
				surface.DrawOutlinedRect(0, 0, w, h)
			end

			pos = pos + 180
		end

		local spellName = createLab(k)
		spellName:SetColor(HpwRewrite.Colors.LightBlue)
		spellName:SetFont("HPW_fontSpells1")
		spellName:SizeToContents()

		if not HpwRewrite:PlayerHasSpell(nil, k) then
			createLab("")
			local text = (spell.IsSkin and HpwRewrite.Language:GetWord("#noskin") or HpwRewrite.Language:GetWord("#notlearned"))
			createLab(text):SetColor(HpwRewrite.Colors.Blue)
		else
			createLab("")
			local text = (spell.IsSkin and HpwRewrite.Language:GetWord("#haveskin") or HpwRewrite.Language:GetWord("#havelrndspell"))
			createLab(text):SetColor(HpwRewrite.Colors.LightBlue)
		end

		if HpwRewrite:PlayerHasLearnableSpell(nil, k) then
			createLab("")
			createLab(HpwRewrite.Language:GetWord("#havebook")):SetColor(HpwRewrite.Colors.Blue)

			if HpwRewrite:CanLearn(nil, k) then
				createLab(HpwRewrite.Language:GetWord("#readytolearn")):SetColor(HpwRewrite.Colors.Blue)
				createLab("")
			end
		end

		createLab("")

		local learninfo = HpwRewrite.Language:GetWord("#instantlrnbl")
		if spell.LearnTime != 0 and not spell.InstantLearn or (spell.IsSkin and spell.ShouldLearn) then
			learninfo = Format(HpwRewrite.Language:GetWord("#learntime"), GetTime(spell.LearnTime))
		end
		createLab(learninfo)

		-- Main info
		createLab("")

		-- TODO: parse long named categories
		if spell.Category then
			if istable(spell.Category) then
				createLab(HpwRewrite.Language:GetWord("#categories"))

				for k, v in pairs(spell.Category) do
					createLab("• " .. v)
				end
			else
				createLab(HpwRewrite.Language:GetWord("#category"))
				createLab("• " .. spell.Category)
			end

			createLab("")
		end

		createLab(HpwRewrite.Language:GetWord("#hasbook") .. yesno(spell.CreateEntity))
		if spell.CreateEntity then createLab(HpwRewrite.Language:GetWord("#bookinqmenu") .. yesno(spell.ShowInSpawnmenu)) end

		if spell.IsSkin then 
			createLab(HpwRewrite.Language:GetWord("#holdtype") .. spell.HoldType) 
		else 
			createLab(HpwRewrite.Language:GetWord("#isselfcastable") .. yesno(spell.CanSelfCast))
			if spell.CanSelfCast then
				createLab(HpwRewrite.Language:GetWord("#reversedselfcast") .. yesno(spell.ShouldReverseSelfCast))
			end
			
			--createLab("Is unforgivable: " .. yesno(spell.Unforgivable)) 
			createLab(HpwRewrite.Language:GetWord("#accuracycost") .. spell.AccuracyDecreaseVal * 100 .. "%")
		end

		if spell.Description != "" then
			createLab("")
			createLab(HpwRewrite.Language:GetWord("#description")):SetColor(HpwRewrite.Colors.Blue)
			
			local str = string.Explode("\n", spell.Description)
			for i = 1, #str - 1 do
				if str[i] then createLab(str[i]) end
			end
		end

		if spell.IsSkin then
			local names = { }

			for k, v in pairs(HpwRewrite:GetSpells()) do
				if v.OnlyWithSkin and table.HasValue(v.OnlyWithSkin, spell.Name) then
					table.insert(names, v.Name)
				end
			end

			if #names > 0 then
				createLab("")
				createLab(HpwRewrite.Language:GetWord("#exclusive")):SetColor(HpwRewrite.Colors.Blue)

				for k, v in pairs(names) do createLab(v) end
			end
		end

		if spell.SecretSpell then
			createLab("")
			createLab(HpwRewrite.Language:GetWord("#secretspell")):SetColor(HpwRewrite.Colors.Blue)
			createLab("")
		end

		-- RESTRICTIOOONS 

		if spell.OnlyWithSkin then
			createLab("")
			createLab(HpwRewrite.Language:GetWord("#onlyavailable")):SetColor(HpwRewrite.Colors.Blue)
			for k, v in pairs(spell.OnlyWithSkin) do createLab(v) end
		end

		if spell.OnlyIfLearned then
			createLab("")
			createLab(HpwRewrite.Language:GetWord("#requiredknowldg")):SetColor(HpwRewrite.Colors.Blue)

			for k, v in pairs(spell.OnlyIfLearned) do
				local reqS = createLab(v)
				local w, h = reqS:GetContentSize()
				local has = HpwRewrite:PlayerHasSpell(nil, v)
				self:CreateLabel(has and "✓" or "✘", w + 14, pos, infopanel):SetColor(has and HpwRewrite.Colors.Green or HpwRewrite.Colors.Red)
			end
		end

		if HpwRewrite:IsSpellInBlacklist(k) then
			createLab("")
			createLab(HpwRewrite.Language:GetWord("#blacklisted")):SetColor(HpwRewrite.Colors.Blue)
			createLab("")
		end

		pos = pos + 32

		local exists = HpwRewrite.FavouriteSpells[k]
		local removeFav = HpwRewrite.Language:GetWord("#removefav")
		local addFav = HpwRewrite.Language:GetWord("#addtofav")

		local btn = self:CreateButton(exists and removeFav or addFav, 10, pos, 183, 25, infopanel, function(btn)
			if exists then
				HpwRewrite.DM:RemoveFromFavourites(k)
				exists = false
				btn:SetText(addFav)
			else
				HpwRewrite.DM:AddToFavourites(k)
				exists = true
				btn:SetText(removeFav)
			end

			AddSpells()
		end)

		if HpwRewrite:PlayerHasLearnableSpell(nil, k) then
			pos = pos + 26
			local btn = self:CreateButton(HpwRewrite.Language:GetWord("#startlrn"), 10, pos, 183, 25, infopanel, function()
				net.Start("hpwrewrite_LrnS")
					net.WriteString(k)
				net.SendToServer()
			end)
		end

		if HpwRewrite:PlayerHasSpell(nil, k) then
			pos = pos + 26

			local btn = self:CreateButton(HpwRewrite.Language:GetWord("#use"), 10, pos, 183, 25, infopanel, function()
				HpwRewrite:RequestSpell(k)
			end)
		end

		pos = pos + 31
		local btn = self:CreateButton(HpwRewrite.Language:GetWord("#closepanel"), 10, pos, 183, 30, infopanel, function()
			infopanel:Remove()
		end)

		local col = HpwRewrite.Colors.Blue
		btn.MainColor = Color(col.r * 0.7, col.g * 0.7, col.b * 0.7)

		infopanel:SetSize(195, pos + 45)

		-- Looking for learning
		do
			local SpellLearning = false
			local p
			infopanel.Think = function()
				if SpellLearning != HpwRewrite.Learning then
					SpellLearning = HpwRewrite.Learning
					
					if SpellLearning then
						p = vgui.Create("DPanel", infopanel)
						p:SetPos(0, pos + 49)
						p:SetSize(195, 200)
						p.Paint = function() end

						local bar = vgui.Create("DProgress", p)
						bar:SetPos(10, 0)
						bar:SetSize(175, 25)

						bar.Think = function()
							local spell = HpwRewrite.LearningSpell

							if spell then
								local learntime = spell.LearnTime
								bar:SetFraction(progress / learntime)
							end
						end
						bar.Paint = function(self, w, h)
							draw.RoundedBox(0, 0, 0, w, h, HpwRewrite.Colors.DarkGrey2)
							draw.RoundedBox(0, 0, 0, w * self:GetFraction(), h, HpwRewrite.Colors.Blue)
						end

						local btn = self:CreateButton(HpwRewrite.Language:GetWord("#stoplrn"), 10, 35, 175, 25, p, function()
							net.Start("hpwrewrite_LrnSt")
							net.SendToServer()
						end)

						local lab = self:CreateLabel("", 10, 65, p)
						lab.Think = function()
							local spell = HpwRewrite.LearningSpell

							if spell and HpwRewrite.LearningSpellName and progress then
								local text = HpwRewrite.Language:GetWord("#learning") .. HpwRewrite.LearningSpellName .. " "
								local learntime = spell.LearnTime

								local timeleft = GetTime(math.Round((1 - bar:GetFraction()) * learntime))

								--local msg2 = "Don't die or exit from the\ngame while learning.\n"
								local msg1 = text .. math.Round((progress / learntime) * 100) .. "%\n" .. timeleft .. " left\n\n"
								local msg1 = Format(HpwRewrite.Language:GetWord("#learningmsg"), text, math.Round((progress / learntime) * 100), "%\n", timeleft)
								local msg2 = HpwRewrite.Language:GetWord("#warning")

								lab:SetText(msg1 .. msg2)
								lab:SizeToContents()
							end
						end

						infopanel:SetSize(195, pos + 216)
					else
						if IsValid(p) then 
							p:Remove() 
							infopanel:SetSize(195, pos + 30) 
						end
					end
				end
			end

			infopanel:Think()
		end
	end

	-- Adding tabs
	local newspells
	local spells
	local skins = self:CreateScrollPanel()

	local skinsButtons = { }

	AddSpells = function()
		-- Adding spell tree
		if not newspells then
			newspells = vgui.Create("HPWSpellTree", win)

			newspells.CatchClick = function(newspells, name)
				CreateInfoPanel(name)
				if HpwRewrite:CanUseSpell(LocalPlayer(), name) and HpwRewrite.CVars.CloseOnSelect:GetBool() then win:Close() end

				HpwRewrite:RequestSpell(name)
			end
		end

		if newspells.Added then newspells:Update() end
		newspells.Added = true

		-- Adding spells with categories
		if not spells then spells = self:CreateScrollPanel() end

		if spells.SpellCats then
			for k, v in pairs(spells.SpellCats) do
				if IsValid(v) then v:Remove() end
			end

			spells.SpellCats = nil
		end

		spells.SpellCats = { }

		local defaultSize = 30
		for k, v in SortedPairs(HpwRewrite:GetCategories()) do
			-- Adding spells to the category

			if not spells.SpellCats[k] then
				local spellCategory = vgui.Create("DPanel", spells)
				spellCategory.Paint = function() end
				spells.SpellCats[k] = spellCategory

				local btn = self:CreateButton(k, 0, 0, sheetWidth, defaultSize, spellCategory, function() 
					closedTabs[k] = not closedTabs[k]
					spellCategory.Hidden = closedTabs[k]
				end)

				btn.DoRightClick = btn.DoClick

				btn:SetFont("HPW_gui3")
				btn.MainColor = HpwRewrite.Colors.DarkGrey
				btn.EnterColor = HpwRewrite.Colors.DarkGrey3
				btn.DoSound = false

				local old = btn.Paint
				btn.Paint = function(btn, w, h)
					old(btn, w, h)
					surface.SetMaterial(gradient)
					surface.SetDrawColor(HpwRewrite.Colors.DarkGrey5)
					surface.DrawTexturedRect(0, 0, w, 1)
					surface.DrawTexturedRect(0, h - 1, w, 1)
				end

				spellCategory.MainButton = btn
				spellCategory.OtherButtons = { }

				local useless = { }
				local function getPos() return defaultSize + 1 + #spellCategory.OtherButtons * 25 end

				for a, b in SortedPairs(HpwRewrite:GetSpells()) do
					local cat = b.Category

					if type(cat) == "table" then
						if table.HasValue(cat, k) then cat = k else cat = nil end
					end
					
					if (cat == k and not b.IsSkin) or (k == HpwRewrite.Language:GetWord("#favcategory") and HpwRewrite.FavouriteSpells[a]) then
						if b.SecretSpell and not HpwRewrite:PlayerHasSpell(LocalPlayer(), a) then continue end
						if not HpwRewrite:CanUseSpell(LocalPlayer(), a) then
							useless[a] = true
							continue
						end

						local btn = self:CreateButton(a, 0, getPos(), sheetWidth, 24, spellCategory, function()
							if HpwRewrite.CVars.CloseOnSelect:GetBool() then win:Close() end
							CreateInfoPanel(a)
							HpwRewrite:RequestSpell(a)
						end)

						btn.DoRightClick = function()
							CreateInfoPanel(a)
						end

						--btn.DoSound = false

						table.insert(spellCategory.OtherButtons, btn)
					end
				end

				for a, b in SortedPairs(useless) do
					local btn = self:CreateButton(a, 0, getPos(), sheetWidth, 24, spellCategory, function() 
						CreateInfoPanel(a)
					end)

					local learn = HpwRewrite:PlayerHasLearnableSpell(LocalPlayer(), a)

					btn.DoRightClick = btn.DoClick
					btn:SetColor(Color(0, 0, 0, 220))
					btn.MainColor = learn and HpwRewrite.Colors.Green or HpwRewrite.Colors.DarkGrey5
					btn.EnterColor = Color(btn.MainColor.r * 1.1, btn.MainColor.g * 1.1, btn.MainColor.b * 1.1)
					btn.DoSound = false

					table.insert(spellCategory.OtherButtons, btn)
				end

				spellCategory.Hidden = closedTabs[k]
			end
		end

		spells.Think = function(spells)
			local w = spells:GetWide()

			for name, spellCategory in SortedPairs(spells.SpellCats) do
				local size = defaultSize+1
				local numBtns = #spellCategory.OtherButtons
				if not spellCategory.Hidden then size = size + numBtns * 25 end

				--local h = Lerp(RealFrameTime() * 12, spellCategory:GetTall(), size)
				local h
				if not spellCategory.LoadedSpells then
					h = size
					spellCategory.LoadedSpells = true
				else
					h = math.Approach(spellCategory:GetTall(), size, RealFrameTime() * 120 * numBtns)
				end

				spellCategory:SetSize(w, h)
				spellCategory:Dock(TOP)
			end
		end

		-- Updating skins
		for k, v in pairs(skinsButtons) do 
			if IsValid(v) then v:Remove() end
			skinsButtons[k] = nil
		end

		for k, v in SortedPairs(HpwRewrite:GetLearnedSpells()) do
			if not v then continue end -- i don't remember for what this is but ill leave it

			local skin = HpwRewrite:GetSkin(k)
			if not skin then continue end

			local btn = self:CreateButton("", 0, 0, sheetWidth, 60, skins, function()
				HpwRewrite:RequestSpell(k)
				CreateInfoPanel(k)
			end)

			btn:Dock(TOP)
			btn:DockMargin(0, 0, 0, 1)

			btn.DoRightClick = function()
				CreateInfoPanel(k)
			end

			local oldPaint = btn.Paint
			btn.Paint = function(self, w, h)
				oldPaint(self, w, h)

				local mat = HpwRewrite:GetSpellIcon(k)
				if not mat:IsError() then
					draw.RoundedBox(0, 5, 5, 50, 50, HpwRewrite.Colors.DarkGrey3)

					surface.SetMaterial(mat)
					surface.SetDrawColor(HpwRewrite.Colors.White)
					surface.DrawTexturedRect(6, 6, 48, 48)
				end

				draw.SimpleText(k, "HPW_gui2", w / 2, h / 2 - 16, HpwRewrite.Colors.White, TEXT_ALIGN_CENTER)
			end

			table.insert(skinsButtons, btn)
		end
	end

	AddSpells()

	-- Infopanel sheet
	local info = vgui.Create("DPanel", win)

	do
		info.Paint = function() end

		local sheet2 = self:CreateSheet(0, 0, sheetWidth, 530, info)

		local faq = self:CreateScrollPanel()
		local pos = 10

		-- F.A.Q
		if HpwRewrite.Manuals.FAQ then
			self:CreateLabel(HpwRewrite.Language:GetWord("#faq_msg1"), 10, pos, faq):SetColor(HpwRewrite.Colors.LightBlue)
			pos = pos + 50

			local btn = self:CreateButton(HpwRewrite.Language:GetWord("#bugsthread"), 415, 13, 120, 24, faq, function() gui.OpenURL("https://github.com/Ayditor/HPW_Rewrite/issues") end)
			local btn = self:CreateButton(HpwRewrite.Language:GetWord("#qathread"), 415, 38, 120, 24, faq, function() gui.OpenURL("http://steamcommunity.com/workshop/filedetails/discussion/875498456/135510393202106420") end)

			for k, v in pairs(HpwRewrite.Manuals.FAQ) do
				self:CreateLabel(string.rep("_", 75), 10, pos, faq):SetColor(HpwRewrite.Colors.DarkGrey3)
				pos = pos + 30

				self:CreateLabel("Q: ", 10, pos, faq):SetColor(Color(0, 150, 255))

				local question = string.Explode("\n", v.Q)
				for _, str in pairs(question) do
					self:CreateLabel(str, 30, pos, faq)
					pos = pos + 16
				end

				self:CreateLabel("A: ", 10, pos, faq):SetColor(Color(0, 150, 255))

				local answer = string.Explode("\n", v.A)
				for _, str in pairs(answer) do
					self:CreateLabel(str, 30, pos, faq)
					pos = pos + 16
				end

				pos = pos + 15
			end

			self:CreateLabel("", 10, pos, faq)
		end

		local help = self:CreateScrollPanel()

		-- Help buttons
		do
			local function createbtn(text, func)
				local btn = self:CreateButton(text, 0, 0, 565, 25, help, func)
				btn:Dock(TOP)
				btn:DockMargin(0, 0, 0, 1)

				return btn
			end

			local btn = createbtn(HpwRewrite.Language:GetWord("#updspells"), function()
				net.Start("hpwrewrite_ClientRequest")
					net.WriteUInt(4, 5)
				net.SendToServer()
			end)

			local btn = createbtn(HpwRewrite.Language:GetWord("#emptymyspells"), function()
				net.Start("hpwrewrite_ClientRequest")
					net.WriteUInt(2, 5)
				net.SendToServer()
			end)

			local btn = createbtn(HpwRewrite.Language:GetWord("#loadmyspells"), function()
				net.Start("hpwrewrite_ClientRequest")
					net.WriteUInt(5, 5)
				net.SendToServer()
			end)

			local btn = createbtn(HpwRewrite.Language:GetWord("#getconfig"), function()
				net.Start("hpwrewrite_ClientRequest")
					net.WriteUInt(1, 5)
				net.SendToServer()
			end)

			local name = HpwRewrite.Language:GetWord("#unlearnmyspells")
			local yes = HpwRewrite.Language:GetWord("#yes")
			local no = HpwRewrite.Language:GetWord("#no")
			local sure = HpwRewrite.Language:GetWord("#sure")
			local btn = createbtn(name, function()
				Derma_Query(sure, name, yes, function()
					net.Start("hpwrewrite_ClientRequest")
						net.WriteUInt(3, 5)
					net.SendToServer()
				end, no)
			end)

			local btn = createbtn(HpwRewrite.Language:GetWord("#learneverything"), function()
				net.Start("hpwrewrite_AdminFunctions")
					net.WriteUInt(14, 5)
				net.SendToServer()
			end)

			local btn = createbtn(HpwRewrite.Language:GetWord("#getdebug"), function()
				HpwRewrite.VGUI:OpenDebugInfoWindow()
			end)

			local btn = createbtn(HpwRewrite.Language:GetWord("#cleardebug"), function()
				RunConsoleCommand("hpwrewrite_cl_cleardebug")
			end)

			local btn = createbtn(HpwRewrite.Language:GetWord("#copycvars"), function()
				local text = ""

				HpwRewrite:LogDebug("Copying convar values to clipboard...")

				for k, v in pairs(HpwRewrite.CVars) do
					text = text .. v:GetName() .. " " .. v:GetString() .. "\n"
				end

				SetClipboardText(text)
			end)

			local name = HpwRewrite.Language:GetWord("#resetcvars")
			local sure2 = HpwRewrite.Language:GetWord("#sure2")
			local btn = createbtn(name, function()
				Derma_Query(sure2, name, yes, function()
					for k, v in pairs(HpwRewrite.CVars) do
						if string.find(v:GetName(), "hpwrewrite_cl") then
							RunConsoleCommand(v:GetName(), v:GetDefault())
						end
					end
				end, no)
			end)

			local btn = createbtn(HpwRewrite.Language:GetWord("#updwin"), function()
				self:UpdateVgui()
				self:OpenNewSpellManager()
			end)

			local btn = createbtn(HpwRewrite.Language:GetWord("#apidoc"), function()
				gui.OpenURL("https://github.com/Ayditor/HPW_Rewrite/wiki/Wand-API")
			end)
		end

		-- License, stuff
		local other = self:CreateScrollPanel()

		local pos = 10
		local lab = self:CreateLabel(HpwRewrite.Language:GetWord("#license"), 0, 0, other)
		lab:SetColor(HpwRewrite.Colors.LightBlue)
		lab:SetFont("HPW_gui2")
		lab:SizeToContents()
		lab:Dock(TOP)
		lab:DockMargin(10, 5, 0, 10)

		for k, v in pairs(string.Explode("\n", HpwRewrite.Manuals.License)) do
			local t = self:CreateLabel(v, 0, 0, other)
			t:Dock(TOP)
			t:DockMargin(10, 0, 0, 0)
		end

		-- Bugs
		local lab = self:CreateLabel(HpwRewrite.Language:GetWord("#knownbugs"), 0, 0, other)
		lab:SetColor(HpwRewrite.Colors.LightBlue)
		lab:SetFont("HPW_gui2")
		lab:SizeToContents()
		lab:Dock(TOP)
		lab:DockMargin(10, 5, 0, 10)

		for k, v in pairs(HpwRewrite.Manuals.KnownBugs) do
			local t = self:CreateLabel(Format("• %s", v), 0, 0, other)
			t:Dock(TOP)
			t:DockMargin(10, 0, 0, 0)
		end

		-- Contributors
		local lab = self:CreateLabel(HpwRewrite.Language:GetWord("#contributors"), 0, 0, other)
		lab:SetColor(HpwRewrite.Colors.LightBlue)
		lab:SetFont("HPW_gui2")
		lab:SizeToContents()
		lab:Dock(TOP)
		lab:DockMargin(10, 5, 0, 10)

		-- Don't remove this piece of code
		for k, v in SortedPairs(HpwRewrite.Manuals.Contributors) do
			local t = self:CreateButton(k, 0, 0, 100, 20, other, function()
				gui.OpenURL(v)
			end)

			t:Dock(TOP)
			t:DockMargin(0, 1, 0, 0)
		end

		-- Client settings
		local clientset = HpwRewrite.Language:GetWord("#clientsettings")
		local clientopt = self:CreateScrollPanel()
		clientopt:SetName(clientset)
		clientopt.HPWColorDraw = HpwRewrite.Colors.White

		local p = vgui.Create("ControlPanel", clientopt)
		HpwRewrite.VGUI.CreateClientOptions(p)

		local old = clientopt.PerformLayout
		clientopt.PerformLayout = function(self, w, h) 
			old(self, w, h) 
			p:SetSize(self:GetWide(), p:GetTall())
		end

		-- Server settings
		local serveropt
		local serverset = HpwRewrite.Language:GetWord("#serversettings")
		serveropt = self:CreateScrollPanel()
		serveropt:SetName(serverset)
		serveropt.HPWColorDraw = HpwRewrite.Colors.White

		local p = vgui.Create("ControlPanel", serveropt)
		HpwRewrite.VGUI.CreateServerOptions(p)

		local old = serveropt.PerformLayout
		serveropt.PerformLayout = function(self, w, h) 
			old(self, w, h) 
			p:SetSize(self:GetWide(), p:GetTall())
		end

		-- List of CVars
		local cvarList = self:CreateScrollPanel()
		local lab = self:CreateLabel(HpwRewrite.Language:GetWord("#helplistcvar"), 10, 10, cvarList)

		local count = 0
		local max = 1

		for k, v in pairs(HpwRewrite.CVars) do
			local len = string.len(k)
			if len > max then max = len end
		end

		for k, v in SortedPairs(HpwRewrite.CVars) do
			local lab = self:CreateLabel(Format("%s%s%s - %s", k, string.rep(" ", (max - string.len(k)) + 2), v:GetName(), v:GetString()), 10, 60 + (count * 16), cvarList)
			lab:SetFont("DebugFixed")
			lab:SizeToContents()

			count = count + 1
		end

		sheet2:AddSheet(HpwRewrite.Language:GetWord("#faq"), faq)--, "icon16/information.png")
		sheet2:AddSheet(HpwRewrite.Language:GetWord("#helpstuff"), help)--, "icon16/cog.png")
		sheet2:AddSheet(HpwRewrite.Language:GetWord("#maininfo"), other)--, "icon16/book.png")
		sheet2:AddSheet(clientset, clientopt)--, "icon16/cog_edit.png")
		if (HpwRewrite.CheckAdmin(LocalPlayer())) then
			sheet2:AddSheet(serverset, serveropt)--, "icon16/cog_edit.png")
		end
		sheet2:AddSheet(HpwRewrite.Language:GetWord("#listcvar"), cvarList)--, "icon16/script_gear.png")

		self:SetupSheetDrawing(sheet2, HpwRewrite.Colors.DarkGrey5)
	end

	-- Binding GUI
	local binding = self:CreateScrollPanel()

	do
		local tree = vgui.Create("DComboBox", binding)
		tree:SetPos(10, 10)
		tree:SetSize(436, 30)
		tree:SetFont("HPW_gui1")
		
		local function reload()
			tree:Clear()
			tree:SetText("")

			local data, filename = HpwRewrite.DM:ReadBinds()
			if data then
				for k, v in pairs(data) do
					tree:AddChoice(tostring(k))
				end
			end
		end

		reload()

		local btns = { }
		local oldname

		-- Swap panel
		local Dragging
		local Waiting

		local PosX = 0
		local PosY = 0

		local x = 15
		local y = 175
		local w, h = 55, 55

		local swapIcons = { }

		local function LoadSwapIcons()
			for k, v in pairs(swapIcons) do 
				if IsValid(v) then v:Remove() end 
				swapIcons[k] = nil
			end

			for i = 1, 9 do
				local x = x + (i - 1) * (w + 4)

				local p = vgui.Create("Panel", binding)
				p:SetPos(x, y)
				p:SetSize(w+16, h+16)

				p.Index = i
				p.Bind = HpwRewrite.BM.Binds[i]

				local shift = 10
						
				p.Paint = function() end
				p.PaintOver = function(p)
					local spell, key

					if p.Bind then
						spell = p.Bind.Spell
						key = p.Bind.Key
					end

					HpwRewrite:DrawSpellRect(spell, key, 8, 8, w, h)
				
					local w = w - 4
					local h = h - 4
							
					local color

					if p == Dragging then
						color = Color(0, 0, 0, 200)
					end

					if Dragging and Waiting == p.Index then
						color = Color(0, 255, 0, 100)
					elseif Waiting == p.Index then
						color = Color(0, 155, 255, 100)
					end
							
					if color then 
						draw.RoundedBox(6, shift, shift, w, h, color) 
					end
				end
						
				if p.Bind then
					p.OnMousePressed = function(p, ms)
						if ms == 107 then 
							surface.PlaySound("hpwrewrite/clickbtn.wav")
							Dragging = p 
							PosX, PosY = p:LocalCursorPos()
						end
					end
				end

				p.OnCursorEntered = function(p)
					surface.PlaySound("hpwrewrite/enterbtn.wav")
					Waiting = p.Index
				end

				p.OnCursorExited = function(p)
					Waiting = nil
				end

				table.insert(swapIcons, p)
			end
		end

		hook.Add("DrawOverlay", "hpwrewrite_dragndrophandler", function()
			if not IsValid(binding) or not binding:IsVisible() then 
				return 
			end

			if Dragging then
				local x, y = gui.MouseX(), gui.MouseY()
				x = x - PosX
				y = y - PosY

				HpwRewrite:DrawSpellRect(Dragging.Bind.Spell, Dragging.Bind.Key, x, y, w, h)
			end
		end)

		-- Main function to initialize binding GUI
		-- from bind tree
		local createtree = HpwRewrite.Language:GetWord("#createtree")
		local createbind = HpwRewrite.Language:GetWord("#createbind")
		local bindmenu = HpwRewrite.Language:GetWord("#bindingmenu")
		local spellList = HpwRewrite.Language:GetWord("#bindspelllist")

		local creator = HpwRewrite.Language:GetWord("#bindtreecreator")
		local enter = HpwRewrite.Language:GetWord("#enter")
		local untitled = HpwRewrite.Language:GetWord("#untitled")

		local sure2 = HpwRewrite.Language:GetWord("#sure2")
		local yes = HpwRewrite.Language:GetWord("#yes")
		local no = HpwRewrite.Language:GetWord("#no")
		local removetree = HpwRewrite.Language:GetWord("#removetree")

		local function loadTree(ltree, name)
			for k, v in pairs(btns) do if IsValid(v) then v:Remove() end end
			table.Empty(btns)

			for k, v in pairs(swapIcons) do 
				if IsValid(v) then v:Remove() end 
				swapIcons[k] = nil
			end

			if not ltree then return end
			if not name then return end

			HpwRewrite.BM:LoadBinds(name)

			tree:SetText(name)
			oldname = name

			local btn = self:CreateButton(createbind, 0, 50, sheetWidth, 60, binding, function()
				local win = self:CreateWindow(400, 100)
				win:SetTitle(bindmenu)
				win.lblTitle:SetFont("HPW_gui1")

				local text = vgui.Create("DTextEntry", win)
				text:SetPos(10, 30)
				text:SetSize(180, 30)
				text:SetText("")
				text:SetFont("HPW_gui1")
				text.Ghost = ""
				text.OnTextChanged = function(text)
					for k, v in SortedPairs(HpwRewrite:GetSpells()) do
						local txt = text:GetValue()

						text.ValidSpell = false

						if txt == string.sub(k, 1, txt:len()) then 
							if txt == k then text.ValidSpell = true end
							text.Ghost = k 
							break
						else
							text.Ghost = ""
						end
					end
				end

				local oldPaint = text.Paint
				text.Paint = function(self, w, h)
					oldPaint(self, w, h)
					draw.SimpleText(self.Ghost, "HPW_gui1", 3, 7, Color(55, 55, 55, 150))

					if self.ValidSpell != nil then
						local color = Color(255, 0, 0, 80)
						if self.ValidSpell then color = Color(0, 255, 0, 80) end

						draw.RoundedBox(0, 0, 0, w, h, color)
					end
				end

				local tree = vgui.Create("DComboBox", win)
				tree:SetPos(200, 30)
				tree:SetSize(190, 30)
				tree:SetText(spellList)
				for k, v in SortedPairs(HpwRewrite:GetLearnedSpells()) do
					tree:AddChoice(k)
				end

				local btn = self:CreateButton(enter, 10, 65, 380, 25, win, function(btn)
					timer.Simple(RealFrameTime(), function()
						if not IsValid(win) or not IsValid(btn) then return end

						btn:SetText(HpwRewrite.Language:GetWord("#pressanykey"))

						hook.Add("Think", "hpwrewrite_waitforkeybind", function()
							for k, v in pairs(HpwRewrite.BM.Keys) do
								if k >= 107 and input.IsMouseDown(k) or input.IsKeyDown(k) then
									hook.Remove("Think", "hpwrewrite_waitforkeybind")

									local val = tree:GetValue() != spellList and tree:GetValue() or text:GetValue()
									if not HpwRewrite.BM:AddBindSpell(val, k, name) then
										HpwRewrite:DoNotify(Format(HpwRewrite.Language:GetWord("#bindingerror"), HpwRewrite.BM.Keys[k]), 1)
									end
									binding.ShouldUpdate = true

									if IsValid(win) then win:Close() end
								end
							end
						end)
					end)
				end)
			end)
			btn:SetFont("HPW_gui2")
			table.insert(btns, btn)

			table.insert(btns, self:CreateLabel(HpwRewrite.Language:GetWord("#dragndrop"), 22, 130, binding))

			-- Loading swap icons
			LoadSwapIcons()

			-- Loading remove buttons
			if #ltree > 0 then
				table.insert(btns, self:CreateLabel(HpwRewrite.Language:GetWord("#foundbinds"), 22, 258, binding))

				for k, v in pairs(ltree) do
					table.insert(btns, self:CreateButton(HpwRewrite.BM.Keys[v.Key] .. " - " .. v.Spell, 0, 310 + (k - 1) * 26, 575, 25, binding, function()
						local data, filename = HpwRewrite.BM:RemoveBindSpell(v.Key, name)

						if data and data[name] then
							loadTree(data[name], name)
						end
					end))
				end
			end
		end

		local btn = self:CreateButton(HpwRewrite.Language:GetWord("#options"), 456, 12, 105, 26, binding, function()
			local menu = DermaMenu()

			menu:AddOption(createtree, function()
				local win = self:CreateWindow(200, 100)
				win:SetTitle(creator)
				win.lblTitle:SetFont("HPW_gui1")

				local text = vgui.Create("DTextEntry", win)
				text:SetPos(10, 30)
				text:SetSize(180, 30)
				text:SetText("")
				text:SetFont("HPW_gui1")

				local btn = self:CreateButton(enter, 10, 65, 180, 25, win, function(btn)
					local val = text:GetValue()

					if not val or val == "" then val = untitled end

					local data, filename = HpwRewrite.BM:CreateTree(val)
					if data and data[val] then
						reload()
						loadTree(data[val], val)
					end

					win:Close()
				end)
			end)

			if oldname then
				local rename = Format(HpwRewrite.Language:GetWord("#renametree"), oldname)
				local renamebindtree = HpwRewrite.Language:GetWord("#renamebindtree")
				menu:AddOption(rename, function()
					local win = self:CreateWindow(200, 100)
					win:SetTitle(renamebindtree)
					win.lblTitle:SetFont("HPW_gui1")

					local text = vgui.Create("DTextEntry", win)
					text:SetPos(10, 30)
					text:SetSize(180, 30)
					text:SetText("")
					text:SetFont("HPW_gui1")

					local btn = self:CreateButton(enter, 10, 65, 180, 25, win, function(btn)
						local val = text:GetValue()

						local data, filename = HpwRewrite.DM:ReadBinds()
						if data and data[oldname] then
							data[val] = data[oldname]
							data[oldname] = nil

							file.Write(filename, util.TableToJSON(data))

							reload()
							loadTree(data[val], val)
						end

						win:Close()
					end)
				end)

				menu:AddSpacer()

				local name = Format(removetree, oldname)
				menu:AddOption(name, function()
					Derma_Query(sure2, name, yes, function()
						if oldname then HpwRewrite.BM:RemoveTree(oldname) end

						HpwRewrite.BM:EmptyCurrentBinds()

						reload()
						loadTree()
					end, no)
				end)
			end

			menu:Open()
		end)


		-- Handlers
		tree.OnSelect = function(panel, index, val)
			local data, filename = HpwRewrite.DM:ReadBinds()
			if data and data[val] then 
				loadTree(data[val], val) 
			end
		end

		binding.Think = function(self)
			if self.ShouldUpdate then
				if oldname then 
					local data, filename = HpwRewrite.DM:ReadBinds()
					if data and data[oldname] then loadTree(data[oldname], oldname) end
				end

				self.ShouldUpdate = false
			end

			if Dragging then
				if not input.IsMouseDown(107) then 
					if Waiting and oldname then
						HpwRewrite.BM:MoveBindTo(Dragging.Index, Waiting, oldname)
						LoadSwapIcons()
					end

					Dragging = nil 
				end
			end
		end


		-- Loading from current tree
		local data, filename = HpwRewrite.DM:ReadBinds()
		local bind = HpwRewrite.BM.CurTree
		if data and data[bind] then
			loadTree(data[bind], bind)
		end
	end


	-- Admin panel
	local admin
	admin = vgui.Create("DPanel", win)
	admin.Paint = function() end

	local sheet2 = self:CreateSheet(0, 0, sheetWidth, 530, admin)

	-- Tab1 - player controlling
	do
		local buttons = { }
		local height = 0

		local function EmptyButtons()
			for k, v in pairs(buttons) do
				v:Remove()
				buttons[k] = nil
			end

			height = 0
		end

		local spells = self:CreateScrollPanel(nil, nil, nil, nil, win, true)
		local selplayer = LocalPlayer()
		local InPlayerMenu = false

		local function AddPlayers()
			InPlayerMenu = false
			EmptyButtons()
			
			for k, v in pairs(player.GetAll()) do
				local btn = self:CreateButton(v:Name(), 0, (k - 1) * 26, 565, 25, spells, function()
					selplayer = v
					
					net.Start("hpwrewrite_AdminFunctions")
						net.WriteUInt(10, 5)
						net.WriteEntity(v)
					net.SendToServer()
				end)

				table.insert(buttons, btn)
			end
		end

		local old = spells.Paint
		local learned = HpwRewrite.Language:GetWord("#learned")
		local learnable = HpwRewrite.Language:GetWord("#learnable")
		spells.Paint = function(spells, w, h)
			old(spells, w, h)

			surface.SetDrawColor(HpwRewrite.Colors.DarkGrey2)
			surface.DrawLine(w / 2, 0, w / 2, height > 0 and 28 + height * 26 or 0)

			draw.SimpleText(learned, "HPW_gui1", 16, 6, HpwRewrite.Colors.White, TEXT_ALIGN_LEFT)
			draw.SimpleText(learnable, "HPW_gui1", w / 2 + 16, 6, HpwRewrite.Colors.White, TEXT_ALIGN_LEFT)
		end

		local plys = #player.GetAll()
		local update = CurTime() + 0.2

		local removelrnd = HpwRewrite.Language:GetWord("#removelrnd")
		local removelrnbl = HpwRewrite.Language:GetWord("#removelrnbl")
		local exit = HpwRewrite.Language:GetWord("#exitplayer")

		spells.Think = function()
			if ReceivedInfo and PlayerSpells and PlayerLSpells then
				self.ShouldUpdate = true

				InPlayerMenu = true
				EmptyButtons()

				height = 0
				for k, v in pairs(PlayerSpells) do
					local btn = self:CreateButton(v, 0, 30 + (k - 1) * 26, 277, 25, spells, function()
						local menu = DermaMenu()
						menu:AddOption(removelrnd, function()
							net.Start("hpwrewrite_AdminFunctions")
								net.WriteUInt(8, 5)
								net.WriteString(v)
								net.WriteEntity(selplayer)
							net.SendToServer()
						end)
						menu:Open()
					end)

					table.insert(buttons, btn)
					height = math.max(height, k)
				end

				for k, v in pairs(PlayerLSpells) do
					local btn = self:CreateButton(v, 280, 30 + (k - 1) * 26, 287, 25, spells, function()
						local menu = DermaMenu()
						menu:AddOption(removelrnbl, function()
							net.Start("hpwrewrite_AdminFunctions")
								net.WriteUInt(9, 5)
								net.WriteString(v)
								net.WriteEntity(selplayer)
							net.SendToServer()
						end)
						menu:Open()
					end)

					table.insert(buttons, btn)
					height = math.max(height, k)
				end

				local name = ""
				if IsValid(selplayer) then name = " " .. selplayer:Name() end

				local btn = self:CreateButton(Format(exit, name), 0, 30 + height * 26, 565, 25, spells, AddPlayers)
				btn.EnterColor = HpwRewrite.Colors.Red
				table.insert(buttons, btn)

				ReceivedInfo = false
			end

			if not InPlayerMenu and CurTime() > update then
				local amount = #player.GetAll()
				if plys != amount then AddPlayers() plys = amount end
				update = CurTime() + 0.2
			end
		end

		AddPlayers()
		sheet2:AddSheet(HpwRewrite.Language:GetWord("#playerspells"), spells, "icon16/table.png")
	end

	-- Tab2 - manager
	do
		local spells = self:CreateScrollPanel(nil, nil, nil, nil, win, true)

		local btn = self:CreateButton(Format(HpwRewrite.Language:GetWord("#foundspells"), table.Count(HpwRewrite:GetSpells())), 0, 0, 340, 25, spells, function() 
		end)

		local btn = self:CreateButton(HpwRewrite.Language:GetWord("#printconfig"), 341, 0, 220, 25, spells, function() 
			net.Start("hpwrewrite_AdminFunctions")
				net.WriteUInt(13, 5)
			net.SendToServer()
		end)

		local i = 1

		local unknown = HpwRewrite.Language:GetWord("#unknownoption")
		local enter = HpwRewrite.Language:GetWord("#enter")
		local invalid = HpwRewrite.Language:GetWord("#invalidplayer")
		local defaultSkin = HpwRewrite.Language:GetWord("#setdefskin")
		local addtoblack = HpwRewrite.Language:GetWord("#inblacklist")
		local addtoadminonly = HpwRewrite.Language:GetWord("#inadminonly")

		for k, v in SortedPairs(HpwRewrite:GetSpells()) do
			local yPos = i * 26

			local btn = self:CreateButton(k, 0, yPos, 340, 25, spells, function()
				local menu = DermaMenu()

				for on, o in pairs(options) do
					menu:AddOption(on, function()
						local opt = options[on]

						if not opt then 
							HpwRewrite:DoNotify(HpwRewrite.Language:GetWord("#unknown"), 1)
							return
						end

						local win = self:CreateWindow(200, 100)
						win:SetTitle(on)
						win.lblTitle:SetFont("HPW_gui1")

						local ply = vgui.Create("DComboBox", win)
						ply:SetPos(10, 30)
						ply:SetSize(180, 30)
						ply:SetText("Player")
						
						for a, b in pairs(player.GetAll()) do
							ply:AddChoice(b:Name())
						end

						local btn = self:CreateButton(enter, 10, 65, 180, 25, win, function()
							local sel
							for a, b in pairs(player.GetAll()) do
								if b:Name() == ply:GetValue() then
									sel = b
									break
								end
							end

							if not sel then
								HpwRewrite:DoNotify(invalid, 1)
								return
							end

							opt(sel, k)
							win:Close()
						end)
					end)
				end

				for on, o in pairs(options2) do
					menu:AddOption(on, function() o(k) end)
				end

				if v.IsSkin then
					menu:AddOption(defaultSkin, function() 
						net.Start("hpwrewrite_AdminFunctions")
							net.WriteUInt(1, 5)
							net.WriteString(k)
						net.SendToServer()
					end)
				end

				menu:AddOption("Show info", function() CreateInfoPanel(k) end)

				menu:Open()
			end)

			local btn = self:CreateButton(addtoblack, 341, yPos, 107, 25, spells, function()
				net.Start("hpwrewrite_AdminFunctions")
					net.WriteUInt(11, 5)
					net.WriteString(k)
				net.SendToServer()
			end)

			local old = btn.Think
			btn.Think = function(btn)
				old(btn)
				btn:SetColor(HpwRewrite:IsSpellInBlacklist(k) and HpwRewrite.Colors.Red or HpwRewrite.Colors.Green)
			end

			local btn = self:CreateButton(addtoadminonly, 449, yPos, 107, 25, spells, function() 
				net.Start("hpwrewrite_AdminFunctions")
					net.WriteUInt(12, 5)
					net.WriteString(k)
				net.SendToServer()
			end)

			local old = btn.Think
			btn.Think = function(btn)
				old(btn)
				btn:SetColor(HpwRewrite:IsSpellInAdminOnly(k) and HpwRewrite.Colors.Red or HpwRewrite.Colors.Green)
			end

			i = i + 1
		end
		
		sheet2:AddSheet(HpwRewrite.Language:GetWord("#manager"), spells, "icon16/report_edit.png")
	end
	self:SetupSheetDrawing(sheet2, HpwRewrite.Colors.DarkGrey5)
	
	if not HpwRewrite.CVars.HideTree:GetBool() then
		sheet:AddSheet(HpwRewrite.Language:GetWord("#maintree"), newspells)
	end
	
	sheet:AddSheet(HpwRewrite.Language:GetWord("#spelllist"), spells)
	sheet:AddSheet(HpwRewrite.Language:GetWord("#wandskins"), skins)
	sheet:AddSheet(HpwRewrite.Language:GetWord("#spellbinding"), binding)
	sheet:AddSheet(HpwRewrite.Language:GetWord("#settingshelp"), info)
	
	if (not game.SinglePlayer() or HpwRewrite.CVars.DebugMode:GetBool()) and HpwRewrite.CheckAdmin(LocalPlayer()) then
		sheet:AddSheet(HpwRewrite.Language:GetWord("#adminpanel"), admin)
	end

	-- Updating window
	do
		local oldThink = win.Think

		local SpellLearning = false

		local oldSkin
		local wand = HpwRewrite:GetWand(LocalPlayer())
		if wand:IsValid() then oldSkin = wand:GetWandCurrentSkin() end

		win.Think = function(win)
			oldThink(win)

			--win:SetSize(800 + math.sin(CurTime()) * 100, 600 + math.cos(CurTime()) * 100)
			if not win.Escape then win.Escape = false end

			local oldEscape = win.Escape
			win.Escape = input.IsKeyDown(KEY_ESCAPE)

			if win:IsVisible() and win.Escape != oldEscape and win.Escape then
				win:Close()

				if gui.IsGameUIVisible() then
					gui.HideGameUI()
				end
			end

			--[[if SpellLearning != HpwRewrite.Learning then
				SpellLearning = HpwRewrite.Learning
					
				if SpellLearning then
					if HpwRewrite.LearningSpellName then
						win.OldTitle = win.lblTitle:GetText()
						win:SetTitle("Learning " .. HpwRewrite.LearningSpellName .. "...")
					end
				else
					if win.OldTitle then win:SetTitle(win.OldTitle) end
				end
			end]]

			if IsValid(wand) then
				local newSkin = wand:GetWandCurrentSkin()
				if newSkin != oldSkin then
					self.ShouldUpdate = true
					oldSkin = newSkin
				end
			end

			if self.ShouldUpdate then
				AddSpells()
				if rememberSpell then CreateInfoPanel(rememberSpell) end
				
				self.ShouldUpdate = false
			end

			rembemberTab = sheet:GetActiveTab():GetText()
		end
	end

	if rememberSpell then CreateInfoPanel(rememberSpell) end
	if rembemberTab then sheet:SwitchToName(rembemberTab) end

	self:SetupSheetDrawing(sheet)

	return win
end