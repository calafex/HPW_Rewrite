
local Spell = { }
Spell.LearnTime = 120
Spell.Description = [[
	Summons a light source and
	places it at your aim position,
	dies in 8-16 seconds.
]]
Spell.Category = HpwRewrite.CategoryNames.Lighting
Spell.OnlyIfLearned = { "Lumos Maxima" }
Spell.AccuracyDecreaseVal = 0.25
Spell.CanSelfCast = false

Spell.ApplyFireDelay = 0.5
Spell.SpriteColor = Color(200, 200, 255)
Spell.NodeOffset = Vector(-158, -126, 0)
Spell.DoSparks = true
Spell.SparksLifeTime = 0.6
Spell.SpriteTime = 300

local mat = Material("hpwrewrite/sprites/magicsprite")
function Spell:Draw(spell)
	render.SetMaterial(mat)

	local size = 86 + math.sin(CurTime() * 10) * 8

	local pos = spell:GetPos()
	pos = pos + Vector((math.sin(CurTime() * 0.01 ^ 3) * 1.2) ^ 2, (math.cos(CurTime()) * 1.6) ^ 3, math.sin(CurTime()) * 3)

	render.DrawSprite(pos, size, size, self.SpriteColor)
	render.DrawSprite(pos, size, size, self.SpriteColor)
end

function Spell:SpellThink(spell)
	if SERVER then return end

	local dlight = DynamicLight(spell:EntIndex())
	if dlight then
		dlight.pos = spell:GetPos()
		dlight.r = 200
		dlight.g = 200
		dlight.b = 255
		dlight.brightness = 3
		dlight.Decay = 600
		dlight.Size = 300
		dlight.DieTime = CurTime() + 6
	end

	if not spell.Emitter then
		spell.Emitter = ParticleEmitter(spell:GetPos()) 
		return
	end

	local p = spell.Emitter:Add("hpwrewrite/sprites/magicsprite", spell:GetPos())
	p:SetDieTime(math.Rand(0.7, 2.6))
	p:SetBounce(0.8)
	p:SetCollide(true)
	p:SetVelocity(VectorRand() * 100 + spell:GetFlyDirection() * 1200)
	p:SetGravity(Vector(0, 0, -400))
	p:SetAirResistance(math.random(15, 40))
	p:SetStartSize(math.random(4, 8))
	p:SetEndSize(0)
	p:SetStartAlpha(255)
	p:SetEndAlpha(0)
	p:SetRoll(math.Rand(-10, 10))
	p:SetRollDelta(math.Rand(-10, 10))
	p:SetColor(self.SpriteColor.r, self.SpriteColor.g, self.SpriteColor.b)
end

function Spell:OnRemove(spell)
	if CLIENT and spell.Emitter then spell.Emitter:Finish() end
end

function Spell:OnSpellSpawned(wand, spell)
	SafeRemoveEntityDelayed(spell, math.random(8, 16))
end

function Spell:OnCollide(spell) 
	spell:SetFlyDirection(Vector(0, 0, 0))
	spell:GetPhysicsObject():SetVelocity(Vector(0, 0, 0))
	spell:GetPhysicsObject():EnableCollisions(false)

	return true 
end

function Spell:OnFire(wand)
	wand:PlayCastSound()

	for i = 1, 4 do
		sound.Play("hpwrewrite/spells/lumos.wav", wand:GetPos(), 75, 100)
	end

	return true
end

HpwRewrite:AddSpell("Lux Bulbus", Spell)