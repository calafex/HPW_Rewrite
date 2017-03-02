local Spell = { }
Spell.LearnTime = 420
Spell.Category = { HpwRewrite.CategoryNames.Fight, HpwRewrite.CategoryNames.Physics }
Spell.Description = [[
	Throws anything this spell
	collides with to nearest
	NPC / Player. Doesnt work on
	striders.
]]
Spell.AccuracyDecreaseVal = 0.20
Spell.FlyEffect = "hpw_reducto_main"
Spell.ApplyDelay = 0.6
Spell.ForceAnim = { ACT_VM_PRIMARYATTACK_1, ACT_VM_PRIMARYATTACK_2 }
Spell.CanSelfCast = false
Spell.SpriteColor = Color(0, 150, 255)
Spell.OnlyIfLearned = { "Wingardium Leviosa" }

Spell.NodeOffset = Vector(21, 201, 0)
Spell.LeaveParticles = true

local mat = Material("hpwrewrite/sprites/magicsprite")

function Spell:Draw(spell)
	local dlight = DynamicLight(spell:EntIndex())
	if dlight then
		dlight.pos = spell:GetPos()
		dlight.r = 0
		dlight.g = 150
		dlight.b = 255
		dlight.brightness = 3
		dlight.Decay = 1000
		dlight.Size = 128
		dlight.DieTime = CurTime() + 1
	end

	render.SetMaterial(mat)
	render.DrawSprite(spell:GetPos(), 64, 64, self.SpriteColor)
	render.DrawSprite(spell:GetPos(), 128, 50, self.SpriteColor)	
end

function Spell:OnSpellSpawned(wand, spell)
	sound.Play("ambient/wind/wind_snippet2.wav", spell:GetPos(), 75, 255)
	spell:EmitSound("ambient/wind/wind_snippet2.wav", 80, 255)
	wand:PlayCastSound()
end

function Spell:OnRemove(spell)
	if CLIENT then
		local dlight = DynamicLight(spell:EntIndex())
		if dlight then
			dlight.pos = spell:GetPos()
			dlight.r = 0
			dlight.g = 150
			dlight.b = 255
			dlight.brightness = 1
			dlight.Decay = 1100
			dlight.Size = 256
			dlight.DieTime = CurTime() + 1
		end
	end
end

function Spell:OnFire(wand)
	return true
end

function Spell:OnCollide(spell, data)
	local ent = data.HitEntity

	if not IsValid(ent) then return end
	if ent:GetPos():Distance(self.Owner:GetPos()) > 3000 then return end
	if ent:GetModelRadius() > 230 then return end

	local maxdist = 3000
	local enemy = NULL

	for k, v in pairs(ents.FindInSphere(ent:GetPos(), maxdist)) do
		if (v:IsPlayer() or (v:IsNPC() and v:GetClass() != "bullseye_strider_focus" and v:GetClass() != "npc_strider")) and v != self.Owner then
			local dist = v:GetPos():Distance(self.Owner:GetPos())
			if dist < maxdist then
				maxdist = dist
				enemy = v
			end
		end
	end

	if enemy:IsValid() then
		local phys = ent:GetPhysicsObject()
		if not phys:IsValid() then return end

		phys:SetVelocity(Vector(0, 0, 320))
		
		timer.Create("hpwrewrite_waddiwasi_helper" .. ent:EntIndex(), 0.3, 1, function()
			if enemy:IsValid() and phys:IsValid() and ent:IsValid() and ent:Visible(enemy) then
				local pos1 = enemy:LocalToWorld(enemy:OBBCenter())
				local pos2 = ent:LocalToWorld(ent:OBBCenter())
				local dist = pos1:Distance(pos2)

				if self.Owner:IsValid() then ent:SetPhysicsAttacker(self.Owner, (dist / 60 / 12 + 0.5)) end -- ???

				phys:ApplyForceCenter((pos1 - pos2):GetNormal() * phys:GetMass() * dist * 7)
			end
		end)
	end
end

HpwRewrite:AddSpell("Waddiwasi", Spell)