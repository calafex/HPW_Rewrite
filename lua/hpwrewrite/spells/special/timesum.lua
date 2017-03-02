local Spell = { }
Spell.LearnTime = 3000
Spell.Category = HpwRewrite.CategoryNames.Special
Spell.ApplyFireDelay = 0.2
Spell.Description = [[
	Makes world time go
	slower.
]]

Spell.ForceAnim = { ACT_VM_PRIMARYATTACK_6 }
Spell.CanSelfCast = false
Spell.NodeOffset = Vector(220, -584, 0)
Spell.AccuracyDecreaseVal = 0

local Exists = false

function Spell:OnFire(wand)
	if Exists then return end
	if self.Wait and CurTime() < self.Wait then return end

	local time = game.GetTimeScale()
	local old = time
	local inverse = false
	local name = "hpwrewrite_timesum_handler" .. self.Owner:EntIndex()

	hook.Add("Think", name, function()
		if inverse then
			time = math.Approach(time, old, FrameTime() * 0.4)

			if time >= old then
				hook.Remove("Think", name)
				Exists = false
				self.Wait = CurTime() + 20
			end
		else
			time = math.Approach(time, 0.05, FrameTime())
			if time <= 0.05 then inverse = true end
		end

		game.SetTimeScale(time)
		self.Time = time
	end)

	Exists = true
end

function Spell:Think(wand)
	if SERVER and Exists and self.Time then
		local col = HSVToColor(self.Time * 360, 1, 1)

		wand:RequestSprite(self.Name, col, 1600, (1 - self.Time) * 2, true)

		local ef = EffectData()
		ef:SetEntity(self.Owner)
		ef:SetStart(Vector(col.r, col.g, col.b))
		ef:SetScale(0.03)
		util.Effect("EffectHpwRewriteSparks", ef, true, true)
	end
end

HpwRewrite:AddSpell("Timesum", Spell)