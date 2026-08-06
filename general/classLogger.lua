local default = {
	fileName = "log.txt",
}

local Logger = {}
Logger.__index = Logger

function Logger:new(fileName)
	local o = o or {}
	setmetatable(o,self)
	
	o.fileName = fileName or default.fileName
	o.log = {}
	
	o:initialize()
	return o
end

function Logger:initialize()
	local f = fs.open(self.fileName, "w")
	if f then f.close() end
end

function Logger:_timestamp()
	local t = os.time()
	return string.format("[%02d:%02d:%02d]", math.floor(t/3600)%24, math.floor(t/60)%60, math.floor(t)%60)
end

function Logger:add(...)
	local parts = {...}
	local txt = table.concat(parts, " ")
	table.insert(self.log, txt)
	local f = fs.open(self.fileName, "a")
	if f then
		f.writeLine(self:_timestamp() .. " " .. txt)
		f.close()
	end
end

function Logger:addFirst(...)
	local parts = {...}
	local txt = table.concat(parts, " ")
	table.insert(self.log, 1, txt)
	local f = fs.open(self.fileName, "a")
	if f then
		f.writeLine(self:_timestamp() .. " " .. txt)
		f.close()
	end
end

function Logger:save(fileName)
	-- kept for compatibility, no-op since entries are written immediately
end

function Logger:print()
	for _,entry in ipairs(self.log) do
		print(entry)
	end
end

return Logger