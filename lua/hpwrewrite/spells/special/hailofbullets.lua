local Spell = { }
Spell.LearnTime = 90
Spell.ApplyFireDelay = 0.16
Spell.Category = HpwRewrite.CategoryNames.Special
Spell.Description = [[
	Creates a plenty of harmful
	lead things muggles call 
	"bullets".
]]

Spell.Category = { HpwRewrite.CategoryNames.Special, HpwRewrite.CategoryNames.Fight }
Spell.ShouldSay = false
Spell.ForceAnim = { ACT_VM_PRIMARYATTACK_7 }
Spell.NodeOffset = Vector(694, -598, 0)
Spell.Diff = 0.1
Spell.CanSelfCast = false

if not game.SinglePlayer() then
	if SERVER then
		util.AddNetworkString("hpwrewrite_hailbullets_handler")
	else
		net.Receive("hpwrewrite_hailbullets_handler", function()
			local ent = net.ReadEntity()
			local wand = HpwRewrite:GetWand(ent)
			local accuracy = 0.2 
			if not HpwRewrite.CVars.NoAccuracy:GetBool() then accuracy = net.ReadFloat() end 
			local spread = math.max(accuracy * 0.1, 0.02)

			if wand:IsValid() then
				local bullet = { }
				bullet.Num = 1
				bullet.Src = wand:GetSpellSpawnPosition()
				bullet.Dir = ent:GetAimVector()
				bullet.Spread = Vector(math.Rand(-spread, spread), math.Rand(-spread - 0.01, spread + 0.01), 0)
				bullet.Tracer = 1	
				bullet.Force = 2
				bullet.Damage = math.random(4, 6)
				ent:FireBullets(bullet)
			end
		end)
	end
end

function Spell:OnFire(wand)
	self.Active = true

	self.Diff = math.Rand(0.02, 0.08)

	timer.Create("hpwrewrite_hailbullets_handler" .. self.Owner:EntIndex(), 0.35, 1, function()
		self.Active = false
	end)
end

function Spell:Think(wand)
	if CLIENT or not self.Active then return end

	if not self.Wait then self.Wait = 0 end
	if self.Wait and CurTime() > self.Wait then
		local accuracy = 0.2
		if not HpwRewrite.CVars.NoAccuracy:GetBool() then accuracy = wand.HpwRewrite.Accuracy end
		local spread = math.max(accuracy * 0.1, 0.02) 
		
		local bullet = { }
		bullet.Num = 1
		bullet.Src = wand:GetSpellSpawnPosition()
		bullet.Dir = self.Owner:GetAimVector()
		bullet.Spread = Vector(spread, spread + 0.01, 0)
		bullet.Tracer = 1	
		bullet.Force = 2
		bullet.Damage = math.random(4, 6)
		self.Owner:FireBullets(bullet)

		sound.Play("weapons/physcannon/energy_sing_flyby" .. math.random(1, 2) .. ".wav", wand:GetPos(), 70, 130)
		self.Wait = CurTime() + self.Diff

		if not game.SinglePlayer() then
			net.Start("hpwrewrite_hailbullets_handler")
				net.WriteEntity(self.Owner)
				net.WriteFloat(accuracy)
			net.Broadcast()
		end
	end
end

HpwRewrite:AddSpell("Hail of bullets", Spell)



-- Duo
local Spell = { }
Spell.Base = "Hail of bullets"
Spell.LearnTime = 330
Spell.OnlyIfLearned = { "Hail of bullets" }
Spell.ApplyFireDelay = 0.35
Spell.ForceDelay = 0.35
Spell.AutoFire = true
Spell.Description = [[
	Creates an endless storm
	of bullets from the tip
	of your wand. More powerful
	than not duo version.
]]
Spell.NodeOffset = Vector(803, -704, 0)

function Spell:OnFire(wand)
	self.BaseClass.OnFire(self, wand)
	self.Diff = math.Rand(0.02, 0.04)
end

HpwRewrite:AddSpell("Hail of bullets Duo", Spell)