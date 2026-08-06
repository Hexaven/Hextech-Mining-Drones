-- Usage:
--   chunk 5,4,0
--   chunk 5,4,0,all
--   chunk 5,4,0,6
--   chunk 5,4,0,6,-59
-- Meaning:
--   <chunkX>,<chunkY>,<chunkZ>[,<groupSize|all>[,<bottomY>]]

local args = { ... }

local function printUsage()
    print("Usage: chunk <chunkX>,<chunkY>,<chunkZ>[,<groupSize|all>[,<bottomY>]]")
    print("Examples:")
    print("  chunk 5,4,0")
    print("  chunk 5,4,0,all")
    print("  chunk 5,4,0,6")
    print("  chunk 5,4,0,6,-59")
end

local function splitCsv(s)
    local out = {}
    for part in string.gmatch(s, "[^,]+") do
        out[#out + 1] = part
    end
    return out
end

local function toInt(v)
    local n = tonumber(v)
    if not n then return nil end
    return math.floor(n)
end

local function parseInput(rawArgs)
    if #rawArgs == 0 then
        return nil, "missing arguments"
    end

    local parts = {}
    if #rawArgs == 1 and string.find(rawArgs[1], ",", 1, true) then
        parts = splitCsv(rawArgs[1])
    elseif #rawArgs >= 3 then
        parts = { rawArgs[1], rawArgs[2], rawArgs[3], rawArgs[4] }
    else
        return nil, "invalid argument format"
    end

    local chunkX = toInt(parts[1])
    local chunkY = toInt(parts[2])
    local chunkZ = toInt(parts[3])
    if chunkX == nil or chunkY == nil or chunkZ == nil then
        return nil, "chunkX, chunkY and chunkZ must be numbers"
    end

    local topY = (chunkY * 16) + 15

    local groupRaw = parts[4]
    local useAll = false
    local groupSize = 0
    if groupRaw == nil or string.lower(groupRaw) == "all" then
        useAll = true
        groupSize = 0
    else
        groupSize = toInt(groupRaw)
        if not groupSize or groupSize < 1 then
            return nil, "group size must be >= 1 or 'all'"
        end
    end

    local bottomY = toInt(parts[5])
    if bottomY == nil then
        bottomY = -59
    end

    return {
        chunkX = chunkX,
        chunkY = chunkY,
        chunkZ = chunkZ,
        groupSize = groupSize,
        useAll = useAll,
        topY = topY,
        bottomY = bottomY,
    }, nil
end

local function buildChunkArea(chunkX, chunkZ, topY, bottomY)
    local chunkSize = 16

    local minX = chunkX * chunkSize
    local minZ = chunkZ * chunkSize
    local maxX = minX + (chunkSize - 1)
    local maxZ = minZ + (chunkSize - 1)

    return vector.new(minX, topY, minZ), vector.new(maxX, bottomY, maxZ)
end

local function main()
    if not global or not global.taskManager then
        print("Host runtime is not initialized. Start host program first.")
        return false
    end

    local parsed, err = parseInput(args)
    if not parsed then
        print("Error:", err)
        printUsage()
        return false
    end

    local startPos, finishPos = buildChunkArea(parsed.chunkX, parsed.chunkZ, parsed.topY, parsed.bottomY)

    local group = global.taskManager:createGroup()
    group:setFunction("excavateArea")
    group:setGroupSize(parsed.groupSize)
    group:setArea(startPos, finishPos)
    group:splitArea()

    local ok = group:start()

    print("Chunk job created:", group.shortId)
    print(string.format("Area: (%d,%d,%d) -> (%d,%d,%d)",
        startPos.x, startPos.y, startPos.z,
        finishPos.x, finishPos.y, finishPos.z))
    print(string.format("Chunk: (%d,%d,%d)  Group: %s  Started: %s",
        parsed.chunkX,
        parsed.chunkY,
        parsed.chunkZ,
        parsed.useAll and "all" or tostring(parsed.groupSize),
        tostring(ok)))

    return ok
end

main()
