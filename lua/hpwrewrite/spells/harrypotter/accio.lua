local Spell = { }
Spell.LearnTime = 30
Spell.Category = HpwRewrite.CategoryNames.Physics
Spell.Description = [[
	Brings anything to you.
]]

Spell.ForceAnim = { ACT_VM_PRIMARYATTACK_3 }
Spell.CanSelfCast = false
Spell.NodeOffset = Vector(140, 610, 0)

function Spell:OnFire(wand)
	sound.Play("ambient/wind/wind_hit" .. math.random(1, 2) .. ".wav", wand:GetPos(), 65, math.random(180, 255))

	self.Prop = nil

	local ent = wand:HPWGetAimEntity(2500, Vector(-6, -6, -4), Vector(6, 6, 4))
	
	if IsValid(ent) and IsValid(ent:GetPhysicsObject()) and not ent:IsPlayer() and not ent:IsNPC() then
		if ent:GetModelRadius() > 280 then return end

		local phys = ent:GetPhysicsObject()
		if phys:GetMass() > 2000 then return end
		phys:ApplyForceCenter(vector_up * phys:GetMass() * 300)

		sound.Play("ambient/wind/wind_snippet2.wav", ent:GetPos(), 75, 255)

		self.Prop = ent

		local dist = ent:GetPos():Distance(self.Owner:GetPos()) * FrameTime()
		local time = math.Clamp(dist, 0.1, 1)
		timer.Create("hpwrewrite_accio_removeprop" .. self.Owner:EntIndex(), time, 1, function()
			self.Prop = nil
		end)
	end
end

function Spell:Think()
	if CLIENT then return end
	
	local ent = self.Prop
	local ply = self.Owner

	if not IsValid(ent) then return end

	local phys = ent:GetPhysicsObject()
	if not IsValid(phys) then return end
	
	phys:ApplyForceCenter((ply:GetPos() - ent:GetPos()):GetNormal() * ent:GetPos():Distance(ply:GetPos()) * phys:GetMass() * 0.08)
	phys:ApplyForceCenter(-phys:GetVelocity() * phys:GetMass() * 0.04)
	phys:AddAngleVelocity(VectorRand() * phys:GetMass() * 0.1)
end

function Spell:OnSelect() self.Prop = nil return true end
function Spell:OnWandHolster() self.Prop = nil end
function Spell:OnHolster() self.Prop = nil end

HpwRewrite:AddSpell("Accio", Spell)