local Spell = { }
Spell.LearnTime = 30
Spell.Description = [[
	Ancient Chineese spell,
	used as a firecrackers
	replacement all around
	the globe.
]]

Spell.AccuracyDecreaseVal = 0.0017
Spell.ApplyFireDelay = 0.1
Spell.ForceDelay = 0.2
Spell.AnimSpeedCoef = 1.5
Spell.AutoFire = true
Spell.ForceAnim = { ACT_VM_PRIMARYATTACK_7 }
Spell.SpriteColor = Color(255, 0, 255)
Spell.DoSparks = true
Spell.NodeOffset = Vector(-951, -940, 0)
Spell.CanSelfCast = false
Spell.ShouldSay = false

PrecacheParticleSystem("purplecracker_main")

function Spell:OnFire(wand)
	HpwRewrite.MakeEffect("purplecracker_main", wand:GetSpellSpawnPosition() + self.Owner:GetAimVector() * 16, self.Owner:EyeAngles() + Angle(90, 0, 0))

	--if math.random(0, 1) == 1 then
		sound.Play("hpwrewrite/spells/cracks.wav", wand:GetPos(), 80)
	--end
end

HpwRewrite:AddSpell("Purple Firecrackers", Spell)