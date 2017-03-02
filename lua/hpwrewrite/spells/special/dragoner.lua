local Spell = { }
Spell.LearnTime = 1500
Spell.Description = [[
	Explosive spell. Can be
	very dangerous in duels.
]]

Spell.FlyEffect = "hpw_dragoner_main"
Spell.ApplyDelay = 0.6
Spell.AccuracyDecreaseVal = 0.15
Spell.Category = { HpwRewrite.CategoryNames.DestrExp, HpwRewrite.CategoryNames.Special }

Spell.ForceAnim = { ACT_VM_PRIMARYATTACK_5 }
Spell.SpriteColor = Color(255, 105, 0)

Spell.NodeOffset = Vector(-361, 200, 0)
Spell.OnlyIfLearned = { "Bombarda" }

Spell.DoSparks = true

function Spell:Draw(spell)
	self:DrawGlow(spell, nil, 128)
end

function Spell:OnSpellSpawned(wand, spell)
	wand:PlayCastSound()
end

PrecacheParticleSystem("hpw_dragoner_ring")

function Spell:SpellThink(spell)
	if SERVER then return end
	if not spell.Wait then spell.Wait = CurTime() + 0.15 end

	if CurTime() > spell.Wait then
		HpwRewrite.MakeEffect("hpw_dragoner_ring", spell:GetPos(), spell:GetFlyDirection():Angle())
		util.ScreenShake(spell:GetPos(), 3, 3, 0.1, 100)

		spell.Wait = CurTime() + 0.06
	end
end

function Spell:OnFire(wand)
	return true
end

function Spell:OnCollide(spell, data)
	HpwRewrite.BlastDamage(self.Owner, data.HitPos, 200, 80)

	local ef = EffectData()
	ef:SetOrigin(data.HitPos)
	util.Effect("explosion", ef, true, true)

	util.ScreenShake(data.HitPos, 1000, 1000, 1, 1000)
	util.Decal("HpwDragoner", data.HitPos - data.HitNormal, data.HitPos + data.HitNormal)
end

HpwRewrite:AddSpell("Dragoner", Spell)