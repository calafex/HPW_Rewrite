local Spell = { }
Spell.LearnTime = 480
Spell.Description = [[
	Makes your opponent cast
	random spell on himself
	if he has the wand.

	Works only on players.
]]
Spell.FlyEffect = "hpw_purple_main"
Spell.ImpactEffect = "hpw_purple_impact"
Spell.ApplyDelay = 0.5
Spell.AccuracyDecreaseVal = 0.33
Spell.Category = HpwRewrite.CategoryNames.Special
Spell.CanSelfCast = false
Spell.ForceSpriteSending = true

Spell.ForceAnim = { ACT_VM_PRIMARYATTACK_3 }
Spell.SpriteColor = Color(255, 50, 255)

Spell.NodeOffset = Vector(-1350, -723, 0)

function Spell:Draw(spell)
	self:DrawGlow(spell, HSVToColor((CurTime() * 200) % 360, 1, 1))
end

function Spell:OnSpellSpawned(wand, spell)
	wand:PlayCastSound()
end

function Spell:OnFire(wand)
	self.SpriteColor = HSVToColor((CurTime() * 200) % 360, 1, 1)
	return true
end

function Spell:OnCollide(spell, data)
	local ent = data.HitEntity

	if IsValid(ent) and ent:IsPlayer() then
		local wand = HpwRewrite:GetWand(ent)

		if wand:IsValid() then
			ent:SelectWeapon(HpwRewrite.WandClass)

			local validSpells = { }
			for k, v in pairs(HpwRewrite:GetLearnedSpells(ent)) do
				if v.CanSelfCast then validSpells[k] = v end
			end

			local spell, name = table.Random(validSpells)

			timer.Simple(0, function()
				ent.HpwRewrite.IsHoldingSelfCast = true
				wand:SetNextPrimaryFire(CurTime())
				wand:PrimaryAttack(name)
				ent.HpwRewrite.IsHoldingSelfCast = false
			end)
		end
	end
end

HpwRewrite:AddSpell("Hocus", Spell)