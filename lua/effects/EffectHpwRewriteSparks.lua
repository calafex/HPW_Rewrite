AddCSLuaFile()

function EFFECT:Init(data)
	self.Hide = HpwRewrite.CVars.HideSparks:GetBool()
	if self.Hide then return end

	local ply = data:GetEntity()
	local col = data:GetStart()
	local dieTime = data:GetScale()

	self.OldPos = vector_origin
	self.Vel = vector_origin
	self.Color = Color(col.x, col.y, col.z)

	self.DieTime = CurTime() + dieTime
	self.Wait = 0
	
	if not IsValid(ply) then return end
	
	self.Player = ply
	self.ViewModel = ply:GetViewModel()

	local vm = self.ViewModel
	if not IsValid(vm) or ply:ShouldDrawLocalPlayer() then vm = HpwRewrite:GetWand(ply) end
	if not IsValid(vm) then return end

	self.Wand = vm

	local vec = Vector(100, 100, 100)
	local pos = vm:GetPos()
	self:SetRenderBoundsWS(pos - vec, pos + vec)
end

function EFFECT:Think() 
	if self.Hide then return false end

	if CurTime() > self.DieTime then 
		if self.Emitter then self.Emitter:Finish() end
		return false 
	end

	return true
end

function EFFECT:Render() 
	if self.Hide then return end

	if CurTime() > self.Wait then
		if IsValid(self.Wand) and IsValid(self.Player) then
			local obj = self.Wand:LookupBone("spritemagic")

			if obj then
				local m = self.Wand:GetBoneMatrix(obj)
				if m then
					local pos = m:GetTranslation()
					if self.Wand == self.ViewModel then pos = pos - self.Player:EyeAngles():Forward() * 10 end

					self.Pos = pos
					local vec = self.Pos - self.OldPos
					self.OldPos = self.Pos

					self.Vel = (vec * (vec:Length() ^ 2) * 0.075) + VectorRand() * 10

					if not self.Emitter then
						self.Emitter = ParticleEmitter(self.Pos) 
						return
					end

					local dieTime = math.Rand(0.2, 0.4)
					local vel = self.Vel
					local grav = self.Vel --Vector(0, 0, -20)
					local resist = math.random(15, 40)

					local p = self.Emitter:Add("hpwrewrite/sprites/magicsprite", self.Pos)
					p:SetBounce(0.8)
					p:SetCollide(true)
					p:SetStartSize(3)
					p:SetEndSize(0)
					p:SetStartAlpha(255)
					p:SetEndAlpha(0)
					p:SetDieTime(dieTime)
					p:SetVelocity(vel)
					p:SetGravity(grav)
					p:SetAirResistance(resist)

					local col = self.Color
					p:SetColor(col.r, col.g, col.b)

					local p = self.Emitter:Add("hpwrewrite/sprites/magicsprite", self.Pos)
					p:SetBounce(0.8)
					p:SetCollide(true)
					p:SetStartSize(1)
					p:SetEndSize(0)
					p:SetStartAlpha(255)
					p:SetEndAlpha(0)
					p:SetDieTime(dieTime)
					p:SetVelocity(vel)
					p:SetGravity(grav)
					p:SetAirResistance(resist)
					p:SetColor(255, 255, 255)
				end
			end
		end

		self.Wait = CurTime() + math.Rand(0.001, 0.015)
	end
end