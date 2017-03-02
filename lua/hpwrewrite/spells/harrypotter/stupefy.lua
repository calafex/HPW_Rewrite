local Spell = { }
Spell.LearnTime = 300
Spell.Description = [[
	The Stunning Spell, also 
	known as a Stunner or 
	Stupefying Charm is a charm 
	that renders a victim 
	unconscious and halts 
	moving objects.
]]
Spell.Category = HpwRewrite.CategoryNames.Fight
Spell.FlyEffect = "hpw_stupefy_main"
Spell.ImpactEffect = "hpw_stupefy_impact"
Spell.AccuracyDecreaseVal = 0.1
Spell.ApplyDelay = 0.35
Spell.PhysObjRadius = 5

Spell.ForceAnim = { ACT_VM_PRIMARYATTACK_1, ACT_VM_PRIMARYATTACK_5 }
Spell.SpriteColor = Color(120, 200, 255)
Spell.Fightable = true

Spell.NodeOffset = Vector(-249, 583, 0)

PrecacheParticleSystem("hpw_stupefy_impactbody")

if SERVER then
	util.AddNetworkString("hpwrewrite_stupefy_handler")
else
	net.Receive("hpwrewrite_stupefy_handler", function()
		local old = CurTime()
		local endtime = old + 40

		hook.Add("RenderScreenspaceEffects", "hpwrewrite_stupefy_handler", function()
			if CurTime() > endtime or not LocalPlayer():Alive() then hook.Remove("RenderScreenspaceEffects", "hpwrewrite_stupefy_handler") return end

			local pow = 1 - (CurTime() - old) / (endtime - old) 
			DrawMotionBlur(0.02, pow, 0.01)
		end)

		hook.Add("Think", "hpwrewrite_stupefy_handler", function()
			if CurTime() > endtime or not LocalPlayer():Alive() then
				local ang = LocalPlayer():EyeAngles()
				ang.r = 0 
				LocalPlayer():SetEyeAngles(ang)
				hook.Remove("Think", "hpwrewrite_stupefy_handler") 
				return 
			end

			local pow = 1 - (CurTime() - old) / (endtime - old) 
			local eyes = LocalPlayer():EyeAngles()

			LocalPlayer():SetEyeAngles(eyes + Angle(math.cos(CurTime() * 2) * 0.2, math.sin(CurTime()) * 0.4, math.sin(CurTime()) * 0.06) * pow)
		end)
	end)
end

local mat = Material("cable/physbeam")
local mat2 = Material("cable/xbeam")
Spell.FightingEffect = function(nPoints, points) 
	render.SetMaterial(mat) 
	render.StartBeam(nPoints)
		for k, v in pairs(points) do
			render.AddBeam(v, (k / nPoints) * 32, math.Rand(0, 1), color_white)
		end
	render.EndBeam()

	render.StartBeam(nPoints)
		for k, v in pairs(points) do
			render.AddBeam(v, (k / nPoints) * 46, math.Rand(0, 1), color_white)
		end
	render.EndBeam()


	render.SetMaterial(mat2)
	render.StartBeam(nPoints)
		for k, v in pairs(points) do
			render.AddBeam(v, (k / nPoints) * 4, math.Rand(0, 1), color_white)
		end
	render.EndBeam()

	render.StartBeam(nPoints)
		for k, v in pairs(points) do
			render.AddBeam(v, (k / nPoints) * 10, math.Rand(0, 1), color_white)
		end
	render.EndBeam()

	for k, v in pairs(points) do
		if math.random(1, (1 / RealFrameTime()) * 3) == 1 then HpwRewrite.MakeEffect("hpw_expulso_impact", v, AngleRand()) end
	end
end

function Spell:OnSpellSpawned(wand, spell)
	sound.Play("ambient/wind/wind_snippet2.wav", spell:GetPos(), 75, 255)
	spell:EmitSound("ambient/wind/wind_snippet2.wav", 80, 255)
	wand:PlayCastSound()
end

function Spell:Draw(spell)
	self:DrawGlow(spell, nil, 32)
end

function Spell:OnFire(wand)
	return true
end

function Spell:AfterCollide(spell, data)
	local ent = data.HitEntity

	if IsValid(ent) then
		local phys = ent:GetPhysicsObject()
		if phys:IsValid() then
			phys:AddAngleVelocity(-phys:GetAngleVelocity() * 0.9)
			phys:SetVelocity(Vector(0, 0, 0))
		end

		ent:TakeDamage(math.random(4, 7), self.Owner, HpwRewrite:GetWand(self.Owner))
		HpwRewrite:ThrowEntity(ent, spell:GetFlyDirection(), 3000, 5, self.Owner)
		HpwRewrite.MakeEffect("hpw_stupefy_impactbody", spell:GetPos(), spell:GetFlyDirection():Angle())

		if ent:IsPlayer() then
			net.Start("hpwrewrite_stupefy_handler")
			net.Send(ent)
		end
	end
end

HpwRewrite:AddSpell("Stupefy", Spell)