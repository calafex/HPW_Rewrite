local Spell = { }
Spell.LearnTime = 120
Spell.Description = [[
	Welds two objects.

	Usage: cast on some object,
	then cast on another object.
]]
Spell.FlyEffect = "hpw_stupefy_main"
Spell.ImpactEffect = "hpw_stupefy_impactbody"
Spell.ApplyDelay = 0.5
Spell.AccuracyDecreaseVal = 0.02
Spell.Category = { HpwRewrite.CategoryNames.Special }

Spell.ShouldSay = false
Spell.SpriteColor = Color(0, 0, 255)
Spell.NodeOffset = Vector(1470, -1038, 0)

Spell.Stage = 1
Spell.Type = 1

Spell.CheckFunction = function(self, ent) 
	if not self.AllowCreatures and (ent:IsPlayer() or ent:IsNPC()) then return false end
	return true
end

function Spell:OnSpellSpawned(wand, spell)
	wand:PlayCastSound()
end

function Spell:OnFire(wand)
	return true
end

function Spell:ToolCallback()
	constraint.Weld(self.Entity1, self.Entity2, 0, 0, 0, true, false) 
end

function Spell:AfterCollide(spell, data)
	local ent = data.HitEntity
	
	if self.Type == 1 then
		if IsValid(ent) and IsValid(ent:GetPhysicsObject()) then
			if not self:CheckFunction(ent) then return end

			if self.Stage == 1 then
				self.Entity1 = ent
				self.Pos1 = data.HitPos
			elseif self.Stage == 2 then
				self.Entity2 = ent
				self.Pos2 = data.HitPos

				if IsValid(self.Entity1) and self.Entity1 != self.Entity2 then self:ToolCallback() end
				self:Die()

				self.Stage = 0
			end

			self.Stage = self.Stage + 1
		end
	elseif self.Type == 2 then
		if IsValid(ent) and IsValid(ent:GetPhysicsObject()) then
			if not self:CheckFunction(ent) then return end

			self.Entity1 = ent
			self.Pos1 = data.HitPos

			self:ToolCallback()
			self:Die()
		end
	end
end

function Spell:Die()
	self.Entity1 = nil
	self.Entity2 = nil
	self.Pos1 = nil
	self.Pos2 = nil

	self.Stage = 1
end

function Spell:OnSelect() self:Die() return true end
function Spell:OnWandHolster() self:Die() end
function Spell:OnHolster() self:Die() end

HpwRewrite:AddSpell("Welding Charm", Spell)



-- No collide tool
local Spell = { }
Spell.Base = "Welding Charm"
Spell.Description = [[
	Makes two objects not collide
	with each other.

	Usage: cast on some object,
	then cast on another object.
]]
Spell.ShouldSay = false
Spell.NodeOffset = Vector(1545, -1180, 0)

function Spell:ToolCallback()
	constraint.NoCollide(self.Entity1, self.Entity2, 0, 0)
end

HpwRewrite:AddSpell("No Collide Charm", Spell)



