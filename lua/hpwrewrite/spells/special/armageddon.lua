local Spell = { }
Spell.LearnTime = 10800
Spell.ApplyFireDelay = 0.9
Spell.Category = { HpwRewrite.CategoryNames.Special, HpwRewrite.CategoryNames.Unforgivable }

Spell.Description = [[
	Destroys the world.

	This spell can crash your
	game, so it's recommended
	to block this spell on servers!

	Can be casted only once in the 
	whole world. 
]]

Spell.OnlyIfLearned = { "Maf" }

Spell.ForceAnim = { ACT_VM_PRIMARYATTACK_6 }
Spell.NodeOffset = Vector(664, -1519, 0)
Spell.SpriteColor = Color(255, 155, 155)
Spell.AccuracyDecreaseVal = 1
Spell.DoSparks = true
Spell.SpriteTime = 900
Spell.SparksLifeTime = 1
Spell.Unforgivable = true

local called = false

local math = math
local util = util
local timer = timer
local HpwRewrite = HpwRewrite
local sound = sound

local rand = math.Rand
local random = math.random

local trace = util.TraceLine
local ScreenShake = util.ScreenShake
local IsInWorld = util.IsInWorld
local decal = util.Decal
local effect = util.Effect

local tsimple = timer.Simple
local blastDmg = HpwRewrite.BlastDamage

local sPlay = sound.Play

function Spell:OnFire(wand)
	if not self.NextCall then self.NextCall = 0 end

	if called or CurTime() < self.NextCall then
		sound.Play("hl1/ambience/port_suckout1.wav", self.Owner:GetPos(), 70)
		self.Owner:Kill()
		return
	end

	self.NextCall = CurTime() + 2
	called = true


	-- Exploding
	local pos = self.Owner:GetPos()

	local ef = EffectData()
	ef:SetOrigin(pos)
	effect("EffectHpwRewriteNuke", ef)

	sPlay("ambient/explosions/explode_6.wav", pos, 120)

	timer.Create("hpwrewrite_donuke" .. self.Owner:EntIndex(), 0.5, 5, function()
		for k, v in pairs(ents.FindInSphere(pos, 200000)) do
			local phys = v:GetPhysicsObject()

			constraint.RemoveAll(v)
			v:TakeDamage(v:Health(), self.Owner, HpwRewrite:GetWand(self.Owner))

			if v.IS_DRR then v:Destroy() end

			if IsValid(phys) then
				local dist = pos:Distance(v:GetPos())
				phys:SetVelocity((v:GetPos() - pos):GetNormal() * phys:GetMass() * 5 + vector_up * phys:GetMass() * 2)
				phys:AddAngleVelocity(VectorRand() * phys:GetMass())

				phys:Wake()
				phys:EnableMotion(true)
			end
		end
	end)

	for i = 1, 20000 do
		local pos = pos + VectorRand() * 2000

		local tr = trace({
			start = pos,
			endpos = pos + VectorRand() * 10000
		})

		if not tr.Hit then continue end
		if tr.HitSky then continue end
		if not IsInWorld(tr.HitPos) then continue end

		tsimple(rand(1, 10), function()
			decal("HpwDeprimoCrack" .. random(1, 5), tr.HitPos - tr.HitNormal, tr.HitPos + tr.HitNormal)

			if math.random(0, 1) == 1 then
				sPlay("ambient/explosions/explode_" .. random(8, 9) .. ".wav", tr.HitPos, 120, random(90, 110))

				local ef = EffectData()
				ef:SetOrigin(tr.HitPos)
				effect("Explosion", ef, true, true)

				blastDmg(self.Owner, tr.HitPos, 400, 100)
				ScreenShake(tr.HitPos, 1000, 1000, 1, 3000)
			end
		end)
	end

	tsimple(3, function()
		sPlay("dimension/screamshorror.wav", Vector(0, 0, 0), 120)
	end)
end

HpwRewrite:AddSpell("Armageddon", Spell)