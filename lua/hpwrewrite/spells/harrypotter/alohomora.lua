local Spell = { }
Spell.LearnTime = 60
Spell.ApplyFireDelay = 0.4
Spell.Description = [[
	Unlocks and opens doors,
	hacks keypads that are not
	protected by magic.
]]

Spell.CanSelfCast = false
Spell.NodeOffset = Vector(-377, -365, 0)
Spell.AccuracyDecreaseVal = 0

function Spell:OnFire(wand)
	local ent = wand:HPWGetAimEntity(100)

	if IsValid(ent) then
		local class = ent:GetClass()
		local valid = true

		if class == "func_movelinear" then -- ???
			ent:Input("Open")
		elseif class == "prop_door_rotating" then -- HL2 door
			ent:Fire("unlock", "", 0.1)
			ent:Fire("open", "", 0.1)
		elseif ent.isFadingDoor and ent.fadeActivate then -- DarkRP door
			if ent.HPWColloportusOldFunc and isfunction(ent.HPWColloportusOldFunc) then
				ent.fadeActivate = ent.HPWColloportusOldFunc
			end

			ent:fadeActivate()
		elseif class == "keypad" or class == "keypad_wire" then -- Nonwire keypad
			if ent.HPWColloportusOldFunc and isfunction(ent.HPWColloportusOldFunc) then
				ent.Process = ent.HPWColloportusOldFunc
			end
			
			if ent.Process then ent:Process(true) end
		elseif class == "gmod_wire_keypad" and ent.IsWire and Wire_TriggerOutput then -- Wire keypad
			-- Ive not found any function similar to Process for wire keypad
			ent:SetNetworkedString("keypad_display", "y")
			Wire_TriggerOutput(ent, "Valid", 1)
			ent:EmitSound("buttons/button9.wav")
		else
			valid = false
		end

		if valid then
			sound.Play("doors/door_locked2.wav", ent:GetPos(), 60, 110)
		end
	end
end

HpwRewrite:AddSpell("Alohomora", Spell)