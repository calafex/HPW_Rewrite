local Spell = { }
Spell.LearnTime = 60
Spell.Description = [[
	Water making spell.
	Can fill up drink 
	entities.
]]

Spell.FlyEffect = "hpw_aguamenti_main"
Spell.ApplyDelay = 0.64

Spell.ForceAnim = { ACT_VM_PRIMARYATTACK_8 }
Spell.SpriteColor = Color(120, 255, 255)

Spell.NodeOffset = Vector(143, -957, 0)
Spell.LeaveParticles = true

function Spell:OnSpellSpawned(wand, spell)
	sound.Play("ambient/water/water_splash" .. math.random(1, 3) .. ".wav", spell:GetPos(), 65, 170)
	wand:PlayCastSound()
end

local function SpillableDrinks(ent)
	if ent.Beer then 
		ent.Beer = ent.Beer + 10 
		ent:EmitSound("ambient/water/rain_drip" .. math.random(1, 4) .. ".wav", 68)
	end
end

local validSents = {
	["sent_beer"] = SpillableDrinks,
	["sent_milk"] = SpillableDrinks,
	["sent_smallbeer"] = SpillableDrinks,
	["sent_smallsoda"] = SpillableDrinks,
	["sent_soda"] = SpillableDrinks,
	["sent_waterbottle"] = SpillableDrinks
}

function Spell:OnFire(wand)
	local ent = wand:HPWGetAimEntity(400)

	if IsValid(ent) then
		local class = ent:GetClass()

		if validSents[ent:GetClass()] then 
			validSents[ent:GetClass()](ent)
			return false
		else
			return true
		end
	else
		return true
	end
end

function Spell:SpellThink(spell)
	if math.random(1, 3) == 1 then
		sound.Play("ambient/water/water_splash" .. math.random(1, 3) .. ".wav", spell:GetPos(), 60, math.random(120, 160))
	end
end

function Spell:OnCollide(spell, data)
	local ent = data.HitEntity
	local pos = data.HitPos
	local ang = data.HitNormal:Angle()

	for i = 1, math.random(2, 3) do 
		ParticleEffect("water_splash_0" .. math.random(1, 3), pos, ang) 
	end

	local ef = EffectData()
	ef:SetStart(pos)
	ef:SetOrigin(pos)
	ef:SetScale(math.random(3, 7))
	util.Effect("watersplash", ef, true, true)

	if IsValid(ent) then
		local class = ent:GetClass()
		if validSents[class] then validSents[class](ent) else ent:TakeDamage(math.random(1, 4)) end

		local phys = ent:GetPhysicsObject()
		if phys:IsValid() then
			phys:ApplyForceOffset(spell:GetFlyDirection() * phys:GetMass() * 120, pos)
		end
	end

	sound.Play("ambient/water/water_splash" .. math.random(1, 3) .. ".wav", pos, 75)
end

HpwRewrite:AddSpell("Aguamenti", Spell)