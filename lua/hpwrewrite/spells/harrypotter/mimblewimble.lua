local Spell = { }
Spell.LearnTime = 120
Spell.Category = HpwRewrite.CategoryNames.Fight
Spell.Description = [[
	Prevents your opponent from 
	casting spells for 10 
	seconds and mutes them.
]]

Spell.ApplyDelay = 0.4
Spell.FlyEffect = "hpw_reducto_main" -- TODO: replace
Spell.ForceAnim = { ACT_VM_PRIMARYATTACK_5 }
Spell.SpriteColor = Color(0, 200, 255)
Spell.LeaveParticles = true
Spell.AccuracyDecreaseVal = 0.1

Spell.NodeOffset = Vector(1103, -212, 0)

function Spell:OnSpellSpawned(wand, spell)
	wand:PlayCastSound()
end

local mat = Material("hpwrewrite/sprites/magicsprite")

function Spell:Draw(spell)
	local dlight = DynamicLight(spell:EntIndex())
	if dlight then
		dlight.pos = spell:GetPos()
		dlight.r = 0
		dlight.g = 200
		dlight.b = 255
		dlight.brightness = 3
		dlight.Decay = 1000
		dlight.Size = 128
		dlight.DieTime = CurTime() + 1
	end

	render.SetMaterial(mat)
	render.DrawSprite(spell:GetPos(), 64, 64, self.SpriteColor)
	render.DrawSprite(spell:GetPos(), 128, 50, self.SpriteColor)	
end

function Spell:OnFire(wand)
	return true
end

function Spell:OnCollide(spell, data)
	local ent = data.HitEntity
	if IsValid(ent) and ent:IsPlayer() then
		local name = "hpwrewrite_mimblewimble_handler" .. ent:EntIndex()

		if not timer.Exists(name) then
			HpwRewrite:BlockSpelling(ent, true)

			ent:EmitSound("hpwrewrite/spells/zipper.wav", 64)

			hook.Add("PlayerSay", name, function(ply, txt)
				if ply == ent then return "" end
			end)

			hook.Add("PlayerCanHearPlayersVoice", name, function(a, ply)
				if ply == ent then return false end
			end)

			timer.Create(name, 10, 1, function()
				if IsValid(ent) then 
					HpwRewrite:BlockSpelling(ent, false) 
				end
				
				hook.Remove("PlayerSay", name)
				hook.Remove("PlayerCanHearPlayersVoice", name)
			end)
		end
	end
end

HpwRewrite:AddSpell("Mimblewimble", Spell)