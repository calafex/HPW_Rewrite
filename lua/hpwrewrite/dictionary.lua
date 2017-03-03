HpwRewrite.Language = HpwRewrite.Language or { }
HpwRewrite.Language.Languages = HpwRewrite.Language.Languages or { }

HpwRewrite.Language.CurrentLanguage = "en"

local cvar = GetConVar("gmod_language")
if cvar then
	if HpwRewrite.Languages[string.lower(cvar:GetString())] then
		HpwRewrite.Language.CurrentLanguage = string.lower(cvar:GetString())
	end
else
	print("[Wand] Can't find 'gmod_language' variable!")
end

local customlang = HpwRewrite.CVars.Language
if customlang then
	local val = customlang:GetString()
	if val != customlang:GetDefault() then
		HpwRewrite.Language.CurrentLanguage = string.lower(val)
	end
end

print("[Wand] Loaded " .. HpwRewrite.Language.CurrentLanguage .. " language!")

function HpwRewrite.Language:AddLanguage(codename, name)
	if self.Languages[codename] then return end

	self.Languages[codename] = { }
	self.Languages[codename].Name = name
	self.Languages[codename].Dictonary = { }

	print("[Wand] Added " .. name .. " language")
end

function HpwRewrite.Language:AddWord(lCodeName, index, word)
	local lang = self.Languages[lCodeName] 
	if not lang then print("[Wand] Language " .. lCodeName .. " not found!") return end

	lang.Dictonary[index] = word
end

function HpwRewrite.Language:GetWord(index, lCodeName)
	lCodeName = lCodeName or self.CurrentLanguage
	local lang = self.Languages[lCodeName]
	if not lang then print("[Wand] Language " .. lCodeName .. " not found!") return end

	local word = lang.Dictonary[index]

	if not word then 
		lang = self.Languages["en"] -- Default one

		if lang then
			word = lang.Dictonary[index]

			if not word then
				print("[Wand] Word " .. index .. " not found!") 
				return index
			end

			return word
		end
	end

	return word
end

HpwRewrite:IncludeFolder("hpwrewrite/language", true)
