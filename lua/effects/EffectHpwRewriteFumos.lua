AddCSLuaFile()

-- TODO: fix 3rd person

function EFFECT:Init(data)
	local ply = data:GetEntity()
	if not IsValid(ply) then return end

	local oldVm = ply:GetViewModel()
	local vm = oldVm

	if not IsValid(vm) or ply:ShouldDrawLocalPlayer() then vm = HpwRewrite:GetWand(ply) end
	if not IsValid(vm) then return end

	local obj = vm:LookupBone("spritemagic")

	if obj then
		local m = vm:GetBoneMatrix(obj)
		if m then
			local pos = m:GetTranslation()
			if vm == oldVm then pos = pos - ply:EyeAngles():Forward() * 10 end

			local emitter = ParticleEmitter(pos)
			if not emitter then return end 

			local p = emitter:Add("particle/smokesprites_000" .. math.random(1, 9), pos)
			p:SetCollide(true)
			p:SetStartSize(15)
			p:SetEndSize(200)
			p:SetAngles(AngleRand())
			p:SetStartAlpha(255)
			p:SetRollDelta(math.Rand(-0.5, 0.5))
			p:SetEndAlpha(0)
			p:SetDieTime(12)
			p:SetVelocity(ply:GetAimVector() * 400 + VectorRand() * 5)
			p:SetGravity(VectorRand() * 50)
			p:SetAirResistance(70)
			p:SetColor(15, 15, 15)

			emitter:Finish()
		end
	end

	local vec = Vector(600, 600, 600)
	local pos = vm:GetPos()
	self:SetRenderBoundsWS(pos - vec, pos + vec)
end

function EFFECT:Think() 
	return false
end

function EFFECT:Render()
end