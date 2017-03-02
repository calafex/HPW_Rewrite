local Spell = { }
Spell.LearnTime = 360
Spell.ApplyFireDelay = 0.4
Spell.Category = HpwRewrite.CategoryNames.Healing
Spell.OnlyIfLearned = { "Episkey" }

Spell.Description = [[
	For maximum effect of the 
	spell, the incantation had 
	to be repeated thrice; 
	firstly slowing the flow 
	of blood to prevent death by 
	exsanguination; the second 
	to clear residue and begin 
	to heal the wounds; and the 
	third to fully knit the 
	wounds, although dittany 
	had to be applied to prevent 
	scarring.

	This is counter-spell to
	Sectumsempra - twice casted
	it will stop bleeding.

	Hold self-cast key to heal
	yourself.
]]

Spell.NodeOffset = Vector(-624, 446, 0)
Spell.AccuracyDecreaseVal = 0.2

if SERVER then
	util.AddNetworkString("hpwrewrite_VulneraSD")
else
	-- It seems like RemoveAllDecals does nothing on serverside
	net.Receive("hpwrewrite_VulneraSD", function()
		local ply = net.ReadEntity()
		if ply:IsValid() then ply:RemoveAllDecals() end
	end)
end

function Spell:OnFire(wand)
	local ent = wand:HPWGetAimEntity(300)

	if IsValid(ent) and (ent:IsPlayer() or ent:IsNPC()) then
		if not self.Victims[ent] then self.Victims[ent] = 0 end

		self.Victims[ent] = self.Victims[ent] + 1
		if self.Victims[ent] > 3 then self.Victims[ent] = 1 end

		local name = "hpwrewrite_vulnerasanentur_handler" .. ent:EntIndex()

		if self.Victims[ent] == 1 then
			timer.Create(name, 0.4, 10, function()
				if ent:IsValid() then ent:SetHealth(math.min(ent:GetMaxHealth(), ent:Health() + 1)) end
			end)
		elseif self.Victims[ent] == 2 then
			-- Counter shit to sectumsempra
			hook.Remove("Think", "hpwrewrite_sectum_handler" .. ent:EntIndex())

			timer.Create(name, 0.3, 10, function()
				if ent:IsValid() then
					ent:SetHealth(math.min(ent:GetMaxHealth(), ent:Health() + 2))

					net.Start("hpwrewrite_VulneraSD")
						net.WriteEntity(ent)
					net.Broadcast()
				end
			end)
		elseif self.Victims[ent] == 3 then
			timer.Remove(name)
			ent:SetHealth(ent:GetMaxHealth())

			net.Start("hpwrewrite_VulneraSD")
				net.WriteEntity(ent)
			net.Broadcast()
		end

		timer.Create("hpwrewrite_vulnerasanentur_handler2" .. ent:EntIndex(), 2, 1, function()
			self.Victims[ent] = 0
		end)
	end

	sound.Play("npc/antlion/idle3.wav", wand:GetPos(), 55, math.random(240, 255))
end

function Spell:OnSpellGiven(ply)
	if SERVER then self.Victims = { } end
	return true
end

HpwRewrite:AddSpell("Vulnera Sanentur", Spell)