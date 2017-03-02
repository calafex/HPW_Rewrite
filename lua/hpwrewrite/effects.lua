if not HpwRewrite then return end

if true then return end

HpwRewrite.Effects = HpwRewrite.Effects or { }

local base = {
	SetupThink = function(self)
		if not self.Think then return end

		hook.Add("Think", self.UniqueName, function()
			self:Think()
		end)
	end,

	RemoveThink = function(self)
		hook.Remove("Think", self.UniqueName)
	end,

	SetupTimer = function(self)
		if timer.Exists(self.UniqueName) then return end

		timer.Create(self.UniqueName, self.Delay, 1, function()
			self:OnEffectGone()
			self:RemoveThink()
		end)
	end
}

local effects = { }
function HpwRewrite.Effects:GetEffects()
	return effects
end

function HpwRewrite.Effects:GetEffect(name)
	return effects[name]
end

function HpwRewrite.Effects:LookupID(id)
	for k, v in pairs(self:GetEffects()) do
		if v.UniqueID == id then return v end
	end
end

local val = 2^32

function HpwRewrite.Effects:AddEffect(name, tab)
	tab.Name = name
	tab.UniqueID = table.Count(self:GetEffects()) + 1
	tab.__index = tab

	for k, v in pairs(base) do
		tab[k] = v
	end

	function tab:__tostring()
		return self.Name
	end

	function tab.New(owner)
		local new = setmetatable({ }, tab)
		new.Owner = owner
		new.UniqueName = "hpwrewrite_effect_" .. self.Name .. (IsValid(owner) and self.Owner:EntIndex() or math.random(1, val))
		return new
	end

	self:GetEffects()[name] = tab.New()
end

if CLIENT then
	local buffer = { }

	hook.Add("HUDPaint", "hpwrewrite_effectsdraw", function()
		
	end)

	net.Receive("hpwrewrite_effect", function()
		local id = net.ReadUInt(7)
		local ef = HpwRewrite.Effects:LookupID(id)
		if not ef then return end
	end)
else
	util.AddNetworkString("hpwrewrite_effect")

	function HpwRewrite.Effects:SaveValue(ply, id, value, callback)
		if not ply.HpwRewrite.SavedValues then ply.HpwRewrite.SavedValues = { } end

		if ply.HpwRewrite.SavedValues[id] then 
			table.insert(ply.HpwRewrite.SavedValues[id].callbacks, callback)
			return 
		end

		ply.HpwRewrite.SavedValues[id] = {
			callbacks = { [1] = callback },
			value = value
		}
	end

	function HpwRewrite.Effects:GetSavedValue(ply, id)
		if not ply.HpwRewrite.SavedValues then ply.HpwRewrite.SavedValues = { } end

		local tab = ply.HpwRewrite.SavedValues[id]
		if not tab then return end

		return tab.value
	end

	function HpwRewrite.Effects:WipeValue(ply, id)
		if not ply.HpwRewrite.SavedValues then ply.HpwRewrite.SavedValues = { } end

		local tab = ply.HpwRewrite.SavedValues[id]
		if not tab then return end

		
	end

	function HpwRewrite.Effects:SetEffect(ply, name)
		local ef = self:GetEffect(name)
		if not ef then return end

		ef = ef.New(ply)
		ef:Initialize()
		ef:SetupThink()
		ef:SetupTimer()

		net.Start("hpwrewrite_effect")
			net.WriteUInt(tab.UniqueID, 7)
		net.Send(ply)
	end
end