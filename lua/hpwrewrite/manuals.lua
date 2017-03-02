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
	Copyright 2016 ProfessorBear

	Licensed under the Apache License, Version 2.0 (the "License");
	you may not use this file except in compliance with the License.
	You may obtain a copy of the License at

		http://www.apache.org/licenses/LICENSE-2.0

	Unless required by applicable law or agreed to in writing, software
	distributed under the License is distributed on an "AS IS" BASIS,
	WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
	See the License for the specific language governing permissions and
	limitations under the License.
]]

HpwRewrite.Manuals.KnownBugs = {
	"Animations are not stable when in multiplayer. Can't be fixed due to Source Engine"
}

HpwRewrite.Manuals.Contributors = {
	["ProfessorBear"] = "https://github.com/ProfessorBear",
	["calafex"] = "http://steamcommunity.com/profiles/76561198076062109/",
	["EgrOnWire"] = "https://steamcommunity.com/profiles/76561198060367130",
	["battlefield 4 russian"] = "http://steamcommunity.com/profiles/76561197980596537/",
	["CrishNate"] = "http://steamcommunity.com/profiles/76561198039998355/"
}




