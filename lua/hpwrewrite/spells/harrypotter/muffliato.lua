local Spell = { }
Spell.LearnTime = 120
Spell.ApplyFireDelay = 0.3
Spell.Description = [[
	Makes your opponent hear
	white noise.

	Works only on players.
]]

Spell.NodeOffset = Vector(-1219, -922, 0)
Spell.AccuracyDecreaseVal = 0.3

function Spell:OnFire(wand)
	local ent, tr = wand:HPWGetAimEntity(800)

	if IsValid(ent) and ent:IsPlayer() then
		local filter = RecipientFilter()
		filter:AddPlayer(ent)

		local snd = CreateSound(ent, "synth/white_noise.wav", filter)
		snd:Play()
		snd:ChangeVolume(1, 0)
		snd:ChangeVolume(0, 20)
	end
end

HpwRewrite:AddSpell("Muffliato", Spell)