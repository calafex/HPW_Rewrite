local Spell = { }
Spell.LearnTime = 360
Spell.Category = HpwRewrite.CategoryNames.Special
Spell.ApplyFireDelay = 0.4
Spell.Description = [[
	Vaporizes your body and 
	sends the vapor wherever you 
	want.
]]

Spell.ForceAnim = { ACT_VM_PRIMARYATTACK_5 }
Spell.NodeOffset = Vector(-392, -618, 0)

local speed = 4000
local FrameTime = FrameTime

if SERVER then
	util.AddNetworkString("hpwrewrite_obscuratio_handler")
else
	net.Receive("hpwrewrite_obscuratio_handler", function()
		local startPos = LocalPlayer():EyePos()
		local oldPos = startPos
		local newPos = net.ReadVector() + LocalPlayer():GetViewOffset()
		local dist = newPos:Distance(oldPos)

		local oldAng = LocalPlayer():EyeAngles()
		local newAng = oldAng
		newAng.yaw = (newPos - oldPos):Angle().y

		local endTime = CurTime() + (dist / speed)

		local roll = 0

		hook.Add("CalcView", "hpwrewrite_obscuratio_handler", function(ply, pos, ang)
			local curTime = CurTime()
			local dt = FrameTime()

			local view = { }
			view.origin = oldPos
			view.angles = oldAng

			if dist > 1000 then 
				view.angles = view.angles + Angle(math.sin(curTime * 5) * roll * 0.02, math.cos(curTime * 5) * roll * 0.02, roll) 
			end

			oldPos = oldPos + (newPos - oldPos):GetNormal() * dt * speed
			roll = roll + (dt * speed * 360) / dist

			return view
		end)
		
		timer.Simple((dist / speed),function() hook.Remove("CalcView", "hpwrewrite_obscuratio_handler") end)
	end)
end

function Spell:OnFire(wand)
	local tr = self.Owner:GetEyeTrace()

	local dif = tr.HitNormal * self.Owner:OBBMaxs().x * 2.5
	dif.z = 0

	local pos = tr.HitPos + dif

	local check = util.TraceLine({ start = pos, endpos = pos + self.Owner:GetViewOffset() + Vector(0, 0, 1) })
	if check.Hit then return end

	for i = 1, self.Owner:GetBoneCount() - 1 do
		local pos, ang = self.Owner:GetBonePosition(i)
		if pos and ang then HpwRewrite.MakeEffect("hpw_stupefy_impact", pos, ang) end
	end

	self.Owner:SetNoDraw(true)
	self.Owner:SetNotSolid(true)
	self.Owner:Lock()

	local oldPos = self.Owner:EyePos()

	net.Start("hpwrewrite_obscuratio_handler")
		net.WriteVector(pos)
	net.Send(self.Owner)

	local name = "hpwrewrite_obscuratio_handler" .. self.Owner:EntIndex()
	hook.Add("GetFallDamage", name, function(ply) if ply == self.Owner then return 0 end end)

	sound.Play("hpwrewrite/spells/spellimpact.wav", oldPos, 75, 170)

	timer.Simple(oldPos:Distance(pos + self.Owner:GetViewOffset()) / speed, function()
		if not IsValid(self.Owner) then return end

		self.Owner:SetPos(pos)
		self.Owner:SetNoDraw(false)
		self.Owner:SetNotSolid(false)
		self.Owner:UnLock()

		for i = 1, self.Owner:GetBoneCount() - 1 do
			local pos, ang = self.Owner:GetBonePosition(i)
			if pos and ang then HpwRewrite.MakeEffect("hpw_stupefy_impact", pos, ang) end
		end

		timer.Simple(0.1, function() hook.Remove("GetFallDamage", name) end)
		sound.Play("hpwrewrite/spells/godivillio.wav", pos, 75)
	end)
end

HpwRewrite:AddSpell("Obscuratio", Spell)
