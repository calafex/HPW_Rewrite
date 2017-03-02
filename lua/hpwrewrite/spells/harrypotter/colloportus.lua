local Spell = { }
Spell.LearnTime = 60
Spell.ApplyFireDelay = 0.4
Spell.Description = [[
	Locks doors and keypads so
	they will be not able to
	open without magic.

	To remove magic effect
	cast it one more time.
]]

Spell.OnlyIfLearned = { "Alohomora" }
Spell.CanSelfCast = false
Spell.NodeOffset = Vector(-479, -440, 0)
Spell.AccuracyDecreaseVal = 0

local undereff = { }

function Spell:OnFire(wand)
	local ent = wand:HPWGetAimEntity(100)

	if IsValid(ent) then
		local class = ent:GetClass()
		local valid = true

		if undereff[ent] then
			if class == "prop_door_rotating" then
				ent:Input("UnLock")
			elseif ent.isFadingDoor then
				ent.fadeActivate = ent.HPWColloportusOldFunc
			elseif class == "keypad" or class == "keypad_wire" then
				ent.Process = ent.HPWColloportusOldFunc
			elseif class == "gmod_wire_keypad" and ent.IsWire and Wire_TriggerOutput then
				-- todo: fix
			else
				valid = false
			end

			undereff[ent] = nil
		else
			if class == "prop_door_rotating" then
				ent:Input("Close")
				ent:Input("Lock")
			elseif ent.isFadingDoor then
				ent.HPWColloportusOldFunc = ent.fadeActivate
				ent.fadeActivate = function(ent) end
				ent:fadeDeactivate()
			elseif class == "keypad" or class == "keypad_wire" then
				ent.HPWColloportusOldFunc = ent.Process
				ent.Process = function() end
				ent:Process(false)
			elseif class == "gmod_wire_keypad" and ent.IsWire and Wire_TriggerOutput then
				-- todo: fix
			else
				valid = false
			end

			undereff[ent] = true
		end

		if valid then
			sound.Play("doors/latchlocked2.wav", ent:GetPos(), 60, 110)
		end
	end
end

HpwRewrite:AddSpell("Colloportus", Spell)