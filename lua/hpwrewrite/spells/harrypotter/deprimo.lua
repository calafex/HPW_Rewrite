local Spell = { }
Spell.LearnTime = 300
Spell.Description = [[
	Creates an area of 
	strong downward pressure
	around the caster.
]]

Spell.ApplyFireDelay = 0.8
Spell.Category = { HpwRewrite.CategoryNames.DestrExp }
Spell.NodeOffset = Vector(1104, -508, 0)
Spell.SpriteColor = Color(0, 255, 0)
Spell.ForceAnim = { ACT_VM_PRIMARYATTACK_6 }
Spell.CanSelfCast = false

local radius = 50

function Spell:OnFire(wand)
	local tr = util.TraceLine({
		start = self.Owner:GetPos() + Vector(0, 0, 5),
		endpos = self.Owner:GetPos() - Vector(0, 0, 5),
		filter = self.Owner
	})

	util.Decal("HpwDeprimoCrack1", tr.HitPos - tr.HitNormal, tr.HitPos + tr.HitNormal)

	for i = 1, math.random(10, 15) do
		local ourPos = self.Owner:GetPos() + self.Owner:GetViewOffset()
		local vec = VectorRand() * radius

		local tr = util.TraceLine({
			start = ourPos,
			endpos = ourPos + vec,
			filter = self.Owner
		})

		if not tr.Hit then continue end

		--timer.Simple(math.Rand(0, 0.3), function()
			util.Decal("HpwDeprimoCrack" .. math.random(1, 5), tr.HitPos - tr.HitNormal, tr.HitPos + tr.HitNormal)
			HpwRewrite.MakeEffect("hpw_reducto_impact_stone", tr.HitPos, tr.HitNormal:Angle())
			sound.Play("physics/concrete/boulder_impact_hard" .. math.random(1, 4) .. ".wav", tr.HitPos, 75)
		--end)
	end
	
	for k, v in pairs(ents.FindInSphere(tr.HitPos, radius)) do
		local phys = v:GetPhysicsObject()

		if v:GetClass() == "prop_physics" then
			local r = v:GetModelRadius()
				
			if r < 100 then constraint.RemoveAll(v) end

			if phys:IsValid() then 
				phys:EnableMotion(true) 
				phys:Wake()
				phys:AddVelocity(Vector(0, 0, -3000))
			end
		end
	end

	HpwRewrite.BlastDamage(self.Owner, tr.HitPos, radius, math.random(10, 20))
	util.ScreenShake(tr.HitPos, 3000, 3000, 3, 3000)
end

HpwRewrite:AddSpell("Deprimo", Spell)