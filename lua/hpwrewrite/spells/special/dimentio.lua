local Spell = { }
Spell.LearnTime = 600
Spell.Description = [[
	Draws the target away from 
	the humans' world to another 
	dimension. Target is able to 
	move but no one can feel it's 
	precense or see it.
]]
Spell.FlyEffect = "hpw_sectumsemp_main"
Spell.ImpactEffect = "hpw_white_impact"
Spell.ApplyDelay = 0.2
Spell.AccuracyDecreaseVal = 0.5
Spell.Category = HpwRewrite.CategoryNames.Special

Spell.SpriteColor = Color(255, 255, 255)

Spell.NodeOffset = Vector(483, -1032, 0)

function Spell:OnSpellSpawned(wand, spell)
	wand:PlayCastSound()
end

function Spell:OnFire(wand)
	return true
end

function Spell:OnCollide(spell, data)
	local ply = data.HitEntity
	
	if IsValid(ply) and ply:IsPlayer() then
		if not ply.HpwRewrite.WasInDimension then
			ply.HpwRewrite.InDimension = true
			
			local oldWep = ""
			if IsValid(ply:GetActiveWeapon()) then oldWep = ply:GetActiveWeapon():GetClass() end

			--local weps = { }
			--for k, v in pairs(ply:GetWeapons()) do table.insert(weps, v:GetClass()) end

			--ply:StripWeapons()
			--ply:DrawWorldModel(false)
			ply:SetNotSolid(true)
			ply:SetMaterial("Models/effects/vol_light001")
			ply:GetActiveWeapon():SetMaterial("Models/effects/vol_light001")
			ply.HpwRewrite.BlockSpelling = true

			timer.Create("hpwrewrite_dimension_handler" .. ply:EntIndex(), 60, 1, function()
				if IsValid(ply) then
					ply.HpwRewrite.BlockSpelling = false
					ply.HpwRewrite.InDimension = false
					ply:SetMaterial("")
					ply:GetActiveWeapon():SetMaterial("")
					ply:SetNotSolid(false)
				end
			end)

			-- Visual effects
			net.Start("hpwrewrite_Dim")
			net.Send(ply)

			ply.HpwRewrite.WasInDimension = true
		else
			util.ScreenShake(data.HitPos, 4000, 4000, 3, 200)
			sound.Play("npc/stalker/go_alert2a.wav", data.HitPos, 60, 90)
		end
	end
end

if SERVER then
	hook.Add("PlayerSwitchWeapon","HPWDimensioStopSwitching",function(who)
		if who.HpwRewrite.InDimension == true then
			return true
		end
	end)
	
	hook.Add("PlayerCanPickupItem","HPWDimensioStopIPickup",function(who)
		if who.HpwRewrite.InDimension == true then
			return false
		end
	end)
	
	hook.Add("PlayerCanPickupWeapon","HPWDimensioStopWPickup",function(who)
		if who.HpwRewrite.InDimension == true then
			return false
		end
	end)
	
	hook.Add("PlayerUse","HPWDimensioStopUse",function(who)
		if who.HpwRewrite.InDimension == true then
			return false
		end
	end)
end

HpwRewrite:AddSpell("Dimentio", Spell)