AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_anim"

ENT.Spawnable = false

ENT.IsHarryPotterSpell = true

function ENT:SetupDataTables()
	self:NetworkVar("String", 0, "SpellDataName")
	self:NetworkVar("Vector", 0, "FlyDirection")
end

if SERVER then
	hook.Add("EntityTakeDamage", "hpwrewrite_removespellphysdmg", function(victim, dmg)
		local attacker = dmg:GetAttacker()
		if IsValid(attacker) and attacker.IsHarryPotterSpell and dmg:IsDamageType(DMG_CRUSH) then
			return true
		end
	end)

	function ENT:SetSpellData(spell)
		self:SetSpellDataName(spell.Name)
		self.SpellData = spell
	end

	function ENT:SetupOwner(ply)
		self:SetOwner(ply)
		self.Owner = ply
	end

	function ENT:Initialize()
		if not self.SpellData then
			HpwRewrite:LogDebug("No spelldata found!")
			print("No spelldata found!")

			self:Remove()			
			return
		end

		local r = self.SpellData.PhysObjRadius or 8
		self.PhysObjRadius = r

		self:PhysicsInitSphere(r, "default")
		self:SetCollisionBounds(Vector(-r, -r, -r), Vector(r, r, r))
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)

		self:DrawShadow(false)
		
		local phys = self:GetPhysicsObject()
		
		if phys:IsValid() then 
			phys:SetMass(1)
			phys:EnableGravity(false)
			phys:EnableDrag(false)
			phys:Wake()
		else
			HpwRewrite:LogDebug("Invalid spell physics!")
			print("Invalid spell physics!")

			self:Remove()
			return
		end

		if self.SpellData.FlyEffect then HpwRewrite.MakeEffect(self.SpellData.FlyEffect, nil, nil, self) end
		self:StartMotionController()
		self:SetCustomCollisionCheck(true)
	end

	local maxForce = 2^32
	function ENT:PhysicsSimulate(phys, dt)
		if self.HpwWeMadeCollide then return end

		if not self.HPWIncrease then self.HPWIncrease = 1 end
		self.HPWIncrease = math.Approach(self.HPWIncrease, maxForce, dt * maxForce * 0.01)

		local force = Vector(0, 0, 0)
		local angForce = Vector(0, 0, 0)

		local ang, pos, shouldOverride = self.SpellData:PhysicsThink(self, phys, dt)
		
		if pos then force = force + pos end
		if ang then angForce = angForce + ang end

		if not shouldOverride then
			force = force + self:GetFlyDirection() * self.HPWIncrease
		end

		force = force * dt
		angForce = angForce * dt

		return angForce, force, SIM_GLOBAL_ACCELERATION
	end

	local ignore_ents = {
		["phys_constraintsystem"] = true,
		["phys_constraint"] = true,
		["logic_collision_pair"] = true,
		["entityflame"] = true,
		["worldspawn"] = true
	}

	-- Storing old angle velocities
	hook.Add("ShouldCollide", "hpwrewrite_spell_oldangvel", function(self, v)
		if not ignore_ents[v:GetClass()] then
			local phys = v:GetPhysicsObject()
			if phys:IsValid() then v.HpwRewriteOldVelocity = phys:GetAngleVelocity() end
		end
	end)

	function ENT:PhysicsCollide(data, physobj)
		local ent = data.HitEntity

		if IsValid(data.HitObject) and data.TheirOldVelocity and ent.HpwRewriteOldVelocity then
			data.HitObject:AddAngleVelocity(ent.HpwRewriteOldVelocity - data.HitObject:GetAngleVelocity())
			data.HitObject:SetVelocity(data.TheirOldVelocity)
		end

		if not self.HpwWeMadeCollide then
			if IsValid(ent) and ent:GetClass() == self.ClassName then
				HpwRewrite.FM:StartFighting(self.Owner, ent.Owner, self.SpellData, ent.SpellData, data.HitPos)
			end

			self.SpellData:DoImpactSound(self, data)

			local blockCollide = self.SpellData:OnCollide(self, data, physobj)
			if not blockCollide then
				local velPlus = data.OurOldVelocity and data.OurOldVelocity:GetNormal() * 60 or vector_origin

				-- Disabling all physics to prevent unforeseen consequences
				self:StopMotionController()
				self:PhysicsDestroy()

				timer.Simple(FrameTime(), function()
					if not self:IsValid() then return end

					local pos = data.HitPos - data.HitNormal * self.PhysObjRadius
					self:SetPos(pos + velPlus)

					if self.SpellData.ImpactEffect then
						HpwRewrite.MakeEffect(self.SpellData.ImpactEffect, pos, data.HitNormal:Angle())
					end

					self.SpellData:AfterCollide(self, data, physobj)
				end)

				local deltime = FrameTime() * 2
				if not game.SinglePlayer() then deltime = FrameTime() * 6 end

				SafeRemoveEntityDelayed(self, deltime)

				self.HpwWeMadeCollide = true
			end
		end
	end
else
	function ENT:Draw()
		if self.SpellData then
			self.SpellData:Draw(self)
		end
	end
end

function ENT:Think()
	if SERVER and self.HpwWeMadeCollide then return end
	if self.SpellData then self.SpellData:SpellThink(self) end

	if CLIENT then 
		local name = self:GetSpellDataName()
		local owner = self:GetOwner()

		if not self.SpellData and name != "" and IsValid(owner) then
			if owner == LocalPlayer() then self.SpellData = HpwRewrite:GetPlayerSpell(nil, name) end

			if self.SpellData then 
				self.SpellData:OnDataReceived(self)
			else
				self.SpellData = HpwRewrite:GetSpell(name)

				if self.SpellData then
					self.SpellData = self.SpellData.New(owner)
					self.SpellData:OnDataReceived(self)
				end
			end
		end
		
		return
	end

	local phys = self:GetPhysicsObject()
	if phys:IsValid() then phys:Wake() end

	self:NextThink(CurTime())
	return true
end

function ENT:OnRemove()
	if self.SpellData then
		self.SpellData:OnRemove(self)
	end

	if CLIENT then 
		if self.SpellData and self.SpellData.LeaveParticles then
			self:StopParticleEmission()
		else
			self:StopAndDestroyParticles() 
		end
	end
end