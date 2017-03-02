local Spell = { }
Spell.LearnTime = 720
Spell.Description = [[
	Curse that can be used to 
	blast solid objects made from
	basic materials into pieces. 
	Cannot blast huge objects.
]]
Spell.Category = HpwRewrite.CategoryNames.DestrExp
Spell.FlyEffect = "hpw_reducto_main"
Spell.ImpactEffect = "hpw_reducto_impact_def"
Spell.ApplyDelay = 0.65
Spell.AccuracyDecreaseVal = 0.2

Spell.ForceAnim = { ACT_VM_PRIMARYATTACK_1 }
Spell.SpriteColor = Color(0, 150, 255)

Spell.NodeOffset = Vector(-394, 492, 0)
Spell.LeaveParticles = true

PrecacheParticleSystem("hpw_reducto_impact_stone")
PrecacheParticleSystem("hpw_reducto_impact_metal")
PrecacheParticleSystem("hpw_reducto_impact_glass")
PrecacheParticleSystem("hpw_reducto_impact_wood")

local mat = Material("hpwrewrite/sprites/magicsprite")

function Spell:Draw(spell)
	local dlight = DynamicLight(spell:EntIndex())
	if dlight then
		dlight.pos = spell:GetPos()
		dlight.r = 0
		dlight.g = 150
		dlight.b = 255
		dlight.brightness = 3
		dlight.Decay = 1000
		dlight.Size = 128
		dlight.DieTime = CurTime() + 1
	end

	render.SetMaterial(mat)
	render.DrawSprite(spell:GetPos(), 64, 64, self.SpriteColor)
	render.DrawSprite(spell:GetPos(), 128, 50, self.SpriteColor)	
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
			dlight.r = 0
			dlight.g = 150
			dlight.b = 255
			dlight.brightness = 1
			dlight.Decay = 1100
			dlight.Size = 256
			dlight.DieTime = CurTime() + 1
		end
	end
end

function Spell:OnFire(wand)
	return true
end

function Spell:AfterCollide(spell, data)
	local tr = util.TraceLine({
		start = data.HitPos - data.HitNormal,
		endpos = data.HitPos + data.HitNormal,
		filter = spell
	})

	if tr.HitSky then return end

	if not IsValid(tr.Entity) then
		tr = util.TraceLine({
			start = data.HitPos + data.HitNormal * 3,
			endpos = data.HitPos - data.HitNormal * 3,
			filter = spell
		})
	end

	local models
	local ent = tr.Entity
	local mat = tr.MatType
	local pos = tr.HitPos
	local isBig = false
	local skipRadius
	local rad = 0
	local callback = function() end

	local amount = math.random(4, 7)

	if IsValid(data.HitEntity) then
		HpwRewrite:ThrowEntity(data.HitEntity, spell:GetFlyDirection(), nil, 2, self.Owner)

		if data.HitEntity:IsPlayer() or data.HitEntity:IsNPC() then
			return
		end
	end

	if IsValid(ent) then
		if ent.PROTEGO_SHIELD then return end

		rad = ent:GetModelRadius()
		if rad > 90 then 
			isBig = true
		else
			ent:TakeDamage(ent:Health())
			amount = math.random(rad * 0.4, rad * 0.6)
			pos = ent:LocalToWorld(ent:OBBCenter())
		end
	end

	if mat == MAT_CONCRETE or mat == MAT_TILE then
		models = { 
			"models/props_debris/concrete_chunk04a.mdl",  
			"models/props_debris/concrete_chunk05g.mdl",
			"models/props_debris/concrete_chunk03a.mdl",
			"models/props_combine/breenbust_chunk06.mdl",
			"models/props_combine/breenbust_chunk05.mdl"
		}

		for i = 1, 4 do sound.Play("physics/concrete/concrete_break" .. math.random(2, 3) .. ".wav", pos, 80) end
		HpwRewrite.MakeEffect("hpw_reducto_impact_stone", pos, tr.HitNormal:Angle())
	elseif mat == MAT_WOOD then
		models = {
			"models/gibs/wood_gib01a.mdl",
			"models/gibs/wood_gib01b.mdl",
			"models/gibs/wood_gib01c.mdl",
			"models/gibs/wood_gib01d.mdl",
			"models/gibs/wood_gib01e.mdl"
		}

		amount = math.floor(amount * 0.7)
		for i = 1, 6 do sound.Play("physics/wood/wood_crate_break" .. math.random(1, 5) .. ".wav", pos, 58) end
		HpwRewrite.MakeEffect("hpw_reducto_impact_wood", pos, tr.HitNormal:Angle())
	elseif mat == MAT_METAL then
		if not isBig then
			models = { 
				"models/props_junk/garbage_glassbottle001a_chunk03.mdl", 
				"models/props_junk/garbage_glassbottle001a_chunk04.mdl" 
			}
		end

		amount = math.floor(amount * 1.5)

		callback = function(debris, phys) 
			phys:SetMaterial("metal") 
			debris:SetMaterial("models/props_c17/metalladder001")
			debris:SetColor(HpwRewrite.Colors.DarkGrey6) 
		end

		for i = 1, 3 do sound.Play("physics/metal/metal_box_break" .. math.random(1, 2) .. ".wav", pos, 72) end
		HpwRewrite.MakeEffect("hpw_reducto_impact_metal", pos, tr.HitNormal:Angle())
	elseif mat == MAT_GLASS then
		models = { 
			"models/gibs/glass_shard.mdl",
			"models/gibs/glass_shard01.mdl",
			"models/gibs/glass_shard02.mdl",
			"models/gibs/glass_shard03.mdl",
			"models/gibs/glass_shard04.mdl",
			"models/gibs/glass_shard06.mdl"
		}

		skipRadius = 200
		amount = amount * 2

		for i = 1, 4 do sound.Play("physics/glass/glass_sheet_break" .. math.random(1, 3) .. ".wav", pos, 68) end
		HpwRewrite.MakeEffect("hpw_reducto_impact_glass", pos, tr.HitNormal:Angle())
	else //if mat == MAT_GRASS or mat == MAT_SAND then
		HpwRewrite.MakeEffect("hpw_reducto_impact_stone", pos, tr.HitNormal:Angle())
	end

	if IsValid(ent) and ent:GetClass() != "prop_physics" then
		ent = NULL
	end

	if skipRadius then
		if rad > skipRadius then ent = NULL end
	elseif isBig then
		ent = NULL
	end

	if models then
		for i = 1, amount do
			local debris = ents.Create("prop_physics")
			debris:SetPos(pos + VectorRand() * amount * 0.4)
			debris:SetAngles(AngleRand())
			debris:SetModel(table.Random(models))
			debris:Spawn()
			debris:SetCollisionGroup(COLLISION_GROUP_DEBRIS)

			local phys = debris:GetPhysicsObject()
			if IsValid(phys) then
				callback(debris, phys)
				phys:SetMass(10)
				phys:ApplyForceCenter(((debris:GetPos() - pos):GetNormal() + VectorRand() * 0.1) * phys:GetMass() * math.random(150, 250))
				phys:AddAngleVelocity(VectorRand() * phys:GetMass() * 100)

				SafeRemoveEntityDelayed(debris, math.random(4, 6))
			else
				SafeRemoveEntity(debris)
			end
		end

		SafeRemoveEntity(ent)
	end
end

HpwRewrite:AddSpell("Reducto", Spell)