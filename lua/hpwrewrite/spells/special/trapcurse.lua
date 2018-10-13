local Spell = { }
Spell.LearnTime = 360
Spell.Description = [[
	Places invisible mine at
	the point you're 
	looking at.
]]
Spell.FlyEffect = "hpw_mine_fly"
Spell.ImpactEffect = "hpw_mine_place"
Spell.ApplyDelay = 0.4
Spell.AccuracyDecreaseVal = 0.3
Spell.Category = { HpwRewrite.CategoryNames.Special, HpwRewrite.CategoryNames.DestrExp }
Spell.OnlyIfLearned = { "Grenadio" }
Spell.NodeOffset = Vector(-1295, -343, 0)
Spell.Traps = true
Spell.ShouldSay = false

function Spell:OnSpellSpawned(wand, spell)
	wand:PlayCastSound()
end

function Spell:OnFire(wand)
	return true
end

local points = { }

if SERVER then
	Spell.Points = points

	local wait = 0

	hook.Add("Think", "hpwrewrite_trapcurse_handler", function()
		if CurTime() < wait then return end

		for _, data in pairs(points) do
			local pos = data.Pos

			for k, ent in pairs(ents.FindInSphere(pos, 60)) do
				if ent == data.Owner and data.FreeOwner then continue end
				if ent.IsHarryPotterSpell or ent.Traps then continue end
				--if ent:GetClass() == "entity_hpwand_flyingspell" then 
				local phys = ent:GetPhysicsObject()

				if phys:IsValid() and phys:GetVelocity():Length() > 10 then
					local ef = EffectData()
					ef:SetOrigin(pos)
					util.Effect("Explosion", ef, true, true)

					local owner = data.Owner
					local wand = data.Wand
					
					if not IsValid(owner) then
						owner = game.GetWorld()
						wand = owner
					end
					
					if not IsValid(wand) then wand = owner end 
					
					util.BlastDamage(wand, owner, pos, 110, 80)

					points[_] = nil
					break
				end
			end
		end

		wait = CurTime() + 0.15
	end)

	hook.Add("PostCleanupMap", "hpwrewrite_trapcurse_handler", function() 
		table.Empty(points)
	end)
end

function Spell:OnCollide(spell, data)
	local data2 = { }
	data2.Owner = self.Owner
	data2.Wand = HpwRewrite:GetWand(self.Owner)
	data2.Pos = data.HitPos
	data2.Normal = data.HitNormal
	points[#points + 1] = data2

	return false, data2
end

HpwRewrite:AddSpell("Trap Curse", Spell)




-- Counter-spell

local Spell = { }
Spell.LearnTime = 150
Spell.Description = [[
	Highlights all nearby placed
	by Trap Curse and Trap Curse
	Duo mines.
]]

--Spell.WhatToSay = "Disarm"
--Spell.ApplyFireDelay = 1
Spell.ShouldSay = false
Spell.AccuracyDecreaseVal = 0.5
Spell.Category = { HpwRewrite.CategoryNames.Special }
Spell.OnlyIfLearned = { "Trap Curse" }
Spell.NodeOffset = Vector(-1198, -441, 0)
Spell.ForceAnim = { ACT_VM_PRIMARYATTACK_8 }
Spell.Traps = true

function Spell:OnFire(wand)
	for _, data in pairs(points) do
		local pos = data.Pos

		if pos:Distance(self.Owner:GetPos()) < 300 then
			sound.Play("hpwrewrite/spells/spellimpact.wav", pos, 66, 135)

			if data.FreeOwner then HpwRewrite.MakeEffect("hpw_mine_detect_duo", pos, data.Normal:Angle())
			else HpwRewrite.MakeEffect("hpw_mine_detect", pos, data.Normal:Angle()) end

			--local n = data.Normal
			--util.Decal("HpwDisarmCurse", pos - n, pos + n)
		end
	end
end

HpwRewrite:AddSpell("Disarm Curse", Spell)




-- Duo
local Spell = { }
Spell.Base = "Trap Curse"
Spell.Description = [[
	Places invisible mine at
	the point you're 
	looking at.
	Will not react to the caster.
]]

Spell.OnlyIfLearned = { "Trap Curse" }
--Spell.ApplyFireDelay = 1.5
Spell.NodeOffset = Vector(-1350, -479, 0)
Spell.ImpactEffect = "hpw_mine_place_duo"

function Spell:OnCollide(spell, data)
	local a, data = self.BaseClass.OnCollide(self, spell, data)
	data.FreeOwner = true
end

HpwRewrite:AddSpell("Trap Curse Duo", Spell)




-- Counter-spell Duo
local Spell = { }
Spell.Base = "Disarm Curse"
Spell.Description = [[
	Destroys all nearby placed
	by Trap Curse and Trap Curse 
	Duo mines.
]]

Spell.OnlyIfLearned = { "Trap Curse Duo", "Disarm Curse" }
Spell.NodeOffset = Vector(-1243, -564, 0)

function Spell:OnFire(wand)
	for _, data in pairs(points) do
		local pos = data.Pos

		if pos:Distance(self.Owner:GetPos()) < 350 then
			sound.Play("hpwrewrite/spells/spellimpact.wav", pos, 66, 135)
			HpwRewrite.MakeEffect("hpw_reducto_impact_metal", pos, Angle(0, 0, 0))

			if data.FreeOwner then
				local owner = data.Owner
				if IsValid(owner) and owner != self.Owner then
					data.Pos = owner:GetPos()
				end

				data.FreeOwner = nil
			else
				points[_] = nil
			end
		end
	end
end

HpwRewrite:AddSpell("Disarm Curse Duo", Spell)