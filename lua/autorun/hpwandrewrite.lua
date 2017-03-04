if SERVER then AddCSLuaFile() end

HpwRewrite = HpwRewrite or { }

HpwRewrite.Version = 10004
HpwRewrite.VCheckLink = "https://raw.githubusercontent.com/Ayditor/HPW_Rewrite/master/info.txt"
HpwRewrite.FavouriteSpells = HpwRewrite.FavouriteSpells or { }
HpwRewrite.DebugInfo = HpwRewrite.DebugInfo or { }

HpwRewrite.Colors = HpwRewrite.Colors or { }
HpwRewrite.Colors.White = Color(255, 255, 255)
HpwRewrite.Colors.Black = Color(0, 0, 0)
HpwRewrite.Colors.DarkGrey = Color(60, 60, 60, 255)
HpwRewrite.Colors.DarkGrey2 = Color(40, 40, 40, 255)
HpwRewrite.Colors.DarkGrey3 = Color(90, 90, 90, 255)
HpwRewrite.Colors.DarkGrey4 = Color(100, 100, 100, 255)
HpwRewrite.Colors.DarkGrey5 = Color(130, 130, 130, 255)
HpwRewrite.Colors.DarkGrey6 = Color(72, 72, 72, 255)
HpwRewrite.Colors.LightGrey = Color(220, 220, 220, 255)
HpwRewrite.Colors.Blue = Color(65, 160, 230, 255)
HpwRewrite.Colors.LightBlue = Color(90, 185, 255, 255)
HpwRewrite.Colors.Red = Color(210, 60, 60, 255)
HpwRewrite.Colors.Green = Color(60, 210, 60, 255)
HpwRewrite.Colors.Magenta = Color(255, 0, 255, 255)
HpwRewrite.Colors.Cyan = Color(0, 255, 255, 255)
HpwRewrite.Colors.Yellow = Color(255, 255, 0, 255)

HpwRewrite.BlockedNPCs = {
	["npc_combinedropship"] = true,
	["npc_combine_camera"] = true,
	["npc_turret_ceiling"] = true,
	["npc_combinegunship"] = true,
	["npc_turret_floor"] = true,
	["npc_antlion_grub"] = true,
	["npc_clawscanner"] = true,
	["npc_rollermine"] = true,
	["npc_helicopter"] = true,
	["npc_barnacle"] = true,
	["npc_cscanner"] = true,
	["npc_strider"] = true,
	["npc_manhack"] = true,
	["npc_dog"] = true
}

if SERVER then
	util.AddNetworkString("HpwRewriteSendColor")

	-- Takes wand damage
	function HpwRewrite.TakeDamage(ent, attacker, damage, force)
		local wand = HpwRewrite:GetWand(attacker)

		local d = DamageInfo()

		if IsValid(attacker) then d:SetAttacker(attacker) else d:SetAttacker(game.GetWorld()) end
		if wand:IsValid() then d:SetInflictor(wand) else d:SetInflictor(d:GetAttacker()) end

		d:SetDamage(damage)
		d:SetDamageType(DMG_GENERIC)
		d:SetDamageForce(force or Vector(1, 1, 1)) -- Force hack

		ent:TakeDamageInfo(d)
	end

	function HpwRewrite.BlastDamage(_attacker, pos, radius, damage)
		local attacker = game.GetWorld()
		local inflictor = attacker

		if IsValid(_attacker) then
			attacker = _attacker

			local wand = HpwRewrite:GetWand(attacker)
			if wand:IsValid() then inflictor = wand end
		end

		util.BlastDamage(inflictor, attacker, pos, radius, damage)
	end

	local zombie = {
		["models/zombie/classic.mdl"] = true,
		["models/zombie/classic_torso.mdl"] = true,
		["models/zombie/poison.mdl"] = true,
		["models/zombie/fast.mdl"] = true,
		["models/zombie/fast_torso.mdl"] = true,
		["models/zombie/zombie_soldier.mdl"] = true
	}

	local function CreateRagdoll(ply, dir, force)
		local mdl = ply:GetModel()
		local rag = ents.Create("prop_ragdoll")
		rag:SetPos(ply:GetPos())
		rag:SetModel(mdl)
		rag:SetAngles(ply:GetAngles())
		rag:SetSkin(ply:GetSkin())
		rag:SetColor(ply:GetColor())
		rag:Spawn()
		rag:Activate()
		rag:SetCollisionGroup(COLLISION_GROUP_DEBRIS)

		rag.PhysgunPickup = false
		rag.CanTool = false
		rag.HPWRagdolledEnt = true
		rag.MaxPenetration = ply:GetMaxHealth()

		dir = dir or vector_origin

		local phys = rag:GetPhysicsObject()
		if not IsValid(phys) then SafeRemoveEntity(rag) return end

		local vec = Vector(0.2, 0, -0.5) + VectorRand() * 0.3
		local vel = ply:GetVelocity()
		for i = 1, rag:GetPhysicsObjectCount() - 1 do
			local physBone = rag:GetPhysicsObjectNum(i)
			local plyBone = ply:GetBoneMatrix(ply:TranslatePhysBoneToBone(i))

			if physBone and plyBone then
				local ang = plyBone:GetAngles()

				physBone:SetAngles(ang)

				physBone:ApplyForceCenter(((dir + Vector(0, 0, 0.45)) * force + vel) * physBone:GetMass() * 0.18)
				physBone:AddAngleVelocity(vec * force * 0.4)
			end
		end

		phys:AddAngleVelocity(VectorRand() * force * 1.5)

		-- For some reason gmod crashes if you grab rag with physgun and hold it until
		-- the victim respawns
		-- TODO: look for crash reason
		local name = "HpwRewrite_throwing_crashfix" .. rag:EntIndex()
		hook.Add("PhysgunPickup", name, function(ply, ent)
			if not IsValid(rag) then hook.Remove("PhysgunPickup", name) return end
			if ent == rag then return false end
		end)

		hook.Add("CanTool", name, function(ply, tr, tool)
			if not IsValid(rag) then hook.Remove("CanTool", name) return end
			if IsValid(tr.Entity) and tr.Entity == rag then return false end
		end)

		if zombie[mdl] then
			for i = 1, 4 do -- headcrab groups
				rag:SetBodygroup(i, 1)
			end
		end

		return rag, phys
	end

	local function CreateTimer(rag, velocityTimerCheck, reviveTimer, delay, done)
		if delay then
			timer.Create(velocityTimerCheck, 0.2, 0, function()
				if not IsValid(rag) then timer.Remove(velocityTimerCheck) return end

				if rag:GetVelocity():Length() < 40 then
					if not timer.Exists(reviveTimer) then 
						timer.Create(reviveTimer, delay or 2, 1, done) 
					end
				end
			end)
		end
	end

	HpwRewrite.Throwing_TimerReviveFunc = CreateTimer

	local HookName = "HpwRewrite_Saver"
	local crashDmgCoef = 0.2

	function HpwRewrite:ThrowPlayer(ply, dir, force, delay, damager, callback)
		if self.CVars.DisableThrowing:GetBool() then return end
		if ply:HasGodMode() then return end

		local rag, phys = CreateRagdoll(ply, dir, force or 1500)
		if not rag then return end

		if ply:InVehicle() then ply:ExitVehicle() end

		-- Colorizing
		timer.Simple(FrameTime() * 6, function()
			if IsValid(ply) and IsValid(rag) then
				rag.GetPlayerColor = function() if ply:IsValid() then return ply:GetPlayerColor() end end
				net.Start("HpwRewriteSendColor")
					net.WriteEntity(rag)
					net.WriteEntity(ply)
				net.Broadcast()
			end
		end)

		local damage = 0
		local lastAttacker = damager
		local eyes = ply:EyeAngles()
		local oldSkin = ply:GetSkin()
		local oldMdl = ply:GetModel()
		local hp = ply:Health()
		local oldWep = ""
		if IsValid(ply:GetActiveWeapon()) then oldWep = ply:GetActiveWeapon():GetClass() end

		local weps = { }
		for k, v in pairs(ply:GetWeapons()) do table.insert(weps, v:GetClass()) end

		ply:SetParent(rag)
		ply:SetNWEntity("HPWThrownRagdoll", rag)
		ply:Spectate(OBS_MODE_CHASE)
		ply:SpectateEntity(rag)
		ply:DrawViewModel(false)
		ply:SetNoDraw(true)
		ply:StripWeapons()

		local reviveTimer = "hpwrewrite_throwing_rag" .. rag:EntIndex()
		local velocityTimerCheck = "hpwrewrite_throwing_rag_handler" .. rag:EntIndex()
		local deathHook = "hpwrewrite_throwing_death" .. rag:EntIndex()
		local damageHook = "hpwrewrite_throwing_dmgsaver" .. rag:EntIndex()
		local suicideHook = "hpwrewrite_throwing_suicide" .. rag:EntIndex()

		-- Function to finish
		local function done(pos)
			-- Wiping hooks
			timer.Remove(reviveTimer)
			timer.Remove(velocityTimerCheck)
			hook.Remove("DoPlayerDeath", deathHook)
			hook.Remove("EntityTakeDamage", damageHook)
			hook.Remove("CanPlayerSuicide", suicideHook)

			if IsValid(ply) then
				ply:SetParent()
				ply:UnSpectate()
				ply:Spawn()

				ply:SetModel(oldMdl)
				ply:SetSkin(oldSkin)
				ply:SetHealth(hp)
				ply:SetEyeAngles(eyes)
				ply:DrawViewModel(true)
				ply:SetNoDraw(false)

				for k, v in pairs(weps) do ply:Give(v) end
				if ply:HasWeapon(oldWep) then ply:SelectWeapon(oldWep) end

				if damage > 0 then 
					if lastAttacker == ply then lastAttacker = game.GetWorld() end -- fix darkrp todo
					--ply:TakeDamage(damage, lastAttacker, HpwRewrite:GetWand(lastAttacker)) 
					HpwRewrite.TakeDamage(ply, lastAttacker, damage)
				end

				if callback then callback(ply, rag) end
			end
			
			if IsValid(rag) then 
				pos = rag:GetPos()
				rag.HpwRewriteWeReDone = true
				rag:Remove()
			end

			ply:SetPos(pos or vector_origin) 

			rag = nil

			return ply
		end

		-- Hooks
		-- We cant instantly call done() in remove hook so waiting one more frame
		rag:CallOnRemove(HookName, function(rag)
			if IsValid(ply) then
				ply:SetParent()
				ply:UnSpectate()
			end

			if not rag.HpwRewriteWeReDone then 
				local pos = rag:GetPos()
				timer.Simple(0, function()
					done(pos)
				end) 
			end
		end)

		hook.Add("DoPlayerDeath", deathHook, function(victim)
			if not IsValid(rag) then hook.Remove("DoPlayerDeath", deathHook) return end
			if victim == ply then done() end
		end)

		hook.Add("EntityTakeDamage", damageHook, function(ent, dmg)
			if IsValid(rag) then
				if ent == ply then return true end -- Prevent from dealing damage to our player

				if ent == rag then 
					lastAttacker = dmg:GetAttacker()
					if lastAttacker:IsWorld() then lastAttacker = damager end

					local coef = 1
					if dmg:IsDamageType(DMG_CRUSH) then coef = crashDmgCoef end

					dmg = dmg:GetDamage()
					damage = damage + dmg * coef

					if damage >= hp then 
						done()
						return true
					end
				end
			else
				hook.Remove("EntityTakeDamage", damageHook)
			end
		end)

		hook.Add("CanPlayerSuicide", suicideHook, function(victim)
			if not IsValid(rag) then hook.Remove("CanPlayerSuicide", suicideHook) return end
			if victim == ply then return false end
		end)

		CreateTimer(rag, velocityTimerCheck, reviveTimer, delay, done)

		return rag, done, velocityTimerCheck, damageHook -- ragdoll itself, function to stop, timer name to revive
	end

	function HpwRewrite:ThrowNPC(npc, dir, force, delay, damager, callback)
		if self.CVars.DisableThrowing:GetBool() then return end

		local className = npc:GetClass()
		if HpwRewrite.BlockedNPCs[className] then return end
		if npc:GetModelRadius() > 300 then return end

		local rag, phys = CreateRagdoll(npc, dir, force or 1500)
		if not rag then return end

		local damage = 0
		local lastAttacker = damager
		local hp = npc:Health()
		local oldWep
		if IsValid(npc:GetActiveWeapon()) then oldWep = npc:GetActiveWeapon():GetClass() end

		-- Saving the owner for prop protection systems
		local owner
		if npc.CPPIGetOwner and npc.CPPISetOwner then
			owner = npc:CPPIGetOwner()
			if not IsValid(owner) then
				owner = damager
			end

			rag:CPPISetOwner(owner)
		end

		local reviveTimer = "hpwrewrite_throwing_rag" .. rag:EntIndex()
		local velocityTimerCheck = "hpwrewrite_throwing_rag_handler" .. rag:EntIndex()
		local damageHook = "hpwrewrite_throwing_dmgsaver" .. rag:EntIndex()

		-- Replacing npc with rag in undoes
		for _, tab in pairs(undo.GetTable()) do
			for id, struct in pairs(tab) do
				for ___, ent in pairs(struct.Entities) do
					if ent == npc then
						struct.Entities[___] = rag

						rag:CallOnRemove("RemoveUndoFunc" .. id, function()
							struct.Functions = { }
						end)

						table.insert(struct.Functions, { function() 
							if not rag:IsValid() then return end

							timer.Remove(velocityTimerCheck)
							timer.Remove(reviveTimer)
							hook.Remove("EntityTakeDamage", damageHook)

							rag:RemoveCallOnRemove(HookName) -- Don't let it spawn a npc
						end, { } })
					end
				end
			end
		end

		cleanup.ReplaceEntity(npc, rag)

		local function done()
			-- Wiping hooks
			timer.Remove(reviveTimer)
			timer.Remove(velocityTimerCheck)
			hook.Remove("EntityTakeDamage", damageHook)

			if IsValid(rag) then 
				rag.HpwRewriteWeReDone = true

				local npc = ents.Create(className)
				npc:SetPos(rag:GetPos()) 
				npc:SetModel(rag:GetModel())
				npc:SetColor(rag:GetColor())
				if rag:GetSkin() then npc:SetSkin(rag:GetSkin()) end
				if oldWep then npc:SetKeyValue("additionalequipment",oldWep) end
				npc:Spawn()
				npc:Activate()
				npc:SetHealth(hp)

				if IsValid(owner) then
					npc:CPPISetOwner(owner)
				end
				
				if damage > 0 then 
					--npc:TakeDamage(math.min(npc:GetMaxHealth(), damage), lastAttacker, HpwRewrite:GetWand(lastAttacker))
					HpwRewrite.TakeDamage(npc, lastAttacker, damage)
				end

				undo.ReplaceEntity(rag, npc)
				cleanup.ReplaceEntity(rag, npc)
				
				if callback then callback(npc, rag) end
				rag:Remove()

				rag = nil

				return npc
			end
		end

		rag:CallOnRemove(HookName, function(rag)
			if not rag.HpwRewriteWeReDone then done() end
		end)

		hook.Add("EntityTakeDamage", damageHook, function(ent, dmg)
			if IsValid(rag) then
				if ent == rag then 
					lastAttacker = dmg:GetAttacker()
					if lastAttacker:IsWorld() then lastAttacker = damager end

					local coef = 1
					if dmg:IsDamageType(DMG_CRUSH) then coef = crashDmgCoef end

					dmg = dmg:GetDamage()
					damage = damage + dmg * coef

					if damage >= hp then 
						done()
						return true
					end
				end
			else
				hook.Remove("EntityTakeDamage", damageHook)
			end
		end)

		CreateTimer(rag, velocityTimerCheck, reviveTimer, delay, done)

		-- Gmod doesnt remove npcs in the moment, it should fix two ragdolls bug
		npc:SetHealth(99999)
		npc.TakeDamage = function() end
		npc:Remove()

		return rag, done, velocityTimerCheck, damageHook -- ragdoll itself, function to stop, timer name to revive, damage hook
	end

	function HpwRewrite:ThrowEntity(ent, dir, force, delay, damager, callback)
		if not IsValid(ent) then return end

		if ent:Health() > 0 then
			if ent:IsPlayer() then
				return self:ThrowPlayer(ent, dir, force, delay, damager, callback)
			elseif ent:IsNPC() then
				return self:ThrowNPC(ent, dir, force, delay, damager, callback)
			end
		end
	end

	function HpwRewrite:BlockSpelling(ply, val)
		ply.HpwRewrite.BlockSpelling = val
	end

	util.AddNetworkString("HpwRewriteSendSelfCast")
	net.Receive("HpwRewriteSendSelfCast", function(len, ply)
		ply.HpwRewrite.IsHoldingSelfCast = tobool(net.ReadBit())
	end)
else
	hook.Add("CalcView", "hpwrewrite_throwing_calcviewhandler", function(ply, pos, ang, fov)
		local rag = ply:GetNWEntity("HPWThrownRagdoll")

		if IsValid(rag) then
			local eyes = rag:GetAttachment(rag:LookupAttachment("eyes"))

			if eyes then
				local view = {
					origin = eyes.Pos,
					angles = eyes.Ang,
					fov = 90
				}

				return view
			end
		end
	end)

	net.Receive("HpwRewriteSendColor", function()
		local rag = net.ReadEntity()
		local ply = net.ReadEntity()

		if not IsValid(rag) then return end
		rag.GetPlayerColor = function() if ply:IsValid() then return ply:GetPlayerColor() end end
	end)
end

-- Stuff for self casting
function HpwRewrite:IsHoldingSelfCast(ply)
	if SERVER then return ply.HpwRewrite.IsHoldingSelfCast end
	return self._IsHoldingSelfCast
end

-- TODO: replace this function with regular ParticleEffect funcs
function HpwRewrite.MakeEffect(name, pos, ang, ent, attachment)
	if IsValid(ent) then
		ParticleEffectAttach(name, attachment or PATTACH_POINT_FOLLOW, ent, 0) 
	else
		ParticleEffect(name, pos or Vector(0, 0, 0), ang or Angle(0, 0, 0))
	end
end

function HpwRewrite.CheckAdmin(ply)
	if not IsValid(ply) then return false end
	if not ply:IsPlayer() then return false end
	if not game.SinglePlayer() and not ply:IsAdmin() then return false end
	
	return true
end

function HpwRewrite:LogDebug(text)
	if not self.CVars then return end
	if not self.CVars.DebugMode:GetBool() then return end
	
	text = os.date("%H:%M:%S", os.time()) .. " " .. text .. " | Message #" .. (#self.DebugInfo)
	if #self.DebugInfo >= 1000 then text = text .. " (MAX)" end

	MsgC(Color(255, 100, 100), "[Debug] ", SERVER and Color(137, 222, 255) or Color(255, 222, 102), text, "\n")

	self.DebugInfo[#self.DebugInfo + 1] = text

	if #self.DebugInfo > 1000 then
		table.remove(self.DebugInfo, 1)
	end
end

function HpwRewrite:DoNotify(...)
	local args = { ... }

	if SERVER then
		net.Start("hpwrewrite_nfy")
			net.WriteString(args[2])

			net.WriteInt(args[3] or -1, 6) 
			net.WriteInt(args[4] or -1, 16) 
		net.Send(args[1])
	else
		if args[1] == nil or not isstring(args[1]) then args[1] = "<empty>" end
		if args[2] == nil or args[2] == -1 or not isnumber(args[2]) then args[2] = NOTIFY_GENERIC end
		if args[3] == nil or args[3] == -1 or not isnumber(args[3]) then args[3] = 5 end

		if self.CVars.DisableAllMsgs:GetBool() then
			HpwRewrite:LogDebug("Attempted to make hint message but messages are disabled - " .. args[1])
			return 
		end

		notification.AddLegacy(args[1], args[2], args[3]) 
		surface.PlaySound("ambient/water/drip3.wav")
	end
end

function HpwRewrite:IncludeFolder(path, recursive, str, fileFilter)
	str = str or "sh"
	fileFilter = fileFilter or { }

	local f, p = file.Find(path .. "/*", "LUA")

	for k, v in pairs(f) do
		if table.HasValue(fileFilter, v) then continue end

		local file = path .. "/" .. v

		if CLIENT and (str == "cl" or str == "sh") then
			include(file)
		end

		if SERVER then
			if str == "sv" or str == "sh" then
				include(file)
			end

			AddCSLuaFile(file)
		end
	end

	if recursive then
		for k, v in pairs(p) do
			self:IncludeFolder(path .. "/" .. v, str)
		end
	end

	self:LogDebug("[Data] Loaded " .. path .. " folder")
end

function HpwRewrite:LoadFile(path)
	if SERVER then AddCSLuaFile(path) end
	include(path)

	self:LogDebug("[Data] Loaded " .. path .. " file")
end

HpwRewrite.WandClass = "weapon_hpwr_stick"

function HpwRewrite.IsValidWand(wand)
	if IsValid(wand) then
		return wand:GetClass() == HpwRewrite.WandClass
	end

	return false
end

function HpwRewrite:GetWand(ply)
	if not IsValid(ply) or not ply:IsPlayer() then return NULL end
	
	local wep = HpwRewrite.WandClass
	if ply:HasWeapon(wep) then
		wep = ply:GetWeapon(wep)
		if IsValid(wep) then return wep end
	end

	return NULL
end

function HpwRewrite:HasWand(ply)
	return ply:HasWeapon(self.WandClass)
end

HpwRewrite:LoadFile("hpwrewrite/cvars.lua")
HpwRewrite:LoadFile("hpwrewrite/dictionary.lua")
HpwRewrite:LoadFile("hpwrewrite/categories.lua")
HpwRewrite:LoadFile("hpwrewrite/particles.lua")
HpwRewrite:LoadFile("hpwrewrite/decals.lua")
HpwRewrite:LoadFile("hpwrewrite/fonts.lua")
HpwRewrite:LoadFile("hpwrewrite/datamanager.lua")
HpwRewrite:LoadFile("hpwrewrite/network.lua")
HpwRewrite:LoadFile("hpwrewrite/effects.lua")
HpwRewrite:LoadFile("hpwrewrite/spellmanager.lua")
HpwRewrite:LoadFile("hpwrewrite/binds.lua")
HpwRewrite:LoadFile("hpwrewrite/manuals.lua")
HpwRewrite:LoadFile("hpwrewrite/vgui.lua")
HpwRewrite:LoadFile("hpwrewrite/debugwin.lua")
HpwRewrite:LoadFile("hpwrewrite/spelltree.lua")
HpwRewrite:LoadFile("hpwrewrite/fightingmanager.lua")

HpwRewrite:IncludeFolder("hpwrewrite/misc", true)
HpwRewrite:IncludeFolder("hpwrewrite/options", true)

if SERVER then
	-- Version checker
	hook.Add("Initialize", "hpwrewrite_versionautocheck", function()
		-- For some reason it won't work without timer
		timer.Simple(0, function()
			http.Fetch(HpwRewrite.VCheckLink,
				function(body, len, headers, code)
					if not body then return end
					local info = util.JSONToTable(body)

					if info then
						local version = info.AddonInfo.Version

						if version == HpwRewrite.Version then
							MsgC(Color(0, 255, 0), "Harry Potter Magic Wand is up to date!\n")
							HpwRewrite.IsUpToDate = true
						else
							local msg1 = "Seems like Harry Potter Magic Wand is outdated!\n"
							local msg2 = "New version: " .. version .. "\n"
							local msg3 = "Your version: " .. HpwRewrite.Version .. "!\n"
							MsgC(Color(255, 100, 80), msg1, msg2, msg3)
						end
					else
						print("Can't read version!")
					end
				end,

				function(error)
					print("Cannot check version of Harry Potter Magic Wand!")
				end
			)
		end)
	end)

	-- Handlers
	hook.Add("PlayerLoadout", "hpwrewrite_givewandonspawn", function(ply)
		if HpwRewrite.CVars.GiveWand:GetBool() then ply:Give(HpwRewrite.WandClass) end
	end)

	-- Updating wand skin
	util.AddNetworkString("hpwrewrite_requestskinupdate")

	net.Receive("hpwrewrite_requestskinupdate", function(len, ply)
		local wand = net.ReadEntity()
		if not HpwRewrite.IsValidWand(wand) then return end

		wand:UpdateClientsideSkin(ply)
	end)
else
	hook.Add("NetworkEntityCreated", "hpwrewrite_sendwandskins", function(ent)
		if HpwRewrite.IsValidWand(ent) then
			-- Update wand's skin
			net.Start("hpwrewrite_requestskinupdate")
				net.WriteEntity(ent)
			net.SendToServer()
		end
	end)

	-- Requesting for our spells
	hook.Add("InitPostEntity", "hpwrewrite_updatespells_request", function()
		net.Start("hpwrewrite_updatespells_request")
		net.SendToServer()
	end)
end

HpwRewrite.Loaded = true
hook.Run("hpwrewrite_loaded")

if SERVER then MsgC(Color(0, 200, 255), "Magic Wand Rewrite addon has been loaded!\n") end
HpwRewrite:LogDebug("Magic Wand Rewrite addon has been loaded!")