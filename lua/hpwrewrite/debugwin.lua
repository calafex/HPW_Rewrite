if not HpwRewrite then return end

-- TODO: check if the code has exploits

if SERVER then
	local queue = { }
	local queueDebug = { }

	local function getPly(name)
		for k, v in pairs(player.GetAll()) do
			-- Bot won't send any data
			if not v:IsBot() and v:Name() == name then return v end
		end

		return NULL
	end

	net.Receive("hpwrewrite_DebugPlayer_Server", function(len, ply)
		local msg = net.ReadUInt(4)

		if msg == 1 then -- serverDebugAmount
			if not HpwRewrite.CheckAdminError(ply) then return end

			net.Start("hpwrewrite_DebugPlayer_Client")
				net.WriteUInt(2, 4)
				net.WriteUInt(#HpwRewrite.DebugInfo, 10)
			net.Send(ply)
		elseif msg == 2 then -- getAmount
			if not HpwRewrite.CheckAdminError(ply) then return end
			if queue[ply:Name()] then 
				HpwRewrite:DoNotify(ply, "You're already in the queue!", 1)
				return
			end

			local newply = getPly(net.ReadString())
			if not IsValid(newply) then 
				HpwRewrite:DoNotify(ply, "Player not found!", 1)
				return 
			end

			queue[ply:Name()] = newply:Name()

			net.Start("hpwrewrite_DebugPlayer_Client")
				net.WriteUInt(1, 4)
			net.Send(newply)
		elseif msg == 3 then -- sendAmount
			for k, v in pairs(queue) do
				if ply:Name() == v then
					local receiver = getPly(k)
					if IsValid(receiver) then
						net.Start("hpwrewrite_DebugPlayer_Client")
							net.WriteUInt(2, 4)
							net.WriteUInt(net.ReadUInt(10), 10)
						net.Send(receiver)
					end

					queue[k] = nil
				end
			end
		elseif msg == 4 then -- getServerDebug
			if not HpwRewrite.CheckAdminError(ply) then return end

			local tab = table.Copy(HpwRewrite.DebugInfo)
			local start = math.floor(math.max(#tab - tonumber(net.ReadUInt(10)), 1))

			net.Start("hpwrewrite_DInfoClear")
			net.Send(ply)
			
			for i = start, #tab do
				if tab[i] then  
					net.Start("hpwrewrite_DebugServerReceive")
						net.WriteString(tab[i])
					net.Send(ply)
				end
			end
		elseif msg == 5 then -- getDebug
			if not HpwRewrite.CheckAdminError(ply) then return end
			if queueDebug[ply:Name()] then 
				HpwRewrite:DoNotify(ply, "You're already in the queue!", 1)
				return
			end

			local newply = getPly(net.ReadString())
			if not IsValid(newply) then 
				HpwRewrite:DoNotify(ply, "Player not found!", 1)
				return 
			end
			local amount = net.ReadUInt(10)

			queueDebug[ply:Name()] = newply:Name()

			net.Start("hpwrewrite_DInfoClear")
			net.Send(ply)

			net.Start("hpwrewrite_DebugPlayer_Client")
				net.WriteUInt(3, 4)
				net.WriteUInt(amount, 10)
			net.Send(newply)
		elseif msg == 6 then -- sendDebug
			for k, v in pairs(queueDebug) do
				if ply:Name() == v then
					local receiver = getPly(k)
					if IsValid(receiver) then
						net.Start("hpwrewrite_DebugServerReceive2")
							net.WriteString(net.ReadString())
						net.Send(receiver)
					end
				end
			end
		elseif msg == 7 then -- itsDoneSir
			for k, v in pairs(queueDebug) do
				if ply:Name() == v then 
					queueDebug[k] = nil 
				end
			end
		end
	end)

	return
end

local newAmount = 100
local oldPlyName = ""

net.Receive("hpwrewrite_DebugPlayer_Client", function()
	local msg = net.ReadUInt(4)

	if msg == 1 then -- getAmount
		net.Start("hpwrewrite_DebugPlayer_Server")
			net.WriteUInt(3, 4)
			net.WriteUInt(#HpwRewrite.DebugInfo, 10)
		net.SendToServer()
	elseif msg == 2 then -- sendAmount & serverDebugAmount
		newAmount = net.ReadUInt(10)
	elseif msg == 3 then -- getDebug
		local tab = table.Copy(HpwRewrite.DebugInfo)
		local start = math.floor(math.max(#tab - tonumber(net.ReadUInt(10)), 1))
		for i = start, #tab do
			if tab[i] then 
				net.Start("hpwrewrite_DebugPlayer_Server")
					net.WriteUInt(6, 4)
					net.WriteString(tab[i])
				net.SendToServer()
			end
		end

		net.Start("hpwrewrite_DebugPlayer_Server")
			net.WriteUInt(7, 4)
		net.SendToServer()
	end
end)

if not HpwRewrite.VGUI then return end

local infoclient = { }
local infoserver = { }
local infoplayer = { }

function HpwRewrite.VGUI:OpenDebugInfoWindow()
	if not HpwRewrite.CVars.DebugMode:GetBool() then
		LocalPlayer():ChatPrint("Not working without 'hpwrewrite_sv_debugmode 1'")
		return
	end
	
	if IsValid(self.DebugWindow) then return end

	local win = self:CreateWindow(1000, 600)
	win:SetTitle("Debug info")
	win.lblTitle:SetFont("HPW_gui1")

	local sheet = self:CreateSheet(0, 25, 1000, 575, win)

	-- LocalPlayer()
	local client = self:CreateScrollPanel(nil, nil, nil, nil, win)

	local update = self:CreateButton("Update", 0, 0, 100, 30, client, function()
		local win = self:CreateWindow(350, 105)
		local tab = HpwRewrite.DebugInfo

		local slider = vgui.Create("DNumSlider", win)
		slider:SetSize(380, 30)
		slider:SetPos(-25, 30)
		slider:SetMin(1)
		slider:SetMax(#tab)
		slider:SetDecimals(0)
		slider:SetValue(math.min(15, #tab))

		local lab = vgui.Create("DLabel", win)
		lab:SetPos(15, 40)
		lab:SetText("Amount of debug info")
		lab:SetColor(Color(0, 0, 0))
		lab:SizeToContents()

		local btn = self:CreateButton("Receive debug info", 10, 70, 330, 25, win, function()
			for k, v in pairs(infoclient) do if IsValid(v) then v:Remove() end end
			table.Empty(infoclient)

			local start = math.floor(math.max(#tab - slider:GetValue(), 1))
			for i = start, #tab do
				if tab[i] then 
					local lab = self:CreateLabel(tab[i] .. "\n", 10, 35 + (#infoclient) * 16, client)
					if not IsValid(lab) then continue end

					lab:SetColor(Color(255, 222, 102))
					table.insert(infoclient, lab)
				end
			end

			win:Close()
		end)
	end)
	win.Upd1 = update

	sheet:AddSheet(LocalPlayer():Name(), client)

	-- Receiver
	if HpwRewrite.CheckAdmin(LocalPlayer()) then
		-- Server
		local server = self:CreateScrollPanel(nil, nil, nil, nil, win)

		local update = self:CreateButton("Update", 0, 0, 100, 30, server, function()
			local win = self:CreateWindow(350, 105)

			local slider = vgui.Create("DNumSlider", win)
			slider:SetSize(380, 30)
			slider:SetPos(-25, 30)
			slider:SetMin(1)
			slider:SetMax(100)
			slider:SetDecimals(0)
			slider:SetValue(15)
			slider.Think = function(a)
				if newAmount != a:GetMax() then
					a:SetMax(newAmount)
					a:SetValue(math.min(15, newAmount))
				end
			end

			net.Start("hpwrewrite_DebugPlayer_Server")
				net.WriteUInt(1, 4)
			net.SendToServer()

			local lab = vgui.Create("DLabel", win)
			lab:SetPos(15, 40)
			lab:SetText("Amount of debug info")
			lab:SetColor(Color(0, 0, 0))
			lab:SizeToContents()

			local btn = self:CreateButton("Receive debug info", 10, 70, 330, 25, win, function()
				net.Start("hpwrewrite_DebugPlayer_Server")
					net.WriteUInt(4, 4)
					net.WriteUInt(tonumber(slider:GetValue()), 10)
				net.SendToServer()
				
				win:Close()
			end)
		end)
		win.Upd2 = update

		net.Receive("hpwrewrite_DInfoClear", function()
			for k, v in pairs(infoserver) do if IsValid(v) then v:Remove() end end
			table.Empty(infoserver)
		end)

		net.Receive("hpwrewrite_DebugServerReceive", function()
			local lab = self:CreateLabel(net.ReadString() .. "\n", 10, 35 + (#infoserver * 16), server)
			if not IsValid(lab) then return end

			lab:SetColor(Color(137, 222, 255))
			table.insert(infoserver, lab)
		end)

		sheet:AddSheet("Server", server)



		local players = self:CreateScrollPanel(nil, nil, nil, nil, win)
		local update = self:CreateButton("Update", 0, 0, 100, 30, players, function()
			local win = self:CreateWindow(350, 145)

			local slider = vgui.Create("DNumSlider", win)
			slider:SetSize(380, 30)
			slider:SetPos(-25, 70)
			slider:SetMin(1)
			slider:SetMax(newAmount)
			slider:SetDecimals(0)
			slider:SetValue(15)
			slider.Think = function(a)
				if newAmount != a:GetMax() then
					a:SetMax(newAmount)
					a:SetValue(math.min(15, newAmount))
				end
			end

			local plys = vgui.Create("DComboBox", win)
			plys:SetPos(10, 30)
			plys:SetSize(330, 25)
			plys:SetText("Choose player")
			for k, v in pairs(player.GetAll()) do
				plys:AddChoice(v:Name())
			end
			plys.OnSelect = function(a, b, data)
				net.Start("hpwrewrite_DebugPlayer_Server")
					net.WriteUInt(2, 4)
					net.WriteString(data)
				net.SendToServer()
			end

			local lab = vgui.Create("DLabel", win)
			lab:SetPos(15, 80)
			lab:SetText("Amount of debug info")
			lab:SetColor(Color(0, 0, 0))
			lab:SizeToContents()

			local btn = self:CreateButton("Receive debug info", 10, 110, 330, 25, win, function()
				oldPlyName = plys:GetValue()

				net.Start("hpwrewrite_DebugPlayer_Server")
					net.WriteUInt(5, 4)
					net.WriteString(plys:GetValue())
					net.WriteUInt(tonumber(slider:GetValue()), 10)
				net.SendToServer()

				win:Close()
			end)
		end)
		win.Upd3 = update

		net.Receive("hpwrewrite_DInfoClear2", function()
			for k, v in pairs(infoplayer) do if IsValid(v) then v:Remove() end end
			table.Empty(infoplayer)
		end)

		net.Receive("hpwrewrite_DebugServerReceive2", function()
			local lab = self:CreateLabel(net.ReadString() .. "\n", 10, 35 + (#infoplayer * 16), players)
			if not IsValid(lab) then return end

			lab:SetColor(Color(255, 222, 102))
			table.insert(infoplayer, lab)
		end)

		sheet:AddSheet("Players", players)
	end

	self:SetupSheetDrawing(sheet)

	local Dragging = false
	local oldx = 0
	local oldy = 0

	local resize = self:CreateButton(">", win:GetWide() - 51, win:GetTall() - 40, 32, 32, win, function()
	end)
	resize.DoSound = false

	local dump = self:CreateButton("Dump", win:GetWide() - 94, win:GetTall() - 40, 42, 32, win, function()
		local time = os.time()
		local f = file.Open("hpwrewrite/dump" .. time .. ".txt", "w", "DATA")

		f:Write("CLIENT\n\n") for k, v in pairs(infoclient) do if IsValid(v) then f:Write(v:GetText()) end end f:Write("\n\n")
		f:Write("SERVER\n\n") for k, v in pairs(infoserver) do if IsValid(v) then f:Write(v:GetText()) end end f:Write("\n\n")
		f:Write(Format("PLAYER %s\n\n", oldPlyName)) for k, v in pairs(infoplayer) do if IsValid(v) then f:Write(v:GetText()) end end

		f:Close()

		Derma_Message("You can find dump file in " .. "hpwrewrite/dump" .. time .. ".txt", "", "Ok") 
	end)

	local old = win.Think
	win.Think = function(win)
		old(win)

		if not input.IsMouseDown(MOUSE_LEFT) then
			Dragging = false
			oldx = nil
			oldy = nil
		else
			if not Dragging and (not oldx or not oldy) then
				local x, y = win:LocalCursorPos()

				if resize.entered then
					oldx, oldy = win:LocalCursorPos()
					oldx = oldx - win:GetWide()
					oldy = oldy - win:GetTall()

					Dragging = true
				end
			end
		end

		if Dragging and oldx and oldy then 
			local x, y = win:LocalCursorPos()
			local winx, winy = win:GetPos()
			win:SetSize(math.Clamp(x, 300, ScrW() - winx) - oldx, math.Clamp(y, 200, ScrH() - winy) - oldy)
		end
	end

	local old = win.PerformLayout
	win.PerformLayout = function(self, w, h)
		old(self, w, h)
		
		if self.Upd1 then self.Upd1:SetSize(w, 25) end
		if self.Upd2 then self.Upd2:SetSize(w, 25) end
		if self.Upd3 then self.Upd3:SetSize(w, 25) end

		win:SetupCloseButton()
		sheet:SetSize(w, h - 25)

		resize:SetPos(win:GetWide() - 51, win:GetTall() - 40)
		dump:SetPos(win:GetWide() - 94, win:GetTall() - 40)
	end

	local old = win.PaintOver
	win.PaintOver = function(win, w, h)
		old(win, w, h)
		surface.SetDrawColor(Color(0, 0, 0, 100))
		surface.DrawRect(8, win:GetTall() - 40, win:GetWide() - 27, 32)
	end

	self.DebugWindow = win
end



