local Spell = { }
Spell.LearnTime = 666
Spell.Description = [[
	Causes terrible hallucinations.
	If you won't go to hell,
	hell will come for you.
]]
Spell.FlyEffect = "hpw_crucio_main"
Spell.ApplyDelay = 0.3
Spell.AccuracyDecreaseVal = 0.5
Spell.Category = HpwRewrite.CategoryNames.Special
Spell.ShouldSay = false
Spell.OnlyIfLearned = { "Dimentio" }

Spell.ForceAnim = { ACT_VM_PRIMARYATTACK_2, ACT_VM_PRIMARYATTACK_5 }
Spell.SpriteColor = Color(255, 0, 0)

Spell.NodeOffset = Vector(583, -1232, 0)

function Spell:OnSpellSpawned(wand, spell)
	wand:PlayCastSound()
end

function Spell:OnFire(wand)
	return true
end

function Spell:OnCollide(spell, data)
	local ply = data.HitEntity
	
	if IsValid(ply) and ply:IsPlayer() then
		local wand = HpwRewrite:GetWand(ply)
		
		if not (wand:IsValid() and wand == ply:GetActiveWeapon() and wand:GetWandCurrentSkin() == "Demonic Wand") then
			net.Start("hpwrewrite_Hell")
			net.Send(ply)
		end
	end
end

HpwRewrite:AddSpell("Holy Hell", Spell)

---

local Spell = { }
Spell.LearnTime = 999
Spell.Description = [[
	Cast this three times to make 
	hell free area, then start 
	casting until you teleport 
	from hell.

	Counter-spell to Holy Hell. 
	Works only if you're under 
	hell effect.
]]
Spell.FlyEffect = "hpw_crucio_main"
Spell.ApplyFireDelay = 0.5
Spell.Category = HpwRewrite.CategoryNames.Special
Spell.CanSelfCast = false
Spell.ForceAnim = { ACT_VM_HITCENTER }
Spell.SpriteColor = Color(0, 255, 0)
Spell.OnlyIfLearned = { "Dimentio" }

Spell.NodeOffset = Vector(683, -1082, 0)

function Spell:OnSpellSpawned(wand, spell)
	wand:PlayCastSound()
end

function Spell:OnFire(wand)
	if not self.Attempt then self.Attempt = 0 end

	self.Attempt = self.Attempt + 1

	sound.Play("npc/zombie/zombie_hit.wav", wand:GetPos(), 70, math.random(110, 130))

	if self.Attempt >= 3 then
		sound.Play("npc/zombie_poison/pz_warn" .. math.random(1, 2) .. ".wav", wand:GetPos(), 70, math.random(130, 140))

		if math.random(1, 3) == 1 then
			sound.Play("ambient/materials/metal4.wav", wand:GetPos(), 70)

			net.Start("hpwrewrite_EHell")
			net.Send(self.Owner)

			self.Attempt = 0
		end
	end
end

HpwRewrite:AddSpell("Antihellia", Spell)