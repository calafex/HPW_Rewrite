local Spell = { }
Spell.LearnTime = 60
Spell.Description = [[
	A charm that allowed the 
	caster to send out red sparks 
	from their wand. The sparks 
	were firework-like in 
	appearance, and had a vast 
	range, shooting up to a great 
	height, then hovering in the 
	spot where the caster aimed.
]]

Spell.ApplyDelay = 0.4
Spell.FlyEffect = "hpw_periculum_main"
Spell.ImpactEffect = "hpw_periculum_impact"
Spell.ForceAnim = { ACT_VM_PRIMARYATTACK_5 }
Spell.SpriteColor = Color(255, 80, 80)
Spell.CanSelfCast = false

Spell.NodeOffset = Vector(-846, -1094, 0)
Spell.LeaveParticles = true

function Spell:Draw(spell)
	self:DrawGlow(spell, nil, 128)
end

function Spell:SpellThink(spell)
	if SERVER then return end

	local dlight = DynamicLight(spell:EntIndex())
	if dlight then
		dlight.pos = spell:GetPos()
		dlight.r = 255
		dlight.g = 80
		dlight.b = 80
		dlight.brightness = 3
		dlight.Decay = 600
		dlight.Size = 1000
		dlight.DieTime = CurTime() + 1
	end
	
	--[[
	if not spell.Emitter then
		spell.Emitter = ParticleEmitter(spell:GetPos()) 
		return
	end

	for i = 1, 2 do
		local die = math.Rand(5, 15)
		local vel = VectorRand() * 30 + spell:GetFlyDirection() * 20
		local res = math.random(15, 40)
		local size = math.random(16, 32)

		local p = spell.Emitter:Add("hpwrewrite/sprites/magicsprite", spell:GetPos())
		p:SetDieTime(die)
		p:SetBounce(0.8)
		p:SetCollide(true)
		p:SetVelocity(vel)
		p:SetAirResistance(res)
		p:SetStartSize(size)
		p:SetEndSize(0)
		p:SetStartAlpha(255)
		p:SetEndAlpha(0)
		p:SetColor(255, 50, 50)

		local p = spell.Emitter:Add("hpwrewrite/sprites/magicsprite", spell:GetPos())
		p:SetDieTime(die)
		p:SetBounce(0.8)
		p:SetCollide(true)
		p:SetVelocity(vel)
		p:SetAirResistance(res)
		p:SetStartSize(size / 3)
		p:SetEndSize(0)
		p:SetStartAlpha(255)
		p:SetEndAlpha(0)
		p:SetColor(255, 255, 255)
	end]]
end

--[[function Spell:OnRemove(spell)
	if CLIENT and spell.Emitter then spell.Emitter:Finish() end
end]]

function Spell:OnFire(wand)
	return true
end

--[[function Spell:OnSpellSpawned(wand, spell)
	wand:PlayCastSound()
	util.SpriteTrail(spell, 0, HpwRewrite.Colors.White, true, 32, 0, 0.6, 0.05, "hpwrewrite/particles/redrope.vmt") 

	spell.Hovering = false
	spell.EndPos = Vector(0, 0, 0)

	local tr = util.TraceLine({
		start = spell:GetPos(),
		endpos = spell:GetPos() + Vector(0, 0, 999999),
		filter = { spell, self.Owner }
	})

	if tr.Hit then
		local dist = spell:GetPos():Distance(tr.HitPos)
		timer.Simple(dist / 10000, function()
			if spell:IsValid() then
				spell.EndPos = spell:GetPos()
				spell.Hovering = true

				SafeRemoveEntityDelayed(spell, 11)

				local phys = spell:GetPhysicsObject()
				if phys:IsValid() then phys:SetVelocity(phys:GetVelocity() * 0.1) end
			end
		end)
	end
end]]

function Spell:OnSpellSpawned(wand, spell)
	wand:PlayCastSound()
	
	timer.Simple(0.8, function()
		if IsValid(spell) then 
			HpwRewrite.BlastDamage(self.Owner, spell:GetPos(), 200, 30)
			
			HpwRewrite.MakeEffect(self.ImpactEffect, spell:GetPos())

			sound.Play("hpwrewrite/spells/periculum.wav", spell:GetPos(), 100, 100)
			
			SafeRemoveEntity(spell)
		end
	end)
end

function Spell:OnCollide(spell, data)
	HpwRewrite.BlastDamage(self.Owner, data.HitPos, 200, 30)

	sound.Play("hpwrewrite/spells/periculum.wav", data.HitPos, 100, 100)
end

--[[function Spell:PhysicsThink(spell, phys, dt)
	if spell.Hovering then
		return nil, ((spell.EndPos - spell:GetPos()):GetNormal() + VectorRand()) * 600000, true
	end

	return nil, nil, false
end]]

--[[function Spell:OnFire(wand)
	local newAng = self.Owner:EyeAngles()
	newAng.p = -90

	local name = "hpwrewrite_periculum_handler" .. self.Owner:EntIndex()
	local time = CurTime() + 0.4
	hook.Add("Think", name, function()
		if not IsValid(self.Owner) then hook.Remove("Think", name) return end
		if CurTime() > time then hook.Remove("Think", name) return end

		self.Owner:SetEyeAngles(LerpAngle(FrameTime() * 15, self.Owner:EyeAngles(), newAng))
	end)

	return true
end]]

HpwRewrite:AddSpell("Periculum", Spell)