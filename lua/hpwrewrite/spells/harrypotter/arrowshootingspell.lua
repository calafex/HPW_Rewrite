local Spell = { }
Spell.LearnTime = 180
Spell.Description = [[
	Spawns magic arrows from
	the tip of your wand.
]]

Spell.Category = HpwRewrite.CategoryNames.Fight
Spell.CanSelfCast = false
Spell.AccuracyDecreaseVal = 0.05

Spell.ForceAnim = { ACT_VM_PRIMARYATTACK_7 }
Spell.ApplyFireDelay = 0.2
Spell.AnimSpeedCoef = 1.5
Spell.ForceDelay = 0.4
Spell.AutoFire = true

Spell.SpriteColor = Color(220, 255, 255)

Spell.ShouldSay = false
Spell.NodeOffset = Vector(940, -845, 0)

function Spell:OnFire(wand)
	local pos = wand:GetSpellSpawnPosition()

	wand:PlayCastSound()

	local a = ents.Create("entity_hpwand_arrow")
	a:SetPos(pos)
	a:SetOwner(self.Owner)

	local dir = (self.Owner:GetEyeTrace().HitPos - pos):GetNormal()
	wand:ApplyAccuracyPenalty(dir)

	a:SetAngles(dir:Angle())
	a:Spawn()

	local phys = a:GetPhysicsObject()
	if not phys:IsValid() then SafeRemoveEntity(a) return end

	phys:ApplyForceCenter(dir * phys:GetMass() * 5000)
	phys:ApplyForceOffset(Vector(0, 0, -phys:GetMass() * 0.15), a:GetPos() + a:GetForward() * 20)
	phys:AddAngleVelocity(Vector(0, 5, 0))

	sound.Play("weapons/crossbow/fire1.wav", pos, 60, math.random(90, 110))
end

HpwRewrite:AddSpell("Arrow-shooting spell", Spell)