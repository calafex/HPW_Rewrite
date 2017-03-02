local Skin = { }

Skin.LearnTime = 240
Skin.ShouldLearn = true

Skin.Description = [[
	Powerful magic hands.
	You can cast fireballs
	like 30 years old virgin.
]]

Skin.ForceAnim = { ACT_VM_PRIMARYATTACK_1, ACT_VM_PRIMARYATTACK }

Skin.ViewModel = Model("models/hpwrewrite/c_hands.mdl")
Skin.WorldModel = Model("models/hpwrewrite/c_hands.mdl")
Skin.HoldType = "knife"

Skin.Models = { Model("models/hpwrewrite/books/book2.mdl") }

Skin.NodeOffset = Vector(621, -289, 0)

function Skin:OnPostLearn(ply)
	if SERVER then HpwRewrite:SaveAndGiveSpell(ply, "Fireball") end
end

function Skin:OnFire(wand)
	if not wand.HpwRewrite.DidAnimations then return end
	self.Owner:ViewPunch(AngleRand() * 0.01)
end

function Skin:GetSpellPosition(wand, oldpos)
	local vm = self.Owner:GetViewModel()
	if not vm then return oldpos end

	local anim = vm:GetSequence()
	if anim == 2 then
		local ang = self.Owner:EyeAngles()
		return self.Owner:EyePos() + ang:Right() * 5 + ang:Forward() * 15
	elseif anim == 3 then
		local ang = self.Owner:EyeAngles()
		return self.Owner:EyePos() - ang:Right() * 5 - ang:Up() * 2 + ang:Forward() * 15
	end 

	return oldpos
end

HpwRewrite:AddSkin("Hands", Skin)