if SERVER then return end

local text = [[
This operating system is locked due to the violation of the federal laws of 
the United States of America! (Article 1, Section 8, Clause 8; Article 202;
Article 210 of th eCriminal Code of U.S.A provides a deprivation of liberty\n
for four to twelve years.)\n
Following violations were detected:\n
Your IP address was used to visit websites containing pornography, child\n
pornography, zoophilia and child abuse. Your computer also contains\n
video files with pornographic content, elements of violence and child\n
pornography! Spam messages with terrorist motives were also send from\n
your computer.\n
This computer lock is aimed to stop your illegal activity.\n
\n
TO UNLOCK THE COMPUTER YOU ARE OBLIGED TO PAY A FINE OF $200.\n
\n
You have 69 hours to pay the fine, otherwise you will be arrested\n
\n
You must pay the fine through MoneyPak:\n
To pay the fine, you should enter the digits resulting code, which is \n
located on the back of your MOneypak, in the payment form and \n
press OK (if you have several codes, enter them one after the other and \n
press OK)>\n
If an error occurs,  send the codes to address 
]]

local arr = string.Explode("\n", text)

local blue = Color(0, 0, 130)
local white = Color(255, 255, 255)

local function EndWinLock()


	surface.PlaySound("vo/ravenholm/madlaugh04.wav")
end

local function CallWinLock()

end
