AddCSLuaFile()

ENT.Type = "anim"
ENT.DisableDuplicator = true

function ENT:SetupDataTables()
	self:NetworkVar("Entity", 0, "Player")
end

function ENT:Initialize()
	self:DrawShadow(false)
end

function ENT:Think()
	if SERVER then return end

	-- Always render omg!
	self:SetRenderBoundsWS(self:GetPos(), LocalPlayer():GetEyeTrace().HitPos)
end

if CLIENT then
	local mat = Material("hpwrewrite/particles/purplerope")

	local sin = math.sin
	local cos = math.cos
	local max = math.max
	local random = math.Rand

	function ENT:OnRemove()
		if self.Emitter then self.Emitter:Finish() end
	end

	function ENT:Draw()
		local ply = self:GetPlayer()
		if not ply:IsValid() then return end

		local _vm = ply:GetViewModel()
		local vm = _vm
		if not IsValid(vm) or ply:ShouldDrawLocalPlayer() then vm = HpwRewrite:GetWand(ply) end
		if IsValid(vm) then
			local obj = vm:LookupBone("spritemagic")
			
			if obj then
				local m = vm:GetBoneMatrix(obj)
				if not m then return end
				local endPos = m:GetTranslation()

				if vm == _vm then
					endPos = endPos - EyeAngles():Forward() * 10
				end

				local x = CurTime()

				for a = 1, 4 do
					local endPos = endPos
					local points = { }
					local nPoints = 20

					local dist = 1
					local dif = vector_origin
					local x = x + a * 10

					for i = 1, nPoints do
						table.insert(points, endPos)

						local val = max(0.1, i / nPoints)

						dist = endPos:Distance(self:GetPos()) * val

						dif = dif + Vector(sin(x) * a, 
							(sin(x * 20 * val) + sin(x * 2)) * a, 
							cos(x * 32 * val) * a + cos(x * a)) * 0.05

						dif = dif:GetNormal()
						dif = LerpVector(0.6, dif, (self:GetPos() - endPos):GetNormal())

						if i == nPoints then endPos = self:GetPos() else endPos = endPos + (dif * dist * val) end
					end

					if self.DrawTime and CurTime() > self.DrawTime then
						if self.Emitter then
							local grav = Vector(0, 0, -140)

							for k, v in pairs(points) do
								local vel = VectorRand() * 30
								local die = random(0.3, 0.6)

								local p = self.Emitter:Add("hpwrewrite/sprites/magicsprite", v)
								p:SetBounce(0.8)
								p:SetCollide(true)
								p:SetStartSize(3)
								p:SetEndSize(0)
								p:SetStartAlpha(255)
								p:SetEndAlpha(0)
								p:SetDieTime(die)
								p:SetVelocity(vel)
								p:SetGravity(grav)
								p:SetAirResistance(10)
								p:SetColor(255, 0, 255)

								local p = self.Emitter:Add("hpwrewrite/sprites/magicsprite", v)
								p:SetBounce(0.8)
								p:SetCollide(true)
								p:SetStartSize(1)
								p:SetEndSize(0)
								p:SetStartAlpha(255)
								p:SetEndAlpha(0)
								p:SetDieTime(die)
								p:SetVelocity(vel)
								p:SetGravity(grav)
								p:SetAirResistance(10)
								p:SetColor(255, 255, 255)
							end
						else
							self.Emitter = ParticleEmitter(self:GetPos())
						end
					end

					if not self.Size then self.Size = { } end

					render.SetMaterial(mat) 
					render.StartBeam(nPoints)
						for k, v in pairs(points) do
							if not self.Size[k] then self.Size[k] = 0 end
							self.Size[k] = math.Approach(self.Size[k], (k / nPoints) * 30, FrameTime())

							render.AddBeam(v, self.Size[k], math.Rand(-1, 1), color_white)
						end
					render.EndBeam()
				end

				self.DrawTime = CurTime()
			end
		end
	end
end