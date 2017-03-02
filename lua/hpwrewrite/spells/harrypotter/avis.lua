local Spell = { }
Spell.LearnTime = 30
Spell.Description = [[
	Spawns birds at the end of
	the wand.
]]

Spell.ApplyFireDelay = 0.4
Spell.CanSelfCast = false
Spell.AccuracyDecreaseVal = 0.1

Spell.NodeOffset = Vector(-791, -32, 0)

function Spell:OnFire(wand)
	local ang = self.Owner:EyeAngles()
	local pos = self.Owner:EyePos() + ang:Right() * 2 + ang:Forward() * 40

	sound.Play("hpwrewrite/notify.wav", pos, 60, 130)

	for i = 1, math.random(3, 5) do
		local dir = ang:Forward() + (VectorRand() * 0.1)

		local a = ents.Create("entity_hpwand_bird")
		a:SetPos(pos + VectorRand() * 10)
		a:SetAngles(dir:Angle())
		a:Spawn()
	end
end

HpwRewrite:AddSpell("Avis", Spell)