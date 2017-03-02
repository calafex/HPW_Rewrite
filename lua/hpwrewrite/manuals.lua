if SERVER then return end
if not HpwRewrite then return end

HpwRewrite.Manuals = HpwRewrite.Manuals or { }
HpwRewrite.Manuals.FAQ = HpwRewrite.Manuals.FAQ or { }

local function AddQA(question, answer)
	table.insert(HpwRewrite.Manuals.FAQ, { Q = question, A = answer })
end

AddQA("I don't have any spell. What's going on?", "In Magic Wand Rewrite spell has to be learned before\nyou use it")
AddQA("I don't want to learn spells, I want to get fun!", "Check Disable learning in\nSpawnMenu > Options > Wand Settings > Server or here in Server settings")
AddQA("I can't find an answer to my question. What now?", "Go to SpawnMenu > Options > Wand Settings > Online help\nand click Online help or click Q.A. thread above, we will answer")
AddQA("How can I cast spells on myself?", "Hold your self cast key and press attack. Self cast key is [Backspace] by default")
AddQA("Backspace key for selfcasting makes selfcasting pain in ass for me!", "Change it in Client settings here. I recommend using Mouse 4 or Mouse 5, \nhowever, you can change it to whatever you want")
AddQA("Where is Bugs thread?", "Go to SpawnMenu > Options > Wand Settings > Online help\nand click Having issue? Let us know or click Bugs thread above")
AddQA("Well, I have to learn spells. Where can I get those\nspells?", "In SpawnMenu > Entities > Harry Potter Spell Books, also you can\nget skins in SpawnMenu > Entities > Harry Potter Skins")
AddQA("Why you made that learning stuff?", "A lot of people asked us to make learning. Learning\nis for servers, in singleplayer you can disable it")
AddQA("These icons in spellbar are terrible and they're\nannoying! Is it possible to disable them?", "Uncheck Draw icons in\nSpawnMenu > Options > Wand Settings > Client")
AddQA("What is that mysterious bar left side from spellbar?", "That bar shows your accuracy, each time you shoot a spell it decrases.\nServer owner can disable accuracy decreasing from options menu")
AddQA("Models are ERRORS!", "Reinstall addon and restart GMod properly")
AddQA("What does 'Update spells' button do?", "When you click it, it will erase all spell data\nfor current session and will load spells from your data file\nthat contains in server data folder")
AddQA("I don't want to see that annoying spellbar and HUD!", "Disable its drawing in\nSpawnMenu > Options > Wand Settings > Client")
AddQA("I connected to a server and some of my spells wouldn't appear!", "Try to reupdate your spells by 'Update my spells info'\nbutton in Help stuff tab here")
AddQA("What is AdminOnly and Blacklist?", "AdminOnly means that non admin users won't be\nable to spawn your spell books and skins\n\nBlacklist means that every player won't be able\nto use spell / skin but able to learn it")
AddQA("I don't want people to say spells into chat. What to do?", "Check No chat spell saying in\nSpawnMenu > Options > Wand Settings > Server")
AddQA("What is default skin?", "Default skin is a special skin that will be given if player has not any skin\nor if something went wrong. Default skin cannot be restricted so be careful when\nyou change it")
AddQA("What is 'Your learning progress'?", "It's a percent of your learned spells")
AddQA("I know Lua and I want to make a spell. What to do?", "Read API Documentation and go ahead. You can find it in help stuff")

--AddQA("Where is Favourite spells like in old wand addon?", "Favourite spells replaced with custom RPG styled spellbar and binds.\nTo bind something go to Binding tab, choose tree or create new one, click 'Create bind',\nenter spell, click 'Enter' and press any key you want to bind spell to")

function HpwRewrite.Manuals.PrintFAQ()
	for k, v in pairs(HpwRewrite.Manuals.FAQ) do
		MsgC(HpwRewrite.Colors.Blue, "Q:")
		local question = string.Explode("\n", v.Q)
		for _, str in pairs(question) do
			MsgC(HpwRewrite.Colors.White, "  " .. str .. "\n")
		end

		MsgC(HpwRewrite.Colors.Blue, "A:")
		local answer = string.Explode("\n", v.A)
		for _, str in pairs(answer) do
			MsgC(HpwRewrite.Colors.White, "  " .. str .. "\n")
		end

		MsgC(HpwRewrite.Colors.Blue, string.rep(".", 60) .. "\n")
	end
end


HpwRewrite.Manuals.License = [[
The MIT License (MIT)

Copyright (c) 2017 G-P.R.O Team

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"),
to deal in the Software without restriction, including without
limitation the rights to use, copy, modify, merge, publish, distribute,
sublicense, and/or sell copies of the Software, and to permit persons
to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES
OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE
OR OTHER DEALINGS IN THE SOFTWARE.
]]

HpwRewrite.Manuals.KnownBugs = {
	"Animations are not stable when in multiplayer. Can't be fixed due to Source Engine",
	"In DarkRP gamemode throwing damage doesnt work because of DarkRP's spawn protection",
	"Autofire animations in multiplayer look strange"
}

HpwRewrite.Manuals.Contributors = {
	["ProfessorBear"] = "http://steamcommunity.com/profiles/76561198073333911",
	["calafex"] = "http://steamcommunity.com/profiles/76561198076062109/",
	["EgrOnWire"] = "https://steamcommunity.com/profiles/76561198060367130",
	["battlefield 4 russian"] = "http://steamcommunity.com/profiles/76561197980596537/",
	["CrishNate"] = "http://steamcommunity.com/profiles/76561198039998355/"
}




