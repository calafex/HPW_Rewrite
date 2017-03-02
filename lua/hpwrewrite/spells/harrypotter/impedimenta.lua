local Spell = { }
Spell.LearnTime = 180
Spell.Description = [[
	Slows down your opponent.

	Casted on NPC will just
	stop it from attacking you
	due to Source 
	engine limitations.
]]
Spell.Category = HpwRewrite.CategoryNames.Fight
Spell.FlyEffect = "hpw_stupefy_main"
Spell.ImpactEffect = "hpw_stupefy_impact"
Spell.ApplyDelay = 0.5
Spell.AccuracyDecreaseVal = 0.3

Spell.ForceAnim = { ACT_VM_PRIMARYATTACK_5 }
Spell.SpriteColor = Color(0, 255, 255)
Spell.NodeOffset = Vector(-727, -393, 0)
Spell.OnlyIfLearned = { "Colloshoo" }

if SERVER then
	util.AddNetworkString("hpwrewrite_impedimenta_handler")
else
	net.Receive("hpwrewrite_impedimenta_handler", function()
		local startTime = CurTime()
		local endTime = CurTime() + 10

		local val = 1

		hook.Add("AdjustMouseSensitivity", "hpwrewrite_impedimenta_handler", function(def)
			if CurTime() > endTime then hook.Remove("AdjustMouseSensitivity", "hpwrewrite_impedimenta_handler") return 1 end
			
			local a = endTime - CurTime()

			if a > 7 then
				val = math.Approach(val, 0.1, FrameTime() * 0.5)
			elseif a < 3 then
				val = math.Approach(val, 1, FrameTime() * 0.5)
			end

			return val
		end)
	end)
end

function Spell:OnSpellSpawned(wand, spell)
	wand:PlayCastSound()
end

function Spell:OnFire(wand)
	return true
end

local undereff = { }

function Spell:OnCollide(spell, data)
	local ent = data.HitEntity
	
	if IsValid(ent) and not undereff[ent] then
		local name = "hpwrewrite_impedimenta_handler" .. ent:EntIndex()

		if ent:IsPlayer() then
			local oldM = ent:GetWalkSpeed()
			local oldR = ent:GetRunSpeed()
			local oldP = ent:GetJumpPower()

			ent:SetWalkSpeed(oldM * 0.1)
			ent:SetRunSpeed(oldR * 0.1)
			ent:SetJumpPower(oldP * 0.1)

			local wep = ent:GetActiveWeapon()
			if IsValid(wep) then 
				wep:SetNextPrimaryFire(CurTime() + 7) 
				wep:SetNextSecondaryFire(CurTime() + 7)
			end

			net.Start("hpwrewrite_impedimenta_handler")
			net.Send(ent)

			timer.Create(name, 10, 1, function()
				ent:SetWalkSpeed(oldM)
				ent:SetRunSpeed(oldR)
				ent:SetJumpPower(oldP)

				undereff[ent] = nil
			end)
		elseif ent:IsNPC() then
			local endTime = CurTime() + 10

			hook.Add("Think", name, function()
				if not IsValid(ent) or CurTime() > endTime then 
					undereff[ent] = nil
					hook.Remove("Think", name) 
					return 
				end

				ent:ClearSchedule()
				ent:ClearGoal()
				ent:ClearEnemyMemory()
				ent:ClearExpression()
				ent:StopMoving()
			end)
		end

		undereff[ent] = true
	end
end

HpwRewrite:AddSpell("Impedimenta", Spell)