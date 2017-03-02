local Spell = { }
Spell.LearnTime = 240
Spell.ApplyFireDelay = 0.4
Spell.Description = [[
	Creates an useless copy of
	the object you're looking at.
]]

Spell.AccuracyDecreaseVal = 0.2
Spell.NodeOffset = Vector(-1410, -32, 0)
Spell.CanSelfCast = false

function Spell:OnFire(wand)
	local ent = wand:HPWGetAimEntity(300, Vector(-2, -2, -2), Vector(2, 2, 2))

	if IsValid(ent) and not ent:IsNPC() and not ent:IsPlayer() then 
		local phys = ent:GetPhysicsObject()
		if not phys:IsValid() then return end
		if ent:GetModelRadius() > 200 then return end

		local class = "prop_physics"
		if ent:GetClass() == "prop_ragdoll" then class = "prop_ragdoll" end

		local copy = ents.Create(class)
		copy:SetModel(ent:GetModel())
		copy:SetSkin(ent:GetSkin())
		copy:SetPos(ent:GetPos())
		copy:SetAngles(ent:GetAngles())
		copy:SetMaterial(ent:GetMaterial())
		copy:SetModelScale(ent:GetModelScale(), 0)
		copy:SetColor(ent:GetColor())
		copy:Spawn()

		if class == "prop_ragdoll" then
			for i = 1, ent:GetPhysicsObjectCount() - 1 do
				local copyBone = copy:GetPhysicsObjectNum(i)
				local entBone = ent:GetBoneMatrix(ent:TranslatePhysBoneToBone(i))

				if entBone and copyBone then
					copyBone:SetAngles(entBone:GetAngles())
				end
			end
		end

		local vec = VectorRand() * 20

		phys:ApplyForceCenter(vec)

		phys = copy:GetPhysicsObject()
		if not phys:IsValid() then SafeRemoveEntity(copy) return end
		phys:ApplyForceCenter(-vec)

		undo.Create("Geminio")
			undo.SetPlayer(self.Owner)
			undo.AddEntity(copy)
		undo.Finish()
	end
end

HpwRewrite:AddSpell("Geminio", Spell)