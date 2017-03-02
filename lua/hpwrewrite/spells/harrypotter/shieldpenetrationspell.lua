local Spell = { }
Spell.LearnTime = 1200
Spell.ApplyFireDelay = 0.8

Spell.Description = [[
	Used to break down magical
	shields. In other words,
	can disable god mode and
	break protego shields.

	Be careful when using this
	spell - it might kill you
	due of it's powers.

	You should have more than
	80% of learned spells to
	use this! Otherwise, you
	will be instantly killed.
]]

Spell.ForceAnim = { ACT_VM_PRIMARYATTACK_6 }
Spell.SpriteColor = Color(190, 240, 255)
Spell.SpriteSize = 5
Spell.DoSparks = true
Spell.SparksLifeTime = 1.1

Spell.ShouldSay = false
Spell.NodeOffset = Vector(934, 47, 0)
Spell.AccuracyDecreaseVal = 1
Spell.ShouldSay = false

function Spell:OnFire(wand)
	if HpwRewrite:SkillLevel(self.Owner) < 0.7 then 
		self.Owner:Kill()
		return 
	end

	local ent = wand:HPWGetAimEntity(1600)

	if IsValid(ent) then
		if ent:IsPlayer() then ent:GodDisable() end
	end

	local dmg = math.random(10, 20)
	if math.random(0, 1) == 1 then dmg = dmg * 2 elseif math.random(0, 2) == 2 then self.Owner:Kill() end
	self.Owner:TakeDamage(dmg)

	local pos = self.Owner:GetPos()
	for i = 1, 8 do
		timer.Simple(math.Rand(0, 3), function()
			sound.Play("ambient/explosions/explode_8.wav", pos + VectorRand() * 1000, 80, math.random(90, 110), 0.5)
		end)
	end

	wand:HPWSendAnimation(ACT_VM_PRIMARYATTACK_7)

	util.ScreenShake(wand:GetPos(), 100, 100, 5, 2000)
end

HpwRewrite:AddSpell("Shield Penetration", Spell)