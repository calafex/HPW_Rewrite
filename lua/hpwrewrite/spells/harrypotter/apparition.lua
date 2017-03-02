local Spell = { }
Spell.LearnTime = 900
Spell.Description = [[
	Turns you into smoke with 
	which you can fly around 
	the world.

	You can change smoke color 
	in clientside options.
]]

Spell.ShouldSay = false
Spell.ForceAnim = { ACT_VM_PRIMARYATTACK_3 }
Spell.CanSelfCast = false

Spell.NodeOffset = Vector(-605, 81, 0)
Spell.AccuracyDecreaseVal = 0
Spell.Enabled = false

PrecacheParticleSystem("hpw_apparation_white")
PrecacheParticleSystem("hpw_apparation_white_impact")

PrecacheParticleSystem("hpw_apparation_black")
PrecacheParticleSystem("hpw_apparation_black_impact")

local cube = Model("models/hunter/blocks/cube025x025x025.mdl")

function Spell:SetEnabled(val)
	if val then
		hook.Add("GetFallDamage", "hpwrewrite_apparition_handler" .. self.Owner:EntIndex(), function(ply)
			if ply == self.Owner then
				return 0
			end
		end)

		self.Owner:SetGravity(0.01) -- for some reason we can't set it to 0
		self.Owner:SetNoDraw(true)
		self.Owner:DrawShadow(false)
		self.Owner:SetVelocity(Vector(0, 0, 400))

		SafeRemoveEntity(self.EffectAtt)
		self.UseWhiteSmoke = tobool(self.Owner:GetInfo("hpwrewrite_cl_appwhitesmoke"))

		local e = ents.Create("prop_physics")
		self.EffectAtt = e

		local dir = self.Owner:GetAimVector()
		local pos = self.Owner:GetPos() + Vector(0, 0, 50) - dir * 80
		local ang = dir:Angle()

		e:SetModel(cube)
		e:SetPos(pos)
		e:SetAngles(ang)
		e:Spawn()

		e:SetColor(Color(0, 0, 0, 0))
		e:SetRenderMode(RENDERMODE_TRANSALPHA)
		e:GetPhysicsObject():EnableMotion(false)
		e:SetNotSolid(true)
		e:SetParent(self.Owner)

		local rad = math.rad
		local sin = math.sin
		local cos = math.cos
		local mat = self.UseWhiteSmoke and "hpwrewrite/sprites/apparition_white.vmt" or "hpwrewrite/sprites/apparition_black.vmt"

		self.Trails = { }

		for i = 1, 5 do
			local e = ents.Create("prop_physics")
			e:SetModel(cube)

			local rad = rad((i / 5) * 360)
			local vec = Vector(0, sin(rad) * 70, cos(rad) * 70)
			vec:Rotate(ang)

			e:SetPos(pos + vec)
			e:Spawn()

			util.SpriteTrail(e, 0, HpwRewrite.Colors.White, true, 0, 32, 1.8, 1, mat) 

			e:SetColor(Color(0, 0, 0, 0))
			e:SetRenderMode(RENDERMODE_TRANSALPHA)
			e:GetPhysicsObject():EnableMotion(false)
			e:SetNotSolid(true)
			e:SetParent(self.EffectAtt)

			self.Trails[i] = e
		end

		timer.Simple(FrameTime() * 3, function()
			if IsValid(e) then HpwRewrite.MakeEffect(self.UseWhiteSmoke and "hpw_apparation_white" or "hpw_apparation_black", nil, nil, e, PATTACH_ABSORIGIN_FOLLOW) end
		end)
	else
		hook.Remove("GetFallDamage", "hpwrewrite_apparition_handler" .. self.Owner:EntIndex())
		self.Owner:SetGravity(1)
		self.Owner:SetNoDraw(false)
		self.Owner:DrawShadow(true)

		if self.Trails then
			for k, v in pairs(self.Trails) do
				if IsValid(v) then
					v:SetParent(NULL)
					SafeRemoveEntityDelayed(v, 6)
				end
			end

			self.Trails = nil
		end

		SafeRemoveEntity(self.EffectAtt)
	end

	self.Enabled = val
end

function Spell:OnFire(wand)
	self:SetEnabled(not self.Enabled)
end

function Spell:Think()
	if CLIENT then return end
	if not self.Enabled then return end

	if math.random(1, 20) == 1 then
		sound.Play("ambient/wind/wind_hit" .. math.random(1, 3) .. ".wav", self.Owner:GetPos() + self.Owner:GetAimVector() * self.Owner:GetVelocity():Length() * 0.7, 78)
	end

	if IsValid(self.EffectAtt) then
		local ang = self.EffectAtt:GetAngles()
		ang:RotateAroundAxis(ang:Right(), 12)
		self.EffectAtt:SetAngles(ang)
	end
	
	local speed = (self.Owner:KeyDown(IN_SPEED) and 4300 or 2400)
	self.Owner:SetVelocity((-self.Owner:GetVelocity() + self.Owner:GetAimVector() * speed + VectorRand() * 400) * 0.035)

	if self.Owner:IsOnGround() or self.Owner:WaterLevel() > 2 then 
		self:SetEnabled(false) 
		HpwRewrite.MakeEffect(self.UseWhiteSmoke and "hpw_apparation_white_impact" or "hpw_apparation_black_impact", self.Owner:GetPos())
	end
end

if SERVER then
	function Spell:OnSelect() self:SetEnabled(false) return true end
	function Spell:OnWandHolster() self:SetEnabled(false) end
	function Spell:OnHolster() self:SetEnabled(false) end
end

HpwRewrite:AddSpell("Apparition", Spell)