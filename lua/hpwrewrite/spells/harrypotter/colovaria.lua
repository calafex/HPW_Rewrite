local Spell = { }
Spell.LearnTime = 30
Spell.ApplyFireDelay = 0.4
Spell.ForceSpriteSending = true
Spell.Description = [[
	Changes the color of the 
	object you're looking at.
]]

Spell.NodeOffset = Vector(-13, 69, 0)
Spell.AccuracyDecreaseVal = 0

function Spell:PreFire(wand)
	if not self.Sound then
		self.Sound = CreateSound(wand, "ambient/creatures/leech_bites_loop1.wav")
		self.Sound:Play()

		timer.Create("hpwrewrite_colovaria_handlersnd" .. wand:EntIndex(), 0.8, 1, function()
			if self.Sound then
				self.Sound:Stop()
				self.Sound = nil
			end
		end)

		return true
	end

	return false
end

function Spell:OnFire(wand)
	local ent = wand:HPWGetAimEntity(400)

	local color = ColorRand()

	if IsValid(ent) then
		if ent:IsPlayer() then
			ent:SetPlayerColor(Vector(color.r / 255, color.g / 255, color.b / 255))
		else
			if ent:GetClass() == "prop_physics" then ent:SetColor(color) end
		end
	end

	self.SpriteColor = color
end

HpwRewrite:AddSpell("Colovaria", Spell)