AddCSLuaFile()

function EFFECT:Init(data)
	local pos = data:GetOrigin()
	local normal = data:GetNormal()

	local emitter = ParticleEmitter(pos)
	if not emitter then return end

	for i = 1, 10 do
		local p = emitter:Add("particle/smokesprites_000" .. math.random(1, 9), pos)

		p:SetDieTime(math.Rand(1.5, 2))
		p:SetStartAlpha(45)
		p:SetEndAlpha(0)
		p:SetStartSize(1)
		p:SetEndSize(90)
		p:SetRoll(math.random(-180, 180))
		p:SetRollDelta(math.Rand(-2, 2))

		p:SetVelocity(Vector(math.random(-10, 10), math.random(-10, 10)) - normal * 4 * i)
		p:SetGravity(Vector(0, 0, 35))
		p:SetColor(150, 150, 150)
	end
	
	emitter:Finish()
end

function EFFECT:Think() return false end
function EFFECT:Render() end