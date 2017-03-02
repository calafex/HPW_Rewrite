local Spell = { }
Spell.LearnTime = 900
Spell.Description = [[
	Starts stabbing your
	opponent until he dies.
]]
Spell.FlyEffect = "hpw_expelliarmus_main"
Spell.ImpactEffect = "hpw_expelliarmus_impact"
Spell.ApplyDelay = 0.5
Spell.AccuracyDecreaseVal = 0.7
Spell.Category = HpwRewrite.CategoryNames.Special
Spell.OnlyIfLearned = { "Gonfiare" }

Spell.ForceAnim = { ACT_VM_PRIMARYATTACK_2, ACT_VM_PRIMARYATTACK_5 }
Spell.SpriteColor = Color(255, 50, 50)

Spell.NodeOffset = Vector(-15, -1091, 0)

function Spell:Draw(spell)
	self:DrawGlow(spell)
end

function Spell:OnSpellSpawned(wand, spell)
	wand:PlayCastSound()
end

function Spell:OnFire(wand)
	return true
end

function Spell:SpellThink(spell)
	if SERVER then return end

	if not spell.Emitter then
		spell.Emitter = ParticleEmitter(spell:GetPos()) 
		return
	end

	
	local die = math.Rand(0.7, 2.6)
	local vel = VectorRand() * 40 + spell:GetFlyDirection() * 300
	local res = math.random(15, 40)
	local size = math.random(4, 8)

	local p = spell.Emitter:Add("hpwrewrite/sprites/magicsprite", spell:GetPos())
	p:SetDieTime(die)
	p:SetBounce(0.8)
	p:SetCollide(true)
	p:SetVelocity(vel)
	p:SetAirResistance(res)
	p:SetStartSize(size)
	p:SetEndSize(0)
	p:SetStartAlpha(255)
	p:SetEndAlpha(0)
	p:SetColor(255, 50, 50)

	local p = spell.Emitter:Add("hpwrewrite/sprites/magicsprite", spell:GetPos())
	p:SetDieTime(die)
	p:SetBounce(0.8)
	p:SetCollide(true)
	p:SetVelocity(vel)
	p:SetAirResistance(res)
	p:SetStartSize(size / 2)
	p:SetEndSize(0)
	p:SetStartAlpha(255)
	p:SetEndAlpha(0)
	p:SetColor(255, 255, 255)
end

function Spell:OnRemove(spell)
	if CLIENT and spell.Emitter then spell.Emitter:Finish() end
end

local blocked = HpwRewrite.BlockedNPCs

function Spell:OnCollide(spell, data)
	local ent = data.HitEntity
	
	if IsValid(ent) and (ent:IsPlayer() or ent:IsNPC()) and not blocked[ent:GetClass()] then
		local owner = self.Owner
		local wand = HpwRewrite:GetWand(owner)

		local time = CurTime()
		local name = "hpwrewrite_secare_handler" .. ent:EntIndex()
		hook.Add("Think", name, function()
			if CurTime() < time then return end
			if not IsValid(ent) or ent:Health() <= 0 then hook.Remove("Think", name) return end

			local pos = ent:GetBonePosition(math.random(1, ent:GetBoneCount() - 1))
			if not pos then pos = ent:GetPos() end

			sound.Play("weapons/knife/knife_hit" .. math.random(1, 4) .. ".wav", pos, 70)
			if math.random(0, 1) == 1 then 
				sound.Play("physics/flesh/flesh_squishy_impact_hard" .. math.random(1, 4) .. ".wav", pos, 70)

				local ef = EffectData()
				ef:SetOrigin(pos)
				util.Effect("BloodImpact", ef, true, true)
			end

			ent:TakeDamage(math.random(1, 2), owner, wand)

			time = CurTime() + math.Rand(0.01, 0.03)
		end)
	end
end

HpwRewrite:AddSpell("Secare", Spell)