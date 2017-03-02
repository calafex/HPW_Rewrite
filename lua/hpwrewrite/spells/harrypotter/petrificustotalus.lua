local Spell = { }
Spell.LearnTime = 360
Spell.Description = [[
	A curse that paralyses the 
	opponent. It is often used 
	by inexperienced or young 
	wizards in duelling.
]]

Spell.FlyEffect = "hpw_sectumsemp_main"
Spell.ImpactEffect = "hpw_white_impact"
Spell.ApplyDelay = 0.5
Spell.AccuracyDecreaseVal = 0.3
Spell.ForceAnim = { ACT_VM_PRIMARYATTACK_5 }
Spell.SpriteColor = Color(255, 255, 255)
Spell.DoSparks = true

Spell.OnlyIfLearned = { "Everte Statum" }
Spell.NodeOffset = Vector(414, 90, 0)


local mat = Material("hpwrewrite/sprites/magicsprite")
function Spell:Draw(spell)
	local dlight = DynamicLight(spell:EntIndex())
	if dlight then
		dlight.pos = spell:GetPos()
		dlight.r = 255
		dlight.g = 255
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

function Spell:OnSpellSpawned(wand, spell)
	wand:PlayCastSound()
end

function Spell:OnFire(wand)
	return true
end

function Spell:AfterCollide(spell, data)
	local ent = data.HitEntity

	local rag, func, name = HpwRewrite:ThrowEntity(ent, spell:GetFlyDirection() + vector_up, 700, 20, self.Owner)

	timer.Simple(FrameTime() * 16, function() -- Gmod doesn't like creating constraints in physcallback
		if IsValid(rag) then
			local bones = rag:GetPhysicsObjectCount()
			if bones < 2 then return end

			for i = 1, bones - 1 do
				constraint.Weld(rag, rag, 0, i, 0)

				local ef = EffectData()
				ef:SetOrigin(rag:GetPhysicsObjectNum(i):GetPos())
				ef:SetScale(1)
				ef:SetMagnitude(1)
				util.Effect("GlassImpact", ef, true, true)
			end
		end
	end)
end

HpwRewrite:AddSpell("Petrificus Totalus", Spell)