local Spell = { }
Spell.LearnTime = 7200
Spell.ApplyFireDelay = 0.9
Spell.Category = { HpwRewrite.CategoryNames.Special, HpwRewrite.CategoryNames.Unforgivable }

Spell.Description = [[
	Kills everyone and destroys
	everything on the map.

	Very dangerous spell, it's
	highly recommended to add it
	to the blacklist.

	Can be casted only 2 times in 
	the whole world.
]]

Spell.CanSelfCast = false
Spell.ForceAnim = { ACT_VM_PRIMARYATTACK_6 }
Spell.NodeOffset = Vector(503, -1408, 0)
Spell.OnlyIfLearned = { "Holy Hell" }
Spell.SpriteColor = Color(255, 155, 155)
Spell.AccuracyDecreaseVal = 1
Spell.DoSparks = true
Spell.SpriteTime = 900
Spell.SparksLifeTime = 1
Spell.Unforgivable = true

local maxCount = 0

function Spell:OnFire(wand)
	if not self.NextCall then self.NextCall = 0 end

	if maxCount > 2 or CurTime() < self.NextCall then

		return
	end

	self.NextCall = CurTime() + 2
	maxCount = maxCount + 1

	for k, v in pairs(ents.GetAll()) do
		if v:IsWorld() then continue end

		timer.Simple(k * 0.001 + math.random(-3, 3), function()
			if not IsValid(v) then return end

			local pos = v:GetPos()

			sound.Play("ambient/atmosphere/cave_hit" .. math.random(1, 6) .. ".wav", pos, 80)
			if math.random(1, 4) == 1 then
				util.ScreenShake(pos, 30, 7, 4, 5000)
				sound.Play("ambient/explosions/explode_" .. math.random(8, 9) .. ".wav", pos, 90)
			end

			local succ, a = constraint.RemoveAll(v)
			if succ then sound.Play("ambient/machines/wall_move3.wav", pos, 80) end

			--v:TakeDamage(v:Health())
			HpwRewrite.TakeDamage(v, self.Owner, v:Health())

			local phys = v:GetPhysicsObject()
			if phys:IsValid() then
				phys:Wake()
				phys:EnableMotion(true)
				phys:ApplyForceCenter(VectorRand() * phys:GetMass() * 3000)
				phys:AddAngleVelocity(VectorRand() * 1000)
			end
		end)
	end
end

HpwRewrite:AddSpell("Maf", Spell)