AddCSLuaFile()

ENT.Base = "base_anim"
ENT.Type = "anim"

local model = Model("models/props_junk/harpoon002a.mdl")

if SERVER then
	function ENT:Initialize()
		self:SetModel(model)
		--self:SetMaterial("models/props_combine/portalball001_sheet")
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)

		local phys = self:GetPhysicsObject()
		if not phys:IsValid() then self:Remove() return end
		
		phys:SetMass(2)

		self:SetModelScale(0.6, 0)
	end

	function ENT:PhysicsCollide(data, physobj)
		data.PhysObject:EnableMotion(false)
		data.PhysObject:Sleep()

		timer.Simple(0, function() 
			local ent = data.HitEntity
			if IsValid(ent) then
				ent:TakeDamage(math.random(15, 20), self:GetOwner(), HpwRewrite:GetWand(self:GetOwner()))

				if ent:IsPlayer() or ent:IsNPC() then
					local ef = EffectData()
					ef:SetOrigin(data.HitPos)
					util.Effect("BloodImpact", ef, true, true)

					sound.Play("weapons/crossbow/bolt_skewer1.wav", data.HitPos, 68)
					self:Remove()
				end
			end

			if IsValid(self) and IsValid(data.PhysObject) then
				self.PhysicsCollide = self.PhysicsCollide2

				data.PhysObject:EnableMotion(true) 
				data.PhysObject:Wake()

				if self:GetForward():Dot(data.HitNormal) > 0.5 and data.Speed >= 1000 then
					sound.Play("weapons/crossbow/bolt_fly4.wav", data.HitPos, 68, math.random(70, 90), 0.7)
					self:PhysicsDestroy()
					self:SetPos(self:GetPos() + self:GetForward() * 45)
				else
					data.PhysObject:SetVelocity(data.OurOldVelocity * 0.3)
					data.PhysObject:AddAngleVelocity(VectorRand() * 300)
				end

				HpwRewrite.MakeEffect("hpw_expulso_impact", data.HitPos, Angle(0, 0, 0))
			end

			SafeRemoveEntityDelayed(self, math.random(4, 6))
		end)
	end

	function ENT:PhysicsCollide2(data, physobj)
		if data.Speed >= 80 then
			sound.Play("hpwrewrite/magicchimes02.wav", data.HitPos, 68, math.random(90, 110))
		end
	end
end