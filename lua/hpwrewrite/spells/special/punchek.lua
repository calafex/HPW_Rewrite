local Spell = { }
Spell.LearnTime = 30
Spell.ApplyFireDelay = 0.6
Spell.Category = HpwRewrite.CategoryNames.Special
Spell.Description = [[
	Like a kick in the teeth.
]]

Spell.ForceAnim = { ACT_VM_PRIMARYATTACK_5 }
Spell.NodeOffset = Vector(392, -618, 0)

function Spell:OnFire(wand)
	local ent = wand:HPWGetAimEntity(250, Vector(-5, -5, -5), Vector(5, 5, 5))

	if IsValid(ent) then
		if ent:IsPlayer() or ent:IsNPC() then
			if ent:IsPlayer() then
				local ang = AngleRand()
				ang.r = 0
				ent:SetEyeAngles(ang)
				ent:ViewPunch(ang * 0.2)
			end

			ent:SetVelocity(VectorRand() * 200)
		end
	end
end

HpwRewrite:AddSpell("Punchek", Spell)


local Spell = { }
Spell.Base = "Punchek"
Spell.LearnTime = 60
Spell.Description = [[
	Very strong kick in the teeth.
]]

Spell.OnlyIfLearned = { "Punchek" }
Spell.NodeOffset = Vector(503, -705, 0)

function Spell:OnFire(wand)
	local ent = wand:HPWGetAimEntity(250, Vector(-5, -5, -5), Vector(5, 5, 5))

	if IsValid(ent) then
		local d = DamageInfo()
		d:SetDamage(25)
		d:SetAttacker(self.Owner)
		d:SetDamageType(DMG_BULLET)
		ent:TakeDamageInfo(d)
	end

	self.BaseClass.OnFire(self, wand)
end

HpwRewrite:AddSpell("Punchek Duo", Spell)