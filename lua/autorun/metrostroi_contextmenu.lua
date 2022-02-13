if SERVER then 
	AddCSLuaFile("alexey/contextmenu/cl_metrocontextmenu.lua")
else
	timer.Simple(5, function()
		include("alexey/contextmenu/cl_metrocontextmenu.lua")
	end)
end

print("Metrostroi Context Menu Loaded!")

