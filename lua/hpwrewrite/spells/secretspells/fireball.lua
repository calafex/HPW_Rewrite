local Spell = { }
Spell.Description = [[
	Like in every game about 
	magic.
]]
Spell.FlyEffect = "hpw_fireballspell"
Spell.ImpactEffect = "hpw_fireballimpact"
Spell.OnlyWithSkin = { "Hands" }

Spell.Category = HpwRewrite.CategoryNames.Fight
Spell.CreateEntity = false
Spell.ShouldSay = false
Spell.SecretSpell = true
Spell.DoCongrats = false
Spell.AutoFire = true
Spell.Category = HpwRewrite.CategoryNames.Special
Spell.ApplyDelay = 0.1

Spell.NodeOffset = Vector(-1076, 420, 0)

function Spell:Draw(spell)
	local dlight = DynamicLight(spell:EntIndex())
	if dlight then
		dlight.pos = spell:GetPos()
		dlight.r = 255
		dlight.g = 120
		dlight.b = 80
		dlight.brightness = 2
		dlight.Decay = 1000
		dlight.Size = 128
		dlight.DieTime = CurTime() + 0.1
	end
end

function Spell:OnFire(wand)
	wand.Owner:EmitSound("ambient/fire/mtov_flame2.wav", 70, math.random(80, 110))
	return true
end

function Spell:OnCollide(spell, data)
	local ent = data.HitEntity

	if IsValid(ent) then
		ent:Ignite(5)
		ent:TakeDamage(35, self.Owner, HpwRewrite:GetWand(self.Owner))
	end

	spell:EmitSound("ambient/fire/mtov_flame2.wav", 84, math.random(120, 160))
	util.Decal("HpwFireball", data.HitPos - data.HitNormal, data.HitPos + data.HitNormal)
end

function Spell:OnRemove(spell)
	if SERVER then return end

	local dlight = DynamicLight(spell:EntIndex())
	if dlight then
		dlight.pos = spell:GetPos()
		dlight.r = 255
		dlight.g = 160
		dlight.b = 80
		dlight.brightness = 0.4
		dlight.Decay = 10
		dlight.Size = 64
		dlight.DieTime = CurTime() + 5
	end
end

HpwRewrite:AddSpell("Fireball", Spell)