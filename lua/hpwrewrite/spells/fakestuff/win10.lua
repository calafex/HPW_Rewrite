local Spell = { }
Spell.Description = [[
	Install Windows 10
	on someones computer!
]]
Spell.FlyEffect = "hpw_wineff"
Spell.ApplyDelay = 0.6

Spell.CreateEntity = false
Spell.ShouldSay = false
Spell.SecretSpell = true
Spell.DoCongrats = false
Spell.Category = HpwRewrite.CategoryNames.Special

Spell.NodeOffset = Vector(-845, -556, 0)

function Spell:OnFire(wand)
	if self.Installed then 
		wand:EmitSound("buttons/combine_button" .. math.random(1, 3) .. ".wav")
	else
		wand:EmitSound("garrysmod/balloon_pop_cute.wav")
	end

	return not self.Installed
end

function Spell:OnCollide(spell, data)
	if self.Installed then return end

	local ent = data.HitEntity

	if IsValid(ent) and ent:IsPlayer() then
		net.Start("hpwrewrite_Win10")
		net.Send(ent)
	end

	spell:EmitSound("garrysmod/save_load4.wav")
	self.Installed = true

	timer.Create("hpwrewrite_waitspellwin10" .. spell:EntIndex(), math.random(6, 10), 1, function()
		self.Installed = false
	end)
end

HpwRewrite:AddSpell("Windows 10", Spell)