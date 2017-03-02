local Spell = { }
Spell.LearnTime = 600
Spell.ApplyFireDelay = 0.4
Spell.ForceAnim = { ACT_VM_PRIMARYATTACK_4 }
Spell.Category = HpwRewrite.CategoryNames.Protecting
Spell.Description = [[
	Makes area around you
	completely invisible for
	everyone who is not inside.
]]

Spell.OnlyIfLearned = { "Protego" }
Spell.NodeOffset = Vector(-923, 277, 0)
Spell.AccuracyDecreaseVal = 0.7

if SERVER then
	util.AddNetworkString("hpwrewrite_salviohexia_handler")
else
	local mdls = { }

	net.Receive("hpwrewrite_salviohexia_handler", function()
		local ent = net.ReadEntity()
		if not IsValid(ent) then return end

		local hide = tobool(net.ReadBit())
		local finished = tobool(net.ReadBit())

		if hide then
			ent:SetNoDraw(true)
			ent:DrawShadow(false)

			--[[for i = 0, ent:GetBoneCount() - 1 do
				local pos = ent:GetBonePosition(i)

				local ef = EffectData()
				ef:SetOrigin(pos)
				util.Effect("GlassImpact", ef)
			end]]

			--SafeRemoveEntity(ent.HPWGhost)

			sound.Play("hl1/ambience/port_suckin1.wav", ent:GetPos(), 60, 180)
		else
			ent:SetNoDraw(false)
			ent:DrawShadow(true)

			--[[for i = 0, ent:GetBoneCount() - 1 do
				local pos = ent:GetBonePosition(i)

				local ef = EffectData()
				ef:SetOrigin(pos)
				util.Effect("GlassImpact", ef)
			end

			if finished then
				for k, v in pairs(mdls) do SafeRemoveEntity(k) end
			else
				if ent != LocalPlayer() then
					local mdl = ClientsideModel(ent:GetModel(), RENDERGROUP_TRANSLUCENT)
					ent.HPWGhost = mdl
					mdl:SetPos(ent:GetPos())
					mdl:SetAngles(ent:GetAngles())
					mdl:SetMaterial("models/props_lab/Tank_Glass001")
					mdl:SetSkin(ent:GetSkin())
					mdl:Spawn()

					mdl:SetRenderMode(RENDERMODE_TRANSALPHA)
					mdl:SetColor(Color(255, 255, 255, 20))

					mdl:SetModelScale(ent:GetModelScale() * 1.02, 0)
					if not ent:IsPlayer() then mdl:SetParent(ent) end

					local name = "hpwrewrite_salviohexia_handler" .. mdl:EntIndex()
					hook.Add("Think", name, function()
						if not IsValid(mdl) or not IsValid(ent) then 
							SafeRemoveEntity(mdl) 
							hook.Remove("Think", name) 

							return 
						end

						if ent:IsPlayer() then
							mdl:SetPos(ent:GetPos())
							mdl:SetAngles(Angle(0, ent:GetAngles().y, 0))
						end

						mdl:SetSequence(ent:GetSequence())
						mdl:FrameAdvance(1)
					end)

					mdls[mdl] = true
				end
			end]]

			sound.Play("hl1/ambience/port_suckout1.wav", ent:GetPos(), 60, 180)
		end
	end)
end

function Spell:OnFire(wand)
	if not self.Exists then
		local name = "hpwrewrite_salviohexia_handler" .. self.Owner:EntIndex()
		local die = CurTime() + 40

		local pos = self.Owner:GetPos()

		hook.Add("Think", name, function()
			if CurTime() > die then
				hook.Remove("Think", name)

				for k, v in pairs(self.Invisible) do
					net.Start("hpwrewrite_salviohexia_handler")
						net.WriteEntity(k)
						net.WriteBit(false)
						net.WriteBit(true)
					net.Broadcast()

					self.Invisible[k] = nil
				end

				table.Empty(self.Proceeded)

				self.Exists = false

				return
			end

			for k, v in pairs(ents.GetAll()) do
				if not IsValid(v) then continue end
				if not v:GetPhysicsObject():IsValid() then continue end
				if v:IsWorld() then continue end

				if v:GetPos():Distance(pos) < 600 then
					self.Invisible[v] = true
				else
					self.Invisible[v] = nil
				end
			end

			for k, v in pairs(self.Invisible) do
				if not IsValid(k) then self.Invisible[k] = nil continue end

				for _, ply in pairs(player.GetAll()) do
					if not self.Proceeded[ply] then 
						self.Proceeded[ply] = { } 

						for k, v in pairs(self.Invisible) do
							self.Proceeded[ply][k] = ply:GetPos():Distance(k:GetPos()) < 400
						end
					end

					if ply:GetPos():Distance(k:GetPos()) > 400 then
						if not self.Proceeded[ply][k] then
							net.Start("hpwrewrite_salviohexia_handler")
								net.WriteEntity(k)
								net.WriteBit(true)
								net.WriteBit(false)
							net.Send(ply)

							self.Proceeded[ply][k] = true
						end
					else
						if self.Proceeded[ply][k] then
							net.Start("hpwrewrite_salviohexia_handler")
								net.WriteEntity(k)
								net.WriteBit(false)
								net.WriteBit(false)
							net.Send(ply)

							self.Proceeded[ply][k] = false
						end
					end
				end
			end
		end)

		self.Exists = true
	end

	sound.Play("npc/antlion/idle3.wav", wand:GetPos(), 55, math.random(240, 255))
end

function Spell:OnSpellGiven(ply)
	if SERVER then
		self.Invisible = { }
		self.Proceeded = { }
	end

	return true
end

HpwRewrite:AddSpell("Salvio Hexia", Spell)