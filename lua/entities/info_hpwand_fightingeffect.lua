AddCSLuaFile()

ENT.Type = "anim"
ENT.DisableDuplicator = true

function ENT:SetupDataTables()
	self:NetworkVar("String", 0, "FirstSpell")
	self:NetworkVar("String", 1, "SecondSpell")

	self:NetworkVar("Entity", 0, "FirstPlayer")
	self:NetworkVar("Entity", 1, "SecondPlayer")
end

function ENT:Initialize()
	self:DrawShadow(false)
end

function ENT:Think()
	if SERVER then
		for k, v in pairs(ents.FindInSphere(self:GetPos(), 40)) do
			if v.TakeDamage then 
				v:TakeDamage(math.random(2, 4)) 
			end
		end

		self:NextThink(CurTime() + 0.2)
		return true
	end

	-- Always render omg!
	self:SetRenderBoundsWS(self:GetPos(), LocalPlayer():GetEyeTrace().HitPos)
end

if CLIENT then
	local glow = Material("hpwrewrite/sprites/magicsprite")
	local sin = math.sin
	local cos = math.cos
	local max = math.max
	local random = math.random
	local playSound = sound.Play
	--local vector_origin = Vector(0, 0, 0)

	function ENT:RenderRope(ply, spell)
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

				local dist = 1
				local dif = vector_origin

				local points = { }
				local nPoints = 20

				for i = 1, nPoints do
					table.insert(points, endPos)

					local val = max(0.1, i / 20)

					dist = endPos:Distance(self:GetPos()) * val

					dif = dif + Vector(0, (sin(x * 16 * val)) + sin(x * 4), (cos(x * 32 * val) * 2) + cos(x * 2)) * 0.1
					dif = dif:GetNormal()
					dif = LerpVector(0.6, dif, (self:GetPos() - endPos):GetNormal())

					if i == 20 then endPos = self:GetPos() else endPos = endPos + (dif * dist * val) end

					if random(1, (1 / RealFrameTime()) * 6) == 1 then
						playSound("ambient/wind/wind_snippet" .. math.random(1, 2) .. ".wav", endPos, 72, 255)
						playSound("weapons/physcannon/superphys_small_zap" .. math.random(1, 4) .. ".wav", endPos, 73, math.random(100, 120))
					end
				end

				if spell then spell.FightingEffect(nPoints, points) end

				return nPoints, points
			end
		end
	end

	function ENT:Draw()
		local ply1 = self:GetFirstPlayer()
		local ply2 = self:GetSecondPlayer()

		if not ply1:IsValid() or not ply2:IsValid() then return end

		if not self.Spell1 then self.Spell1 = HpwRewrite:GetSpell(self:GetFirstSpell()) return end
		if not self.Spell2 then self.Spell2 = HpwRewrite:GetSpell(self:GetSecondSpell()) return end

		if self.Spell1.ImpactEffect or self.Spell2.ImpactEffect then
			if not self.Waiting then self.Waiting = 0 end

			if CurTime() > self.Waiting then
				if self.Spell1.ImpactEffect then HpwRewrite.MakeEffect(self.Spell1.ImpactEffect, self:GetPos(), AngleRand()) end
				if self.Spell2.ImpactEffect then HpwRewrite.MakeEffect(self.Spell2.ImpactEffect, self:GetPos(), AngleRand()) end

				self.Waiting = CurTime() + math.Rand(0.05, 0.15)
			end
		end

		local size = 140 + sin(CurTime() * 8) * 20
		render.SetMaterial(glow)

		for i = 1, 2 do 
			render.DrawSprite(self:GetPos(), size, size, HpwRewrite.Colors.White)

			if self.Spell1.SpriteColor then 
				local size = size + math.sin(CurTime() * 8) * 32
				render.DrawSprite(self:GetPos(), size * 2, size * 2, self.Spell1.SpriteColor) 
			end

			if self.Spell2.SpriteColor then 
				local size = size + math.sin(CurTime() * 16) * 32
				render.DrawSprite(self:GetPos(), size * 2, size * 2, self.Spell2.SpriteColor) 
			end
		end 

		self:RenderRope(ply1, self.Spell1)
		self:RenderRope(ply2, self.Spell2)
	end
end