local Spell = { }
Spell.LearnTime = 360
Spell.Category = HpwRewrite.CategoryNames.Protecting
Spell.Description = [[
	Creates magical barrier that
	blocks spells except 
	unforgivable ones.
	
	Also it can protect you
	from props.
]]

Spell.CanSelfCast = false
Spell.ApplyFireDelay = 0.2
Spell.ForceAnim = { ACT_VM_PRIMARYATTACK_4 }
Spell.SpriteColor = Color(130, 230, 255)
Spell.AccuracyDecreaseVal = 0

Spell.NodeOffset = Vector(-836, 429, 0)

PrecacheParticleSystem("hpw_protego_main")
PrecacheParticleSystem("hpw_protego_impact")

function Spell:OnFire(wand)
	local pos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * 50
	local ang = self.Owner:EyeAngles()
	
	HpwRewrite.MakeEffect("hpw_protego_main", pos, ang)

	sound.Play("ambient/levels/labs/electric_explosion5.wav", wand:GetPos(), 70, 240)

	--for i = 1, 3 do
		--sound.Play("weapons/flashbang/flashbang_explode" .. math.random(1, 2) .. ".wav", wand:GetPos(), 70, math.random(230, 255))
	--end

	self.Owner:ViewPunch(Angle(-1, 0, -1))

	SafeRemoveEntity(self.Shield)

	-- Setup shield
	local s = ents.Create("prop_physics")
	s:SetCustomCollisionCheck(true)

	hook.Add("ShouldCollide", "hpwrewrite_protego_physhandler" .. s:EntIndex(), function(ent1, ent2)
		if IsValid(s) then
			if ent1 == s then
				if ent2:IsWorld() then return false end
				if ent2.SpellData and ent2.SpellData.Unforgivable then return false end
				if ent2:IsPlayer() then return false end

				sound.Play("weapons/physcannon/energy_bounce" .. math.random(1, 2) .. ".wav", ent2:GetPos(), 60, math.random(110, 150)) 
			end
		else
			hook.Remove("ShouldCollide", "hpwrewrite_protego_physhandler" .. s:EntIndex())
		end
	end)

	s:SetModel("models/hpwrewrite/misc/protego/protego.mdl")
	s:SetPos(pos)
	s:SetAngles(ang)
	s:SetNoDraw(true)
	s.PROTEGO_SHIELD = true
	s:Spawn()
	s:GetPhysicsObject():EnableMotion(false)
	--s:GetPhysicsObject():SetMaterial("metal")
	s:AddCallback("PhysicsCollide", function(ent, data)
		HpwRewrite.MakeEffect("hpw_protego_impact", data.HitPos, ang)
	end)

	self.Shield = s

	SafeRemoveEntityDelayed(s, 0.6)
end

function Spell:Think()
	--[[
	if CLIENT then return end

	if not self.Remove then return end
	if CurTime() > self.Remove then 
		self.Remove = nil 
		return 
	end

	for k, v in pairs(ents.FindInSphere(self.Owner:GetPos(), 400)) do
		if IsValid(v) then
			if v:IsPlayer() or v:IsNPC() then continue end

			local shootPos = self.Owner:GetShootPos()
			local forward = self.Owner:EyeAngles():Forward()
			local dir = (v:GetPos() - shootPos):GetNormal()

			if dir:Dot(forward) > 0.7 then 
				if v:GetClass() == "entity_hpwand_flyingspell" and v.SpellData and not v.SpellData.Unforgivable then
					local data = { }
					data.HitEntity = NULL
					data.HitPos = v:GetPos()
					data.Speed = 0
					data.HitNormal = Vector(0, 0, 0)

					v:PhysicsCollide(data, v:GetPhysicsObject())
					sound.Play("physics/concrete/concrete_impact_flare" .. math.random(1, 4) .. ".wav", v:GetPos(), 78, math.random(90, 120))

					local ef = EffectData()
					ef:SetOrigin(v:GetPos())
					ef:SetAngles(dir:Angle())
					ef:SetMaterialIndex(2)
					util.Effect("EffectHpwRewriteBrigde", ef, true, true)
				else
					local phys = v:GetPhysicsObject()
					if not IsValid(phys) then continue end

					local vel = phys:GetVelocity()
					if vel:Length() <= 50 then continue end

					if not self.StuffTable[v:EntIndex()] then 
						phys:ApplyForceCenter(-vel * 10)
						phys:AddAngleVelocity(-phys:GetAngleVelocity())
						sound.Play("physics/concrete/concrete_impact_flare" .. math.random(1, 4) .. ".wav", v:GetPos(), 78, math.random(90, 120))

						local ef = EffectData()
						ef:SetOrigin(v:GetPos())
						ef:SetAngles(dir:Angle())
						ef:SetMaterialIndex(2)
						util.Effect("EffectHpwRewriteBrigde", ef, true, true)						

						self.StuffTable[v:EntIndex()] = true 
					end

					phys:ApplyForceCenter(dir * phys:GetMass() * 40)
					phys:AddAngleVelocity(dir * phys:GetMass() * 0.001)
				end
			end
		end
	end]]
end

HpwRewrite:AddSpell("Protego", Spell)