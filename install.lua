local git = "https://raw.githubusercontent.com/Hexaven/Hextech-Mining-Drones/main"
-- Hexaven Installer : pastebin 3PtZVWHF
local allFolders = {
    ["general"] = { 
        name = "general",
        files = {
            "classLogger.lua",
            "classPathFinder.lua",
            "classQueue.lua",
            "classSimpleVector.lua",
            "config.lua",
            "classBlockColor.lua",
            "blockColor.lua",
            "killRednet.lua",
            "utilsSerialize.lua",
            "blockTranslation.lua",
            "bluenet.lua",
            "classBluenetNode.lua",
            "classChunkyMap.lua",
            "classHeap.lua",
            "classList.lua",
            "utils.lua",
        }
    },
    ["gui"] = { 
        name = "gui",
        files = {
            "classBasicWindow.lua",
            "classMonitor.lua",
            "classTaskGroupControl.lua",
            "classTaskGroupSelector.lua",
            "classTaskSelector.lua",
            "classToggleButton.lua",
            "classTurtleControl.lua",
            "classWindow.lua",
            "classBox.lua",
            "classButton.lua",
            "classCheckBox.lua",
            "classFrame.lua",
            "classGPU.lua",
            "classHostDisplay.lua",
            "classLabel.lua",
            "classMapDisplay.lua",
            "classChoiceSelector.lua",
            "classScrollBar.lua",
            "classPixelDrawer.lua",
            "classTaskGroupDetails.lua",
            "classTurtleList.lua",
            "classTurtleDetails.lua",
            "classTaskList.lua",
            "classTaskControl.lua",
            "classNumberInput.lua",
            "classOptionSelector.lua",
            "classStorageDisplay.lua",
            "classStorageItemControl.lua",
        }
    },
    ["host"] = { 
        name = "host",
        files = {
            "startup.lua",
            "classTaskGroup.lua",
            "display.lua",
            "global.lua",
            "initialize.lua",
            "main.lua",
            "receive.lua",
            "send.lua",
            "hostTransfer.lua",
            "classTaskAssignment.lua",
            "classTaskManager.lua",
            "classLoadBalancer.lua",
            "classRecurringProject.lua",
            "classComplexTask.lua",
        }
    },
    ["storage"] = {
        name = "storage",
        files = {
            "classItemStorage.lua",
            "classRemoteStorage.lua",
            "test.lua",
        }
    },
    ["pocket"] = { 
        name = "pocket",
        files = {
            "shellDisplay.lua",
        }
    }
}

-- Host computer specific startup
--local files = {
--    "startup.lua"
--}

local function saveFile(filePath, fileData)
    if fs.exists(filePath) then
        fs.delete(filePath)
    end

    local f = fs.open(filePath, "w")
    f.write(fileData)
    f.close()
end

local function downloadFile(filePath)
    local url = git.."/"..filePath
    print("downloading " .. filePath)

    local file = http.get(url)
    
    -- The Safety Net: Prevent crashes on 404 errors
    if not file then
        print("WARNING: Skipped missing file -> " .. filePath)
        return nil
    end
    
    local fileData = file.readAll()
    file.close()
    return fileData
end

-- Ensure the unified runtime directory exists
if not fs.exists("runtime") then
    fs.makeDir("runtime")
end

-- Download and route folders
for _,folder in pairs(allFolders) do
    print("--- downloading folder: " .. folder.name .. " ---")
    
    for _,fileName in pairs(folder.files) do
        local fetchPath = folder.name.."/"..fileName
        local data = downloadFile(fetchPath)
        
        if data then
            -- Unified routing directly to runtime/
            if fileName == "startup.lua" then
                saveFile(fileName, data) 
            else
                saveFile("runtime/"..fileName, data)
            end
        end
    end
end

-- Download single files
--for _,fileName in pairs(files) do
--    local data = downloadFile(fileName)
--    if data then saveFile(fileName, data) end
--end
if files and type(files) == "table" then
    for _,fileName in pairs(files) do
        local data = downloadFile(fileName)
        if data then saveFile(fileName, data) end
    end
end
os.reboot()
