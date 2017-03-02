local Spell = { }
Spell.LearnTime = 360
Spell.Description = [[
	Disguising spell, disguises 
	anything this spell hits 
	from players' eyes for
	a while.
]]
--Spell.WhatToSay = "Hide"
Spell.ShouldSay = false
Spell.FlyEffect = "hpw_white_main"
Spell.ImpactEffect = "hpw_white_impact"
Spell.CanSelfCast = false
Spell.ApplyDelay = 0.4
Spell.AccuracyDecreaseVal = 0.2
Spell.Category = { HpwRewrite.CategoryNames.Protecting, HpwRewrite.CategoryNames.Special }
Spell.OnlyIfLearned = { "Salvio Hexia" }
Spell.NodeOffset = Vector(-1095, 243, 0)

function Spell:OnSpellSpawned(wand, spell)
	wand:PlayCastSound()
end

function Spell:OnFire(wand)
	return true
end

local undereff = { }

local function RemoveOcculto(ent)
	if not undereff[ent] then return end

	if IsValid(ent) then 
		ent:SetNoDraw(false) 
		sound.Play("npc/turret_floor/active.wav", ent:GetPos(), 65, 180)

		timer.Remove("hpwrewrite_occulto_handler" .. ent:EntIndex())
	end

	undereff[ent] = nil
end

function Spell:OnCollide(spell, data)
	local ent = data.HitEntity
	
	if IsValid(ent) and not undereff[ent] then
		ent:SetNoDraw(true)
		undereff[ent] = true

		timer.Create("hpwrewrite_occulto_handler" .. ent:EntIndex(), 45, 1, function() RemoveOcculto(ent) end)
	end
end

HpwRewrite:AddSpell("Hiding Charm", Spell)

-- Counter spell

local Spell = { }
Spell.ShouldSay = false
Spell.LearnTime = 360
Spell.Description = [[
	Counter-spell to Hiding Charm,
	removes disguising effect
	from everything in small area around 
	spell hit position.
]]
--Spell.WhatToSay = "Reveal"
Spell.FlyEffect = "hpw_white_main"
Spell.ImpactEffect = "hpw_white_impact"
Spell.ApplyDelay = 0.4
Spell.AccuracyDecreaseVal = 0.4
Spell.Category = { HpwRewrite.CategoryNames.Protecting, HpwRewrite.CategoryNames.Special }
Spell.OnlyIfLearned = { "Hiding Charm" }
Spell.CanSelfCast = false
Spell.NodeOffset = Vector(-966, 133, 0)

function Spell:OnSpellSpawned(wand, spell)
	wand:PlayCastSound()
end

function Spell:OnFire(wand)
	return true
end

function Spell:OnCollide(spell, data)
	for k, v in pairs(ents.FindInSphere(data.HitPos, 100)) do
		RemoveOcculto(v)
	end
end

HpwRewrite:AddSpell("Revealing Charm", Spell)