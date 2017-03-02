local Spell = { }
Spell.LearnTime = 480
Spell.ApplyFireDelay = 0.4
Spell.CanSelfCast = false
Spell.OnlyIfLearned = { "Reducto", "Expulso" }
Spell.ForceAnim = { ACT_VM_PRIMARYATTACK, ACT_VM_PRIMARYATTACK_1 }
Spell.Description = [[
	The incantation of a charm 
	used to provoke small 
	explosions; one use for this 
	explosion is to blast open 
	sealed doors or to blow bars 
	off of windows.
]]

Spell.Category = HpwRewrite.CategoryNames.DestrExp
Spell.NodeOffset = Vector(-298, 373, 0)

function Spell:OnFire(wand)
	local tr = util.TraceLine({
		start = self.Owner:GetShootPos(),
		endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * 1200,
		filter = self.Owner
	})

	local ent = tr.Entity
	local pos = tr.HitPos

	for k, v in pairs(ents.FindInSphere(pos, 50)) do
		local phys = v:GetPhysicsObject()

		if v:GetClass() == "prop_physics" then
			local r = v:GetModelRadius()
			
			if r < 100 then 
				constraint.RemoveAll(v) 

				if r > 60 then
					local ef = EffectData()
					ef:SetNormal(v:GetUp())
					ef:SetScale(r)
					ef:SetOrigin(v:GetPos())
					util.Effect("ThumperDust", ef)
				end

				if phys:IsValid() then 
					phys:EnableMotion(true) 
					phys:Wake() 
				end
			end
		end

		if phys:IsValid() then
			phys:ApplyForceCenter((v:GetPos() - pos):GetNormal() * phys:GetMass() * 40)
		end
	end

	for i = 1, 2 do sound.Play("phx/kaboom.wav", pos, 82, math.random(90, 110) + i * 8) end
	sound.Play("ambient/explosions/explode_7.wav", pos, 75, 255)

	util.ScreenShake(pos, 4, 32, 1, 160) 

	util.BlastDamage(self.Owner, self.Owner, pos, 90, 30) 
	for k, v in pairs(ents.FindInSphere(pos, 90)) do if v.Extinguish then v:Extinguish() end end -- because blastdamage ignites stuff
end

HpwRewrite:AddSpell("Bombarda", Spell)



-- Maxima

local Spell = { }
Spell.LearnTime = 960
Spell.ApplyFireDelay = 0.4
Spell.OnlyIfLearned = { "Bombarda" }
Spell.CanSelfCast = false
Spell.ForceAnim = { ACT_VM_PRIMARYATTACK, ACT_VM_PRIMARYATTACK_1, ACT_VM_PRIMARYATTACK_5 }
Spell.Description = [[
	More powerful version of
	Bombarda spell.
]]

Spell.Category = HpwRewrite.CategoryNames.DestrExp
Spell.NodeOffset = Vector(-186, 253, 0)

function Spell:OnFire(wand)
	local tr = util.TraceLine({
		start = self.Owner:GetShootPos(),
		endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * 1800,
		filter = self.Owner
	})

	local ent = tr.Entity
	local pos = tr.HitPos

	for k, v in pairs(ents.FindInSphere(pos, 100)) do
		local phys = v:GetPhysicsObject()

		if v:GetClass() == "prop_physics" then
			local r = v:GetModelRadius()

			if r < 200 then 
				constraint.RemoveAll(v) 

				if r > 60 then
					local ef = EffectData()
					ef:SetNormal(v:GetUp())
					ef:SetScale(r)
					ef:SetOrigin(v:GetPos())
					util.Effect("ThumperDust", ef)
				end

				if phys:IsValid() then 
					phys:EnableMotion(true) 
					phys:Wake() 
				end
			end
		end

		if phys:IsValid() then
			phys:ApplyForceCenter((v:GetPos() - pos):GetNormal() * phys:GetMass() * 120)
		end
	end

	for i = 1, 4 do sound.Play("phx/kaboom.wav", pos, 90, math.random(90, 110) + i * 8) end
	sound.Play("ambient/explosions/explode_7.wav", pos, 80, 255)

	util.ScreenShake(pos, 8, 32, 1, 350) 

	util.BlastDamage(self.Owner, self.Owner, pos, 300, 40)
	for k, v in pairs(ents.FindInSphere(pos, 300)) do if v.Extinguish then v:Extinguish() end end -- because blastdamage ignites stuff
end

HpwRewrite:AddSpell("Bombarda Maxima", Spell)