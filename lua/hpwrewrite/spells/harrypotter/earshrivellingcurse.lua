local Spell = { }
Spell.LearnTime = 360
Spell.ApplyFireDelay = 0.4
Spell.ShouldSay = false
Spell.Description = [[
	Makes intense ear pain
	by producing loud noise.

	Works only on players.
]]

Spell.SpriteColor = Color(255, 0, 0)
Spell.NodeOffset = Vector(-515, -269, 0)
Spell.AccuracyDecreaseVal = 0.22

function Spell:OnFire(wand)
	local ent = wand:HPWGetAimEntity(400)

	if IsValid(ent) and ent:IsPlayer() then
		if not timer.Exists("hpwrewrite_earrape" .. ent:EntIndex()) then
			local filter = RecipientFilter()
			filter:AddPlayer(ent)

			local snd = CreateSound(ent, "synth/25_pwm_1760.wav", filter)
			snd:Play()
			snd:ChangeVolume(1, 0)
			snd:ChangeVolume(0, 4)

			util.ScreenShake(ent:GetPos(), 64, 128, 3, 40)

			local ang = AngleRand() * 0.2
			ent:ViewPunch(ang)

			ang.r = 0
			ent:SetEyeAngles(ent:EyeAngles() + ang)
			ent:ConCommand("stopsound")

			timer.Create("hpwrewrite_earrape" .. ent:EntIndex(), 10, 1, function()
				snd:Stop()
			end)
		end
	end

	local pos = self.Owner:GetShootPos()
	local dir = self.Owner:GetAimVector()
	for i = 1, 4 do
		timer.Simple(i * 0.1, function()
			sound.Play("weapons/physcannon/energy_bounce2.wav", pos + dir * i * 30, 60, math.random(120, 140))
		end)
	end

	wand:PlayCastSound()
end

HpwRewrite:AddSpell("Ear shrivelling Curse", Spell)