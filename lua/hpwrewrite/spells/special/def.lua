local Spell = { }
Spell.LearnTime = 420
Spell.Description = [[
	Forces your target to drop 
	it's weapons.
]]
Spell.FlyEffect = "hpw_expelliarmus_main"
Spell.ImpactEffect = "hpw_expelliarmus_impact"
Spell.ApplyDelay = 0.5
Spell.AccuracyDecreaseVal = 0.25
Spell.Category = { HpwRewrite.CategoryNames.Fight, HpwRewrite.CategoryNames.Special }
Spell.OnlyIfLearned = { "Expelliarmus" }

Spell.ForceAnim = { ACT_VM_PRIMARYATTACK_2, ACT_VM_PRIMARYATTACK_5 }
Spell.SpriteColor = Color(255, 0, 0)

Spell.NodeOffset = Vector(638, 12, 0)

function Spell:OnSpellSpawned(wand, spell)
	wand:PlayCastSound()
end

function Spell:OnFire(wand)
	return true
end

function Spell:OnCollide(spell, data)
	local ent = data.HitEntity
	
	if IsValid(ent) then
		if ent:IsPlayer() then
			for k, v in pairs(ent:GetWeapons()) do
				ent:DropWeapon(v)
			end
		elseif ent:IsNPC() then
			local wep = ent:GetActiveWeapon()
			if wep:IsValid() then
				local fwep = ents.Create(wep:GetClass())
				if not IsValid(fwep) then return end

				-- These commands will fix game crash
				ent:ClearSchedule()
				ent:ClearGoal()
				ent:ClearEnemyMemory()
				ent:ClearExpression()
				ent:StopMoving()

				fwep:SetPos(ent:LocalToWorld(ent:OBBCenter()))
				fwep:Spawn()

				local phys = fwep:GetPhysicsObject()
				if not IsValid(phys) then return end
				phys:AddAngleVelocity(VectorRand() * phys:GetMass() * 128)
				phys:ApplyForceCenter((ent:GetAimVector() + vector_up * 0.8) * phys:GetMass() * 290)

				wep:Remove()
			end
		else
			local phys = ent:GetPhysicsObject()
			if IsValid(phys) then
				phys:AddAngleVelocity(VectorRand() * 45)
				phys:ApplyForceCenter(((spell:GetPos() - ent:GetPos()):GetNormal() + vector_up * 0.6) * phys:GetMass() * 200)
			end
		end

		ent:TakeDamage(6,self.Owner)
	end
end

HpwRewrite:AddSpell("Def", Spell)