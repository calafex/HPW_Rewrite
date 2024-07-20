local Spell = { }
Spell.LearnTime = 1200
Spell.Description = [[
	The Killing curse.
	Inflicts instant painless death.
]]
Spell.Category = HpwRewrite.CategoryNames.Unforgivable
Spell.FlyEffect = "hpw_avadaked_main"
Spell.ImpactEffect = "hpw_avadaked_impact"
Spell.ApplyDelay = 0.5
Spell.AccuracyDecreaseVal = 0.3
Spell.Unforgivable = true
Spell.ForceAnim = { ACT_VM_PRIMARYATTACK_1, ACT_VM_PRIMARYATTACK_2 }
Spell.SpriteColor = Color(60, 255, 160)
Spell.Fightable = true
Spell.DoSparks = true

Spell.NodeOffset = Vector(938, -511, 0)

local mat = Material("cable/hydra")
local mat2 = Material("cable/xbeam")

Spell.FightingEffect = function(nPoints, points) 
	render.SetMaterial(mat)
	for i = 1, 3 do
		render.StartBeam(nPoints)
			for k, v in pairs(points) do
				render.AddBeam(v, (k / nPoints) * 60, math.Rand(0, 2), color_white)
			end 
		render.EndBeam()
	end

	render.SetMaterial(mat2)
	for i = 1, 2 do
		render.StartBeam(nPoints)
			for k, v in pairs(points) do
				render.AddBeam(v, (k / nPoints) * 10, math.Rand(0, 1), color_white)
			end
		render.EndBeam()
	end

	for k, v in pairs(points) do
		if math.random(1, (1 / RealFrameTime()) * 2) == 1 then HpwRewrite.MakeEffect("hpw_avadaked_impact", v, AngleRand()) end
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

function Spell:OnRemove(spell)
	if CLIENT then
		local dlight = DynamicLight(spell:EntIndex())
		if dlight then
			dlight.pos = spell:GetPos()
			dlight.r = 80
			dlight.g = 235
			dlight.b = 180
			dlight.brightness = 6
			dlight.Decay = 1000
			dlight.Size = 256
			dlight.DieTime = CurTime() + 1
		end
	end
end

function Spell:OnFire(wand)
	return true
end

function Spell:OnCollide(spell, data)
	local ent = data.HitEntity

	if IsValid(ent) then
		local force = spell:GetFlyDirection() * 10000

		if ent:IsNPC() or ent:IsPlayer() then 
			HpwRewrite.Kill(ent, self.Owner, force)
		elseif ent.HPWRagdolledEnt then
			HpwRewrite.TakeDamage(ent, self.Owner, ent.MaxPenetration, force)
		end
	end
end

HpwRewrite:AddSpell("Avada kedavra", Spell)