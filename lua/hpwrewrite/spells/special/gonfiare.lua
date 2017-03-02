local Spell = { }
Spell.LearnTime = 900
Spell.Description = [[
	Brutally blows up your victim
	from inside.
]]
Spell.FlyEffect = "hpw_purple_main"
Spell.ImpactEffect = "hpw_purple_impact"
Spell.ApplyDelay = 0.5
Spell.AccuracyDecreaseVal = 0.25
Spell.Category = HpwRewrite.CategoryNames.Special
Spell.OnlyIfLearned = { "Perfectium" }

Spell.ForceAnim = { ACT_VM_PRIMARYATTACK_2, ACT_VM_PRIMARYATTACK_5 }
Spell.SpriteColor = Color(255, 50, 255)

Spell.NodeOffset = Vector(-83, -936, 0)

function Spell:Draw(spell)
	self:DrawGlow(spell)
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
	
	if IsValid(ent) and (ent:IsPlayer() or ent:IsNPC()) and not undereff[ent] then
		undereff[ent] = true

		local scales = { }
		for i = 1, ent:GetBoneCount() - 1 do scales[i] = 1 end

		local endTime = CurTime() + math.Rand(1.5, 2.5)

		local name = "hpwrewrite_gonfiare_handler" .. ent:EntIndex()
		hook.Add("Think", name, function()
			if not IsValid(ent) or (ent:IsPlayer() and not ent:Alive()) or CurTime() > endTime then
				undereff[ent] = nil
				hook.Remove("Think", name)

				if IsValid(ent) then
					local pos = ent:GetPos()
					local ef = EffectData()
					ef:SetOrigin(pos)
					util.Effect("Explosion", ef, true, true)

					for i = 1, ent:GetBoneCount() - 1 do 
						if i % 2 == 0 then
							local pos = ent:GetBonePosition(i)

							timer.Simple(math.Rand(0, 0.3), function()
								sound.Play("physics/flesh/flesh_squishy_impact_hard" .. math.random(1, 4) .. ".wav", pos, 70)

								local ef = EffectData()
								ef:SetOrigin(pos)
								util.Effect("BloodImpact", ef, true, true)
							end)
						end
					end
					
					local def = Vector(1, 1, 1)
					local defa = Angle(0, 0, 0)
					for k, v in pairs(scales) do 
						ent:ManipulateBoneScale(k, def) 
						ent:ManipulateBoneAngles(k, defa)
					end
				
					util.BlastDamage(ent, ent, pos, 120, 50)
					ent:TakeDamage(ent:Health(), self.Owner, HpwRewrite:GetWand(self.Owner))

					if ent:IsNPC() then 
						SafeRemoveEntity(ent)
					elseif ent:IsPlayer() then 
						SafeRemoveEntity(ent:GetRagdollEntity()) 
					end
				end

				return
			end
			
			local x = CurTime()
			for k, v in pairs(scales) do
				scales[k] = scales[k] + math.Rand(-0.005, 0.01)
				ent:ManipulateBoneScale(k, Vector(v, v, v))
				ent:ManipulateBoneAngles(k, Angle(math.sin(x), math.cos(x), math.sin(x)) * 3)

				if math.random(0, 8) == 0 then
					sound.Play("npc/zombie/foot_slide" .. math.random(1, 3) .. ".wav", ent:GetPos(), 57)
				end
			end
		end)
	end
end

HpwRewrite:AddSpell("Gonfiare", Spell)