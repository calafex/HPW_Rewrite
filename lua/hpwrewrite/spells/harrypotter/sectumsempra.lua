local Spell = { }
Spell.LearnTime = 600
Spell.Description = [[
	A rather dangerous curse
	when the incantation is uttered 
	its effect is the equivalent of 
	an invisible sword; it is used 
	to slash the victim from a 
	distance, causing rather deep 
	wounds.
]]

Spell.Category = HpwRewrite.CategoryNames.Fight
Spell.FlyEffect = "hpw_sectumsemp_main"
Spell.ImpactEffect = "hpw_white_impact"
Spell.ApplyDelay = 0.4
Spell.AccuracyDecreaseVal = 0.25
Spell.ForceAnim = { ACT_VM_PRIMARYATTACK_5 }
Spell.SpriteColor = Color(255, 255, 255)
Spell.NodeOffset = Vector(168, -180, 0)

function Spell:Draw(spell)
	local dlight = DynamicLight(spell:EntIndex())
	if dlight then
		dlight.pos = spell:GetPos()
		dlight.r = 255
		dlight.g = 255
		dlight.b = 255
		dlight.brightness = 3
		dlight.Decay = 1000
		dlight.Size = 128
		dlight.DieTime = CurTime() + 1
	end
end

function Spell:OnRemove(spell)
	if CLIENT then
		local dlight = DynamicLight(spell:EntIndex())
		if dlight then
			dlight.pos = spell:GetPos()
			dlight.r = 255
			dlight.g = 255
			dlight.b = 255
			dlight.brightness = 5
			dlight.Decay = 1000
			dlight.Size = 128
			dlight.DieTime = CurTime() + 1
		end
	end
end

function Spell:OnSpellSpawned(wand, spell)
	wand:PlayCastSound()
end

function Spell:OnFire(wand)
	return true
end

local function doSounds(ent)
	local pos = ent:GetPos()
	for i = 1, 3 do
		timer.Simple(math.Rand(0.1, 0.4), function()
			sound.Play("weapons/knife/knife_hit" .. math.random(1, 4) .. ".wav", pos, 60, math.random(110, 120))
		end)
	end
end

local function doDecals(ent)
	local src = ent:LocalToWorld(ent:OBBCenter())
	for i = 1, 12 do
		local dir = VectorRand() * ent:GetModelRadius() * 1.4
		util.Decal("Blood", src - dir, src + dir)
	end
end

local function setupBleeding(ent, owner)
	owner = owner or NULL

	doDecals(ent)

	local wait = 0
	local hName = "hpwrewrite_sectum_handler" .. ent:EntIndex()
	hook.Add("Think", hName, function()
		if not ent:IsValid() or (ent:IsPlayer() and not ent:Alive()) then hook.Remove("Think", hName) return end

		if CurTime() > wait then
			local bone = ent:GetBonePosition(math.random(1, ent:GetBoneCount() - 1))
			if bone then
				local ef = EffectData()
				ef:SetOrigin(bone)
				util.Effect("BloodImpact", ef, true, true)
			end

			ent:TakeDamage(math.random(1, 4), owner, HpwRewrite:GetWand(owner))
			wait = CurTime() + math.Rand(0.5, 1.3)
		end
	end)
end

local blocked = HpwRewrite.BlockedNPCs

function Spell:AfterCollide(spell, data)
	local ent = data.HitEntity

	if IsValid(ent) and not blocked[ent:GetClass()] then
		if ent:IsNPC() or ent:IsPlayer() then 
			doSounds(ent)

			for i = 1, ent:GetBoneCount() - 1 do 
				if i % 4 == 0 then
					local pos = ent:GetBonePosition(i)

					timer.Simple(math.Rand(0, 0.3), function()
						sound.Play("physics/flesh/flesh_squishy_impact_hard" .. math.random(1, 4) .. ".wav", pos, 70)

						local ef = EffectData()
						ef:SetOrigin(pos)
						util.Effect("BloodImpact", ef, true, true)
					end)
				end
			end

			if not (ent:IsPlayer() and ent:HasGodMode()) then
				local dmg = math.random(20, 40)

				ent:SetHealth(ent:Health() - dmg)
				if ent:Health() <= 0 then ent:TakeDamage(dmg) end
			end

			local rag = HpwRewrite:ThrowEntity(ent, spell:GetFlyDirection(), 600, 4, self.Owner, function(ent)
				setupBleeding(ent, self.Owner)
			end)

			if IsValid(rag) then
				doDecals(rag)
			end
		end
	end
end

HpwRewrite:AddSpell("Sectumsempra", Spell)