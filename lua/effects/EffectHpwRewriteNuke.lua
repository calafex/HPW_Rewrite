 AddCSLuaFile()

local glow = CreateMaterial("glow", "UnlitGeneric", {["$basetexture"] = "sprites/orangecore1", ["$spriterendermode"] = 9, ["$ignorez"] = 1, ["$illumfactor"] = 8, ["$additive"] = 1, ["$vertexcolor"] = 1, ["$vertexalpha"] = 1})

function EFFECT:Init(data)
	self.Start = data:GetOrigin()
	self.LifeTime = CurTime() + 32
	self.Index = math.random(1, 1337)
	
	self.Value = 1
	self.Alpha = 255
	self.Size = 0

	local tr = util.TraceLine({
		start = self.Start,
		endpos = self.Start - vector_up * 5000,
		mask = MASK_SOLID_BRUSHONLY
	})

	self.Mushroom = tr.Hit

	hook.Add("RenderScreenspaceEffects", "hpwrewrite_nuke_blind" .. self.Index, function()
		local val = self.Value
		if not val then return end

		local tab = {
			["$pp_colour_addr"] = 1 * val,
			["$pp_colour_addg"] = 0.5 * val,
			["$pp_colour_addb"] = 0,
			["$pp_colour_brightness"] = -0.1 * val,
			["$pp_colour_contrast"] = 1 + 0.8 * val,
			["$pp_colour_colour"] = 1 - 0.7 * val,
			["$pp_colour_mulr"] = 0,
			["$pp_colour_mulg"] = 0,
			["$pp_colour_mulb"] = 0
		}
		
		DrawColorModify(tab)
	end)

	util.ScreenShake(self:GetPos(), 4, 2, 15, 100000) 

	sound.Play("ambient/explosions/explode_1.wav", LocalPlayer():GetPos(), 100, 50)

	for i = 1, 3 do
		sound.Play("drones/missilelaunch.wav", self.Start, 150, 30)
		sound.Play("drones/missilelaunch.wav", self.Start, 150, 60)
		sound.Play("ambient/explosions/explode_6.wav", self.Start, 150)
		sound.Play("ambient/explosions/explode_6.wav", self.Start, 180)
	end

	self.Emitter = ParticleEmitter(self.Start)

	local p = self.Emitter:Add("sprites/heatwave", self.Start)
	p:SetDieTime(10)
	p:SetStartAlpha(255)
	p:SetEndAlpha(0)
	p:SetStartSize(math.Rand(4000, 8000))
	p:SetEndSize(20000)
	p:SetRoll(math.Rand(-5, 5))
	p:SetRollDelta(math.Rand(-5, 5))

	for i = 1, 90 do
		local i = i * 2

		for a = 1, 2 do
			local p = self.Emitter:Add("particle/smokesprites_000" .. math.random(3, 9), self.Start)
			p:SetDieTime(math.random(10, 20))
			p:SetStartAlpha(64)
			p:SetEndAlpha(0)
			p:SetStartSize(2000)
			p:SetEndSize(1000)
			p:SetRollDelta(math.random(-0.4, 0.4))
			p:SetVelocity(Vector(math.sin(i / 2), math.cos(i / 2), 0) * 8000)
			p:SetColor(80, 50, 50)
		end

		for a = 1, 4 do
			local vec = VectorRand()
			vec.z = 0

			local p = self.Emitter:Add("particle/smokesprites_000" .. math.random(3, 9), self.Start + vec * 20000)
			p:SetDieTime(math.random(10, 25))
			p:SetStartAlpha(64)
			p:SetEndAlpha(0)
			p:SetStartSize(0)
			p:SetEndSize(math.random(1000, 2000))
			p:SetRollDelta(math.random(-0.4, 0.4))
			p:SetVelocity(Vector(math.sin(i / 2), math.cos(i / 2), 0) * 400)
			p:SetColor(50, 50, 50)
		end

		local size = math.random(1300, 2300)

		if self.Mushroom then
			local p = self.Emitter:Add("particle/smokesprites_000" .. math.random(3, 9), self.Start)
			p:SetDieTime(math.random(35, 45) + i * 0.02)
			p:SetStartAlpha(150)
			p:SetEndAlpha(0)
			p:SetStartSize(800)
			p:SetEndSize(size * 0.9)
			p:SetRollDelta(math.random(-0.4, 0.4))	
			p:SetAirResistance(12)
			p:SetVelocity(vector_up * i * 8 + VectorRand() * 100)
			p:SetColor(50, 50, 50)

			local p = self.Emitter:Add("particles/fir21", self.Start)
			p:SetDieTime(math.random(6, 8) + i * 0.02)
			p:SetStartAlpha(155)
			p:SetEndAlpha(0)
			p:SetStartSize(size * 0.6)
			p:SetEndSize(size * 0.2)
			p:SetRollDelta(math.random(-0.4, 0.4))	
			p:SetAirResistance(12)
			p:SetVelocity(vector_up * i * 8 + VectorRand() * 60)

			local size = math.random(1024, 2048)

			for i = 1, 3 do
				local p = self.Emitter:Add("particle/smokesprites_000" .. math.random(3, 9), self.Start)
				p:SetDieTime(math.random(45, 55))
				p:SetStartAlpha(150)
				p:SetEndAlpha(0)
				p:SetStartSize(1000)
				p:SetEndSize(size * 1.3)
				p:SetRollDelta(math.random(-0.4, 0.4))
				p:SetAirResistance(12)
				local vec = VectorRand()
				vec.z = vec.z * 0.8
				p:SetVelocity(vector_up * 1900 + vec * size * 0.45)
				p:SetColor(50, 50, 50)
			end

			local p = self.Emitter:Add("particles/fir21", self.Start)
			p:SetDieTime(math.random(4, 8))
			p:SetStartAlpha(150)
			p:SetEndAlpha(0)
			p:SetStartSize(size)
			p:SetEndSize(size)
			p:SetRollDelta(math.random(-2, 2))
			p:SetAirResistance(12)
			p:SetVelocity(vector_up * 1900 + VectorRand() * size * 0.4)
		end

		local size = math.random(2500, 3500)

		local p = self.Emitter:Add("particles/fir21", self.Start)
		p:SetDieTime(math.random(4, 6))
		p:SetStartAlpha(255)
		p:SetEndAlpha(0)
		p:SetStartSize(800)
		p:SetEndSize(400)
		p:SetRollDelta(math.random(-0.4, 0.4))	
		p:SetAirResistance(math.random(75, 140))
		p:SetVelocity(Vector(math.sin(i), math.cos(i), 0) * 8000)

		local p = self.Emitter:Add("particle/smokesprites_000" .. math.random(3, 9), self.Start)
		p:SetDieTime(math.random(42, 46))
		p:SetStartAlpha(100)
		p:SetEndAlpha(0)
		p:SetStartSize(1000)
		p:SetEndSize(size * 0.8)
		p:SetRollDelta(math.random(-0.4, 0.4))	
		p:SetAirResistance(math.random(75, 140))
		p:SetVelocity(Vector(math.sin(i), math.cos(i), 0) * 8000)
		p:SetColor(50, 50, 50)

		local p = self.Emitter:Add("particle/smokesprites_000" .. math.random(3, 9), self.Start + Vector(0, 0, math.random(400, 1000)))
		p:SetDieTime(math.random(42, 46))
		p:SetStartAlpha(100)
		p:SetEndAlpha(0)
		p:SetStartSize(1000)
		p:SetEndSize(size * 0.8)
		p:SetRollDelta(math.random(-0.4, 0.4))
		p:SetAirResistance(math.random(75, 140))
		p:SetVelocity(Vector(math.sin(i), math.cos(i), 0) * 4000)
		p:SetColor(50, 50, 50)
	end
end

function EFFECT:Think()
	self.Value = math.Approach(self.Value, 0, 0.0008)
	self.Alpha = math.Approach(self.Alpha, 0, 1)
	self.Size = math.Approach(self.Size, 50000, 1000)

	if CurTime() > self.LifeTime then
		hook.Remove("RenderScreenspaceEffects", "hpwrewrite_nuke_blind" .. self.Index)

		self.Emitter:Finish()
	end

	return CurTime() < self.LifeTime
end

function EFFECT:Render()
	render.SetMaterial(glow)
	render.DrawSprite(self.Start, self.Size, self.Size, Color(255, 255, 255, self.Alpha))
end

