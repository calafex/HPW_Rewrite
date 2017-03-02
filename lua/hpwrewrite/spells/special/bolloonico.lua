local Spell = { }
Spell.LearnTime = 540
Spell.Description = [[
	Summons magic ballons and
	welds them to victim's
	bones, so the victim will
	not be able to move and
	start flying upwards.
]]

Spell.FlyEffect = "hpw_yellow_main"
Spell.ImpactEffect = "hpw_yellow_impact"
Spell.ApplyDelay = 0.5
Spell.AccuracyDecreaseVal = 0.3
Spell.Category = { HpwRewrite.CategoryNames.Special }

Spell.ForceAnim = { ACT_VM_PRIMARYATTACK_3 }
Spell.SpriteColor = Color(255, 255, 0)
Spell.DoSparks = true
Spell.NodeOffset = Vector(582, 549, 0)

function Spell:Draw(spell)
	self:DrawGlow(spell)
end

function Spell:OnSpellSpawned(wand, spell)
	wand:PlayCastSound()
end

function Spell:OnFire(wand)
	return true
end

function Spell:AfterCollide(spell, data)
	local ent = data.HitEntity
	local rag, func, name = HpwRewrite:ThrowEntity(ent, spell:GetFlyDirection(), nil, nil, self.Owner)

	if IsValid(rag) then
		local balloons = 0

		for i = 1, rag:GetPhysicsObjectCount() - 1 do
			if i % 2 == 0 then continue end

			local bone = rag:GetPhysicsObjectNum(i)

			if IsValid(bone) then
				timer.Simple(0, function()
					if not IsValid(rag) then return end

					local balloon = ents.Create("gmod_balloon")
					if not IsValid(balloon) then return end

					balloon:SetModel("models/maxofs2d/balloon_classic.mdl")
					balloon:SetPos(bone:GetPos() + vector_up * math.random(20, 30))
					balloon:Spawn()

					balloon:GetPhysicsObject():Wake()
					balloon:SetOwner(rag)

					local color = ColorRand()
					local force = math.random(80, 280)

					balloon:SetColor(color)
					balloon:SetForce(force)
					balloon:SetPlayer(self.Owner)

					balloon.Player = self.Owner
					balloon.r = color.r
					balloon.g = color.g
					balloon.b = color.b
					balloon.force = force
					print(balloon:GetPos())
					constraint.Rope(
						balloon,
						rag,
						0,
						i,
						Vector(0, 0, 0),
						Vector(0, 0, 0),
						0,
						math.random(5, 30),
						0,
						0.5,
						"cable/rope"
					)
				
					balloons = balloons + 1

					timer.Simple(math.Rand(2, 8), function()
						balloons = balloons - 1
						if IsValid(balloon) then balloon:TakeDamage(1) end
						if balloons <= 0 then 
							if rag:IsValid() then
								timer.Simple(0.3, function() -- let us get some velocity
									HpwRewrite.Throwing_TimerReviveFunc(rag, name, "hpwrewrite_ballonico_handler" .. rag:EntIndex(), 2, func)
								end)
							end 
						end
					end)
				end)
			end
		end
	end
end

HpwRewrite:AddSpell("Balloonico", Spell)