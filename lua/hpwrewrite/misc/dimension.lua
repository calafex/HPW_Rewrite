if SERVER then AddCSLuaFile() return end

local Dimension = false
local Ending = false
local Blinded = false
local PortalPos = vector_origin

--local Video = nil

local HookCache = { }
local TimerCache = { }
local SoundCache = { }
local ModelCache = { }

local CreatePhysModel = function(mdl)
	local ent = ents.CreateClientProp()
	ent:SetModel(mdl)
	ent:PhysicsInit(SOLID_VPHYSICS)
	ent:SetMoveType(MOVETYPE_VPHYSICS)
	ent:SetSolid(SOLID_VPHYSICS)

	table.insert(ModelCache, ent)

	return ent
end

local CreateModel = function(mdl)
	local ent = ClientsideModel(mdl, RENDERGROUP_OTHER)

	table.insert(ModelCache, ent)
	
	return ent
end

local AddSound = function(name)
	local snd = CreateSound(LocalPlayer(), name)
	
	table.insert(SoundCache, snd)
	
	return snd
end

local NewHookAdd = function(str, name, func)
	name = "dimension_hook_" .. name
	
	hook.Add(str, name, func)
	
	table.insert(HookCache, {
		str = str,
		name = name
	})
end

local NewTimerSimple = function(time, func)
	local name = "dimension_timer_" .. table.Count(TimerCache)
	timer.Create(name, time, 1, func)
	
	table.insert(TimerCache, {
		name = name
	})
end

local StopTimers = function() for k, v in pairs(TimerCache) do timer.Remove(v.name) end end
local RemoveHooks = function() for k, v in pairs(HookCache) do hook.Remove(v.str, v.name) end end
local StopSounds = function() for k, v in pairs(SoundCache) do if v then v:Stop() end end end
local RemoveModels = function() for k, v in pairs(ModelCache) do SafeRemoveEntity(v) end end

local function GetRandomPosition()
	local tr = util.TraceLine({
		start = LocalPlayer():GetPos(),
		endpos = LocalPlayer():GetPos() + vector_up * 50000,
		filter = LocalPlayer()
	})

	tr = util.TraceLine({
		start = tr.HitPos + tr.HitNormal * 8,
		endpos = tr.HitPos + Vector(math.sin(math.Rand(0, 360)) * math.random(100, 10000), math.cos(math.Rand(0, 360)) * math.random(100, 10000), 0),
		filter = LocalPlayer()
	})

	tr = util.TraceLine({
		start = tr.HitPos + tr.HitNormal * 8,
		endpos = tr.HitPos - vector_up * 200000,
		filter = LocalPlayer()
	})

	return tr
end

local function MakeBlind(time, force)
	if not force and Blinded then return end
	Blinded = true

	local blind = 0
	local reverse = false

	local name = force and "render_forcedblind" or "render_blind"

	NewHookAdd("RenderScreenspaceEffects", name, function()
		if reverse then
			blind = Lerp(0.1, blind, 0)
		else
			blind = Lerp(0.1, blind, 1)
		end

		local eff_tab = {
			["$pp_colour_addr"] = 0,
			["$pp_colour_addg"] = 0,
			["$pp_colour_addb"] = 0,
			["$pp_colour_brightness"] = blind,
			["$pp_colour_contrast"] = 1,
			["$pp_colour_colour"] = 1,
			["$pp_colour_mulr"] = 0,
			["$pp_colour_mulg"] = 0,
			["$pp_colour_mulb"] = 0
		}
				
		DrawColorModify(eff_tab)
	end)

	NewTimerSimple(time / 2, function()
		reverse = true
	end)

	NewTimerSimple(time, function()
		hook.Remove("RenderScreenspaceEffects", "dimension_hook_" .. name)
		Blinded = false
	end)
end

local function End()
	RemoveHooks()
	StopTimers()
	StopSounds()
	RemoveModels()
			
	--if IsValid(Video) then Video:Stop() end

	LocalPlayer():DrawViewModel(true)
			
	Blinded = false
	Dimension = false
end

local function EndSmoothly()
	if not Dimension then return end

	for k, v in pairs(SoundCache) do
		if v then v:ChangeVolume(0, 3) end
	end

	local oldpos = LocalPlayer():EyePos()
	local oldangles = LocalPlayer():EyeAngles()

	local newpos = oldpos
	local newang = oldangles

	local ratio = 0

	NewHookAdd("CalcView", "byebye", function(ply, pos, ang, fov)
		ratio = Lerp(0.005, ratio, 200)

		newpos = newpos + (PortalPos - newpos):GetNormal() * ratio
		newang = LerpAngle(0.01, newang, (PortalPos - pos):Angle())

		local view = { }
		view.origin = newpos
		view.angles = newang
		view.fov = 60
			
		return view
	end)

	local endtime = math.Round(oldpos:Distance(PortalPos) / 2300)

	NewTimerSimple(endtime, function() 
		MakeBlind(15, true)
		Ending = true
	end)

	NewTimerSimple(7.5 + endtime, function()
		hook.Remove("CalcView", "dimension_hook_viewbase")
		hook.Remove("CalcView", "dimension_hook_byebye")

		RemoveModels()
	end)

	NewTimerSimple(9 + endtime, function() End() end)
end

local Emitter = ParticleEmitter(Vector(0, 0, 0))

local function OpenDimension()
	if Dimension then return end

	Dimension = true
	Ending = false

	local Start = 0

	local voice = {
		"vo/breencast/br_welcome02.wav",
		"vo/breencast/br_welcome03.wav",
		"vo/breencast/br_welcome04.wav",
		"vo/breencast/br_welcome05.wav",
		"vo/breencast/br_welcome06.wav",
		"vo/breencast/br_welcome07.wav",
		"vo/breencast/br_instinct01.wav",
		"vo/breencast/br_collaboration07.wav",
		"vo/breencast/br_collaboration06.wav",
		"vo/breencast/br_collaboration05.wav",
		"vo/breencast/br_collaboration02.wav",
		"vo/eli_lab/eli_vilebiz03.wav",
		"vo/citadel/br_newleader_c.wav",
		"vo/k_lab/kl_modifications01.wav"
	}

	local mdls = {
		"models/props_junk/bicycle01a.mdl",
		"models/props_junk/meathook001a.mdl",
		"models/props_interiors/Furniture_Couch02a.mdl",
		"models/props_c17/doll01.mdl",
		"models/props_lab/monitor01a.mdl",
		"models/props_lab/harddrive02.mdl",
		"models/props_junk/wood_crate002a.mdl",
		"models/props_junk/wood_crate001a.mdl",
		"models/props_wasteland/controlroom_filecabinet001a.mdl",
		"models/props_junk/TrafficCone001a.mdl"
	}

	local mdls_2 = {
		"models/props_interiors/Furniture_shelf01a.mdl",
		"models/props_lab/blastdoor001c.mdl",
		"models/props_c17/FurnitureBed001a.mdl",
		"models/props_vehicles/car002a_physics.mdl",
		"models/props_vehicles/car001b_hatchback.mdl",
		"models/props_vehicles/van001a_physics.mdl",
		"models/props_trainstation/train005.mdl"
	}

	for k, v in pairs(mdls) do table.insert(mdls_2, v) end

	NewHookAdd("Think", "main", function()
		Start = math.Approach(Start, Ending and 0 or 1, FrameTime())

		if Start >= 1 then
			local plypos = LocalPlayer():GetPos()

			if math.random(1, 2) == 1 then
				local tr = util.TraceLine({
					start = plypos,
					endpos = plypos + vector_up * math.random(300, 500),
					filter = LocalPlayer()
				})

				local vec = Vector(math.random(-2000, -1000), math.random(-1000, 1000), math.random(-300, 100))

				tr = util.TraceLine({
					start = tr.HitPos,
					endpos = tr.HitPos + vec,
					filter = LocalPlayer()
				})

				local ang = AngleRand()
				local ent = CreateModel(table.Random(mdls))
				ent:SetPos(tr.HitPos + tr.HitNormal * 32)
				ent:SetAngles(ang)
				ent:Spawn()

				ent.Box = true
				ent.MoveVal = math.random(40, 80)
				ent.AngCoef = math.Rand(0.01, 0.1)
				ent.OldAngle = ang

				NewTimerSimple(9, function() SafeRemoveEntity(ent) end)
			end

			if PortalPos then
				local tr = GetRandomPosition()
				local ang = AngleRand()

				local ent = CreateModel(table.Random(mdls_2))
				ent:SetPos(tr.HitPos + tr.HitNormal * 32)
				ent:SetAngles(ang)
				ent:Spawn()

				ent.ToPortal = true
				ent.MoveVal = math.random(40, 80)
				ent.OldAngle = ang

				NewTimerSimple(9, function() SafeRemoveEntity(ent) end)
			end

			for k, v in pairs(ModelCache) do
				if v.Box then
					v:SetPos(v:GetPos() + Vector(v.MoveVal, 0, 0))
					v:SetAngles(v:GetAngles() + v.OldAngle * 0.03)
				end

				if v.ToPortal then
					local vec = (PortalPos - v:GetPos()):GetNormal() * v.MoveVal
					v:SetPos(v:GetPos() + vec)
					v:SetAngles(v:GetAngles() + v.OldAngle * 0.03)

					if v:GetPos():Distance(PortalPos) < 100 then SafeRemoveEntity(v) end
				end
			end

			if math.random(1, 60) == 1 then
				local snd = AddSound("ambient/wind/wind_snippet" .. math.random(1, 5) .. ".wav")
				snd:Play()
			end

			if math.random(1, 80) == 1 then
				local snd = AddSound("ambient/wind/wind_hit" .. math.random(1, 3) .. ".wav")
				snd:Play()
			end

			if math.random(1, 160) == 1 then
				local snd = AddSound(table.Random(voice))
				snd:Play()
				snd:ChangeVolume(math.Rand(0.07, 0.1), 0)
				snd:ChangePitch(math.random(75, 90), 0)
			end

			if math.random(1, 600) == 1 then
				MakeBlind(3)
			end

			if PortalPos then
				local vec = VectorRand() * 5000
				vec.z = math.random(-200, 0)
				local p = Emitter:Add("sprites/orangecore1", PortalPos + vec)
				
				p:SetDieTime(8)
				p:SetStartAlpha(120)
				p:SetEndAlpha(0)
				p:SetStartSize(math.random(500, 1000))
				p:SetRoll(math.Rand(-10, 10))
				p:SetRollDelta(math.Rand(-5, 5))
				p:SetEndSize(0)		
				p:SetVelocity(-vec * 0.3)
				p:SetGravity(Vector(0, 0, -1000) + vec * 0.5)
				p:SetColor(0, 255, 255)

				for a = 1, 4 do
					local vec = GetRandomPosition().HitPos
					vec.x = vec.x / 2
					vec.y = vec.y / 2

					local p = Emitter:Add("effects/fleck_cement" .. math.random(1, 2), vec)
					
					p:SetDieTime(15)
					p:SetStartAlpha(255)
					p:SetEndAlpha(0)
					p:SetStartSize(math.random(20, 40))
					p:SetRoll(math.Rand(-10, 10))
					p:SetRollDelta(math.Rand(-16, 16))
					p:SetEndSize(0)		
					p:SetVelocity(VectorRand() * 1000)
					p:SetGravity((PortalPos - vec):GetNormal() * math.random(1000, 3000))
					p:SetColor(0, 0, 0)
				end
			end

			local PPos = plypos + Vector(0, 0, 200)

			for i = 1, 5 do
				local vec = VectorRand() * 4000
				vec.z = PPos.z + math.random(-200, 500)
				local p = Emitter:Add("particle/smokesprites_000" .. math.random(1, 9), PPos + vec)
				
				p:SetDieTime(6)
				p:SetStartAlpha(120)
				p:SetEndAlpha(0)
				p:SetStartSize(math.random(500, 1000))
				p:SetRoll(math.Rand(-10, 10))
				p:SetRollDelta(math.Rand(-5, 5))
				p:SetEndSize(200)		
				p:SetGravity(Vector(math.random(7000, 9000), 0, 0) + VectorRand() * 200)
				p:SetColor(100, 85, 66)

				for a = 1, 10 do
					local vec = VectorRand() * 4000
					vec.z = PPos.z + math.random(-200, 500)
					local p = Emitter:Add("effects/fleck_cement" .. math.random(1, 2), PPos + vec)
					
					p:SetDieTime(9)
					p:SetStartAlpha(200)
					p:SetEndAlpha(0)
					p:SetStartSize(math.random(5, 20))
					p:SetRoll(math.Rand(-10, 10))
					p:SetRollDelta(math.Rand(-1, 1))
					p:SetEndSize(0)		
					p:SetVelocity(VectorRand() * 100)
					p:SetGravity(Vector(math.random(3000, 5000), 0, 0) + VectorRand() * 200)
					p:SetColor(100, 85, 66)
				end

				for a = 1, 10 do
					local vec = VectorRand() * 4000
					vec.z = PPos.z + math.random(-200, 500)
					local p = Emitter:Add("effects/fleck_cement" .. math.random(1, 2), PPos + vec)
					
					p:SetDieTime(9)
					p:SetStartAlpha(200)
					p:SetEndAlpha(0)
					p:SetStartSize(math.random(5, 10))
					p:SetRoll(math.Rand(-10, 10))
					p:SetRollDelta(math.Rand(-1, 1))
					p:SetEndSize(0)		
					p:SetVelocity(VectorRand() * 100)
					p:SetGravity(Vector(math.random(3000, 4000), 0, 0))
					p:SetColor(255, 255, 255)
				end
			end
		end
	end)

	NewHookAdd("RenderScreenspaceEffects", "render", function()
		local eff_tab = {
			["$pp_colour_addr"] = 0,
			["$pp_colour_addg"] = 0,
			["$pp_colour_addb"] = 0,
			["$pp_colour_brightness"] = 0,
			["$pp_colour_contrast"] = 1,
			["$pp_colour_colour"] = 1 - Start,
			["$pp_colour_mulr"] = 0,
			["$pp_colour_mulg"] = 0,
			["$pp_colour_mulb"] = 0
		}
				
		DrawColorModify(eff_tab)
			
		DrawBloom(Start * 0.24, Start * 3.2, Start * 11, Start * 9, Start, Start, Start, Start, Start) 
		DrawMotionBlur(Start * 0.2, Start * 0.2, 1.2 - Start)
		DrawToyTown(Start * 8, ScrH())
	end)

	NewHookAdd("HUDShouldDraw", "nohud", function(name) 
		if name != "CHudGMod" then return false end
	end)

	NewHookAdd("PlayerBindPress", "nobinds", function(ply, bind, p)
		local tools = {
			"phys_swap",
			"slot",
			"invnext",
			"invprev",
			"lastinv",
			"gmod_tool",
			"gmod_toolmode"
		}

		for k, v in pairs(tools) do if bind:find(v) then return true else return false end end
	end)

	NewHookAdd("HUDPaint", "noise", function()
		--surface.SetMaterial(Material("dimension/oldnoise"))
		--surface.SetDrawColor(Color(255, 255, 255, 20 * Start))
		--surface.DrawTexturedRect(0, 0, ScrW(), ScrH())
	end)

	NewTimerSimple(1, function() MakeBlind(6) end)

	-- Initialize code is here
	NewTimerSimple(3, function()
		LocalPlayer():DrawViewModel(false)

		local trees = {
			"models/props_foliage/tree_cliff_01a.mdl",
			"models/props_foliage/tree_deciduous_03b.mdl",
			"models/props_foliage/tree_deciduous_03a.mdl",
			"models/props_foliage/tree_poplar_01.mdl",
			"models/props_foliage/tree_deciduous_01a.mdl",
			"models/props_foliage/tree_deciduous_01a-lod.mdl"
		}

		-- Spawning trees
		for i = 1, 250 do
			local tr = GetRandomPosition()

			if tr.MatType == MAT_GRASS or tr.MatType == MAT_DIRT then
				local mdl = CreateModel(table.Random(trees))
				mdl:SetPos(tr.HitPos - tr.HitNormal * 16)
				mdl:SetAngles(AngleRand() * 0.1)
				mdl:Spawn()
			end
		end

		--[[
		local cars = {
			"models/props_vehicles/car001a_hatchback.mdl",
			"models/props_vehicles/car002b_physics.mdl",
			"models/props_vehicles/car003a_physics.mdl",
			"models/props_vehicles/car005a_physics.mdl",
			"models/props_vehicles/car004b_physics.mdl",
			"models/props_vehicles/car001b_hatchback.mdl",
			"models/props_vehicles/car002a_physics.mdl",
			"models/props_vehicles/car005b_physics.mdl"
		}

		-- Spawning cars
		for i = 1, 40 do
			local tr = GetRandomPosition()

			local mdl = CreateModel(table.Random(cars))
			mdl:SetPos(tr.HitPos)
			mdl:SetAngles(Angle(0, math.random(-180, 180), 0))
			mdl:Spawn()
		end

		-- Spawning strange columns ??!?!?
		for i = 1, 10 do
			local pos = GetRandomPosition()
			if pos.HitWorld then
				local pos = pos.HitPos
				pos.x = pos.x * 3
				pos.y = pos.y * 3

				local mdl = CreateModel("models/props_c17/column02a.mdl")
				mdl:SetPos(pos)
				mdl:SetAngles(Angle(0, math.random(-180, 180), 0))
				mdl:Spawn()
				mdl:SetMaterial("models/props_vents/borealis_vent001c")
				mdl:SetColor(Color(50, 50, 50))
				mdl:SetModelScale(math.Rand(0.4, 1.2))
			end
		end]]

		-- Spawning portal
		local tr = util.TraceLine({
			start = LocalPlayer():GetPos(),
			endpos = LocalPlayer():GetPos() + vector_up * 200000,
			filter = LocalPlayer()
		})

		if tr.HitSky then
			PortalPos = tr.HitPos + tr.HitNormal * 8

			local mdl = CreateModel("models/effects/combineball.mdl")
			mdl:SetPos(PortalPos)
			mdl:SetAngles(Angle(90, 0, 0))
			mdl:Spawn()
			mdl:SetModelScale(1200, 0)
		else
			PortalPos = LocalPlayer():GetPos() + vector_up * 10000
		end

		--LocalPlayer():SetEyeAngles(Angle(90, 0, 0))

		--local newpos = PortalPos
		--local ratio = 0

		--[[NewHookAdd("CalcView", "start", function(ply, pos, ang, fov)
			ratio = Lerp(0.0001, ratio, 2)

			newpos = newpos + (LocalPlayer():EyePos() - newpos) * ratio

			if newpos:Distance(LocalPlayer():EyePos()) <= 400 then
				MakeBlind(4, true)

				hook.Remove("CalcView", "dimension_hook_start")

				NewHookAdd("CalcView", "viewbase", function(ply, pos, ang, fov)
					local view = { }
					view.origin = pos
					view.angles = ang + AngleRand() * 0.0009
					view.fov = 60
					
					return view
				end)

				return
			end

			local view = { }
			view.origin = newpos
			view.angles = ang
			view.fov = 60
				
			return view
		end)]]

		NewHookAdd("CalcView", "viewbase", function(ply, pos, ang, fov)
			local view = { }
			view.origin = pos
			view.angles = ang + AngleRand() * 0.0009
			view.fov = 60
					
			return view
		end)

		local snd = AddSound("music/hl1_song3.mp3")
		snd:Play()
		snd:ChangePitch(90, 10)
		snd:ChangeVolume(0.7, 3)

		local snd = AddSound("music/hl2_intro.mp3")
		snd:Play()
		snd:ChangePitch(80, 6)
		snd:ChangeVolume(0.55, 3)

		local snd = AddSound("ambient/alarms/city_siren_loop2.wav")
		snd:Play()
		snd:ChangeVolume(0.45, 0)

		local snd = AddSound("ambient/levels/canals/windmill_wind_loop1.wav")
		snd:Play()
		snd:ChangeVolume(0, 0)
		snd:ChangeVolume(0.2, 6)

		local snd = AddSound("dimension/screamshorror.wav")
		snd:Play()
		snd:ChangeVolume(0.8, 0)
	end)

	NewTimerSimple(60, function()
		EndSmoothly()
	end)
end

net.Receive("hpwrewrite_Dim", function()
	OpenDimension()
end)

hook.Add("PlayerSwitchWeapon","HPWDimensioStopSwitching",function(who)
	if Dimension == true then
		return true
	end
end)

net.Receive("hpwrewrite_EDim", function()
	EndSmoothly()
end)