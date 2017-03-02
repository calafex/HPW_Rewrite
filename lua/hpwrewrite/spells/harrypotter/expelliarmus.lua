local Spell = { }
Spell.LearnTime = 180
Spell.Description = [[
	Disarms your opponent.
]]
Spell.Category = HpwRewrite.CategoryNames.Fight
Spell.FlyEffect = "hpw_expelliarmus_main"
Spell.ImpactEffect = "hpw_expelliarmus_impact"
Spell.ApplyDelay = 0.65

Spell.ForceAnim = { ACT_VM_PRIMARYATTACK_3 }
Spell.SpriteColor = Color(255, 0, 20)
Spell.Fightable = true

Spell.NodeOffset = Vector(669, 135, 0)

local mat = Material("cable/redlaser")
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
		if math.random(1, (1 / RealFrameTime()) * 3) == 1 then HpwRewrite.MakeEffect("hpw_expelliarmus_impact", v, AngleRand()) end
	end
end

function Spell:Draw(spell)
	self:DrawGlow(spell)
end

function Spell:OnSpellSpawned(wand, spell)
	sound.Play("ambient/wind/wind_snippet2.wav", spell:GetPos(), 75, 255)
	spell:EmitSound("ambient/wind/wind_snippet2.wav", 80, 255)
	wand:PlayCastSound()
end

function Spell:OnFire(wand)
	return true
end

function Spell:AfterCollide(spell, data)
	local ent = data.HitEntity

	if IsValid(ent) then
		if ent:IsPlayer() then
			local wep = ent:GetActiveWeapon()
			if wep:IsValid() then ent:DropWeapon(wep) end
		elseif ent:IsNPC() then
			local wep = ent:GetActiveWeapon()
			if wep:IsValid() then
				local fwep = ents.Create(wep:GetClass())
				if not IsValid(fwep) then return end

				-- These commands will fix game crash
				ent:ClearSchedule()
				ent:ClearGoal()
				ent:ClearEnemyMemory()
				ent:ClearExpression()
				ent:StopMoving()

				fwep:SetPos(ent:LocalToWorld(ent:OBBCenter()))
				fwep:Spawn()

				local phys = fwep:GetPhysicsObject()
				if not IsValid(phys) then return end
				phys:AddAngleVelocity(VectorRand() * phys:GetMass() * 128)
				phys:ApplyForceCenter((ent:GetAimVector() + vector_up * 0.8) * phys:GetMass() * 290)

				wep:Remove()
			end
		else
			local phys = ent:GetPhysicsObject()
			if IsValid(phys) then
				phys:AddAngleVelocity(VectorRand() * 45)
				phys:ApplyForceCenter(((spell:GetPos() - ent:GetPos()):GetNormal() + vector_up * 0.6) * phys:GetMass() * 200)
			end
		end
	end
end

HpwRewrite:AddSpell("Expelliarmus", Spell)