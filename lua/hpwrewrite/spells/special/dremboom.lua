local Spell = { }
Spell.LearnTime = 4800
Spell.Description = [[
	Very powerful and big
	explosion. Nothing will
	survive under this spell's effect.
]]

Spell.FlyEffect = "hpw_dremboom_main"
Spell.ImpactEffect = "hpw_dremboom_impact"
Spell.ApplyDelay = 0.8
Spell.AccuracyDecreaseVal = 1
Spell.DoSelfCastAnim = false
Spell.Category = { HpwRewrite.CategoryNames.DestrExp, HpwRewrite.CategoryNames.Special }

Spell.DoSparks = true
Spell.SparksLifeTime = 1.1

Spell.ForceAnim = { ACT_VM_PRIMARYATTACK_6 }
Spell.SpriteColor = Color(55, 255, 255)

Spell.OnlyIfLearned = { "Forbefire" }

Spell.NodeOffset = Vector(-501, -78, 0)

function Spell:OnSpellSpawned(wand, spell)
	sound.Play("npc/strider/fire.wav", spell:GetPos(), 75, 170)
	self.Owner:ViewPunch(Angle(-8, 0, -4))
	--wand:PlayCastSound()
end

function Spell:GetAnimations(wand)
	if self.NotAvailable then return ACT_VM_PRIMARYATTACK_3 end
end

function Spell:OnFire(wand)
	if self.NotAvailable then sound.Play("npc/manhack/mh_blade_snick1.wav", wand:GetPos(), 60, 100) return false end
	self.NotAvailable = true

	timer.Create("hpwrewrite_dremboom_nerf" .. self.Owner:EntIndex(), 7, 1, function()
		self.NotAvailable = false
	end)

	return true
end

function Spell:OnCollide(spell, data)
	sound.Play("ambient/explosions/explode_6.wav", data.HitPos, 120, 210)
	sound.Play("ambient/explosions/explode_8.wav", data.HitPos, 100, 110)
	sound.Play("ambient/explosions/explode_5.wav", data.HitPos, 100, 110)
	
	local i = 10
	timer.Create("hpwrewrite_dremboom_handler" .. spell:EntIndex(), 0.01, 75, function()
		i = i + 20
		HpwRewrite.BlastDamage(self.Owner, data.HitPos, i, 10)
	end)

	for k, v in pairs(ents.FindInSphere(data.HitPos, 420)) do
		local d = DamageInfo()
		d:SetDamage(v:Health())
		d:SetAttacker(self.Owner)

		local wand = HpwRewrite:GetWand(self.Owner)
		if not wand:IsValid() then wand = self.Owner end
		
		d:SetInflictor(wand)
		d:SetDamageType(DMG_DISSOLVE)
		v:TakeDamageInfo(d)
	end

	util.ScreenShake(data.HitPos, 4000, 4000, 3, 10000)
	util.Decal("HpwDremboom", data.HitPos - data.HitNormal, data.HitPos + data.HitNormal)
end

HpwRewrite:AddSpell("Dremboom", Spell)