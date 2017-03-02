local Skin = { }

Skin.Base = "Wand"

Skin.Description = [[
	Made of anger and rage.
	This wand looks weird
	and suspicious.
]]

Skin.ViewModel = Model("models/hpwrewrite/c_demonicwand.mdl")
Skin.WorldModel = Model("models/hpwrewrite/w_demonicwand.mdl")

Skin.NodeOffset = Vector(757, -298, 0)

HpwRewrite:AddSkin("Demonic Wand", Skin)