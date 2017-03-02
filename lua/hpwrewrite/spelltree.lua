if SERVER then return end

local PANEL = { }

local Scale = 0.5
local NewScale = 0.4

local BackgroundAdd = Vector(0, 0)
local BackgroundDiff = BackgroundAdd

local AddDiff = Vector(0, 0)
local Diff = nil

local glow = Material("hpwrewrite/sprites/magicsprite")
local beam = Material("sprites/physbeama")
local background = Material("vgui/hpwrewrite/misc/background")
local shadow = Material("vgui/hpwrewrite/misc/shadow")

local drawText = true

HpwRewrite.Nodes = HpwRewrite.Nodes or { }

local function _SetPos(self, x, y)
	self.Pos = Vector(x, y)
	if self.Offset then self.Pos = self.Pos + self.Offset end
end

local function CreateNode()
	return { 
		Pos = Vector(0, 0), 
		Childs = { }, 
		Parents = { },

		SetPos = _SetPos
	}
end

local function BuildNodes()
	table.Empty(HpwRewrite.Nodes)

	for k, v in pairs(HpwRewrite:GetSpells()) do
		if v.SecretSpell and not HpwRewrite:PlayerHasSpell(nil, k) then continue end

		if not HpwRewrite.Nodes[k] then HpwRewrite.Nodes[k] = CreateNode() end
		HpwRewrite.Nodes[k].Mat = HpwRewrite:GetSpellIcon(k)
		HpwRewrite.Nodes[k].WeldTree = v.WeldTree

		if v.OnlyIfLearned then
			for a, b in pairs(v.OnlyIfLearned) do
				if b == k then continue end

				local pSpell = HpwRewrite:GetSpell(b)

				if pSpell then
					if pSpell.SecretSpell and not HpwRewrite:PlayerHasSpell(nil, b) then continue end
					if not HpwRewrite.Nodes[b] then HpwRewrite.Nodes[b] = CreateNode() end

					table.insert(HpwRewrite.Nodes[k].Parents, HpwRewrite.Nodes[b])
					table.insert(HpwRewrite.Nodes[b].Childs, HpwRewrite.Nodes[k])
				end
			end
		end

		HpwRewrite.Nodes[k].Offset = v.NodeOffset
		HpwRewrite.Nodes[k]:SetPos(0, 0)
	end

	local newcount = 0
	for k, v in pairs(HpwRewrite.Nodes) do
		local spell = HpwRewrite:GetSpell(k)

		v.NodeDraw = spell.NodeDraw
		v.NodeDrawOpti = spell.NodeDrawOpti
		v.NodeEdgeDraw = spell.NodeEdgeDraw
		v.NodeEdgeToParentDraw = spell.NodeEdgeToParentDraw
		v.NodeIntersectDist = spell.NodeIntersectDist

		if spell.CalculateNodeOffset then
			newcount = newcount + 1

			local max = 1
			for a, b in pairs(HpwRewrite.Nodes) do
				local len = b.Pos:Length()
				if len > max then max = len end
			end

			max = max + (spell.CalculationCoef or 1) * 15

			local a = math.rad(((newcount % 12) / 12) * 360)

			v.Offset = Vector(math.sin(a) * max, math.cos(a) * max)
			v:SetPos(0, 0)
		end

		if spell.NodeDependOn then
			local parent = HpwRewrite.Nodes[spell.NodeDependOn]

			if parent then
				local x, y = parent.Pos.x, parent.Pos.y
				v:SetPos(x, y)
			end
		end
	end
end

local c_quality = 5

local function circle(x, y, radius, seg)
	local cir = {}

	cir[1] = { x = x, y = y, u = 0.5, v = 0.5 }
	for i = 0, seg do
		local a = math.rad((i / seg) * -360 + 180)
		cir[#cir+1] = { x = x + math.sin(a) * radius, y = y + math.cos(a) * radius, u = math.sin(a) / 2 + 0.5, v = math.cos(a) / 2 + 0.5 }
	end

	local a = math.rad(0) -- This is need for non absolute segment counts
	cir[#cir+1] = { x = x + math.sin(a) * radius, y = y + math.cos(a) * radius, u = math.sin(a) / 2 + 0.5, v = math.cos(a) / 2 + 0.5 }

	surface.DrawPoly(cir)
end

local function GetRadius()
	return 26 * Scale
end

local function GetPos(node)
	return Diff.x + node.Pos.x * Scale, Diff.y + node.Pos.y * Scale
end

function PANEL:CatchClick()
	-- Override this function
end

function PANEL:Reset()
	Scale = 0.5
	NewScale = 0.4

	AddDiff = Vector(0, 0)
	Diff = nil

	self.StartMousePos = Vector(0, 0)

	BuildNodes()
end

function PANEL:Fullscreen()
	self:Reset()

	if self.IsFullWindowed then
		self:SetSize(self.OldW, self.OldH)
		self:SetPos(self.OldX, self.OldY)
		
		if IsValid(self.OldParent) then
			self:SetParent(self.OldParent)
			self.OldParent = nil
		else
			self:Remove()
		end

		gui.EnableScreenClicker(false)
		HpwRewrite.VGUI:OpenNewSpellManager()

		self.IsFullWindowed = false

		return
	end

	self.OldParent = self:GetParent()
	if not IsValid(self.OldParent) then return end

	if IsValid(HpwRewrite.VGUI.Window) then HpwRewrite.VGUI.Window:Close() end

	self.OldW = self:GetWide()
	self.OldH = self:GetTall()

	local x, y = self:GetPos()
	self.OldX = x
	self.OldY = y

	self:SetParent(NULL)
	self:SetPos(0, 0)
	self:SetSize(ScrW(), ScrW())

	self.IsFullWindowed = true

	gui.EnableScreenClicker(true)
end

function PANEL:Init()
	self.Node = HpwRewrite.Nodes
	self.Magic = { }
	self.Dragging = false

	self.StartMousePos = Vector(0, 0)

	self.MenuBtn = HpwRewrite.VGUI:CreateButton("Menu", 0, -25, 25, 25, self, function()
		local menu = DermaMenu()

		menu:AddOption("Reset", function()
			self:Reset()
		end)

		menu:AddOption(drawText and "Don't draw text" or "Draw text", function() drawText = not drawText end)

		menu:AddOption("Empty current spell", function()
			net.Start("hpwrewrite_RemSpell")
			net.SendToServer()
		end)

		menu:AddOption((self.IsFullWindowed and "Windowed" or "Fullscreen") .. " (or F11 key)", function()
			self:Fullscreen()
		end)

		menu:AddSpacer()
		menu:AddOption("Dump nodes' positions", function()
			MsgC(Color(255, 0, 0), "DUMPING\n")

			for k, v in SortedPairs(HpwRewrite.Nodes) do
				local spell = HpwRewrite:GetSpell(k)

				local pos = v.Pos
				if pos != spell.NodeOffset then
					print(k, Format("Spell.NodeOffset = Vector(%i, %i, %i)", pos.x, pos.y, 0))
				end
			end

			MsgC(Color(255, 0, 0), "FINISHED\n")
		end)

		menu:Open()
	end)
	self.MenuBtn.DoSound = false
	self.MenuBtn.DrawDiff = false
	self.MenuBtn:SetAlpha(180)

	self.Anim = Derma_Anim("SetPos", self, function(p, anim, delta, data)
		if not p.MenuBtn.Offset then p.MenuBtn.Offset = -26 end
		p.MenuBtn.Offset = Lerp(delta, p.MenuBtn.Offset, (data and 0 or -26))
		p.MenuBtn:SetPos(0, p.MenuBtn.Offset)
	end)
end

function PANEL:PerformLayout(w, h)
	self.MenuBtn:SetSize(w, 25)
end

local oldx = 0
local oldy = 0
function PANEL:OnMousePressed(key)
	if key == MOUSE_LEFT then
		for k, v in pairs(self.Node) do 
			if v.Intersect then
				self:CatchClick(k, v)
				return
			end 
		end

		if not self.Drag then
			self.Dragging = true
			self.StartMousePos = Vector(gui.MouseX(), gui.MouseY())
		end
	else
		-- TODO: erase 
		if self.Drag then self.Drag = nil return end
		for k, v in pairs(self.Node) do
			if v.Intersect then 
				self.Drag = v 
				oldx = v.Pos.x
				oldy = v.Pos.y
			end
		end

		self.StartMousePos = Vector(gui.MouseX(), gui.MouseY())
	end
end

function PANEL:OnMouseWheeled(dt) 
	dt = dt * 0.1
	NewScale = math.Clamp(NewScale + NewScale * dt, 0.1, 4)

	if NewScale < 4 and NewScale > 0.1 then
		local x, y = self:LocalCursorPos()
		AddDiff = AddDiff + Vector(AddDiff.x - x, AddDiff.y - y) * dt
		BackgroundAdd = BackgroundAdd + Vector(BackgroundAdd.x - x, BackgroundAdd.y - y) * dt * 0.04
	end
end

function PANEL:Think()
	if self.F11Key == nil then self.F11Key = false end

	local oldpressed = self.F11Key
	self.F11Key = input.IsKeyDown(KEY_F11)

	if oldpressed != self.F11Key and self.F11Key then
		self:Fullscreen()
	end

	if self.Anim:Active() then self.Anim:Run() end

	local mx = gui.MouseX()
	local my = gui.MouseY()

	local x, y = self:LocalCursorPos() 
	local w, h = self:GetWide(), self:GetTall()

	-- If we're in button zone
	if (x > 0 and x < w) and (y > 0 and y < 25) then
		if not self.Started then self.Anim:Start(0.6, true) self.Started = true end
	else
		if self.Started then self.Anim:Start(0.4, false) self.Started = false end
	end

	local lerpScal = RealFrameTime() * 8

	Scale = Lerp(lerpScal, Scale, NewScale)

	if not Diff then
		Diff = Vector(w, h) * 0.5
		AddDiff = Diff

		BackgroundDiff = Diff
		BackgroundAdd = Diff
	else
		Diff = LerpVector(lerpScal, Diff, AddDiff)
	end

	BackgroundDiff = LerpVector(lerpScal, BackgroundDiff, BackgroundAdd)

	if self.Dragging then
		local vec = Vector(mx - self.StartMousePos.x, my - self.StartMousePos.y) * 0.6
		AddDiff = Diff + vec
		BackgroundAdd = BackgroundDiff + vec * 0.07

		self.StartMousePos = LerpVector(lerpScal, self.StartMousePos, Vector(mx, my))

		if not input.IsMouseDown(MOUSE_LEFT) then
			self.Dragging = false
		end
	end

	-- TODO: erase
	if self.Drag then 
		self.Drag.Pos = Vector(oldx+(mx - self.StartMousePos.x)*(1/Scale), oldy+(my - self.StartMousePos.y)*(1/Scale), 0) 
	end

	for k, v in pairs(self.Node) do
		local x2, y2 = GetPos(v)
		v.Intersect = math.Distance(x, y, x2, y2) < GetRadius() + (v.NodeIntersectDist or 1)
	end
end

local arrow = Material("vgui/hpwrewrite/arrow")

function PANEL:Paint(w, h)
	-- Background
	surface.SetDrawColor(HpwRewrite.Colors.White)
	surface.SetMaterial(background)

	local truesizeW = w * 1.6
	local truesizeH = h * 1.6

	local maxW = w / 1.7 / 2
	local maxH = h / 1.7 / 2

	local valx = math.Clamp((BackgroundDiff.x - w * 0.5), -maxW, maxW)
	local valy = math.Clamp((BackgroundDiff.y - h * 0.5), -maxH, maxH)

	local x = (w - truesizeW) * 0.5 + valx
	local y = (h - truesizeH) * 0.5 + valy

	surface.DrawTexturedRect(x, y, truesizeW, truesizeH)


	-- Main draw code
	local radius = GetRadius()

	--[[surface.SetDrawColor(Color(0, 0, 0, 120))
	surface.DrawLine(0, Diff.y, w, Diff.y)
	surface.DrawLine(Diff.x, 0, Diff.x, h)

	surface.SetDrawColor(HpwRewrite.Colors.White)
	surface.DrawLine(Diff.x, Diff.y + radius, Diff.x, Diff.y - radius)
	surface.DrawLine(Diff.x - radius, Diff.y, Diff.x + radius, Diff.y)]]

	-- Edges
	for k, v in pairs(self.Node) do
		local x, y = GetPos(v)
		local new = v.Childs

		if new then
			for c, child in pairs(new) do
				local x2, y2 = GetPos(child)

				local stopdraw = false

				if v.NodeEdgeDraw and v.NodeEdgeDraw(v, x, y, child, x2, y2, radius) then
					stopdraw = true
				end

				if not stopdraw then
					local pos1 = Vector(x, y)
					local pos2 = Vector(x2, y2)
					local dir = (pos2 - pos1):GetNormal()
					local a = dir:Angle()
					local x = pos1.x + (pos2.x - pos1.x) * 0.5
					local y = pos1.y + (pos2.y - pos1.y) * 0.5
					local w = pos1:Distance(pos2)
					local h = math.max(1, 8 * Scale)

					local size = 16 * Scale
					local newpos = pos2 - dir * (radius + size * 0.6)

					surface.SetMaterial(arrow)

					surface.SetDrawColor(HpwRewrite.Colors.Black)
					surface.DrawTexturedRectRotated(x+1, y+1, w - radius, h, -a.yaw)
					surface.DrawTexturedRectRotated(newpos.x+1, newpos.y+1, size, size * 0.8, -a.yaw)

					surface.SetDrawColor(HpwRewrite.Colors.LightGrey)
					surface.DrawTexturedRectRotated(x, y, w - radius, h, -a.yaw)

					surface.SetDrawColor(HpwRewrite.Colors.White)
					surface.DrawTexturedRectRotated(newpos.x, newpos.y, size, size * 0.8, -a.yaw)

					draw.NoTexture()


					--[[local start = Vector(x, y, 0)
					local endpos = Vector(x2, y2, 0)
					local dir = (endpos - start):GetNormal()

					local a = dir:Angle()
					local newpos = endpos - dir * radius
					local newpos2 = newpos + a:Right() * radius * 0.2 - a:Forward() * radius
					local newpos3 = newpos - a:Right() * radius * 0.2 - a:Forward() * radius
					
					surface.SetDrawColor(Color(0, 0, 0, 200))
					surface.DrawPoly({
						{ x = newpos3.x, y = newpos3.y, u = 0.5, v = 0.5 },
						{ x = newpos2.x, y = newpos2.y, u = 0.5, v = 0.5 },
						{ x = newpos.x, y = newpos.y, u = 0.5, v = 0.5 },
					})

					surface.SetDrawColor(Color(255, 255, 255, 200))
					surface.DrawPoly({
						{ x = newpos3.x + 1, y = newpos3.y + 1, u = 0.5, v = 0.5 },
						{ x = newpos2.x + 1, y = newpos2.y + 1, u = 0.5, v = 0.5 },
						{ x = newpos.x + 1, y = newpos.y + 1, u = 0.5, v = 0.5 },
					})]]
				end
			end
		end

		if v.NodeEdgeToParentDraw then
			local new = v.Parents

			if new then
				for c, parent in pairs(new) do
					local x2, y2 = GetPos(parent)
					v.NodeEdgeToParentDraw(v, x, y, parent, x2, y2, radius)
				end
			end
		end
	end

	-- Learning effect
	surface.SetMaterial(glow)
	for k, v in pairs(self.Magic) do
		if not v.Start then v.Start = v.Pos + VectorRand() * GetRadius() end

		surface.SetDrawColor(Color(v.Color.r, v.Color.g, v.Color.b, v.Alpha))

		local dif = (v.Alpha / 255)
		local ang = -(v.Pos - v.Start):Angle().y
		surface.DrawTexturedRectRotated(Diff.x + v.Pos.x * Scale, Diff.y + v.Pos.y * Scale, dif * v.Size * Scale * 3, dif * v.Size * Scale, ang)

		v.Pos = v.Pos + (v.Pos - v.Start):GetNormal() * dif * FrameTime() * 60
		v.Alpha = v.Alpha - 2 * FrameTime() * 60
		if v.Alpha <= 0 then self.Magic[k] = nil end
	end

	-- Vertices, rings, circles, etc
	for k, v in pairs(self.Node) do
		local x, y = GetPos(v)

		local stopdraw = false

		if v.NodeDraw and v.NodeDraw(v, x, y, radius) then
			stopdraw = true
		end

		if not stopdraw and not (x < -radius or y < -radius or x > w + radius or y > h + radius) then
			if v.NodeDrawOpti and v.NodeDrawOpti(v, x, y, radius) then
				stopdraw = true
			end

			if not stopdraw then
				if HpwRewrite:PlayerHasLearnableSpell(nil, k) and HpwRewrite:CanLearn(nil, k) then
					surface.SetDrawColor(Color(80, 255, 80))
					surface.SetMaterial(glow)

					local w = radius * (16 + math.sin(CurTime() * 10) * 3)
					local h = w
					surface.DrawTexturedRect(x - w*0.5, y - h*0.5, w, h)

					if math.random(1, 4) == 1 then
						table.insert(self.Magic, { 
							Pos = Vector(v.Pos.x, v.Pos.y, 0), 
							Alpha = 255, 
							Size = math.random(35, 60), 
							Color = ColorRand() 
						})
					end
				end				

				draw.NoTexture()
				surface.SetDrawColor(v.Intersect and HpwRewrite.Colors.Blue or HpwRewrite.Colors.DarkGrey2)
				circle(x, y, radius * 1.15, c_quality)

				if v.Mat and not v.Mat:IsError() then 
					surface.SetDrawColor(HpwRewrite.Colors.White)
					surface.SetMaterial(v.Mat)
				else
					surface.SetDrawColor(HpwRewrite.Colors.DarkGrey5)
				end

				circle(x, y, radius, c_quality)

				if not HpwRewrite:CanUseSpell(LocalPlayer(), k) then
					surface.SetDrawColor(Color(200, 20, 20, 220))
					circle(x, y, radius, c_quality)
				end
			end
		end
	end

	if drawText then
		surface.SetFont("HPW_fontSpells3")

		local gx, gy = self:LocalToScreen()
		render.SetScissorRect(gx, gy, gx + self:GetWide(), gy + self:GetTall(), true)
		for k, v in pairs(self.Node) do
			local x, y = GetPos(v)
			y = y + GetRadius() * 2

			local pos = Vector(gx, gy)
			local val = ((Scale / 4) * 0.9) + 0.1
			local tx, ty = surface.GetTextSize(k)

			local m = Matrix()
			m:Translate(pos)
			m:Scale(Vector(1, 1, 1) * val)
			m:Translate(-pos)
			m:Translate(Vector(x, y) / val)
			m:Translate(Vector(-tx / 2, -ty / 2))

			cam.PushModelMatrix(m)
				draw.SimpleText(k, "HPW_fontSpells3", 2, 2, HpwRewrite.Colors.Black, TEXT_ALIGN_LEFT)
				draw.SimpleText(k, "HPW_fontSpells3", 0, 0, HpwRewrite.Colors.White, TEXT_ALIGN_LEFT)
			cam.PopModelMatrix()
		end
		render.SetScissorRect(0, 0, 0, 0, false)
	end

	surface.SetDrawColor(HpwRewrite.Colors.White)
	surface.SetMaterial(shadow)
	surface.DrawTexturedRect(0, 0, w, h)
end

function PANEL:Update()
	BuildNodes()
end

BuildNodes()

derma.DefineControl("HPWSpellTree", "Tree with spells", PANEL, "DPanel")









