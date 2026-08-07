-- Usage:
--   chunk 5,4,0
--   chunk 5,4,-1 5,4,-10
--   chunk 5,4,0,all
--   chunk 5,4,0,6
--   chunk 5,4,0,6,-59
-- Meaning:
--   <chunkX>,<chunkY>,<chunkZ>[,<groupSize|all>[,<bottomY>]]
--   <chunkX1>,<chunkY>,<chunkZ1> <chunkX2>,<chunkY>,<chunkZ2>[,<groupSize|all>[,<bottomY>]]

local args = { ... }

local function printUsage()
    print("Usage:")
    print("  chunk <chunkX>,<chunkY>,<chunkZ>[,<groupSize|all>[,<bottomY>]]")
    print("  chunk <chunkX1>,<chunkY>,<chunkZ1> <chunkX2>,<chunkY>,<chunkZ2>[ <groupSize|all> [<bottomY>]]")
    print("Examples:")
    print("  chunk 5,4,0")
    print("  chunk 5,4,-1 5,4,-10")
    print("  chunk 5,4,0,all")
    print("  chunk 5,4,0,6")
    print("  chunk 5,4,0,6,-59")
    print("  chunk 5,4,-1 5,4,-10 all -59")
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
    for _, raw in ipairs(rawArgs) do
        if string.find(raw, ",", 1, true) then
            local segs = splitCsv(raw)
            for _, s in ipairs(segs) do
                parts[#parts + 1] = s
            end
        else
            parts[#parts + 1] = raw
        end
    end
    if #parts < 3 then
        return nil, "invalid argument format"
    end

    local chunkX1 = toInt(parts[1])
    local chunkY1 = toInt(parts[2])
    local chunkZ1 = toInt(parts[3])
    if chunkX1 == nil or chunkY1 == nil or chunkZ1 == nil then
        return nil, "chunk coordinates must be numbers"
    end

    local hasSecondCorner = toInt(parts[4]) ~= nil and toInt(parts[5]) ~= nil and toInt(parts[6]) ~= nil
    local optionIndex = hasSecondCorner and 7 or 4
    local chunkX2, chunkY2, chunkZ2

    if hasSecondCorner then
        chunkX2 = toInt(parts[4])
        chunkY2 = toInt(parts[5])
        chunkZ2 = toInt(parts[6])
        if chunkY1 ~= chunkY2 then
            return nil, "both chunk corners must use the same chunkY"
        end
    else
        chunkX2, chunkY2, chunkZ2 = chunkX1, chunkY1, chunkZ1
    end

    local topY = (chunkY1 * 16) + 15

    local groupRaw = parts[optionIndex]
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

    local bottomY = toInt(parts[optionIndex + 1])
    if bottomY == nil then
        bottomY = -59
    end

    if parts[optionIndex + 2] ~= nil then
        return nil, "too many arguments"
    end

    local minChunkX = math.min(chunkX1, chunkX2)
    local maxChunkX = math.max(chunkX1, chunkX2)
    local minChunkZ = math.min(chunkZ1, chunkZ2)
    local maxChunkZ = math.max(chunkZ1, chunkZ2)

    return {
        chunkX = chunkX1,
        chunkY = chunkY1,
        chunkZ = chunkZ1,
        chunkX2 = chunkX2,
        chunkY2 = chunkY2,
        chunkZ2 = chunkZ2,
        minChunkX = minChunkX,
        maxChunkX = maxChunkX,
        minChunkZ = minChunkZ,
        maxChunkZ = maxChunkZ,
        isRange = hasSecondCorner,
        groupSize = groupSize,
        useAll = useAll,
        topY = topY,
        bottomY = bottomY,
    }, nil
end

local function buildChunkArea(minChunkX, minChunkZ, maxChunkX, maxChunkZ, topY, bottomY)
    local chunkSize = 16

    local minX = minChunkX * chunkSize
    local minZ = minChunkZ * chunkSize
    local maxX = (maxChunkX * chunkSize) + (chunkSize - 1)
    local maxZ = (maxChunkZ * chunkSize) + (chunkSize - 1)

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

    local startPos, finishPos = buildChunkArea(
        parsed.minChunkX,
        parsed.minChunkZ,
        parsed.maxChunkX,
        parsed.maxChunkZ,
        parsed.topY,
        parsed.bottomY
    )

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
    if parsed.isRange then
        print(string.format("Chunks: (%d,%d,%d) -> (%d,%d,%d)  Group: %s  Started: %s",
            parsed.chunkX,
            parsed.chunkY,
            parsed.chunkZ,
            parsed.chunkX2,
            parsed.chunkY2,
            parsed.chunkZ2,
            parsed.useAll and "all" or tostring(parsed.groupSize),
            tostring(ok)))
    else
        print(string.format("Chunk: (%d,%d,%d)  Group: %s  Started: %s",
            parsed.chunkX,
            parsed.chunkY,
            parsed.chunkZ,
            parsed.useAll and "all" or tostring(parsed.groupSize),
            tostring(ok)))
    end

    return ok
end

main()
