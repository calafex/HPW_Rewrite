local Spell = { }
Spell.LearnTime = 30
Spell.ApplyFireDelay = 0.4
Spell.Category = { HpwRewrite.CategoryNames.Special }
Spell.Description = [[
	Makes Playable Piano play
	Hedwig's Theme.
]]

Spell.NodeOffset = Vector(975, -1207, 0)
Spell.WhatToSay = "Propositum"

local notes = "r u0 o I u0 a p0 I0 u0 o I Y0 i r70 r u0 o I u0 a dy9wE S st8qW O Y80e a P pQ*0 o uo w u0 o aw07 o aw07 o sw07 a Pw08 I ow07 a P Ew08 r aw07 o aw07 o aw07 o dw9^ S s8q0 O sw07 a P EQ*0 o uw0 u3 a fu h G fu k ju Gu fu h G Du g aru a fu h G fu k zdyoP L lstiO H ltup k J jITO h fh o fu h kour h kour h lour k Jout G hour k J Pout a kour h kour h kour h zoyE L ltiu H lour k J PITO h fou u0"
notes = string.Replace(notes, " ", "")

local notesLength = string.len(notes)

function Spell:OnFire(wand)
	local ent = wand:HPWGetAimEntity(400)

	sound.Play("hpwrewrite/magicchimes03.wav", wand:GetPos(), 73)

	if IsValid(ent) and ent.Base == "gmt_instrument_base" and ent.GetSound and ent.AdvancedKeys then
		local name = "hpwrewrite_propositum_handler" .. ent:EntIndex()
		local nextPlay = 0
		local nextNote = 1

		hook.Add("Think", name, function()
			if not IsValid(ent) or nextNote >= notesLength then hook.Remove("Think", name) return end

			if CurTime() > nextPlay then
				local note = string.sub(notes, nextNote, nextNote)
				local found = false

				for a, keyTab in pairs(ent.AdvancedKeys) do
					if keyTab.Label == note then
						note = keyTab.Sound
						found = true
						break
					elseif keyTab.Shift then
						if keyTab.Shift.Label == note then
							note = keyTab.Shift.Sound
							found = true
							break
						end
					end
				end

				if found then
					local snd = ent:GetSound(note)
					if snd then ent:EmitSound(snd, 80) end
				end
				
				nextNote = nextNote + 1
				nextPlay = CurTime() + 0.23
			end
		end)
	end
end

HpwRewrite:AddSpell("Propositum Charm", Spell)

