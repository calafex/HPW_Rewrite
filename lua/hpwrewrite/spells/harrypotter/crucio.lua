local Spell = { }
Spell.LearnTime = 900
Spell.Description = [[
	One of the three Unforgivable 
	Curses. It is one of the most 
	powerful and sinister spells 
	known to wizardkind. When 
	cast successfully, the curse 
	inflicts intense, excruciating 
	pain on the victim. 
]]
Spell.Category = HpwRewrite.CategoryNames.Unforgivable
Spell.FlyEffect = "hpw_crucio_main"
Spell.ImpactEffect = "hpw_expelliarmus_impact"
Spell.ApplyDelay = 0.5
Spell.AccuracyDecreaseVal = 0.5
Spell.Unforgivable = true
Spell.ForceAnim = { ACT_VM_PRIMARYATTACK_5 }
Spell.SpriteColor = Color(255, 0, 0)
Spell.NodeOffset = Vector(385, -76, 0)

function Spell:Draw(spell)
	self:DrawGlow(spell, nil, 80)
end

function Spell:OnSpellSpawned(wand, spell)
	sound.Play("ambient/wind/wind_snippet2.wav", spell:GetPos(), 75, 255)
	spell:EmitSound("ambient/wind/wind_snippet2.wav", 80, 255)
	wand:PlayCastSound()
end

function Spell:OnRemove(spell)
	if CLIENT then
		local dlight = DynamicLight(spell:EntIndex())
		if dlight then
			dlight.pos = spell:GetPos()
			dlight.r = 255
			dlight.g = 0
			dlight.b = 0
			dlight.brightness = 1
			dlight.Decay = 1100
			dlight.Size = 256
			dlight.DieTime = CurTime() + 1
		end
	end
end

function Spell:OnFire(wand)
	return true
end

function Spell:AfterCollide(spell, data)
	local ent = data.HitEntity

	if IsValid(ent) and ent.UnderCrucio then
		local phys = ent:GetPhysicsObject()

		if IsValid(phys) then
			phys:ApplyForceCenter(VectorRand() * phys:GetMass() * 400)
			phys:AddAngleVelocity(VectorRand() * 7000)
		end

		ent:TakeDamage(5, self.Owner, HpwRewrite:GetWand(self.Owner))
		ent:EmitSound("physics/flesh/flesh_squishy_impact_hard" .. math.random(1, 2) .. ".wav", 68, math.random(90, 130))
	end

	local rag, func, name = HpwRewrite:ThrowEntity(ent, spell:GetFlyDirection(), nil, 12, self.Owner)

	if IsValid(rag) then
		rag.UnderCrucio = true

		local wait = 0
		local hName = "hpwrewrite_crucio_handler" .. rag:EntIndex()
		hook.Add("Think", hName, function()
			if not IsValid(rag) then hook.Remove("Think", hName) return end

			if CurTime() > wait then
				if math.random(1, 4) == 1 then 
					rag:TakeDamage(math.random(2, 4), self.Owner, HpwRewrite:GetWand(self.Owner)) 
				end

				if ent:IsPlayer() then
					//local filter = RecipientFilter()
					//filter:AddPlayer(ent)

					local screams = 
					{
						"vo/npc/male01/no01.wav",
						"vo/npc/male01/no02.wav",
						"vo/npc/male01/pain07.wav",
						"vo/npc/male01/pain08.wav",
						"vo/npc/male01/pain09.wav"
					}
					
					local snd = CreateSound(rag, screams[math.random(1, #screams)])
					snd:Play()
					//snd:ChangePitch(170, 0)
				end

				local phys = rag:GetPhysicsObject()
				if IsValid(phys) then
					phys:ApplyForceCenter(VectorRand() * phys:GetMass() * 500)
					//phys:AddAngleVelocity(VectorRand() * phys:GetMass())
				end

				wait = CurTime() + math.Rand(0.3, 0.5)
			end
		end)
	end
end

HpwRewrite:AddSpell("Crucio", Spell)