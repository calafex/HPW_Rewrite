if SERVER then return end

-- Clientside attack
net.Receive("hpwrewrite_ClientsidePrimaryAttack", function()
	local wand = net.ReadEntity()
	local spellId = net.ReadUInt(9)
	if not HpwRewrite.IsValidWand(wand) then return end

	for k, v in pairs(HpwRewrite:GetLearnedSpells()) do
		if v.UniqueID == spellId then
			v:OnFire(wand)
			break
		end
	end
end)

-- Receiving new models
net.Receive("hpwrewrite_vm_wm", function()
	local wand = net.ReadEntity()
	local vm_mdl = net.ReadString()
	local wm_mdl = net.ReadString()
	
	if IsValid(wand) then
		wand.ViewModel = vm_mdl 
		wand.WorldModel = wm_mdl
	end
end)

net.Receive("hpwrewrite_DefSkin", function()
	HpwRewrite.DefaultSkin = net.ReadString()
end)

net.Receive("hpwrewrite_nfy", function()
	local msg = net.ReadString()
	local ntype = net.ReadInt(6)
	local time = net.ReadInt(16)

	HpwRewrite:DoNotify(msg, ntype, time)
end)

net.Receive("hpwrewrite_Snd", function()
	surface.PlaySound(net.ReadString())
end)

-- Receive blacklist
net.Receive("hpwrewrite_clBlack", function()
	local name = net.ReadString()
	local val = net.ReadBit()

	HpwRewrite.Blacklist[name] = tobool(val)
	HpwRewrite.VGUI.ShouldUpdate = true
end)

-- Receive adminonly
net.Receive("hpwrewrite_clAdm", function()
	local name = net.ReadString()
	local val = net.ReadBit()

	HpwRewrite.AdminOnly[name] = tobool(val)
end)



-- Learnable spell add
net.Receive("hpwrewrite_SplA", function()
	local id = net.ReadUInt(9)
	local spell = HpwRewrite:GetSpellById(id)
	if not spell then return end

	local name = spell.Name

	HpwRewrite:GetLearnableSpells()[name] = spell.New(LocalPlayer())
	HpwRewrite.VGUI.ShouldUpdate = true
end)

-- Learnable spell remove
net.Receive("hpwrewrite_SplR", function()
	local id = net.ReadUInt(9)
	local spell = HpwRewrite:GetSpellById(id)
	if not spell then return end

	local name = spell.Name

	HpwRewrite:GetLearnableSpells()[name] = nil
	HpwRewrite.VGUI.ShouldUpdate = true
end)

-- Spell add
net.Receive("hpwrewrite_SpA", function()
	local id = net.ReadUInt(9)
	local spell = HpwRewrite:GetSpellById(id)
	if not spell then return end

	local name = spell.Name

	if HpwRewrite:PlayerHasSpell(nil, name) then return end

	if not spell.IsSkin and spell.ShouldCount then
		if not HpwRewrite.PlyNumOfSpells then HpwRewrite.PlyNumOfSpells = 0 end
		HpwRewrite.PlyNumOfSpells = HpwRewrite.PlyNumOfSpells + 1
	end

	if HpwRewrite:PlayerHasLearnableSpell(nil, name) then -- If true, get the spell from learnables
		spell = HpwRewrite:GetLearnableSpells()[name] -- Getting from learnables

		HpwRewrite:GetLearnedSpells()[name] = spell -- Swapping
		HpwRewrite:GetLearnableSpells()[name] = nil
	else
		HpwRewrite:GetLearnedSpells()[name] = spell.New(LocalPlayer()) -- New instance
	end

	HpwRewrite:GetLearnedSpells()[name]:OnSpellGiven(LocalPlayer())

	HpwRewrite.VGUI.ShouldUpdate = true
end)

-- Spell remove
net.Receive("hpwrewrite_SpR", function()
	local id = net.ReadUInt(9)
	local spell = HpwRewrite:GetSpellById(id)
	if not spell then return end

	local name = spell.Name

	if not HpwRewrite:PlayerHasSpell(nil, name) then return end

	if not spell.IsSkin and spell.ShouldCount then
		if not HpwRewrite.PlyNumOfSpells then HpwRewrite.PlyNumOfSpells = 0 end
		HpwRewrite.PlyNumOfSpells = HpwRewrite.PlyNumOfSpells - 1
	end

	HpwRewrite:GetLearnedSpells()[name]:OnSpellRemoved(LocalPlayer())
	HpwRewrite:GetLearnedSpells()[name] = nil

	HpwRewrite.VGUI.ShouldUpdate = true
end)

-- Spell tables empty
net.Receive("hpwrewrite_SpCl", function()
	table.Empty(HpwRewrite:GetLearnedSpells())
	table.Empty(HpwRewrite:GetLearnableSpells())
	HpwRewrite.PlyNumOfSpells = 0
	
	HpwRewrite.VGUI.ShouldUpdate = true
end)

-- Start spell learning
net.Receive("hpwrewrite_Lrn", function()
	local id = net.ReadUInt(9)
	local spell = HpwRewrite:GetSpellById(id)
	if not spell then return end

	local name = spell.Name

	if HpwRewrite:PlayerHasLearnableSpell(nil, name) then
		HpwRewrite.LearningSpell = HpwRewrite:GetLearnableSpells()[name]
	else
		-- This piece of code should never be used
		local new = spell.New(LocalPlayer())

		HpwRewrite.LearningSpell = new
		HpwRewrite:GetLearnableSpells()[name] = new
	end

	HpwRewrite.LearningSpell:OnStartLearn(LocalPlayer())
	
	HpwRewrite.LearningSpellName = name
	HpwRewrite.Learning = true
end)

-- Stop spell learning
net.Receive("hpwrewrite_LrnS", function()
	local didWeLearn = tobool(net.ReadBit())

	if HpwRewrite.LearningSpell then
		if didWeLearn then
			HpwRewrite.LearningSpell:OnPostLearn(LocalPlayer())
		else
			HpwRewrite.LearningSpell:OnStopLearn(LocalPlayer())
		end
	end

	HpwRewrite.LearningSpell = nil
	HpwRewrite.LearningSpellName = nil
	HpwRewrite.Learning = false
end)



-- Got secret spell
net.Receive("hpwrewrite_Congrats", function()
	local snd = CreateSound(LocalPlayer(), "dimension/screamshorror.wav")
	snd:Play()
	snd:ChangePitch(110, 0)

	timer.Create("hpwrewrite_stopcongrats", 12, 1, function()
		snd:ChangeVolume(0, 6)
	end)
end)

-- Learned everything
net.Receive("hpwrewrite_Congrats2", function()
	local ent = ClientsideModel("models/dav0r/hoverball.mdl")
	ent:SetPos(LocalPlayer():EyePos() + Vector(0, 0, 40))
	ent:Spawn()
	ent:SetColor(Color(0, 0, 0, 0))
	ent:SetRenderMode(RENDERMODE_TRANSALPHA)

	hook.Add("Think", "hpwrewrite_congrats1_follow", function()
		if IsValid(ent) then ent:SetPos(LocalPlayer():EyePos() + Vector(0, 0, 40)) end
	end)

	ParticleEffectAttach("hpw_congratsup", PATTACH_POINT_FOLLOW, ent, 0)

	local snd = CreateSound(LocalPlayer(), "music/hl2_song10.mp3")
	snd:Play()

	timer.Create("hpwrewrite_stopcongrats1", 12, 1, function()
		snd:ChangeVolume(0, 6)
		SafeRemoveEntity(ent)
		hook.Remove("Think", "hpwrewrite_congrats1_follow")
	end)

	HpwRewrite:DoNotify("Our congratulations! You just learned all spells!", 0, 8)
end)


