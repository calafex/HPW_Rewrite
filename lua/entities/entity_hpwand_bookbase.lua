AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.Model = ""
ENT.Spawnable = false

if SERVER then
	function ENT:CheckCanSpawn(ply)
		--if not IsValid(ply) then return false end

		if HpwRewrite:IsSpellInAdminOnly(self.PrintName) and not HpwRewrite.CheckAdmin(ply) then 
			HpwRewrite:DoNotify(ply, "Only admins can spawn " .. self.PrintName .. "!", 1)
			return false
		end

		return true
	end

	-- To setup owner
	function ENT:SetupOwner(ply)
		self.Owner = ply
	end

	-- SpawnFunction is only sandbox function???
	function ENT:SpawnFunction(ply, tr, class)
		if not tr.Hit then return end

		local ent = ents.Create(class)
		ent:SetupOwner(ply)
		ent:SetPos(tr.HitPos + tr.HitNormal * 16)
		ent:SetAngles(Angle(0, (ply:GetPos() - tr.HitPos):Angle().y, 0))
		ent:Spawn()
		ent:Activate()

		return ent
	end

	function ENT:Initialize()
		-- Notifying server admins that they're doing something wrong
		if self.Owner == nil then
			local text = "Spell book owner is not valid! It seems like you're running server on DarkRP or other not Sandbox gamemode! To setup owner use ENT:SetupOwner(ply) function in spawn code. If you do not understand what to do, contact Magic Wand developers."

			ErrorNoHalt(text .. "\n")
			HpwRewrite:LogDebug("[ERROR] " .. text)

			self:Remove()
			return
		end
	
		if not self:CheckCanSpawn(self.Owner) then
			self:Remove()
			return
		end

		self:SetModel(self.Model)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetUseType(SIMPLE_USE)

		local phys = self:GetPhysicsObject()
		if IsValid(phys) then
		    phys:Wake()
		else
			self:Remove()
		end
	end

	function ENT:GiveSpells()
		return true
	end

	function ENT:OnTakeDamage(dmg)
		self:TakePhysicsDamage(dmg)
	end

	function ENT:Use(activator, caller)
		if not activator:IsPlayer() then return end

		-- Spells
		if not self:GiveSpells(activator, caller) then return end

		self:EmitSound("garrysmod/save_load1.wav", 60)
		SafeRemoveEntity(self)
	end
else
	function ENT:Draw()
		self:DrawModel()

		if not HpwRewrite.CVars.DrawBookText:GetBool() then return end

		local pos = self:LocalToWorld(self:OBBCenter()) + vector_up * (self:OBBMaxs().z + 6)
		local ang = (pos - EyePos()):Angle()

		local a = 170 - math.Clamp(self:GetPos():Distance(EyePos()) * 0.8, 0, 170)
		
		cam.Start3D2D(pos, Angle(0, ang.y - 90, -ang.p + 90), 0.05)
			local name = self.PrintName
			local color = Color(255, 255, 255, a + math.sin(CurTime() * 5) * a * 0.3)
			draw.SimpleText(name, "HPW_fontbig", 0, 0, color, TEXT_ALIGN_CENTER)
		
			if self.CustomIcon then
				local lenw, lenh = surface.GetTextSize(name)

				surface.SetMaterial(self.CustomIcon)
				color.a = math.min(255, a * 1.7)
				surface.SetDrawColor(color)

				local x = -(lenw / 2) - 142
				local y = -lenh / 2 + 32
				local w, h = 128, 128
				surface.DrawTexturedRect(x, y, w, h)

				color.r, color.g, color.b = 0, 0, 0
				surface.SetDrawColor(color)
				surface.DrawOutlinedRect(x - 2, y - 2, w + 4, h + 4)
			end
		cam.End3D2D()
	end
end