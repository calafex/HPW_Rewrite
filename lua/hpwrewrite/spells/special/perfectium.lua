local Spell = { }
Spell.LearnTime = 1080
Spell.Description = [[
	Blows up opponent's head.

	100% brutal.
]]
Spell.FlyEffect = "hpw_confringo_main"
Spell.ImpactEffect = "hpw_stupefy_impactbody"
Spell.ApplyDelay = 0.5
Spell.AccuracyDecreaseVal = 0.35
Spell.Category = HpwRewrite.CategoryNames.Special

Spell.ForceAnim = { ACT_VM_PRIMARYATTACK_2, ACT_VM_PRIMARYATTACK_5 }
Spell.SpriteColor = Color(255, 165, 0)

Spell.NodeOffset = Vector(-29, -796, 0)

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
		undereff[ent] = true

		local oldHp = ent:Health()
		local newHp = oldHp * 6
		local bone = ent:LookupBone("ValveBiped.Bip01_Head1")

		local name = "hpwrewrite_perfectium_handler" .. ent:EntIndex()
		hook.Add("Think", name, function()
			if not IsValid(ent) or (ent:IsPlayer() and not ent:Alive()) then
				undereff[ent] = nil
				hook.Remove("Think", name)
				return
			end
			
			if ent:Health() < newHp then
				ent:SetHealth(ent:Health() + 1)
				
				local sc = 1 + (ent:Health() - oldHp) / (newHp - oldHp)	
				local col = (1 - sc) * 255
				ent:SetColor(Color(255, col, col))
						
				if bone then
					ent:ManipulateBoneScale(bone, Vector(sc, sc, sc))
				end
			else
				ent:SetColor(Color(255, 255, 255))
						
				if bone then
					ent:ManipulateBoneScale(bone, Vector(1, 1, 1))
				end

				HpwRewrite.TakeDamage(ent, self.Owner, ent:Health())
				undereff[ent] = false
			end
		end)
	end
end

HpwRewrite:AddSpell("Perfectium", Spell)