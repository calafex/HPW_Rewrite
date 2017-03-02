local Skin = { }

Skin.Base = "Wand"

Skin.Description = [[
	Apparently, someone thought
	that magicly enchanced
	soldering iron can be used
	as a magic wand. Geez...
]]

Skin.ViewModel = Model("models/hpwrewrite/c_egrswand.mdl")
Skin.WorldModel = Model("models/hpwrewrite/w_egrswand.mdl")

Skin.Models = { Model("models/hpwrewrite/w_egrswand.mdl") }

Skin.NodeOffset = Vector(488, -167, 0)

HpwRewrite:AddSkin("Soldering iron", Skin)