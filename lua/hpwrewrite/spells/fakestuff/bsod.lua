local Spell = { }
Spell.Description = [[
	Crash someones
	Windows! (Fake BSOD)
]]
Spell.FlyEffect = "hpw_bsodeff"
Spell.ApplyDelay = 0.35

Spell.CreateEntity = false
Spell.ShouldSay = false
Spell.SecretSpell = true
Spell.DoCongrats = false
Spell.Category = HpwRewrite.CategoryNames.Special

Spell.NodeOffset = Vector(-716, -649, 0)

function Spell:OnFire(wand)
	if self.Installed then
		wand:EmitSound("hpwrewrite/winerror2.wav")
	else
		wand:EmitSound("hpwrewrite/winerror1.wav")
	end

	return not self.Installed
end

function Spell:OnCollide(spell, data)
	if self.Installed then return end

	local ent = data.HitEntity

	if IsValid(ent) and ent:IsPlayer() then
		net.Start("hpwrewrite_BSODFAKESTART")
		net.Send(ent)
	end

	spell:EmitSound("garrysmod/save_load4.wav")
	self.Installed = true

	timer.Create("hpwrewrite_waitspellbsod" .. spell:EntIndex(), math.random(2, 3), 1, function()
		self.Installed = false
	end)
end

HpwRewrite:AddSpell("BSOD", Spell)