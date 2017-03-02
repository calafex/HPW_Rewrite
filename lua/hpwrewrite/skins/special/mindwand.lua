local Skin = { }

Skin.Base = "Wand"

Skin.Description = [[
	This wand was made for
	true light wizards.
]]

Skin.ViewModel = Model("models/hpwrewrite/c_mindwand.mdl")
Skin.WorldModel = Model("models/hpwrewrite/w_mindwand.mdl")

Skin.NodeOffset = Vector(624, -190, 0)

HpwRewrite:AddSkin("Mind Wand", Skin)