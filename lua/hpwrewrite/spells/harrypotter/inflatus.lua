local Spell = { }
Spell.LearnTime = 90
Spell.Description = [[
	Used to increase the size 
	of the target by inflating 
	it; once inflated beyond the 
	maximum capacity of its outer 
	size, the targeted creature 
	will explode into colourful 
	party balloons.
]]

Spell.ApplyDelay = 0.4
Spell.FlyEffect = "hpw_blue_main"
Spell.ImpactEffect = "hpw_blue_impact"
Spell.SpriteColor = Color(0, 0, 255)
Spell.NodeOffset = Vector(-1403, 168, 0)

function Spell:Draw(spell)
	self:DrawGlow(spell)
end

function Spell:OnSpellSpawned(wand, spell)
	wand:PlayCastSound()
end

function Spell:OnFire(wand)
	return true
end

function Spell:AfterCollide(spell, data)
	local ent = data.HitEntity
	if IsValid(ent) then
		local name = "hpwrewrite_inflatus_handler" .. ent:EntIndex()
		if timer.Exists(name) then return end

		ent:EmitSound("hl1/ambience/particle_suck2.wav", 60, 110)
		
		if ent:IsNPC() or ent:IsPlayer() then
			local size = 1
			hook.Add("Think", name, function()
				if not IsValid(ent) or size >= 2 then hook.Remove("Think", name) return end

				size = size + FrameTime() * 0.25
				for i = 1, ent:GetBoneCount() - 1 do
					ent:ManipulateBoneScale(i, Vector(size, size, size))
				end
			end)
		else
			ent:SetModelScale(2, 4)
		end

		timer.Create(name, 4, 1, function()
			if not IsValid(ent) then return end

			ent:EmitSound("ambient/fire/gascan_ignite1.wav", 75, 160)

			if ent:IsNPC() or ent:IsPlayer() then
				local size = 2
				hook.Add("Think", name, function()
					if not IsValid(ent) or size <= 1 then hook.Remove("Think", name) return end

					size = size - FrameTime() * 3.3
					for i = 1, ent:GetBoneCount() - 1 do
						ent:ManipulateBoneScale(i, Vector(size, size, size))
					end
				end)
			else
				ent:SetModelScale(1, 0.3)
			end

			for i = 1, math.random(14, 20) do
				local balloon = ents.Create("gmod_balloon")
				if not IsValid(balloon) then continue end

				balloon:SetModel("models/maxofs2d/balloon_classic.mdl")
				balloon:SetPos(ent:LocalToWorld(ent:OBBCenter()) + VectorRand() * ent:GetModelRadius() * 0.5)
				balloon:SetAngles(AngleRand())
				balloon:Spawn()

				balloon:GetPhysicsObject():Wake()
				balloon:SetOwner(ent)

				local color = ColorRand()
				local force = math.random(10, 30)

				balloon:SetColor(color)
				balloon:SetForce(force)
				balloon:SetPlayer(self.Owner)

				balloon.Player = self.Owner
				balloon.r = color.r
				balloon.g = color.g
				balloon.b = color.b
				balloon.force = force

				local phys = balloon:GetPhysicsObject()
				if not phys:IsValid() then SafeRemoveEntity(balloon) return end

				phys:ApplyForceCenter(VectorRand() * 300 * phys:GetMass())

				timer.Simple(math.random(4, 8), function()
					if balloon:IsValid() then
						balloon:TakeDamage(1)
					end
				end)
			end
		end)
	end
end

HpwRewrite:AddSpell("Inflatus", Spell)