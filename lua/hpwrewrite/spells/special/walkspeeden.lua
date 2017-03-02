local Spell = { }
Spell.LearnTime = 60
Spell.ApplyFireDelay = 0.6
Spell.Category = HpwRewrite.CategoryNames.Special
Spell.Description = [[
	Makes your legs move with 
	abnormal speed.
]]

Spell.ForceAnim = { ACT_VM_PRIMARYATTACK_5 }
Spell.DoSelfCastAnim = false
Spell.NodeOffset = Vector(245, -714, 0)
Spell.ShouldReverseSelfCast = true

function Spell:OnFire(wand)
	local ent = wand:HPWGetAimEntity(250)

	if IsValid(ent) then
		if ent:IsPlayer() then
			local name = "hpwrewrite_walkspeeden_handler" .. ent:EntIndex()
			if hook.GetTable()["Think"][name] then return end

			local oldspeed = ent:GetRunSpeed()
			local newspeed = oldspeed * 4
			local speed = oldspeed
			local inverse = false

			hook.Add("Think", name, function()
				if not IsValid(ent) then hook.Remove("Think", name) return end

				ent:ConCommand("+forward")
				ent:ConCommand("+speed")
				ent:ConCommand("-back")

				if inverse then
					speed = math.Approach(speed, oldspeed, FrameTime() * 200)
					if speed <= oldspeed then 
						hook.Remove("Think", name) 
						ent:ConCommand("-forward")
						ent:ConCommand("-speed")
					end
				else
					speed = math.Approach(speed, newspeed, FrameTime() * 300)
					if speed >= newspeed then inverse = true end
				end

				ent:SetRunSpeed(speed)
			end)
		end
	end
end

HpwRewrite:AddSpell("Walkspeeden", Spell)