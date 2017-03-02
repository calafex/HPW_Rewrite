AddCSLuaFile()

ENT.Base = "base_anim"
ENT.Type = "anim"

ENT.AutomaticFrameAdvance = true

local model = Model("models/pigeon.mdl")

if SERVER then
	function ENT:Initialize()
		local color = ColorRand()

		self:DrawShadow(false)
		self:SetModel(model)
		self:SetColor(color)

		self:ResetSequence(0)
		self:SetPlaybackRate(math.Rand(0.6, 1.3))
		self:SetSequence(0)

		util.SpriteTrail(self, 0, color, true, 12, 0, 0.2, 1, "effects/laser1.vmt") 

		SafeRemoveEntityDelayed(self, math.Rand(2, 4))
	end

	function ENT:Think()
		if not self.Dir then self.Dir = self:GetAngles():Forward() end

		self:SetPos(self:GetPos() + self.Dir * 3)
		self:SetAngles(self.Dir:Angle())

		self.Dir = LerpVector(0.06, self.Dir, self.Dir + VectorRand())
		self.Dir = self.Dir:GetNormal()

		self:NextThink(CurTime())
		return true
	end
else
	local mat = Material("particle/fire")

	function ENT:Draw()
		local col = self:GetColor()
		local pos = self:GetPos() + Vector(0, 0, 6)

		local dlight = DynamicLight(self:EntIndex())
		if dlight then
			dlight.pos = pos
			dlight.r = col.r
			dlight.g = col.g
			dlight.b = col.b
			dlight.brightness = 3
			dlight.Decay = 1000
			dlight.Size = 128
			dlight.DieTime = CurTime() + 1
		end

		local sin = math.sin(CurTime() * 4) * 16
		render.SetMaterial(mat)
		render.DrawSprite(pos, 64 + sin, 64 + sin, col)

		self:DrawModel()
	end

	function ENT:OnRemove()
		local color = self:GetColor()

		local ef = EffectData()
		ef:SetOrigin(self:GetPos())
		ef:SetStart(Vector(color.r, color.g, color.b))
		util.Effect("balloon_pop", ef)
	end
end