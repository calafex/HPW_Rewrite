local Spell = { }
Spell.LearnTime = 450
Spell.Category = HpwRewrite.CategoryNames.Physics
Spell.Description = [[
	Pulling spell. Creates 
	magical rope that can pull 
	objects to you or pull you 
	to the point you're looking at.

	To pull yourself hold
	self-cast key.

	Maximum distance is 2000
	units.
]]

Spell.DoSelfCastAnim = false
Spell.ApplyFireDelay = 0.8
Spell.ForceAnim = { ACT_VM_PRIMARYATTACK_6 }
Spell.NodeOffset = Vector(-661, -973, 0)

Spell.SpriteColor = Color(255, 0, 255)
Spell.DoSparks = true
Spell.SparksLifeTime = 1.5

function Spell:PreFire()
	return not IsValid(self.PullEntity)
end

function Spell:OnFire(wand)
	if wand:GetWandCurrentSpell() != self.Name then return end

	local ent, tr = wand:HPWGetAimEntity(2000, Vector(-5, -5, -2), Vector(5, 5, 2))
	if not tr.Hit then return end
	if not IsValid(ent) then return end
	
	if ent != self.Owner and not ent:GetPhysicsObject():IsMotionEnabled() then return end

	sound.Play("hpwrewrite/wand/spellcast01.wav", wand:GetPos(), 70)
	sound.Play("hpwrewrite/magicchimes01.wav", wand:GetPos(), 65, math.random(100, 120))
	SafeRemoveEntity(self.Rope)

	self.PullEntity = ent
	self.Position = tr.HitPos
	self.Speed = 500

	local rope = ents.Create("info_hpwand_magicalrope")
	rope:SetPos(tr.HitPos)
	
	if IsValid(self.PullEntity) and self.PullEntity != self.Owner then
		rope:SetParent(self.PullEntity)
	end

	rope:SetPlayer(self.Owner)
	rope:Spawn()

	self.Rope = rope
end

function Spell:Exit()
	SafeRemoveEntity(self.Rope)
	self.PullEntity = nil
end

function Spell:Think(wand)
	if CLIENT then return end
	if not IsValid(self.PullEntity) then return end

	if math.random(0, 5) == 0 then
		sound.Play("hpwrewrite/magicchimes03.wav", wand:GetPos(), 65, math.random(90, 110))
	end

	local ourPos = self.Owner:GetPos()
	self.Speed = math.Approach(self.Speed, 3000, FrameTime() * 400)

	wand:HPWDoSprite(self)
	wand:HPWSendAnimation(ACT_VM_PRIMARYATTACK_7)

	if self.PullEntity == self.Owner then
		local dist = ourPos:Distance(self.Position)
		if dist >= 2000 then self:Exit() return end

		if dist <= 100 then 
			self.Owner:SetVelocity(-self.Owner:GetVelocity() * 0.65)
			self:Exit()
			return 
		end

		local dir = (self.Position - ourPos):GetNormal()


		self.Owner:SetVelocity(-self.Owner:GetVelocity() * 0.3 + dir * self.Speed)
	else
		local phys = self.PullEntity
		if not (phys:IsNPC() or phys:IsPlayer()) then phys = phys:GetPhysicsObject() end

		local dist = ourPos:Distance(phys:GetPos())
		if dist >= 4000 then self:Exit() return end

		if dist <= math.max(120, self.PullEntity:GetModelRadius() * 1.4) then 
			phys:SetVelocity(vector_origin)
			self:Exit()
			return 
		end

		local dir = (ourPos - phys:GetPos()):GetNormal()
		phys:SetVelocity(-phys:GetVelocity() * 0.3 + dir * self.Speed)
	end
end

function Spell:OnWandHolster() self:Exit() end
function Spell:OnHolster() self:Exit() end

HpwRewrite:AddSpell("Carpe Retractum", Spell)