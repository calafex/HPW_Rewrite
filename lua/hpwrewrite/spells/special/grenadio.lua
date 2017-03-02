local Spell = { }
Spell.LearnTime = 330
Spell.Description = [[
	Creates a grenade at impact
	position.
]]
Spell.FlyEffect = "hpw_grenadio_main"
Spell.ImpactEffect = "hpw_expulso_impact_warp"
Spell.ApplyDelay = 0.7
Spell.AccuracyDecreaseVal = 0.3
Spell.Category = { HpwRewrite.CategoryNames.Special, HpwRewrite.CategoryNames.DestrExp }
Spell.NodeOffset = Vector(-1354, -180, 0)
Spell.ForceAnim = { ACT_VM_PRIMARYATTACK_5 }

function Spell:OnSpellSpawned(wand, spell)
	wand:PlayCastSound()
end

function Spell:OnFire(wand)
	local ef = EffectData()
	ef:SetEntity(self.Owner)
	local col = Color(255, 255, 255)
	ef:SetStart(Vector(col.r, col.g, col.b))
	ef:SetScale(0.3)
	util.Effect("EffectHpwRewriteSparks", ef, true, true)

	return true
end

function Spell:OnCollide(spell, data)
	local ent = ents.Create("npc_grenade_frag")
	ent:SetPos(data.HitPos - data.HitNormal * 25)
	ent:SetAngles(AngleRand())
	ent:Spawn()
	ent:Activate()

	ent:Fire("SetTimer", "2")

	local phys = ent:GetPhysicsObject()
	if not IsValid(phys) then ent:Remove() return end

	phys:ApplyForceCenter((VectorRand() * 0.2 - data.HitNormal) * phys:GetMass() * 200)
	phys:AddAngleVelocity(VectorRand() * 60)
end

HpwRewrite:AddSpell("Grenadio", Spell)