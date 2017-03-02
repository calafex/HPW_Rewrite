AddCSLuaFile()

SWEP.PrintName	= "Magic Wand Rewrite"
SWEP.Category = "Harry Potter"
SWEP.Purpose = ""

SWEP.Weight = 5

SWEP.Spawnable	= true
SWEP.UseHands	= true
SWEP.DrawAmmo	= false

SWEP.ViewModelFOV	= 56
SWEP.Slot			= 2
SWEP.SlotPos		= 5

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "none"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

SWEP.ViewModel = Model("models/hpwrewrite/c_magicwand.mdl")
SWEP.WorldModel = Model("models/hpwrewrite/w_magicwand.mdl")

SWEP.BobScale = 0.26
SWEP.SwayScale = 0.8

AccessorFunc(SWEP, "m_hpw_accuracy_penalty", "HPWAccuracyPenalty", FORCE_NUMBER) 

--local setup = CreateConVar("hpwrewrite_setup", "0", { FCVAR_ARCHIVE, FCVAR_PROTECTED, FCVAR_REPLICATED })

if CLIENT then
	killicon.Add("weapon_hpwr_stick", "hpwrewrite/killicon", Color(255, 80, 0, 255))

	hook.Add("OnContextMenuOpen", "hpwrewrite_wand_handler_open", function() 
		local self = LocalPlayer():GetActiveWeapon()
		if HpwRewrite.IsValidWand(self) then
			self.HpwRewrite.ShouldSetPos = true
			self.HpwRewrite.Select = true 
		end
	end)

	hook.Add("OnContextMenuClose", "hpwrewrite_wand_handler_close", function() 
		local self = LocalPlayer():GetActiveWeapon()
		if HpwRewrite.IsValidWand(self) then
			self.HpwRewrite.Select = false 
		end
	end)

	--[[net.Receive("hpwrewrite_setup", function(len)
		if not HpwRewrite.CheckAdmin(ply) or not ply:IsSuperAdmin() or setup:GetBool() then return end

		local time = SysTime()
		local win = HpwRewrite.VGUI:CreateWindow(800, 425)

		local alpha = 0
		win.Paint = function(self, w, h)
			Derma_DrawBackgroundBlur(self, time)

			alpha = math.Approach(alpha, 150, RealFrameTime() * 60)
			local col = Color(255, 255, 255, alpha)
			draw.RoundedBox(0, 0, 0, ScrW(), ScrH(), col)
		end

		win.PaintOver = function() end

		local lab = HpwRewrite.VGUI:CreateLabel("Should we enable spell learning?", nil, nil, win)
		lab:SetFont("HPW_guibiggest")
		lab:Dock(TOP)
		lab:InvalidateParent(true)
		lab:SetColor(HpwRewrite.Colors.DarkGrey2)
		lab:SetContentAlignment(5)
		lab:SizeToContents()

		local yes = HpwRewrite.VGUI:CreateButton("Yes!", 85, 155, 300, 200, win, function()
			net.Start("hpwrewrite_setup")
				net.WriteBit(false)
			net.SendToServer()

			win:Close()
		end)
		yes.MainColor = Color(50, 160, 50)
		yes.EnterColor = Color(50, 200, 50)
		yes:SetFont("HPW_guibiggest")

		local no = HpwRewrite.VGUI:CreateButton("No!", 410, 155, 300, 200, win, function()
			net.Start("hpwrewrite_setup")
				net.WriteBit(true)
			net.SendToServer()

			win:Close()
		end)
		no.MainColor = Color(160, 50, 50)
		no.EnterColor = Color(200, 50, 50)

		no:SetFont("HPW_guibiggest")
	end)]]

	function SWEP:AdjustMouseSensitivity()
		if HpwRewrite.FM:GetValue(self.Owner) then return 0.3 end
	end

	SWEP.WepSelectIcon = surface.GetTextureID("vgui/hpwrewrite/selection/wep_sel")
	function SWEP:DrawWeaponSelection(x, y, wide, tall, alpha)
		x = x + wide / 2
		y = y + tall / 2

		tall = tall * 0.75

		x = x - tall / 2
		y = y - tall / 2 - 10

		surface.SetDrawColor(255, 255, 255, alpha)
		surface.SetTexture(self.WepSelectIcon)

		surface.DrawTexturedRect(x, y, tall, tall)
	end

	function SWEP:FirstCellPos()
		return ScrW() / 2 - 305 + HpwRewrite.CVars.XOffset:GetInt(), ScrH() - 130 + HpwRewrite.CVars.YOffset:GetInt()
	end

	local cellSize = 68

	function SWEP:GetCellPosition(index)
		local x, y = self:FirstCellPos()
		return x + (index - 1) * cellSize + 32, y + 32
	end

	function SWEP:CalculateCellOffset()
		local mx, my = input.GetCursorPos()
		local x, y = self:FirstCellPos()

		local st1 = (my - y) / cellSize
		local st2 = (mx - x) / cellSize

		if st2 > 9 or st2 < 0 then return 0 end
		if st1 > 1 or st1 < 0 then return 0 end

		return math.Clamp(math.floor(st2) + 1, 1, 9)
	end

	local glow = Material("hpwrewrite/sprites/magicsprite")
	function SWEP:DrawSpriteStuff(vm)
		local obj = vm:LookupBone("spritemagic")
		local pos = self.Owner:EyePos()
		local val = 1
		
		local curskin = HpwRewrite:GetPlayerSkin(self.Owner, self:GetWandCurrentSkin())
		if curskin then curskin:DrawMagicSprite(self, vm, obj) end

		if self.HpwRewrite.SpriteAlpha > 0 then 
			local curspell = HpwRewrite:GetPlayerSpell(self.Owner, self:GetWandCurrentSpell())
			if curspell and curspell.Name == self.HpwRewrite.LastAttackerSpellName then curspell:DrawMagicSprite(self, vm, obj) end

			self.HpwRewrite.SpriteAlpha = math.Approach(self.HpwRewrite.SpriteAlpha, 0, FrameTime() * self.HpwRewrite.SpriteTime) 
		else 
			return
		end

		if obj then
			local m = vm:GetBoneMatrix(obj)
			if m then
				pos = m:GetTranslation()

				if curskin and curskin.AdjustSpritePosition then
					pos = pos + curskin:AdjustSpritePosition(vm, m, curspell)
				end

				val = self.HpwRewrite.SpriteColor.a / 255

				self.HpwRewrite.SpriteColor.a = Lerp(FrameTime() * 16, self.HpwRewrite.SpriteColor.a, self.HpwRewrite.SpriteAlpha)

				render.SetMaterial(glow)
				local white = Color(255, 255, 255, self.HpwRewrite.SpriteColor.a)
				local sin = math.sin(CurTime() * 24) * 0.3

				for i = 1, 8 do 
					local size = (i * 3 * val + sin) * self.HpwRewrite.SpriteSize
					render.DrawSprite(pos, size, size, self.HpwRewrite.SpriteColor) 
					render.DrawSprite(pos, 7 * val * self.HpwRewrite.SpriteSize, 7 * val * self.HpwRewrite.SpriteSize, white)
				end 
			end
		end

		local dlight = DynamicLight(vm:EntIndex())
		if dlight then
			dlight.pos = pos + Vector(3, 0, 0) -- Moved a bit to solve light inside wand bug
			dlight.r = self.HpwRewrite.SpriteColor.r
			dlight.g = self.HpwRewrite.SpriteColor.g
			dlight.b = self.HpwRewrite.SpriteColor.b
			dlight.brightness = 2
			dlight.Decay = 1000
			dlight.Style = 5
			dlight.Size = 160 * val
			dlight.DieTime = CurTime() + 0.1
		end
	end

	-- Better than DrawWorldModel
	-- TODO: fix wand:DrawModel()

	--[[hook.Add("PostDrawOpaqueRenderables", "hpwrewrite_weapon_spritedrawing_handler", function()
		for k, v in pairs(ents.FindByClass(HpwRewrite.WandClass)) do
			if not v:GetNoDraw() then
				v:DrawModel()

				if IsValid(v.Owner) then
					v:DrawSpriteStuff(v)

					local curskin = HpwRewrite:GetPlayerSkin(v.Owner, v:GetWandCurrentSkin())
					if curskin then curskin:DrawWorldModel(v) end

					local curspell = HpwRewrite:GetPlayerSpell(v.Owner, v:GetWandCurrentSpell())
					if curspell then curspell:DrawWorldModel(v) end
				end
			end
		end
	end)]]

	-- TODO: Leave it empty
	function SWEP:DrawWorldModel()
		self:DrawModel()

		if IsValid(self.Owner) then
			self:DrawSpriteStuff(self)

			local curskin = HpwRewrite:GetPlayerSkin(self.Owner, self:GetWandCurrentSkin())
			if curskin then curskin:DrawWorldModel(self) end

			local curspell = HpwRewrite:GetPlayerSpell(self.Owner, self:GetWandCurrentSpell())
			if curspell then curspell:DrawWorldModel(self) end
		end
	end

	function SWEP:PostDrawViewModel(vm, wep, ply)
		local curskin = HpwRewrite:GetPlayerSkin(self.Owner, self:GetWandCurrentSkin())
		if curskin then curskin:PostDrawViewModel(self, vm) end

		local curspell = HpwRewrite:GetPlayerSpell(self.Owner, self:GetWandCurrentSpell())
		if curspell then curspell:PostDrawViewModel(self, vm) end

		cam.IgnoreZ(true)
			self:DrawSpriteStuff(vm)
		cam.IgnoreZ(false)
	end

	local spellbar = Material("vgui/hpwrewrite/spellbar")
	local leftBar = Material("vgui/hpwrewrite/leftbar")
	local leftBarEmpty = Material("vgui/hpwrewrite/leftbarempty")
	local gradient = Material("vgui/gradient_up")
	local centerGradient = Material("gui/center_gradient")
	local waitBeforeHide = 0

	local hintMenu = HpwRewrite.Language:GetWord("#menu_hint")
	local treeWord = HpwRewrite.Language:GetWord("#spelltreeword")
	local curSpellWord = HpwRewrite.Language:GetWord("#curspell")
	local quickBarHint = HpwRewrite.Language:GetWord("#quick_bar_hint")

	function SWEP:DrawHUD()
		if HpwRewrite.CVars.NoHud:GetBool() then return end

		-- Spells
		if HpwRewrite.CVars.DrawSpellBar:GetBool() then
			local x, y = self:FirstCellPos()

			for i = 1, 9 do
				local x = x + (i - 1) * cellSize
				local w, h = 64, 64
				local bind = HpwRewrite.BM.Binds[i]

				local spell, key

				if bind then
					spell = bind.Spell
					key = bind.Key
				end

				HpwRewrite:DrawSpellRect(spell, key, x, y, w, h)
			end
		end

		local xoffset = HpwRewrite.CVars.XOffset:GetInt()
		local yoffset = HpwRewrite.CVars.YOffset:GetInt()

		local x = ScrW() / 2 - 305 + xoffset
		local y = ScrH() - 62 + yoffset

		local mmorpg = HpwRewrite.CVars.MmorpgStyle:GetBool()

		-- Spellbar
		if HpwRewrite.CVars.DrawCurrentSpell:GetBool() then
			if mmorpg then
				surface.SetMaterial(spellbar)
				surface.SetDrawColor(Color(255, 255, 255, 255))
				surface.DrawTexturedRect(x - 3, y - 75, 616, 220)
			else
				draw.RoundedBox(0, x, y, 608, 70, Color(0, 0, 0, 150))
			end


			local spellName = self:GetWandCurrentSpell()
			if spellName == "" then spellName = "None" end

			local text = curSpellWord .. spellName
			draw.SimpleText(text, "HPW_font2", x + 17, y + 13, HpwRewrite.Colors.Black, TEXT_ALIGN_LEFT)
			draw.SimpleText(text, "HPW_font2", x + 16, y + 12, HpwRewrite.Colors.White, TEXT_ALIGN_LEFT)
		end

		if self.HpwRewrite.PrintHelp and HpwRewrite.CVars.DrawHint:GetBool() and not self.HpwRewrite.Select then
			draw.SimpleText(Format(hintMenu, HpwRewrite.BM.Keys[HpwRewrite.CVars.MenuKey:GetInt()] or "NONE"), "HPW_font3", x + 305, y - 108, Color(255, 255, 255, 150 + math.sin(CurTime() * 4) * 100), TEXT_ALIGN_CENTER)
		elseif self.HpwRewrite.Select then
			draw.SimpleText(treeWord .. HpwRewrite.BM.CurTree, "HPW_font3", x + 305, y - 108, Color(255, 255, 255, 150 + math.sin(CurTime() * 4) * 100), TEXT_ALIGN_CENTER)
		end

		if self.HpwRewrite.Select and HpwRewrite.CVars.DrawSelHint:GetBool() then
			draw.SimpleText(quickBarHint, "HPW_font3", ScrW() / 2, 64, Color(255, 255, 255, 200 + math.sin(CurTime() * 4) * 55), TEXT_ALIGN_CENTER)
		end

		-- Left side accuracy bar
		local accVal = self:GetHPWAccuracyValue()

		if waitBeforeHide and accVal > 0 then
			waitBeforeHide = nil
		elseif not waitBeforeHide then
			waitBeforeHide = CurTime() + 1.5
		end

		if accVal > 0 or (waitBeforeHide and CurTime() < waitBeforeHide) then
			local mainH = 147

			local length = math.floor(accVal * mainH)
			local w = ScrW()
			local h = ScrH()

			local colVal = accVal * 255

			if mmorpg then
				local x = x - 30
				local y = y - mainH / 2 + 1
				local color = Color(colVal, 255 - colVal, 0, 255 - colVal)

				surface.SetDrawColor(HpwRewrite.Colors.White)
				surface.SetMaterial(leftBar)
				surface.DrawTexturedRect(x, y, 30, mainH)

				draw.RoundedBox(0, x + 4, y + length + 10, 20, mainH - 16 - length, color)

				surface.SetMaterial(gradient)
				surface.DrawTexturedRect(x + 4, y + length + 5, 20, 6) 

				surface.SetDrawColor(HpwRewrite.Colors.White)
				surface.SetMaterial(leftBarEmpty)
				surface.DrawTexturedRect(x, y, 30, mainH)

				if accVal > 0.6 then
					surface.SetDrawColor(Color(255, 0, 0, 90 + math.sin(CurTime() * 16) * 80))
					surface.SetMaterial(centerGradient)
					surface.DrawTexturedRect(x, y, 30, mainH)
				end
			else
				local x = x - 24
				local y = y - mainH / 2 + 5
				local color = Color(colVal, 255 - colVal, 0, 255 - colVal)

				draw.RoundedBox(0, x, y, 20, mainH - 9, Color(0, 0, 0, 200))
				draw.RoundedBox(0, x, y + length, 20, mainH - 9 - length, color)

				if accVal > 0.6 then
					draw.RoundedBox(0, x, y, 20, mainH, Color(255, 0, 0, 90 + math.sin(CurTime() * 16) * 80))
				end
			end
		end
	end

	-- Wand net system is too big
	net.Receive("HpwRewriteSpriteSend", function(len)
		local stuff = tobool(net.ReadBit())
		local wep = net.ReadEntity()

		if not wep:IsValid() then return end
		if not wep.HpwRewrite then HpwRewrite:LogDebug("Wand table doesn't exist!") return end

		-- if the server knows that player used the same spell as before we won't receive anymore data (Saving a lot of bits)
		if stuff then
			wep.HpwRewrite.SpriteAlpha = 255
			return
		end

		-- Other data
		local r = net.ReadUInt(8)
		local g = net.ReadUInt(8)
		local b = net.ReadUInt(8)
		local time = net.ReadUInt(11)
		local size = net.ReadFloat()
		local name = net.ReadString()

		wep.HpwRewrite.SpriteAlpha = 255
		wep.HpwRewrite.SpriteColor = Color(r, g, b, (wep.HpwRewrite.SpriteColor.a))
		wep.HpwRewrite.SpriteTime = time
		wep.HpwRewrite.SpriteSize = size
		wep.HpwRewrite.LastAttackerSpellName = name
	end)
else
	util.AddNetworkString("HpwRewriteSpriteSend")
	
	--[[util.AddNetworkString("hpwrewrite_setup")

	net.Receive("hpwrewrite_setup", function(len, ply)
		if not HpwRewrite.CheckAdmin(ply) or not ply:IsSuperAdmin() then return end

		local val = tostring(net.ReadBit())
		if val != "0" and val != "1" then print("Wrong argument! Expected", "1/0", "Got", val) return end

		RunConsoleCommand("hpwrewrite_sv_nolearning", val)
		RunConsoleCommand("hpwrewrite_setup", "1")
	end)]]

	function SWEP:RequestSprite(name, col, time, size, forcedata)
		if self.HpwRewrite.BlockSprite then return end
		size = size or 1

		local noData = name == self.HpwRewrite.LastAttackerSpellName
		if forcedata then noData = false end

		net.Start("HpwRewriteSpriteSend")
			net.WriteBit(noData)
			net.WriteEntity(self)

			if not noData then
				net.WriteUInt(col.r, 8)
				net.WriteUInt(col.g, 8)
				net.WriteUInt(col.b, 8)
				net.WriteUInt(time, 11)
				net.WriteFloat(size)
				net.WriteString(name)
			end
		net.Broadcast()

		self.HpwRewrite.LastAttackerSpellName = name
	end

	function SWEP:UpdateClientsideSkin(ply)
		net.Start("hpwrewrite_vm_wm")
			net.WriteEntity(self)
			net.WriteString(self.ViewModel)
			net.WriteString(self.WorldModel)
		if IsValid(ply) then 
			net.Send(ply) 
		else 
			net.Broadcast() 
		end
	end

	function SWEP:HPWSetWandSkin(name)
		local wep = self.Owner:GetActiveWeapon()
		if wep != self then HpwRewrite:LogDebug(self.Owner:Name() .. "'s weapon isn't wand, cannot change skin!") return end

		local isDefSkin = false

		-- Skip checking and giving skin if name is DefaultSkin
		if name == HpwRewrite.DefaultSkin then 
			HpwRewrite:PlayerGiveSpell(self.Owner, HpwRewrite.DefaultSkin, nil, true)
			isDefSkin = true
		else
			if not HpwRewrite:CanUseSpell(self.Owner, name) then 
				if self:GetWandCurrentSkin() == name then self:HPWSetWandSkin(HpwRewrite.DefaultSkin) end
				return	
			end
		end

		local oldskin = self:GetWandCurrentSkin()
		local skin = HpwRewrite:GetPlayerSkin(self.Owner, name)
		if not skin then print(name .. " does not exist!") return end

		HpwRewrite:LogDebug(self.Owner:Name() .. " changing skin to " .. name)

		if not skin:PreSkinSelect(self) then 
			HpwRewrite:LogDebug(self.Owner:Name() .. " attempted to change his skin to " .. name)
			if not isDefSkin then return end
		end

		self:Holster(nil, true)
			self:SetHoldType(skin.HoldType)

			local vm = skin.ViewModel
			local wm = skin.WorldModel

			self.ViewModel = vm
			self.WorldModel = wm

			self.Owner:GetViewModel():SetWeaponModel(vm, self)
			self:SetWandCurrentSkin(name)

			self:UpdateClientsideSkin()
		self:Deploy(true)

		skin:OnSkinSelect(self)
		
		oldskin = HpwRewrite:GetPlayerSkin(self.Owner, oldskin)
		if oldskin then oldskin:OnSkinHolster(self) end

		self:CheckSpellUseable(self:GetWandCurrentSpell())

		-- Notifying those people who has problems with models from .gma
		-- It should help them
		if game.SinglePlayer() and not HpwRewrite.CVars.ErrorNotify:GetBool() and not util.IsValidModel(skin.ViewModel) then
			HpwRewrite:DoNotify(self.Owner, "Seems like the wand addon was not installed correctly! Try to deinstall and install it then restart the game several times.", 1, 14)
			RunConsoleCommand("hpwrewrite_sv_error_notify", "1")
		end

		return true
	end

	function SWEP:HPWSetCurrentSpell(name)
		local oldspellname = self:GetWandCurrentSpell()

		if not HpwRewrite:CanUseSpell(self.Owner, name) then
			if name == oldspellname then self:HPWRemoveCurSpell() end
			HpwRewrite:LogDebug(self.Owner:Name() .. " attempted to change his spell to " .. name)
			return
		end

		if name == oldspellname then return true end -- true

		local oldspell = HpwRewrite:GetPlayerSpell(self.Owner, oldspellname)
		local newspell = HpwRewrite:GetPlayerSpell(self.Owner, name)

		if not newspell:OnSelect(self) then 
			HpwRewrite:LogDebug(self.Owner:Name() .. " attempted to change his spell to " .. name)
			return 
		end

		self.Primary.Automatic = false
		if newspell.AutoFire then
			self.Primary.Automatic = true
		end

		if oldspell then oldspell:OnHolster(self) end

		self:SetWandCurrentSpell(name)
		HpwRewrite:LogDebug(self.Owner:Name() .. " changed spell to " .. name)

		return true
	end

	function SWEP:HPWRemoveCurSpell()
		local oldspell = HpwRewrite:GetPlayerSpell(self.Owner, self:GetWandCurrentSpell())
		if oldspell then oldspell:OnHolster(self) end

		self.Primary.Automatic = false
		self:SetWandCurrentSpell("")
	end

	function SWEP:HPWGetAimEntity(distance, mins, maxs)
		distance = distance or 1000

		local ply = self.Owner

		local tr
		local pos1 = ply:GetShootPos()
		local pos2 = ply:GetShootPos() + ply:GetAimVector() * distance

		if mins and maxs then
			tr = util.TraceHull({
				start = pos1,
				endpos = pos2,
				filter = ply,
				mins = mins,
				maxs = maxs
			})
		else
			tr = util.TraceLine({
				start = pos1,
				endpos = pos2,
				filter = ply
			})
		end

		if self.HoldingSelfCast then return ply, tr end
		return tr.Entity, tr
	end

	function SWEP:HPWDecreaseAccuracy(amount)
		-- 0 accuracy is the best one
		if not self.HpwRewrite.Accuracy then self.HpwRewrite.Accuracy = 0 end

		if not HpwRewrite.CVars.NoAccuracy:GetBool() then
			if self.GetHPWAccuracyPenalty then amount = amount * self:GetHPWAccuracyPenalty() end -- useless if

			self.HpwRewrite.Accuracy = math.Approach(self.HpwRewrite.Accuracy, 1, amount)
			self.HpwRewrite.CooldownAccuracy = CurTime() + 1.2
		end
	end

	function SWEP:ApplyAccuracyPenalty(vec)
		-- TODO: check if its quite optimized
		vec:Rotate(AngleRand() * (self.HpwRewrite.Accuracy or 0) * 0.06)
	end

	function SWEP:HPWSpawnSpell(curspell)
		local pos = self:GetSpellSpawnPosition()
		local dir = (self.Owner:GetEyeTrace().HitPos - pos):GetNormal()

		self:ApplyAccuracyPenalty(dir)

		local ent = ents.Create("entity_hpwand_flyingspell")
		ent:SetPos(pos)
		ent:SetAngles(dir:Angle())
		ent:SetFlyDirection(dir)
		ent:SetSpellData(curspell)
		ent:SetupOwner(self.Owner)
		ent:Spawn()

		curspell:OnSpellSpawned(self, ent)

		if curspell.CanSelfCast and self.HoldingSelfCast then
			local data = { }

			data.HitEntity = self.Owner
			data.HitPos = self.Owner:LocalToWorld(self.Owner:OBBCenter())
			data.Speed = 0
			data.HitNormal = Vector(0, 0, 0)

			ent:PhysicsCollide(data, ent:GetPhysicsObject())
		end

		self:HPWDecreaseAccuracy(curspell.AccuracyDecreaseVal)
		self.HoldingSelfCast = false
	end

	function SWEP:HPWDoSprite(curspell)
		local col = curspell.SpriteColor
		if col then
			local force = false
			if curspell.ForceSpriteSending then force = true end
			self:RequestSprite(curspell.Name, col, curspell.SpriteTime or 600, curspell.SpriteSize, force)
		end
	end

	function SWEP:HPWDoSpell(curspell)
		self:HPWSpawnSpell(curspell)
		self:HPWDoSprite(curspell)
	end

	function SWEP:AnimationSpeedTimer(speed, seconds)
		if speed <= 0 then return end

		self.HpwRewrite.AnimationSpeed = speed

		timer.Create("hpwrewrite_adnimation_" .. self:EntIndex(), seconds, 1, function()
			if IsValid(self) then self.HpwRewrite.AnimationSpeed = 1 end
		end)
	end

	function SWEP:CanContinue(curspell)
		return IsValid(self.Owner) and self == self.Owner:GetActiveWeapon() and curspell and HpwRewrite:CanUseSpell(self.Owner, curspell.Name)
	end

	function SWEP:AttackSpell(curspell)
		if curspell:OnFire(self) then 
			if curspell.UseClientsideOnFire then
				net.Start("hpwrewrite_ClientsidePrimaryAttack")
					net.WriteEntity(self)
					net.WriteUInt(curspell.UniqueID, 9) -- 2^9 = 512 will there be more than 512 spells?
				if curspell.ClientsideOnFireShouldBroadcast then
					net.Broadcast()
				else
					net.Send(self.Owner)
				end
			end

			if curspell.ApplyDelay then
				timer.Simple(self:HPWSeqDuration2() * curspell.ApplyDelay, function()
					if IsValid(self) and self:CanContinue(curspell) then self:HPWDoSpell(curspell) end
				end)
			else
				self:HPWDoSpell(curspell)
			end
		else
			self:HPWDoSprite(curspell)
			self:HPWDecreaseAccuracy(curspell.AccuracyDecreaseVal) -- for spells without entity
		end
	end

	-- TODO: add more sounds
	local sounds = {
		"hpwrewrite/wand/maincast.wav"
	}
	
	function SWEP:PlayCastSound()
		local name = table.Random(sounds) 
		local override = false

		local skin = HpwRewrite:GetPlayerSkin(self.Owner, self:GetWandCurrentSkin())
		if skin then 
			local cast

			cast, override = skin:GetCastSound(self)
			if override then return end

			if cast then name = cast end
		end

		self:EmitSound(name, 70, math.random(95, 105), 1, CHAN_WEAPON)
	end
end

function SWEP:SetupDataTables()
	self:NetworkVar("String", 0, "WandCurrentSpell")
	self:NetworkVar("String", 1, "WandCurrentSkin")
	self:NetworkVar("Float", 0, "WandNextIdle")
	self:NetworkVar("Float", 1, "HPWAccuracyValue") -- for clientside only
end

function SWEP:GetSpellSpawnPosition()
	local ang = self.Owner:EyeAngles()
	local pos = self.Owner:EyePos() + ang:Right() * 2 + ang:Forward() * 16

	if HpwRewrite.CVars.AlwaysCenter:GetBool() then
		pos = self.Owner:EyePos() + ang:Forward() * 10
	else
		local skin = HpwRewrite:GetPlayerSkin(self.Owner, self:GetWandCurrentSkin())
		if skin then
			pos = skin:GetSpellPosition(self, pos)
		end
	end

	return pos
end

function SWEP:CheckSpellUseable(name)
	if not HpwRewrite:CanUseSpell(self.Owner, name) then
		if SERVER then
			if self:GetWandCurrentSkin() == name then self:HPWSetWandSkin(HpwRewrite.DefaultSkin) end
			if self:GetWandCurrentSpell() == name then self:HPWRemoveCurSpell() end
		end

		return false
	end

	return true
end

function SWEP:HPWSeqDuration2()
	return self.HpwRewrite.SequenceDuration
end

function SWEP:HPWSendAnimation(act)
	self.HpwRewrite.SequenceDuration = 1 -- TODO: choose whether leave it or delete

	if not act then return end
	if not game.SinglePlayer() and not IsFirstTimePredicted() then return end

	local vm = self.Owner:GetViewModel()
	if not IsValid(vm) then return end

	local seq = vm:SelectWeightedSequence(act)
	if not seq or seq == -1 then return end

	vm:SendViewModelMatchingSequence(seq)

	local val = self.HpwRewrite.AnimationSpeed * HpwRewrite.CVars.AnimSpeed:GetFloat()
	
	vm:SetPlaybackRate(1 * val)
	self.HpwRewrite.SequenceDuration = vm:SequenceDuration(seq) / val

	self:SetWandNextIdle(CurTime() + self.HpwRewrite.SequenceDuration)
end

function SWEP:Initialize()
	if self.HpwRewrite then table.Empty(self.HpwRewrite) end

	self.HpwRewrite = { }
	self.HpwRewrite.SequenceDuration = 0
	self.HpwRewrite.AnimationSpeed = 1
	self.HpwRewrite.BlockSprite = false
	self.HpwRewrite.LastAttackerSpellName = nil

	if CLIENT then 
		self.HpwRewrite.PrintHelp = true 
		self.HpwRewrite.Select = false
		self.HpwRewrite.ShouldSetPos = false
		self.HpwRewrite.CurrentSpellPr = ""

		self.HpwRewrite.SpriteAlpha = 0
		self.HpwRewrite.SpriteTime = 1
		self.HpwRewrite.SpriteSize = 1
		self.HpwRewrite.SpriteColor = Color(0, 0, 0, 0)
		
		if LocalPlayer() == self.Owner then			
			if not HpwRewrite.CVars.DisableMsg:GetBool() and not HpwRewrite.MessagePrinted then
				HpwRewrite:DoNotify("You can disable magic wand hints in SpawnMenu > Options > Wand Settings > Client > Disable popup hints", 3, 13)
				
				timer.Simple(3, function()
					if not HpwRewrite.CVars.DisableMsg:GetBool() then
						HpwRewrite:DoNotify("Need help? Go to SpawnMenu > Options > Wand Settings > Online Help", 3, 18)
					end
				end)

				if HpwRewrite.CVars.NoLearning:GetBool() then
					if self.Owner:IsSuperAdmin() then
						timer.Simple(8, function()
							if not HpwRewrite.CVars.DisableMsg:GetBool() then
								HpwRewrite:DoNotify("You can enable learning in SpawnMenu > Options > Wand Settings > Server > Disable learning", 3, 14)
							end
						end)
					end
				else
					timer.Simple(7, function()
						if not HpwRewrite.CVars.DisableMsg:GetBool() then
							HpwRewrite:DoNotify("To get spells go to SpawnMenu > Entities > Harry Potter Spell Books and spawn books", 3, 17)
						end
					end)

					if self.Owner:IsSuperAdmin() then
						timer.Simple(14, function()
							if not HpwRewrite.CVars.DisableMsg:GetBool() then
								HpwRewrite:DoNotify("You can disable learning in SpawnMenu > Options > Wand Settings > Server > Disable learning", 3, 14)
							end
						end)
					end
				end

				HpwRewrite.MessagePrinted = true
			else
				HpwRewrite:LogDebug("Popup hints are disabled or already printed")
			end
		end
	else
		self.HpwRewrite.ShouldBlockMouse = false
		timer.Simple(0, function()
			if not IsValid(self) then return end
			if not IsValid(self.Owner) then return end
			self.HpwRewrite.ShouldBlockMouse = tobool(self.Owner:GetInfoNum("hpwrewrite_cl_blockleftmouse", 0))
		end)

		self.HpwRewrite.Accuracy = 0
		self.HpwRewrite.UpdateAccuracy = 0
		self.HpwRewrite.CooldownAccuracy = 0

		self:SetHPWAccuracyPenalty(1)
		self:SetHPWAccuracyValue(0)

		-- Annoying window to setup learning config
		-- Leave it under comment

		--[[local ply = self.Owner
		if HpwRewrite.CheckAdmin(ply) and ply:IsSuperAdmin() and not setup:GetBool() then
			net.Start("hpwrewrite_setup")
			net.Send(ply)

			RunConsoleCommand("hpwrewrite_setup", "1")
		end]]
	end
end

function SWEP:EmptySpellAttack()
	self.Owner:SetAnimation(PLAYER_ATTACK1)
	self:HPWSendAnimation(ACT_VM_PRIMARYATTACK)
	self:SetNextPrimaryFire(CurTime() + self:HPWSeqDuration2())

	if SERVER then
		self:RequestSprite("", ColorRand(), 500, 0.6, true)

		for i = 1, math.random(4, 8) do
			timer.Simple(math.Rand(0, 0.4), function()
				if IsValid(self) and IsValid(self.Owner) then
					sound.Play("ambient/energy/zap" .. math.random(1, 3) .. ".wav", self:GetPos(), 60, math.random(200, 255))
				end
			end)
		end

		local tr = util.TraceLine({
			start = self.Owner:GetShootPos(),
			endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * 256,
			filter = self.Owner
		})

		local ent = tr.Entity
		if IsValid(ent) and not (ent:IsNPC() or ent:IsPlayer()) then
			local phys = ent:GetPhysicsObject()
			if IsValid(phys) then
				phys:ApplyForceOffset(self.Owner:GetAimVector() * math.Clamp(phys:GetMass() * 100, 1, 700), tr.HitPos)
				ent:TakeDamage(5, self.Owner, self)
			end
		end
	end
end

function SWEP:OnRemove()
	timer.Remove("hpwrewrite_skinhelper" .. self:EntIndex())

	if IsValid(self.Owner) then
		local lastSpell = self:GetWandCurrentSpell() 
		if lastSpell != "" then self.Owner:SetPData("WeaponHpwrStick_LastSpell", lastSpell) end

		local lastSkin = self:GetWandCurrentSkin()
		if lastSkin != "" then self.Owner:SetPData("WeaponHpwrStick_LastSkin", lastSkin) end
	end 
end

function SWEP:Holster(wep, anim)
	self:OnRemove()

	if CLIENT then 
		self.HpwRewrite.Select = false 
	end

	local curspell = HpwRewrite:GetPlayerSpell(self.Owner, self:GetWandCurrentSpell())
	if curspell then curspell:OnWandHolster(self) end

	return true
end

function SWEP:Deploy(anim)
	if self.Owner:IsNPC() then print("Wand won't handle NPC owner! Removing...") self:Remove() return end
	if not self.Owner:IsPlayer() then print("Wand owner should be a player! Removing...") self:Remove() return end

	if not self.HpwRewrite then
		self.HpwRewrite = { }
		ErrorNoHalt("Wand's HpwRewrite table has been initialized in the Deploy function! Please, contact addon's developers\n")
	end

	self:HPWSendAnimation(ACT_VM_DRAW)
	self:SetNextPrimaryFire(CurTime() + self:HPWSeqDuration2())

	if SERVER then
		if not self.Owner.HpwRewrite then 
			self.Owner.HpwRewrite = { } 
			HpwRewrite:LogDebug(self.Owner:Name() .. " HpwRewrite namespace has been initialized in SWEP") 
			
			print("Your HpwRewrite table has been initialized in the Deploy function! Please, contact addon's developers")
		end
		
		if not anim then 
			-- TODO: do something to remove this timer
			-- Seems like gmod doesn't like doing it in the same frame as you deploy
			timer.Create("hpwrewrite_skinhelper" .. self:EntIndex(), FrameTime(), 1, function()
				if not IsValid(self) or not IsValid(self.Owner) then return end
				if not self.Owner:GetPData("WeaponHpwrStick_LastSkin") then 
					self.Owner:SetPData("WeaponHpwrStick_LastSkin", HpwRewrite.DefaultSkin)
				end

				self:HPWSetWandSkin(self.Owner:GetPData("WeaponHpwrStick_LastSkin")) 
			end)
		end

		local oldspell = self.Owner:GetPData("WeaponHpwrStick_LastSpell")
		if oldspell then 
			self:HPWSetCurrentSpell(oldspell) 
		end

		local curspell = HpwRewrite:GetPlayerSpell(self.Owner, self:GetWandCurrentSpell())
		if curspell then curspell:OnWandDeploy(self) end
	end

	return true
end

function SWEP:MakeSparks(col, lifetime)
	local ef = EffectData()
	ef:SetEntity(self.Owner)
	ef:SetStart(Vector(col.r, col.g, col.b))
	ef:SetScale(lifetime)
	util.Effect("EffectHpwRewriteSparks", ef, true, true)
end

function SWEP:PrimaryAttack(spellName)
	if self.Owner:InVehicle() and not self.Owner:GetAllowWeaponsInVehicle() then return end
	if self.HpwRewrite.ShouldBlockMouse and not spellName then return end

	if CurTime() < self:GetNextPrimaryFire() then return end
	if HpwRewrite.FM:GetValue(self.Owner) then return end

	-- Protection
	self:SetNextPrimaryFire(CurTime() + 1.5)

	-- Check if we have skin
	local skintab = HpwRewrite:GetPlayerSkin(self.Owner, self:GetWandCurrentSkin())
	if not skintab then
		if SERVER then self:HPWSetWandSkin(HpwRewrite.DefaultSkin) end
		return
	end

	-- Quick attack
	if SERVER and spellName then 
		if self:HPWSetCurrentSpell(spellName) then 
			if game.SinglePlayer() then self:CallOnClient("PrimaryAttack") end
		else
			HpwRewrite:LogDebug(self.Owner:Name() .. " attempted to use quick attack with " .. spellName)
			return 
		end
	end

	-- Making anims, checking if we can attack
	local curspell = self:GetWandCurrentSpell()
	local name = curspell
	if not self:CheckSpellUseable(name) then self:EmptySpellAttack() return end

	curspell = HpwRewrite:GetPlayerSpell(self.Owner, name)
	if not curspell then self:EmptySpellAttack() return end

	self.HpwRewrite.AnimationSpeed = curspell.AnimSpeedCoef or 1
	self.HoldingSelfCast = curspell.ShouldReverseSelfCast
	self.HpwRewrite.DidAnimations = false

	if curspell.PlayAnimation then
		self.Owner:SetAnimation(PLAYER_ATTACK1)

		local newAnim = curspell:GetAnimations(self)
		if newAnim then
			self:HPWSendAnimation(ACT_VM_PRIMARYATTACK) -- if theres no newAnim
			self:HPWSendAnimation(newAnim)
		else
			if skintab.ForceAnim then
				self:HPWSendAnimation(table.Random(skintab.ForceAnim))
			else
				self:HPWSendAnimation(ACT_VM_PRIMARYATTACK)
			end

			if curspell.ForceAnim then self:HPWSendAnimation(table.Random(curspell.ForceAnim)) end
		end

		if curspell.CanSelfCast then
			if HpwRewrite:IsHoldingSelfCast(self.Owner) then
				if SERVER then 
					timer.Create("hpwrewrite_timer_selfcastspr" .. self:EntIndex(), self:HPWSeqDuration2() * 0.7, 1, function()
						if IsValid(self) and self:CanContinue(curspell) then 
							self:HPWDoSprite(curspell) 
						end
					end)
				end

				self.HoldingSelfCast = not curspell.ShouldReverseSelfCast
			end

			if curspell.DoSelfCastAnim then 
				if HpwRewrite:IsHoldingSelfCast(self.Owner) then
					if not curspell.ShouldReverseSelfCast then
						self:HPWSendAnimation(ACT_VM_HITCENTER) 
					end
				else
					if curspell.ShouldReverseSelfCast then
						self:HPWSendAnimation(ACT_VM_HITCENTER) 
					end
				end
			end
		end
		
		self:SetNextPrimaryFire(CurTime() + self:HPWSeqDuration2())
		self.HpwRewrite.DidAnimations = true
	end

	if curspell.ForceDelay then self:SetNextPrimaryFire(CurTime() + curspell.ForceDelay) end

	-- Fire, fire, FIRE !!!
	if SERVER and not self.Owner.HpwRewrite.BlockSpelling then -- The second expression is for Mimblewimble and so on
		skintab:OnFire(self)

		if curspell:PreFire(self) then
			if curspell.DoSparks then
				self:MakeSparks(curspell.SpriteColor, curspell.SparksLifeTime or 0.4)
			end

			if curspell.ApplyFireDelay then
				timer.Simple(self:HPWSeqDuration2() * curspell.ApplyFireDelay, function()
					if IsValid(self) and self:CanContinue(curspell) then self:AttackSpell(curspell) end
				end)
			else
				self:AttackSpell(curspell)
			end

			if curspell.ShouldSay and not HpwRewrite.CVars.NoSay:GetBool() then
				self.Owner:Say((curspell.WhatToSay or name) .. "!")
			end
		end
	end

	self.HpwRewrite.AnimationSpeed = 1
	self.HpwRewrite.DidAnimations = false
end

function SWEP:Think()
	if not IsValid(self.Owner) then return end

	local idle = self:GetWandNextIdle()
	if idle > 0 and CurTime() > idle then
		self:HPWSendAnimation(ACT_VM_IDLE)
	end

	local curspell = HpwRewrite:GetPlayerSpell(self.Owner, self:GetWandCurrentSpell())
	if curspell then curspell:Think(self) end

	local curskin = HpwRewrite:GetPlayerSkin(self.Owner, self:GetWandCurrentSkin())
	if curskin then curskin:Think(self) end

	if SERVER then
		if self.HpwRewrite.Accuracy and self.HpwRewrite.CooldownAccuracy then
			if CurTime() > self.HpwRewrite.CooldownAccuracy then
				self.HpwRewrite.Accuracy = math.Approach(self.HpwRewrite.Accuracy, 0, FrameTime() * 0.35)
			end

			if not self.HpwRewrite.UpdateAccuracy then self.HpwRewrite.UpdateAccuracy = 0 end

			if CurTime() > self.HpwRewrite.UpdateAccuracy then
				self:SetHPWAccuracyValue(self.HpwRewrite.Accuracy)
				self.HpwRewrite.UpdateAccuracy = CurTime() + 0.1
			end
		end
	end

	-- Selecting
	if CLIENT and LocalPlayer() == self.Owner then
		if HpwRewrite.FM:GetValue() then return end

		-- Selecting spell by mouse and context menu
		if vgui.CursorVisible() and self.HpwRewrite.Select and not HpwRewrite.CVars.NoChoosing:GetBool() and HpwRewrite.CVars.DrawSpellBar:GetBool() and not HpwRewrite.CVars.NoHud:GetBool() then
			local bind = HpwRewrite.BM.Binds[self:CalculateCellOffset()]

			if self.HpwRewrite.ShouldSetPos then
				local spell
				for k, v in pairs(HpwRewrite.BM.Binds) do
					if v.Spell == self:GetWandCurrentSpell() then
						spell = k
						break
					end
				end

				if spell then
					local x, y = self:GetCellPosition(spell)
					input.SetCursorPos(x, y)
				end

				self.HpwRewrite.ShouldSetPos = false
			end

			if bind and bind.Spell != self.HpwRewrite.CurrentSpellPr then
				HpwRewrite:RequestSpell(bind.Spell)
				self.HpwRewrite.CurrentSpellPr = bind.Spell
			end
		end

		-- Main menu
		if not vgui.CursorVisible() then
			if not self.HpwRewrite.WasMenuKeyPressed then self.HpwRewrite.WasMenuKeyPressed = false end

			local key = HpwRewrite.CVars.MenuKey:GetInt()
			local oldpressed = self.HpwRewrite.WasMenuKeyPressed
			self.HpwRewrite.WasMenuKeyPressed = key >= 107 and input.IsMouseDown(key) or input.IsKeyDown(key)

			if oldpressed != self.HpwRewrite.WasMenuKeyPressed and self.HpwRewrite.WasMenuKeyPressed then
				if self:GetWandCurrentSkin() == "" then
					HpwRewrite:RequestSpell(HpwRewrite.DefaultSkin)
				end

				HpwRewrite.VGUI:OpenNewSpellManager()
				if self.HpwRewrite.PrintHelp then self.HpwRewrite.PrintHelp = false end
			end
		end
	end

	if self.OldOwner != nil and self.OldOwner != self.Owner then
		self:Initialize()
	end

	self.OldOwner = self.Owner

	self:NextThink(CurTime())
	return true
end

function SWEP:SecondaryAttack()
end