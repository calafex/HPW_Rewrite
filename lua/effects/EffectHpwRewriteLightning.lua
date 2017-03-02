AddCSLuaFile()

local validEffects = 0

local Vector = Vector
local VectorRand = VectorRand
local sin = math.sin
local cos = math.cos
local max = math.max
local ceil = math.ceil
local random = math.Rand

local redMat = Material("cable/redlaser")
local grMat = Material("cable/hydra")
local blueMat = Material("cable/blue_elec")

local mat2 = Material("cable/xbeam")

local glow = Material("hpwrewrite/sprites/magicsprite")
local glowColorRed = Color(255, 50, 50, 100)
local glowColorGreen = Color(50, 255, 50, 100)
local glowColorBlue = Color(50, 150, 255, 100)

local vmin = 2^8
local vmax = 2^32

function EFFECT:Init(data)
	local ply = data:GetEntity()
	local st = data:GetStart()

	self.EndPos = data:GetOrigin()
	self.RandomId = math.random(vmin, vmax)

	self.Mat = blueMat
	self.Color = glowColorBlue

	local type = data:GetAttachment()

	if type == 2 then
		self.Mat = grMat
		self.Color = glowColorGreen
	elseif type == 3 then
		self.Mat = redMat
		self.Color = glowColorRed
	end

	self.DieTime = CurTime() + 1
	self.Diff = Vector(0, 0, 0)

	self.LocalEndPos = { }
	self.LocalStartPos = { }

	local pos = st

	if IsValid(ply) then
		self.Player = ply
		self.ViewModel = ply:GetViewModel()

		local vm = self.ViewModel
		if not IsValid(vm) or ply:ShouldDrawLocalPlayer() then vm = HpwRewrite:GetWand(ply) end
		if not IsValid(vm) then return end

		self.Wand = vm

		pos = vm:GetPos()
	else
		self.StartPos = st 
	end

	local vec = Vector(1000, 1000, 1000)
	self:SetRenderBoundsWS(pos - vec, pos + vec)

	validEffects = validEffects + 1
end

function EFFECT:Think() 
	local pos = self.LocalEndPos[1]
	if pos then
		local dlight = DynamicLight(self.RandomId)
		if dlight then
			dlight.pos = pos
			dlight.r = self.Color.r
			dlight.g = self.Color.g
			dlight.b = self.Color.b
			dlight.brightness = 3
			dlight.Decay = 1000
			dlight.Size = 128
			dlight.DieTime = CurTime() + 1
		end
	end

	if CurTime() > self.DieTime then validEffects = validEffects - 1 return false end
	return true
end

function EFFECT:Render() 
	if not self.StartPos and IsValid(self.Wand) then
		local obj = self.Wand:LookupBone("spritemagic")

		if obj then
			local m = self.Wand:GetBoneMatrix(obj)
			if m then self.StartPos = m:GetTranslation() end
		end
	end

	if not self.StartPos then return end

	local dt = FrameTime()
	local value = dt * 1200
	local time = (self.DieTime - CurTime()) * value
	local unTime = (value / time)

	local quality = ceil(validEffects * 0.2)
	local x = CurTime()
	local nPoints = max(5, 10 - quality)

	for a = 1, max(1, 6 - quality) do
		if not self.LocalEndPos[a] then self.LocalEndPos[a] = self.StartPos end
		if not self.LocalStartPos[a] then self.LocalStartPos[a] = self.StartPos end

		local endPos = self.LocalEndPos[a]
		local pos = self.LocalStartPos[a] + VectorRand() * unTime

		self.LocalStartPos[a] = (pos + (endPos - pos):GetNormal() * time) + self.Diff * 60 * dt
		self.LocalEndPos[a] = (endPos + (self.EndPos - pos):GetNormal() * time) + self.Diff * 250 * dt

		local dist = 1
		local dif = vector_origin

		local points = { }

		for i = 1, nPoints do
			table.insert(points, pos)

			local val = max(0.1, i / nPoints)

			dist = pos:Distance(endPos) * val

			dif = dif + VectorRand()
			dif = LerpVector(0.6, dif, (endPos - pos):GetNormal())

			pos = pos + (dif * dist * val)
		end

		self.Diff = LerpVector(0.1, self.Diff, VectorRand())

		-- Rendering beams
		render.SetMaterial(self.Mat) 
		render.StartBeam(nPoints)
			for k, v in pairs(points) do
				render.AddBeam(v, (k / nPoints) * random(4, 12), random(0, 0.5), color_white)
			end
		render.EndBeam()

		--[[render.SetMaterial(mat2)
		render.StartBeam(nPoints)
			for k, v in pairs(points) do
				render.AddBeam(v, (k / nPoints), random(0, 1), color_white)
			end
		render.EndBeam()]]

		render.SetMaterial(glow)
		render.DrawSprite(endPos, 50 + unTime * 6, 50 + unTime * 6, self.Color)
	end
end