local data = { }

local function ResizeEnt(ent, bigger)
	if not IsValid(ent) then return end
	
	local scale = 1
	if bigger then scale = 1.1 else scale = 0.9 end

	if ent:GetClass() == "prop_physics" then
		local phys = ent:GetPhysicsObject()
		if not IsValid(phys) then return end

		local mesh = phys:GetMeshConvexes()
		if #mesh < 1 then return end

		phys:ApplyForceCenter(vector_up * phys:GetMass() * 120)
		phys:AddAngleVelocity(VectorRand() * 200)

		timer.Simple(0.2, function()
			if not IsValid(ent) or not IsValid(phys) then return end

			if not data[ent] then data[ent] = 1 end
			if data[ent] > 2 then scale = 0.9 end
			if data[ent] < 0.5 then scale = 1.1 end

			data[ent] = data[ent] * scale

			for k, v in pairs(mesh) do for a, b in pairs(v) do v[a] = b.pos * scale end end

			local vel = phys:GetVelocity()
			local aVel = phys:GetAngleVelocity()
			local mass = phys:GetMass()

			ent:PhysicsInitMultiConvex(mesh)
			ent:EnableCustomCollisions(true)

			local newPhys = ent:GetPhysicsObject()
			if not IsValid(newPhys) then ent:Remove() return end

			newPhys:Wake()
			newPhys:SetVelocity(vel)
			newPhys:AddAngleVelocity(aVel)
			newPhys:SetMass(mass * scale)

			local mins, maxs = ent:GetCollisionBounds()
			ent:SetCollisionBounds(mins * scale, maxs * scale)
			ent:SetModelScale(ent:GetModelScale() * scale, 0.2)
		end)
	elseif ent:IsPlayer() then
		if not data[ent] then data[ent] = 1 end
		if data[ent] > 2 then scale = 0.9 end
		if data[ent] < 0.5 then scale = 1.1 end

		data[ent] = data[ent] * scale
		
		if data[ent] >= 0.75 and data[ent] <= 0.75 then -- Saves actual size
			ent:SetViewOffset(Vector(0, 0, 64))
			ent:SetViewOffsetDucked(Vector(0, 0, 28))
			ent:SetStepSize(18)
			ent:SetModelScale(1, 0.2)
			ent:ResetHull()
		else
			ent:SetViewOffset(ent:GetViewOffset() * scale)
			ent:SetViewOffsetDucked(ent:GetViewOffsetDucked() * scale)
			ent:SetStepSize(ent:GetStepSize() * scale)
			ent:SetModelScale(ent:GetModelScale() * scale, 0.2)
			ent:SetHull(Vector(-16, -16, 0) * scale, Vector(16, 16, 72) * scale)
			ent:SetHullDuck(Vector(-16, -16, 0) * scale, Vector(16, 16, 36) * scale)
		end
	elseif ent:IsNPC() then
		if not data[ent] then data[ent] = 1 end
		if data[ent] > 2 then scale = 0.9 end
		if data[ent] < 0.5 then scale = 1.1 end

		data[ent] = data[ent] * scale

		ent:SetModelScale(ent:GetModelScale() * scale, 0.2)
	end
end




-- Engorgio
local Spell = { }
Spell.LearnTime = 240
Spell.ApplyFireDelay = 0.4
Spell.Description = [[
	Increases the size of your 
	target.
]]

Spell.SpriteColor = Color(120, 220, 255)
Spell.NodeOffset = Vector(-1565, -316, 0)

function Spell:OnFire(wand)
	ResizeEnt(wand:HPWGetAimEntity(400), true)
end

HpwRewrite:AddSpell("Engorgio", Spell)



-- Reducio
local Spell = { }
Spell.LearnTime = 240
Spell.ApplyFireDelay = 0.4
Spell.Description = [[
	Reduces the size of your
	target.
]]

Spell.OnlyIfLearned = { "Engorgio" }
Spell.SpriteColor = Color(220, 120, 255)
Spell.NodeOffset = Vector(-1684, -466, 0)

function Spell:OnFire(wand)
	ResizeEnt(wand:HPWGetAimEntity(400), false)
end

HpwRewrite:AddSpell("Reducio", Spell)



-- Engorgio Skullus
local Spell = { }
Spell.LearnTime = 120
Spell.ApplyFireDelay = 0.4
Spell.Description = [[
	Increases the size of your
	target's skull.
]]

Spell.OnlyIfLearned = { "Engorgio" }
Spell.SpriteColor = Color(0, 255, 0)
Spell.NodeOffset = Vector(-1501, -536, 0)

function Spell:OnFire(wand)
	local ent = wand:HPWGetAimEntity(400)

	if IsValid(ent) and (ent:IsPlayer() or ent:IsNPC()) then
		local bone = ent:LookupBone("ValveBiped.Bip01_Head1")

		if bone then
			local scale = 1
			local name = "hpwrewrite_engorgioskullus_handler" .. ent:EntIndex()

			timer.Create(name, 0.1, 5, function()
				if IsValid(ent) then
					scale = scale + 0.2
					ent:ManipulateBoneScale(bone, Vector(scale, scale, scale))

					if scale >= 1.9 then -- wtf (scale >= 2) == false
						timer.Simple(5, function()
							timer.Create(name, 0.1, 5, function()
								if IsValid(ent) then
									scale = scale - 0.2
									ent:ManipulateBoneScale(bone, Vector(scale, scale, scale))
								end
							end)
						end)
					end
				end
			end)
		end
	end
end

HpwRewrite:AddSpell("Engorgio Skullus", Spell)