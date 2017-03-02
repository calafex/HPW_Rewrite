local Skin = { }

Skin.Description = [[
	CHISTI GOVNO CHISTI
	
	Some effects may not 
	work with this skin!
]]

Skin.ForceAnim = { ACT_VM_PRIMARYATTACK_1, ACT_VM_PRIMARYATTACK }

Skin.ViewModel = Model("models/hpwrewrite/c_fork.mdl")
Skin.WorldModel = Model("models/hpwrewrite/c_fork.mdl")
Skin.HoldType = "pistol"

Skin.Models = { Model("models/hpwrewrite/w_fork.mdl") }

Skin.NodeOffset = Vector(619, -402, 0)

function Skin:OnFire(wand)
	if not wand.HpwRewrite.DidAnimations then return end

	local tr = util.TraceLine({
		start = self.Owner:GetShootPos(),
		endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * 50,
		filter = self.Owner
	})

	if tr.Hit then
		if IsValid(tr.Entity) then tr.Entity:TakeDamage(1, self.Owner, wand) end
		self.Owner:EmitSound("physics/metal/metal_solid_impact_bullet1.wav", 62, math.random(220, 240))
	else
		self.Owner:EmitSound("weapons/iceaxe/iceaxe_swing1.wav", 55, math.random(150, 180), 1, CHAN_WEAPON) 
	end
end

HpwRewrite:AddSkin("Fork", Skin)