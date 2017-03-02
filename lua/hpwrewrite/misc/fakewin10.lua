if SERVER then return end

local blue = Color(45, 137, 239)
local black = Color(0, 0, 0)
local grey = Color(50, 50, 50)
local white = Color(255, 255, 255)

local complete = 0
local complete2 = 0
local state = 0

surface.CreateFont("PaintWin10", { font = "Segoe UI Light", size = 40, weight = 1 })
surface.CreateFont("PaintWin10_2", { font = "Segoe UI Light", size = 70, weight = 1 })
surface.CreateFont("PaintWin10_3", { font = "Segoe UI Light", size = 23, weight = 1 })
surface.CreateFont("PaintWin10_4", { font = "Segoe UI Light", size = 120, weight = 1 })
	
local function GetPerc(new)
	if state == new then
		return (" " .. Format("%i%%", complete2 * 100)), white
	elseif state > new then
		return "", blue
	end
	
	return "", white
end

local function Circle(x, y, radius, seg)
	local cir = {}

	table.insert(cir, { x = x, y = y, u = 0.5, v = 0.5 })
	for i = 0, seg do
		local a = math.rad((i / seg) * -360)
		table.insert(cir, { x = x + math.sin(a) * radius, y = y + math.cos(a) * radius, u = math.sin(a) / 2 + 0.5, v = math.cos(a) / 2 + 0.5 })
	end

	surface.DrawPoly(cir)
end

local function Chunk(x, y, radius, complete, seg)
	local cir = {}

	table.insert(cir, { x = x, y = y, u = 0.5, v = 0.5 })
	for i = 0, seg do
		local a = math.rad(180 + (i / seg) * -complete)
		table.insert(cir, { x = x + math.sin(a) * radius, y = y + math.cos(a) * radius, u = math.sin(a) / 2 + 0.5, v = math.cos(a) / 2 + 0.5 })
	end

	surface.DrawPoly(cir)
end

local function DrawLogo(x, y)
	surface.SetDrawColor(blue)
	
	-- Top left
	do
		local x = x - 3
		local y = y - 3
		
		local logo = {
			{ x = x - 80, y = y, u = 0.5, v = 0.5 },
			{ x = x - 80, y = y - 60, u = 0.5, v = 0.5 },
			{ x = x, y = y - 75, u = 0.5, v = 0.5 },
			{ x = x, y = y, u = 0.5, v = 0.5 },
		}
		
		surface.DrawPoly(logo)
	end
	
	-- Bottom left
	do
		local x = x - 3
		local y = y + 3
		
		local logo = {
			{ x = x - 80, y = y + 60, u = 0.5, v = 0.5 },
			{ x = x - 80, y = y, u = 0.5, v = 0.5 },
			{ x = x, y = y, u = 0.5, v = 0.5 },
			{ x = x, y = y + 75, u = 0.5, v = 0.5 },
		}
		
		surface.DrawPoly(logo)
	end
	
	-- Bottom right
	do
		local x = x + 3
		local y = y + 3
		
		local logo = {
			{ x = x, y = y, u = 0.5, v = 0.5 },
			{ x = x + 100, y = y, u = 0.5, v = 0.5 },
			{ x = x + 100, y = y + 93, u = 0.5, v = 0.5 },
			{ x = x, y = y + 76, u = 0.5, v = 0.5 },
		}
		
		surface.DrawPoly(logo)
	end
	
	-- Top right
	do
		local x = x + 3
		local y = y - 3
		
		local logo = {
			{ x = x + 100, y = y, u = 0.5, v = 0.5 },
			{ x = x, y = y, u = 0.5, v = 0.5 },
			{ x = x, y = y - 76, u = 0.5, v = 0.5 },
			{ x = x + 100, y = y - 93, u = 0.5, v = 0.5 },
		}
		
		surface.DrawPoly(logo)
	end	
end

local angles = { }
local function DrawRing(x, y)
	draw.NoTexture()
	surface.SetDrawColor(white)
	for i = 1, 5 do
		if not angles[i] then angles[i] = i * 24 end
		
		local vel = (4 + (angles[i] % 360) * 0.02) - math.NormalizeAngle(angles[i]) * 0.02
		angles[i] = angles[i] + vel
		
		if angles[i] < 690 then
			local sin = math.sin(-math.rad(angles[i]+30)) * 32
			local cos = math.cos(-math.rad(angles[i]+30)) * 32
			
			Circle(x + sin, y + cos, 4, 16)
		elseif angles[i] > 870 then
			angles[i] = -60
		end
	end	
end


local function PaintWin10(w, h)
	local x, y = w / 2, h / 2
	local dt = FrameTime()
	
	draw.NoTexture()
	surface.SetDrawColor(blue)
	surface.DrawRect(0, 0, w, h)
	
	DrawRing(x, y - 86)
	
	draw.SimpleText("Configuring update for Windows 10", "PaintWin10", x, y - 32, white, TEXT_ALIGN_CENTER)
	draw.SimpleText(Format("%i%% complete", complete * 100), "PaintWin10", x, y, white, TEXT_ALIGN_CENTER)
	draw.SimpleText("Do not turn off your computer", "PaintWin10", x, y + 32, white, TEXT_ALIGN_CENTER)
	
	complete = math.Approach(complete, 1, math.Rand(0.01, 0.2) * dt)
end

local function PaintWin10_2(w, h)
	local x, y = w / 2, h / 2
	local dt = FrameTime()
	
	draw.NoTexture()
	
	surface.SetDrawColor(black)
	surface.DrawRect(0, 0, w, h)
	
	draw.SimpleText("Installing Windows", "PaintWin10_2", x, y - 350, white, TEXT_ALIGN_CENTER)
	draw.SimpleText("Your PC will restart several times. Sit back and relax.", "PaintWin10_3", x, y - 270, white, TEXT_ALIGN_CENTER)

	surface.SetDrawColor(grey)
	Circle(x, y, 164, 64)
	
	surface.SetDrawColor(blue)
	Chunk(x, y, 164, complete2 * 360, 64)
	
	surface.SetDrawColor(black)
	Circle(x, y, 159, 64)
	
	complete2 = math.Approach(complete2, 1, math.Rand(0.01, 0.35) * dt)
	
	if complete2 >= 1 then 
		state = math.Approach(state, 3, 1) 
		if state < 3 then complete2 = 0 end
	end

	do
		local x = x - 105
		
		local perc, color = GetPerc(0)
		draw.SimpleText("Copying files" .. perc, "PaintWin10_3", x - 200, y + 280, color)
		
		local perc, color = GetPerc(1)
		draw.SimpleText("Installing features and drivers" .. perc, "PaintWin10_3", x, y + 280, color)
	
		local perc, color = GetPerc(2)
		draw.SimpleText("Configuring Settings" .. perc, "PaintWin10_3", x + 300, y + 280, color)
	end	
	
	draw.SimpleText(Format("%i%%", complete2 * 100), "PaintWin10_4", x, y - 60, white, TEXT_ALIGN_CENTER)
end

local function PaintWin10_Boot(w, h)
	local x, y = w / 2, h / 2 - 140
	local dt = FrameTime()
	
	draw.NoTexture()
	
	surface.SetDrawColor(black)
	surface.DrawRect(0, 0, w, h)
	
	DrawLogo(x, y)
	DrawRing(x, y + 300)
end

net.Receive("hpwrewrite_Win10", function()
	complete = 0
	complete2 = 0
	state = 0

	hook.Add("Think", "hpwrewrite_fakewin10", function()
		RunConsoleCommand("stopsound")
	end)

	hook.Add("DrawOverlay", "hpwrewrite_fakewin10", function()
		if complete2 < 100 and state < 3 then
			PaintWin10_2(ScrW(), ScrH())
		else
			PaintWin10(ScrW(), ScrH())	
		end
		
		if complete >= 1 then
			PaintWin10_Boot(ScrW(), ScrH())

			if not timer.Exists("hpwrewrite_fakewin10stop") then
				timer.Create("hpwrewrite_fakewin10stop", 5, 1, function()
					hook.Remove("Think", "hpwrewrite_fakewin10")
					hook.Remove("DrawOverlay", "hpwrewrite_fakewin10")
				end)
			end
		end
	end)
end)

net.Receive("hpwrewrite_EWin10", function()
	hook.Remove("Think", "hpwrewrite_fakewin10")
	hook.Remove("DrawOverlay", "hpwrewrite_fakewin10")
end)