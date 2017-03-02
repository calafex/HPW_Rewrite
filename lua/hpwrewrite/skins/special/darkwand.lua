local Skin = { }

Skin.Base = "Wand"

Skin.Description = [[
	This wand was made for
	true dark wizards.
	Made of wood from dark
	forest it really fits
	with you
]]

Skin.ViewModel = Model("models/hpwrewrite/c_darkwand.mdl")
Skin.WorldModel = Model("models/hpwrewrite/w_darkwand.mdl")

Skin.NodeOffset = Vector(754, -160, 0)

function Skin:AdjustSpritePosition(vm, m)
	return (m:GetAngles() + Angle(10, 0, 0)):Up() * 0.9
end

HpwRewrite:AddSkin("Dark Wand", Skin)