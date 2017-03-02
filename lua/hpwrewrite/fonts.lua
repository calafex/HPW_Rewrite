if SERVER then 
	resource.AddFile("resource/fonts/harrypotter.ttf")
	resource.AddFile("resource/fonts/tahoma.otf")
	resource.AddFile("resource/fonts/gnuolane.ttf")
	resource.AddFile("resource/fonts/gothic.ttf")
	resource.AddFile("resource/fonts/gregorian.ttf")

	return 
end

if not HpwRewrite then return end

function HpwRewrite:LoadFonts()
	local fontCVar = self.CVars.FontName:GetString()
	local fontname = "Harry P"
	if fontCVar then fontname = fontCVar end

	surface.CreateFont("HPW_GnuolaneDefault", { font = "Gnuolane Rg", size = 100, weight = 0 })
	surface.CreateFont("HPW_GnuolaneDefaultsmall", { font = "Gnuolane Rg", size = 50, weight = 0 })

	-- Interface
	surface.CreateFont("HPW_fontSpells", { font = fontname, size = 30, weight = 0 })
	surface.CreateFont("HPW_fontSpells1", { font = fontname, size = 22, weight = 0 })
	surface.CreateFont("HPW_fontSpells2", { font = fontname, size = 18, weight = 0 })
	surface.CreateFont("HPW_fontSpells3", { font = fontname, size = 80, weight = 0 }) -- For spell tree

	-- Interface
	surface.CreateFont("HPW_font1", { font = fontname, size = 16, weight = 0 })
	surface.CreateFont("HPW_font2", { font = fontname, size = 42, weight = 0 })
	surface.CreateFont("HPW_font3", { font = fontname, size = 28, weight = 0 })

	-- Boxes
	surface.CreateFont("HPW_fontbig", { font = fontname, size = 100, weight = 0 })

	-- GUI
	local vguiFont = "Tahoma"
	surface.CreateFont("HPW_gui1", { font = vguiFont, size = 16, weight = 0 })
	surface.CreateFont("HPW_gui2", { font = vguiFont, size = 30, weight = 0 })
	surface.CreateFont("HPW_gui3", { font = vguiFont, size = 19, weight = 0 })
	surface.CreateFont("HPW_guismall", { font = vguiFont, size = 12, weight = 0 })

	surface.CreateFont("HPW_helvbig", { font = vguiFont, size = 100, weight = 0 })

	surface.CreateFont("HPW_guibiggest", { font = "Gnuolane Rg", size = 70, weight = 32 })
end

HpwRewrite:LoadFonts()