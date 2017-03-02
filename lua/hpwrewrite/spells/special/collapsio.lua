local Spell = { }
Spell.Description = [[
	Produces a warp bulb that 
	collapses target on impact.

	Doesn't work on scripted
	entities due to security
	problems.
]]
Spell.FlyEffect = "hpw_collapsio_main"
Spell.ApplyDelay = 0.4
Spell.SpriteColor = Color(0, 0, 0)

Spell.LearnTime = 780
Spell.Category = { HpwRewrite.CategoryNames.Special, HpwRewrite.CategoryNames.Physics }
Spell.AccuracyDecreaseVal = 0.3

Spell.OnlyIfLearned = { "Waddiwasi", "Levicorpus" }
Spell.ForceAnim = { ACT_VM_PRIMARYATTACK_5 }

Spell.NodeOffset = Vector(137, 115, 0)

function Spell:OnFire(wand)
	return true
end

function Spell:OnSpellSpawned(wand)
	wand:PlayCastSound()
end

function Spell:AfterCollide(spell, data)
	local ent = data.HitEntity
	if not IsValid(ent) then return end

	local rag, func, name = HpwRewrite:ThrowEntity(ent, spell:GetFlyDirection(), nil, nil, self.Owner)

	if IsValid(rag) then 
		ent = rag
		timer.Remove(name)
	elseif ent:GetClass() != "prop_physics" then
		return
	end

	local phys = ent:GetPhysicsObject()
	if not phys:IsValid() then return end

	phys:EnableGravity(false)
	for i = 1, ent:GetPhysicsObjectCount() - 1 do 
		local bone = ent:GetPhysicsObjectNum(i)
		bone:EnableGravity(false)
	end

	ent:SetModelScale(0, 0.4)

	local hitPos = data.HitPos
	local hName = "hpwrewrite_collapsio_handler" .. ent:EntIndex()
	hook.Add("Think", hName, function()
		if not ent:IsValid() then hook.Remove("Think", hName) return end
		if ent:GetModelScale() <= 0 then SafeRemoveEntity(ent) return end

		for i = 1, ent:GetPhysicsObjectCount() - 1 do 
			local bone = ent:GetPhysicsObjectNum(i)
			bone:ApplyForceCenter((hitPos - bone:GetPos()) * hitPos:Distance(bone:GetPos()) * bone:GetMass() * 0.7 - bone:GetVelocity() * 0.3)
		end

		ent:TakeDamage(1, self.Owner, HpwRewrite:GetWand(self.Owner))
	end)
end

HpwRewrite:AddSpell("Collapsio", Spell)