if SERVER then return end

local text = [[
A problem has been detected and windows has been shut down to prevent damage 
to your computer

The problem seems to be caused by the following file: hl2.exe

GMOD_LUA_PANIC

If this is the first time you've seen this stop error screen,
restart your computer. If this screen appears again, follow
these steps:

Check to make sure any new hardware or software is properly installed.
If this is a new installation, ask your hardware or software manufacturer
for any Windows updates you might need.

If problems continue, disable or remove any newly installed hardware
or software. Disable BIOS memory options such as caching or shadowing.
If you need to use safe mode to remove or disable components, restart
your computer, press F8 to select Advanced Startup Options, and then
select Safe Mode.

Technical Information:

*** STOP: 0x00000539

*** hl2.exe - Address 0x474D4F44 base at 0x474D4F44 DateStamp 0x00000000
]]

local arr = string.Explode("\n", text)

local blue = Color(0, 0, 130)
local white = Color(255, 255, 255)

surface.CreateFont("HPW_BSOD", { font = "Lucida Console", size = 16, weight = 1 })

local function EndBsod()
	hook.Remove("DrawOverlay", "hpwrewrite_fakebsod")
	hook.Remove("Think", "hpwrewrite_fakebsod")

	surface.PlaySound("vo/ravenholm/madlaugh04.wav")
end

local function CallBsod()
	if not system.IsWindows() then return end -- yes

	hook.Add("DrawOverlay", "hpwrewrite_fakebsod", function()
		draw.RoundedBox(0, 0, 0, ScrW(), ScrH(), blue)

		for k, v in pairs(arr) do
			draw.SimpleText(v, "HPW_BSOD", 0, k*18, white)
		end
	end)

	hook.Add("Think", "hpwrewrite_fakebsod", function() RunConsoleCommand("stopsound") end)

	timer.Create("hpwrewrite_fakebsodstop", 5, 1, function()
		EndBsod()
	end)
end

net.Receive("hpwrewrite_BSODFAKESTART", function()
	CallBsod()
end)

net.Receive("hpwrewrite_BSODFAKESTOP", function()
	EndBsod()
end)