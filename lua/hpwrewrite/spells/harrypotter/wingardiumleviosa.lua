local Spell = { }
Spell.LearnTime = 240
Spell.Category = HpwRewrite.CategoryNames.Physics
Spell.Description = [[
	Can make something fly.
	Doesn't work on huge and
	massive objects.

	Use 'Reload' (R) and 'Use' (E) 
	keys to change object's 
	distance from you.

	Hold shift and press
	'Fire 1' (Left mouse button)
	to throw object away.
]]

Spell.OnlyIfLearned = { "Arresto Momentum" }
Spell.ForceAnim = { ACT_VM_PRIMARYATTACK_3 }
Spell.SpriteColor = Color(255, 255, 255)
Spell.CanSelfCast = false
Spell.AccuracyDecreaseVal = 0.1

Spell.NodeOffset = Vector(76, 336, 0)

function Spell:Exit()
	if IsValid(self.Prop) then
		local phys = self.Prop:GetPhysicsObject()
		if phys:IsValid() then phys:EnableGravity(true) end
	end

	self.Prop = nil
end

function Spell:OnFire(wand)
	sound.Play("hpwrewrite/spells/lumos.wav", wand:GetPos(), 65, 80)

	local ply = self.Owner

	if IsValid(self.Prop) then
		if ply:KeyDown(IN_SPEED) then
			local phys = self.Prop:GetPhysicsObject()
			local vel = ply:GetVelocity()
			phys:ApplyForceCenter((ply:GetAimVector() + vel:GetNormal()) * phys:GetMass() * math.max(380, vel:Length() * 0.75))
			phys:AddAngleVelocity(VectorRand() * 300)
		end

		self:Exit()
		return
	end

	self.Distance = 1200

	local tr = util.TraceHull({
		start = ply:GetShootPos(),
		endpos = ply:GetShootPos() + ply:GetAimVector() * self.Distance,
		filter = ply
	})
	
	local ent = tr.Entity
	
	if IsValid(ent) and IsValid(ent:GetPhysicsObject()) and not ent:IsPlayer() and not ent:IsNPC() then
		if ent:GetModelRadius() > 280 then return end
		if ent:GetPhysicsObject():GetMass() > 2000 then return end

		self.Distance = ply:GetPos():Distance(ent:GetPos())
		self.HitPos = ent:WorldToLocal(tr.HitPos)
		self.Prop = ent
		ent:GetPhysicsObject():EnableGravity(false)
	end
end

function Spell:Think()
	if CLIENT then return end
	
	local ent = self.Prop
	local ply = self.Owner

	if not self.Distance then return end
	if not self.HitPos then return end
	if not IsValid(ent) then return end
	if not ply:Alive() then self:Exit() return end

	if ply:KeyDown(IN_USE) then
		self.Distance = math.Approach(self.Distance, 3000, 15)
	end
			
	if ply:KeyDown(IN_RELOAD) then
		self.Distance = math.Approach(self.Distance, 80, -15)
	end
				
	local tr = util.TraceLine({
		start = ply:GetShootPos(),
		endpos = ply:GetShootPos() + ply:GetAimVector() * self.Distance,
		filter = { ent, ply }
	})
	
	local propPos = ent:LocalToWorld(self.HitPos)
	local phys = ent:GetPhysicsObject()
	if not IsValid(phys) then return end
	
	local dt = FrameTime() * 100
	phys:ApplyForceCenter((tr.HitPos - propPos):GetNormal() * tr.HitPos:Distance(propPos) * phys:GetMass() * 0.8 * dt)
	phys:ApplyForceCenter(-phys:GetVelocity() * phys:GetMass() * 0.2 * dt)
	phys:AddAngleVelocity(-phys:GetAngleVelocity() * 0.1 * dt)
end

function Spell:OnSelect() self:Exit() return true end
function Spell:OnWandHolster() self:Exit() end
function Spell:OnHolster() self:Exit() end

HpwRewrite:AddSpell("Wingardium Leviosa", Spell)