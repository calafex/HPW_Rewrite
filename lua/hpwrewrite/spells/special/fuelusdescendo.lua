local Spell = { }
Spell.LearnTime = 300
Spell.Description = [[
	Make some machines' fuel 
	magically disappear.
]]
Spell.FlyEffect = "hpw_expulso_main"
Spell.ImpactEffect = "hpw_stupefy_impactbody"
Spell.ApplyDelay = 0.35
Spell.AccuracyDecreaseVal = 0.1
Spell.Category = HpwRewrite.CategoryNames.Special

Spell.ForceAnim = { ACT_VM_PRIMARYATTACK_5 }
Spell.SpriteColor = Color(255, 170, 40)
Spell.LeaveParticles = true
Spell.NodeOffset = Vector(-68, 754, 0)

function Spell:OnSpellSpawned(wand, spell)
	sound.Play("weapons/flashbang/flashbang_explode2.wav", spell:GetPos(), 75, 120)
	wand:PlayCastSound()

	HpwRewrite.MakeEffect("hpw_flipendo_main", nil, nil, spell)
end

function Spell:SpellThink(spell)
	if not spell.SoundStuff then spell.SoundStuff = 0 end

	if CurTime() > spell.SoundStuff then
		sound.Play("weapons/flashbang/flashbang_explode2.wav", spell:GetPos(), 75, 140)
		spell.SoundStuff = CurTime() + math.Rand(0.1, 0.4)
	end
end

function Spell:OnFire(wand)
	return true
end

function Spell:OnCollide(spell, data)
	local ent = data.HitEntity
	
	if IsValid(ent) then
		local valid = false

		if ent.IS_DRONE then
			valid = true

			if ent.IS_DRR then
				ent:SetFuel(ent:GetFuel() - math.Rand(10, 40))
			else
				if ent.Fuel < ent.MaxFuel then ent:SetFuel(ent.Fuel + 1) end
			end
		end

		if string.find(ent:GetClass(), "sent_sakarias_car") and ent.IsDestroyed != 1 then
			valid = true

			ent.Fuel = ent.Fuel - 5000
			ent.Fuel = math.Clamp(ent.Fuel, 0, ent.MaxFuel)
		end
		
		if string.find(ent:GetClass(), "acf_fueltank") then
			if ent.Fuel > 0 then
				ent.Fuel = math.Clamp(ent.Fuel - ent.Capacity*math.Rand(0.01,0.1),0,ent.Capacity)
			end
		end

		if valid then
			local ef = EffectData()
			ef:SetOrigin(ent:GetPos())
			ef:SetEntity(ent)
			util.Effect("entity_remove", ef, true, true)
		end

		local pos = data.HitPos
		for i = 1, 3 do
			timer.Simple(i * 0.1, function()
				sound.Play("weapons/airboat/airboat_gun_lastshot" .. math.floor(math.Rand(1, 2)+0.5) .. ".wav", pos, 75, 120)
			end)
		end
	end
end

HpwRewrite:AddSpell("Fuelus Descendo", Spell)