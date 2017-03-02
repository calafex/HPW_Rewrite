local Spell = { }
Spell.LearnTime = 480
Spell.ApplyFireDelay = 0.4
Spell.Category = HpwRewrite.CategoryNames.Physics
Spell.Description = [[
	Causes the victim to be 
	hoisted into the air by 
	their ankle.
]]

Spell.ForceAnim = { ACT_VM_PRIMARYATTACK_1, ACT_VM_PRIMARYATTACK_2 }
Spell.SpriteColor = Color(150, 255, 150)
Spell.OnlyIfLearned = { "Wingardium Leviosa" }
Spell.CanSelfCast = false
Spell.NodeOffset = Vector(184, 239, 0)
Spell.AccuracyDecreaseVal = 0.4

function Spell:GetAnimations()
	if IsValid(self.Victim) then return ACT_VM_PRIMARYATTACK_3 end
end

function Spell:Empty()
	if IsValid(self.Victim) then 
		sound.Play("ambient/machines/thumper_dust.wav", self.Victim:GetPos(), 70, 120)

		if self.Function and self.FName then
			HpwRewrite.Throwing_TimerReviveFunc(self.Victim, self.FName, "hpwrewrite_levicorpus_handler" .. self.Victim:EntIndex(), 2, self.Function)
		else
			self.Victim:Remove()
		end
	end

	self.Victim = nil
	self.Function = nil
	self.FName = nil
end

function Spell:OnFire(wand)
	if wand:GetWandCurrentSpell() != self.Name then return end

	if IsValid(self.Victim) then 
		self:Empty()
		return
	end

	local ent = wand:HPWGetAimEntity(400)

	if IsValid(ent) and (ent:IsPlayer() or ent:IsNPC()) then
		if ent:GetModelRadius() > 280 then return end
		if ent:GetPhysicsObject():GetMass() > 2000 then return end

		local rag, func, name = HpwRewrite:ThrowEntity(ent, nil, 0, 15, self.Owner)

		if IsValid(rag) then 
			local pos = rag:GetPos()

			self.Victim = rag
			self.Function = func 
			self.FName = name
			self.Distance = self.Owner:GetPos():Distance(pos)

			sound.Play("ambient/atmosphere/city_skypass1.wav", pos, 70, math.random(220, 255))
			timer.Simple(0.2, function()
				sound.Play("ambient/machines/floodgate_stop1.wav", pos, 75, math.random(140, 150))
			end)
		end
	end
end

function Spell:Think()
	if CLIENT then return end
	
	local ent = self.Victim
	local ply = self.Owner

	if not IsValid(ent) then self:Empty() return end
	if not ply:Alive() then self:Empty() return end
	if not self.Distance then self:Empty() return end
	if ent:GetPos():Distance(ply:GetPos()) > 500 then self:Empty() return end
	
	local ang = ply:EyeAngles()
	ang.p = ang.p * 0.6

	local tr = util.TraceLine({
		start = ply:GetShootPos(),
		endpos = ply:GetShootPos() + ang:Forward() * self.Distance,
		filter = { ent, ply }
	})
	
	tr.HitPos = tr.HitPos + vector_up * 30

	local phys = ent:GetPhysicsObject()
	local phys1, phys2 = ent:GetPhysicsObjectNum(12), ent:GetPhysicsObjectNum(14)
	
	if IsValid(phys1) and IsValid(phys2) then
		phys1:ApplyForceCenter((tr.HitPos - phys1:GetPos()):GetNormal() * tr.HitPos:Distance(phys1:GetPos()) * phys:GetMass())
		phys2:ApplyForceCenter((tr.HitPos - phys2:GetPos()):GetNormal() * tr.HitPos:Distance(phys2:GetPos()) * phys:GetMass())
	elseif IsValid(phys) then
		phys:ApplyForceCenter((tr.HitPos - phys:GetPos()):GetNormal() * tr.HitPos:Distance(phys:GetPos()) * phys:GetMass() * 2)
	end

	phys:ApplyForceCenter(-phys:GetVelocity() * phys:GetMass() * 0.4)
	phys:AddAngleVelocity(-phys:GetAngleVelocity() * 0.4)
end

function Spell:OnSelect() self:Empty() return true end
function Spell:OnWandHolster() self:Empty() end
function Spell:OnHolster() self:Empty() end

HpwRewrite:AddSpell("Levicorpus", Spell)