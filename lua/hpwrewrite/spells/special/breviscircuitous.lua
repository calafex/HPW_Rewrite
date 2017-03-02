local Spell = { }
Spell.LearnTime = 1200
Spell.ApplyFireDelay = 0.6
Spell.Category = { HpwRewrite.CategoryNames.Special }

Spell.Description = [[
	Spell that can disrupt
	wiremod constructions. 
	Affects anything with 
	electrical damage.

	It's recommended to blacklist
	this spell.
]]

Spell.ForceAnim = { ACT_VM_PRIMARYATTACK_5 }
Spell.NodeOffset = Vector(235, -1226, 0)
Spell.SpriteColor = Color(0, 120, 255)
Spell.DoSparks = true
Spell.AccuracyDecreaseVal = 0

local doEffect = util.Effect
local EffectData = EffectData
local WireLib = WireLib
local VectorRand = VectorRand
local LerpVector = LerpVector
local sphere = ents.FindInSphere
local random = math.random
local rand = math.Rand
local snd = sound.Play
local sub = string.sub
local sreplace = string.Replace
local char = string.char
local insert = table.insert
local tRandom = table.Random

local function GetRandomStrings()
	local new = { }

	for i = 1, random(1, 6) do
		local str = ""

		for a = 1, random(1, 16) do
			str = str .. char(random(1, 255))
		end

		insert(new, str)
	end

	-- Randomizing indexes
	for k, v in pairs(new) do
		local toSwap, toSwapKey = tRandom(new)

		local old = new[k]
		new[k] = toSwap
		new[toSwapKey] = old
	end

	return new
end

local function CorruptString(str)
	local length = #str
	local amount = random(8, 32)

	local minCurSymbol = 1

	for i = 1, amount do
		local shift = random(1, 4)

		local minrand = random(length)
		local maxrand = minrand + shift
		local find = sub(str, minrand, maxrand)
		find = sreplace(find, "\n", "")

		local maxCurSymbol = minCurSymbol + shift
		local replace = sub(str, minCurSymbol, maxCurSymbol)
		replace = sreplace(replace, "\n", "")

		str = sreplace(str, find, replace) .. char(random(1, 255))

		minCurSymbol = random(maxCurSymbol, length)
		if minCurSymbol >= #str then break end
	end

	return str
end

local wireIndividual = {
	["gmod_wire_expression2"] = function(e2)
		local code, _ = e2:GetCode()
		if not code then return end

		-- TODO: check if the timer is needed
		timer.Simple(0, function() e2:Setup(CorruptString(code), e2.inc_files, nil, true) end)
	end,

	["gmod_wire_textscreen"] = function(screen)
		screen:Setup(CorruptString(screen.text), screen.chrPerLine, screen.textJust, screen.valign, screen.tfont, screen.fgcolor, screen.bgcolor)
	end,

	["gmod_wire_thruster"] = function(thr)
		thr:SetForce(random(1, 1000))
	end,

	["gmod_wire_turret"] = function(tur)
		tur:Setup(rand(0.1, 1), random(0, 40), random(0, 100), "", random(1, 4), VectorRand(), tur.tracer)
	end,

	["gmod_wire_explosive"] = function(exp)
		if random(0, 1) == 1 then exp:Explode() end
	end,

	["gmod_wire_simple_explosive"] = function(exp)
		if random(0, 1) == 1 then exp:Explode() end
	end,

	["gmod_wire_light"] = function(light)
		light:Setup(tobool(random(0, 1)), tobool(random(0, 1)), tobool(random(0, 1)), random(0, 10), random(0, 1024), random(0, 255), random(0, 255), random(0, 255))
	end,

	["gmod_wire_pod"] = function(pod)
		pod:UnlinkEnt()
	end,

	["gmod_wire_cameracontroller"] = function(cam)
		cam:UnlinkEnt()
	end,

	["gmod_wire_soundemitter"] = function(emit)
		local wait = CurTime() + math.Rand(0, 1)
		local name = "hpwrewrite_breviscir_emitter" .. emit:EntIndex()

		hook.Add("Think", name, function()
			if CurTime() < wait then return end
			if not IsValid(emit) then hook.Remove("Think", name) return end

			emit:EmitSound("hpwrewrite/spells/electricity/sndemitter0" .. random(1, 3) .. ".wav", 50, random(90, 120), rand(0.5, 1), CHAN_WEAPON)
			wait = CurTime() + rand(1, 3)
		end)

		emit:SetSound("hpwrewrite/spells/electricity/sndemitter03.wav")
	end,

	["gmod_wheel"] = function(wheel)
		if random(0, 1) == 1 then wheel:SetDirection(-wheel:GetDirection()) end
		wheel:SetTorque(random(1, 10000))
	end,

	["gmod_button"] = function(btn)
		if random(0, 1) == 1 then btn:Toggle(not btn:GetOn()) end
	end,

	["gmod_dynamite"] = function(dyn)
		if random(0, 1) == 1 then dyn:Explode(0) end
	end,

	["gmod_hoverball"] = function(ball)
		ball:SetZVelocity((ball.ZVelocity / FrameTime() / 5000) * random(-10, 10))
		ball:SetSpeed(ball:GetSpeed() * rand(0.1, 5))
	end,

	["gmod_thruster"] = function(thr)
		if random(0, 1) == 1 then thr:SetOn(not thr:IsOn()) end
		thr:SetOffset(thr:GetOffset() * VectorRand())
		thr:SetForce(thr.force and thr.force * rand(-1, 1) or random(-1000, 1000), rand(0, 1))
	end,

	["dronesrewrite_console"] = function(cns)
		cns:Explode()
		cns.Hp = math.min(20, cns.Hp)
	end
}

local function Electricity(v, dmger, inf)
	local vec = Vector(0, 0, 0)
	local name = "hpwrewrite_breviscir_electricity" .. v:EntIndex()
	timer.Create(name, rand(0.1, 0.2), random(1, 6), function()
		if not IsValid(v) then return end

		local phys = v:GetPhysicsObject()
		if phys:IsValid() then
			vec = LerpVector(0.2, vec, VectorRand())

			phys:ApplyForceCenter(vec * phys:GetMass() * 100)
			phys:AddAngleVelocity(vec * 400)
		end

		if random(0, 6) == 1 then
			snd("ambient/energy/zap" .. random(5, 9) .. ".wav", v:GetPos(), 65)
		end

		for k, v in pairs(sphere(v:GetPos(), 60)) do
			v:TakeDamage(random(2, 5), dmger, inf)
		end
	end)
end

function Spell:OnFire(wand)
	local ent, tr = wand:HPWGetAimEntity(700, Vector(-15, -15, 0), Vector(15, 15, 0))
	local hitPos = tr and tr.HitPos or ent:GetPos()

	local ef = EffectData()
	ef:SetEntity(self.Owner)
	ef:SetStart(vector_origin)
	ef:SetOrigin(hitPos)
	ef:SetAttachment(1)
	doEffect("EffectHpwRewriteLightning", ef, true, true)

	snd("ambient/energy/weld" .. random(1, 2) .. ".wav", wand:GetPos(), 70, random(120, 160))

	local owner = self.Owner

	timer.Simple(hitPos:Distance(wand:GetPos()) * 0.0003, function()
		if IsValid(ent) then
			for k, v in pairs(constraint.GetAllConstrainedEntities(ent)) do
				if not IsValid(v) then continue end

				Electricity(v, owner, wand)

				if v.IS_DRR then
					v:SetEnabled(false)
				end

				local pos = v:GetPos()
				local ef = EffectData()
				ef:SetEntity(NULL)
				ef:SetStart(pos + VectorRand() * 10)
				ef:SetOrigin(pos)
				ef:SetAttachment(1)
				doEffect("EffectHpwRewriteLightning", ef, true, true)

				local class = v:GetClass()
				if wireIndividual[class] then 
					wireIndividual[class](v) 
					snd("ambient/energy/spark" .. random(1, 6) .. ".wav", pos, 72, random(100, 120))
				end

				if v.IsWire then
					if v.UpdateOverlay then
						v:UpdateOverlay()

						local new = "???"
						if v.OverlayData and v.OverlayData.txt then
							new = CorruptString(v.OverlayData.txt)
						end

						function v:UpdateOverlay()
							self:SetOverlayText(new)
						end

						v:SetOverlayText(new)
					end

					if not v.HpwRewriteEffectExists then
						HpwRewrite.MakeEffect("hpw_misc_energy_main", nil, nil, v)

						timer.Simple(random(12, 24), function() 
							if IsValid(v) then 
								v:StopParticles() 
								v.HpwRewriteEffectExists = nil
							end
						end)

						v.HpwRewriteEffectExists = true
					end

					if WireLib then
						if v.Outputs then
							for port, tab in pairs(v.Outputs) do
								WireLib.DisconnectOutput(v, port)
							end
						end

						if v.Inputs then
							for port, tab in pairs(v.Inputs) do
								WireLib.RetypeInputs(v, port, tab.Type, "???")
							end
						end

						-- TODO: fix io
						--WireLib.AdjustInputs(v, GetRandomStrings())
						--WireLib.AdjustOutputs(v, GetRandomStrings())

						snd("ambient/energy/zap" .. random(5, 9) .. ".wav", pos, 68, random(100, 120))
					end
				elseif v.IsMediaPlayerEntity then
					-- Is there any better way to cleanup a mediaplayer?
					local oldPhys = v:GetPhysicsObject()
					if not oldPhys:IsValid() then return end

					local newEnt = ents.Create(class)
					newEnt:SetPos(v:GetPos())
					newEnt:SetAngles(v:GetAngles())
					newEnt:SetColor(v:GetColor())
					newEnt:SetMaterial(v:GetMaterial())
					newEnt:SetOwner(v:GetOwner())
					newEnt:Spawn()

					if v.CPPIGetOwner and newEnt.CPPISetOwner then
						local owner = v:CPPIGetOwner()
						if IsValid(owner) then
							newEnt:CPPISetOwner(owner)
						end
					end

					local phys = newEnt:GetPhysicsObject()
					if not phys:IsValid() then newEnt:Remove() return end

					phys:SetVelocity(oldPhys:GetVelocity())
					phys:AddAngleVelocity(oldPhys:GetAngleVelocity())

					undo.ReplaceEntity(v, newEnt)
					cleanup.ReplaceEntity(v, newEnt)

					v:Remove()
				end
			end
		end
	end)
end

HpwRewrite:AddSpell("Brevis Circuitous", Spell)