if not HpwRewrite then return end

function HpwRewrite:AddSkin(name, tab)
	if not tab.Base then
		tab.ShouldSay = false
		tab.IsSkin = true

		tab.OnSelect = function() return false end
		tab.OnFire = tab.OnFire or function() return false end
	end

	self:AddSpell(name, tab)
end

function HpwRewrite:GetSkin(name)
	local skin = self:GetSpell(name)
	return (skin and skin.IsSkin) and skin or nil
end

function HpwRewrite:GetPlayerSkin(ply, name)
	local spell = self:GetPlayerSpell(ply, name)
	return (spell and spell.IsSkin) and spell or nil
end

function HpwRewrite:GetNumOfSkins()
	return self.NumOfSkins
end

-- Adding skins
HpwRewrite:IncludeFolder("hpwrewrite/skins", true)
