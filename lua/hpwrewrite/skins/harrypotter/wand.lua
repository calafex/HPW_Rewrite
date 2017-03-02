local Skin = { }

Skin.Description = [[
	Simple wand, can make
	stuff and magic.
	Makes you feel wizard.
]]

Skin.ViewModel = Model("models/hpwrewrite/c_magicwand.mdl")
Skin.WorldModel = Model("models/hpwrewrite/w_magicwand.mdl")
Skin.HoldType = "melee"

Skin.NodeOffset = Vector(473, -293, 0)

function Skin:OnFire(wand)
	-- Epic animations for fights
	local vm = wand.Owner:GetViewModel()
	if not vm then return end

	local anim = vm:GetSequence()
	if anim == 5 or anim == 4 then
		self.Owner:ViewPunch(AngleRand() * 0.006)
	end 
end

HpwRewrite:AddSkin("Wand", Skin)