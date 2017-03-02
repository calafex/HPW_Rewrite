local Spell = { }
Spell.LearnTime = 60
Spell.Description = [[
	Light. Click one more time
	to cast Nox.
]]

Spell.Category = HpwRewrite.CategoryNames.Lighting
Spell.PlayAnimation = false
Spell.ForceDelay = 0.5
Spell.CanSelfCast = false

local lumos = Color(200, 200, 255)

Spell.SpriteColor = lumos

Spell.AccuracyDecreaseVal = 0
Spell.NodeOffset = Vector(-187, 117, 0)

function Spell:ToggleOn(wand)
	wand:RequestSprite(self.Name, self.SpriteColor, 0, 0.6, true)
end

function Spell:ToggleOff(wand)
	wand:RequestSprite(self.Name, self.SpriteColor, 700, 0.6, true)
end

function Spell:OnFire(wand)
	self.Toggled = not self.Toggled

	if self.Toggled then
		self.WhatToSay = "Lumos"
		self:ToggleOn(wand)
	else
		self.WhatToSay = "Nox"
		self:ToggleOff(wand)
	end

	sound.Play("hpwrewrite/spells/lumos.wav", wand:GetPos(), 65)

	return false
end

function Spell:OnSelect(wand)
	if self.Toggled then self:ToggleOn(wand) end
	return true
end

function Spell:OnSpellGiven(ply)
	if SERVER then self.Toggled = false end
	return true
end

function Spell:OnSpellRemoved(ply)
	if SERVER then
		local wand = HpwRewrite:GetWand(ply)
		if wand:IsValid() then if self.Toggled then self:ToggleOff(wand) end end
	end
end

HpwRewrite:AddSpell("Lumos", Spell)


-- Lumos maxima

local lumosmaxima = Color(255, 255, 220)

if SERVER then
	util.AddNetworkString("hpwrewrite_DoLight")
else
	net.Receive("hpwrewrite_DoLight", function()
		local pos = net.ReadVector()
		local id = net.ReadUInt(16)

		local dlight = DynamicLight(id)
		if dlight then
			dlight.pos = pos
			dlight.r = lumosmaxima.r
			dlight.g = lumosmaxima.g
			dlight.b = lumosmaxima.b
			dlight.brightness = 5
			dlight.Decay = 600
			dlight.Size = 250
			dlight.DieTime = CurTime() + 6
		end
	end)
end

local Spell = { }
Spell.LearnTime = 180
Spell.Description = [[
	Yellow light flash. Cast three 
	times to bring super light.
]]
Spell.Category = HpwRewrite.CategoryNames.Lighting
Spell.OnlyIfLearned = { "Lumos" }
Spell.AccuracyDecreaseVal = 0
Spell.CanSelfCast = false

Spell.NodeOffset = Vector(-267, -6, 0)

function Spell:SpellThink(spell)
	if SERVER then return end

	local dlight = DynamicLight(spell:EntIndex())
	if dlight then
		dlight.pos = spell:GetPos()
		dlight.r = lumosmaxima.r
		dlight.g = lumosmaxima.g
		dlight.b = lumosmaxima.b
		dlight.brightness = 5
		dlight.Decay = 600
		dlight.Size = 900
		dlight.DieTime = CurTime() + 6
	end
end

function Spell:OnSpellSpawned(wand, spell)
	SafeRemoveEntityDelayed(spell, 4)
end

function Spell:PhysicsThink()
	return nil, VectorRand() * 99999999, true
end

function Spell:OnCollide() 
	return true 
end

function Spell:OnHolster(wand)
	self.LightCount = -1
end

function Spell:OnFire(wand)
	if not self.LightCount then self.LightCount = -1 end
	self.LightCount = self.LightCount + 1

	if self.LightCount > 2 then 
		self.LightCount = 0
	end

	local pos = self.Owner:LocalToWorld(self.Owner:OBBCenter())

	net.Start("hpwrewrite_DoLight")
		net.WriteVector(pos)
		net.WriteUInt(self.Owner:EntIndex(), 16)
	net.Broadcast()

	wand:RequestSprite(self.Name, lumosmaxima, 400, 1 + self.LightCount * 2, true)

	for i = 1, 4 + (self.LightCount * 2) do
		sound.Play("hpwrewrite/spells/lumos.wav", wand:GetPos(), 75, math.random(90, 110) - (self.LightCount * 20 * math.random(-1, 1)))
	end

	timer.Create("hpwrewrite_lumoxmaxima_set" .. wand.Owner:EntIndex(), wand:HPWSeqDuration2() + 0.3, 1, function()
		self.LightCount = -1
		self.ForceAnim = nil
	end)

	if (self.LightCount + 1) == 2 then self.ForceAnim = { ACT_VM_PRIMARYATTACK_2 } else self.ForceAnim = nil end
	if (self.LightCount + 1) == 3 then return true end

	return false
end

HpwRewrite:AddSpell("Lumos Maxima", Spell)


-- Lumos solem

local Spell = { }
Spell.LearnTime = 360
Spell.Category = HpwRewrite.CategoryNames.Lighting
Spell.OnlyIfLearned = { "Lumos Maxima" }
Spell.ForceAnim = { ACT_VM_PRIMARYATTACK_1 }
Spell.SpriteSize = 5
Spell.SpriteTime = 200
Spell.SpriteColor = lumos
Spell.CanSelfCast = false
Spell.AccuracyDecreaseVal = 0
Spell.Description = [[
	Makes very bright light
	that can blind anyone who's
	looking on it
]]

Spell.NodeOffset = Vector(-314, -169, 0)

local mat = Material("hpwrewrite/sprites/magicsprite")
function Spell:Draw(spell)
	render.SetMaterial(mat)

	local size = 1024 + math.sin(CurTime() * 10) * 512
	render.DrawSprite(spell:GetPos(), size, size, lumos)
	render.DrawSprite(spell:GetPos(), size * 2, size, lumos)
end

function Spell:SpellThink(spell)
	if SERVER then return end

	local dlight = DynamicLight(spell:EntIndex())
	if dlight then
		dlight.pos = spell:GetPos()
		dlight.r = lumos.r
		dlight.g = lumos.g
		dlight.b = lumos.b
		dlight.brightness = 3
		dlight.Decay = 4000
		dlight.Size = 2000 + math.sin(CurTime() * 5) * 500
		dlight.DieTime = CurTime() + 0.7
	end

	if not spell.Emitter then
		spell.Emitter = ParticleEmitter(spell:GetPos()) 
		return
	end

	for i = 1, 4 do
		local p = spell.Emitter:Add("hpwrewrite/sprites/magicsprite", spell:GetPos() + spell:GetFlyDirection() * math.random(-32, 32))
		p:SetDieTime(math.Rand(0.7, 2.6))
		p:SetBounce(0.8)
		p:SetCollide(true)
		p:SetVelocity(VectorRand() * (600 + math.tan(CurTime() * 3) * 500) + spell:GetFlyDirection() * 1200)
		p:SetGravity(Vector(0, 0, -400))
		p:SetAirResistance(math.random(15, 40))
		p:SetStartSize(math.random(32, 64))
		p:SetEndSize(0)
		p:SetStartAlpha(255)
		p:SetEndAlpha(0)
		p:SetRoll(math.Rand(-10, 10))
		p:SetRollDelta(math.Rand(-10, 10))
		p:SetColor(lumos.r, lumos.g, lumos.b)
	end
end

function Spell:OnDataReceived(spell)
	local a = 0
	local b = 0

	hook.Add("RenderScreenspaceEffects", "hpwrewrite_lumossolemblind" .. spell:EntIndex(), function()
		if not IsValid(spell) then return end

		if (spell:GetPos() - EyePos()):GetNormal():Dot(EyeAngles():Forward()) > 0.2 and EyePos():Distance(spell:GetPos()) < 1000 then
			a = math.Approach(a, 1, 0.15)
		else
			a = math.Approach(a, 0, 0.05)
		end

		b = math.Approach(b, 1, 0.006)

		local eff_tab = {
			["$pp_colour_addr"] = 0,
			["$pp_colour_addg"] = 0,
			["$pp_colour_addb"] = 0,
			["$pp_colour_brightness"] = math.Clamp(a - b, 0, 1), 
			["$pp_colour_contrast"] = 1,
			["$pp_colour_colour"] = 1,
			["$pp_colour_mulr"] = 0,
			["$pp_colour_mulg"] = 0,
			["$pp_colour_mulb"] = 0
		}
				
		DrawColorModify(eff_tab)
	end)
end

function Spell:OnRemove(spell)
	if CLIENT then
		if spell.Emitter then
			spell.Emitter:Finish()
		end

		hook.Remove("RenderScreenspaceEffects", "hpwrewrite_lumossolemblind" .. spell:EntIndex())
	end
end

function Spell:OnSpellSpawned(wand, spell)
	SafeRemoveEntityDelayed(spell, 3)
end

local beam = Material("sprites/physbeama")
function Spell:DrawMagicSprite(wand, vm, sprite)
	if not sprite then return end
	local m = vm:GetBoneMatrix(sprite)
	if not m then return end
	local pos

	render.SetMaterial(beam)
	local val = wand.HpwRewrite.SpriteColor.a / 255
	local col = Color(HpwRewrite.Colors.Blue.r, HpwRewrite.Colors.Blue.g, HpwRewrite.Colors.Blue.b, wand.HpwRewrite.SpriteColor.a)
	
	for a = 1, 5 do
		render.StartBeam(4)
		pos = m:GetTranslation()
		for i = 1, 4 do 
			render.AddBeam(pos, 5 - i, math.Rand(0, 1), col) 
			pos = pos + VectorRand() * val * 6
		end
		render.EndBeam()
	end
end

function Spell:OnCollide(spell) 
	spell:SetFlyDirection(Vector(0, 0, 0))
	spell:GetPhysicsObject():SetVelocity(Vector(0, 0, 0))

	return true 
end

function Spell:OnFire(wand)
	for i = 1, 4 do sound.Play("hpwrewrite/spells/lumos.wav", wand:GetPos(), 70) end
	return true
end

HpwRewrite:AddSpell("Lumos Solem", Spell)