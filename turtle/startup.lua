package.path = package.path ..";../runtime/?.lua"

-- Safely disable Rednet directly to avoid conflicts with Bluenet
if rednet then
    os.unloadAPI("rednet")
end

os.loadAPI("/runtime/bluenet.lua")
shell.run("/runtime/update.lua")

os.loadAPI("/runtime/global.lua")
os.loadAPI("/runtime/config.lua")

shell.run("/runtime/initialize.lua")

tabMain = shell.openTab("/runtime/main.lua")
tabReceive = shell.openTab("/runtime/receive.lua")
tabSend = shell.openTab("/runtime/send.lua")

multishell.setTitle(tabMain, "main")
multishell.setTitle(tabReceive, "receive")
multishell.setTitle(tabSend, "send")
