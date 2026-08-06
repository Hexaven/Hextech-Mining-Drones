local function hasTable(t)
	return type(t) == "table"
end

if not hasTable(global)
	or not hasTable(global.map)
	or not hasTable(global.turtles)
	or not hasTable(global.node)
	or not hasTable(global.nodeStream)
	or not hasTable(global.nodeUpdate)
	or not hasTable(global.monitor) then
	print("mon.lua is a host debug script.")
	print("Run it on the host after startup is fully initialized.")
	return
end

function printGlobals()
	local count = 0
	for _,entry in pairs(global.map.chunks) do
		count = count + 1
	end
	print("map chunks       ", count)
	print("map.log          ", #global.map.log)
	print("global.updates   ", #global.updates)
end

function printTurtles()
	for id,turtle in pairs(global.turtles) do
		print("turtle.state.mapLog", id, #turtle.state.mapLog)
		print("turtle.maplog      ", id, #turtle.mapLog)
		print("turtle.mapBuffer   ", id, #turtle.mapBuffer)
	end
end

function printEvents()
	local streamCt = 0
	for _,v in pairs(global.nodeStream.streams) do streamCt = streamCt + 1 end
	print("streams          ", streamCt)
	print("stream.events    ", global.nodeStream.events.count)
	print("stream.messages  ", global.nodeStream.messages.count)
	print("stream.waitlist  ", global.nodeStream.waitlist.count)
	print("stream.streamlist", global.nodeStream.streamlist.count)
	
	print("global.updates   ", #global.updates)
	print("update.events    ", global.nodeUpdate.events.count)
	print("update.messages  ", global.nodeUpdate.messages.count)
	print("update.waitlist  ", global.nodeUpdate.waitlist.count)
	
	print("node.events      ", global.node.events.count)
	print("node.messages    ", global.node.messages.count)
	print("node.waitlist    ", global.node.waitlist.count)
	print("monitor.events   ", global.monitor.events.count)
end

function createDeepTable()
	local updates = {}
	local mapLogs = {}
	local ct = 0
	for i=1,2000 do
		mapLogs[i] = {}
		for k = 1,80 do
			table.insert(mapLogs[i], { x=200, y=200, z=200, data = "asdfkjasdflklaksjdflksadjflaskdfj"..k})
			ct = ct +1
		end
	end
	print("created mapLogs", ct)
	
	return mapLogs
end

function createFlatTable(mapLogs)
	local mapLogReturn = {}
	for _,mapLog in ipairs(mapLogs) do
		for _,entry in ipairs(mapLog) do
			table.insert(mapLogReturn,entry)
		end
	end
	return mapLogReturn
end

function emptyDeepTable(mapLogs)
	local start = os.epoch("local")
	for _,mapLog in ipairs(mapLogs) do
		for _,entry in ipairs(mapLog) do
			global.map:setData(entry.x,entry.y,entry.z,entry.data)
		end
	end
	print("deep", os.epoch("local")-start)
end

function emptyFlatTable(mapLog)
	local start = os.epoch("local")
	for _,entry in ipairs(mapLog) do
		global.map:setData(entry.x,entry.y,entry.z,entry.data)
	end
	print("flat", os.epoch("local")-start)
end

mapLogs = {}
mapLog = {}

function testTableInsert()
	mapLogs = createDeepTable()
	mapLog = createFlatTable(createDeepTable())
	
	emptyDeepTable(mapLogs)
	emptyFlatTable(mapLog)
	
end


local function render()
	term.setCursorPos(1, 1)
	term.clear()
	printTurtles()
	printGlobals()
	printEvents()
end

local function getMainMonitorName()
	if not hasTable(global.monitor) or not global.monitor.term then
		return nil
	end
	local ok, name = pcall(peripheral.getName, global.monitor.term)
	if ok then return name end
	return nil
end

local function getMonitorNames()
	local result = {}
	for _, name in ipairs(peripheral.getNames()) do
		if peripheral.getType(name) == "monitor" then
			table.insert(result, name)
		end
	end
	return result
end

local function resolveMonitor(sideArg)
	if sideArg then
		local mon = peripheral.wrap(sideArg)
		if mon and peripheral.getType(sideArg) == "monitor" then
			return mon, sideArg
		end
		return nil, nil
	end

	local monitorNames = getMonitorNames()
	if #monitorNames == 0 then
		return nil, nil
	end

	local mainName = getMainMonitorName()
	if mainName then
		for _, name in ipairs(monitorNames) do
			if name ~= mainName then
				return peripheral.wrap(name), name
			end
		end
	end

	return peripheral.wrap(monitorNames[1]), monitorNames[1]
end

local args = { ... }
local monitorSide = args[1]
local interval = tonumber(args[2]) or 1

local mon, pickedSide = resolveMonitor(monitorSide)

if monitorSide and not mon then
	print("Invalid monitor side: " .. tostring(monitorSide))
	print("Usage: mon <side> [interval]")
	return
end

if mon then
	if not monitorSide then
		print("mon: using monitor " .. tostring(pickedSide))
	end

	local previousTerm = term.current()
	term.redirect(mon)
	if mon.setBackgroundColor then mon.setBackgroundColor(colors.black) end
	if mon.setTextColor then mon.setTextColor(colors.white) end

	while true do
		render()
		sleep(interval)
	end

	term.redirect(previousTerm)
else
	render()
end
--testTableInsert()
