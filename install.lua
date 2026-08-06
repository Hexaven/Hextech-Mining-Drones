
-- installation using github for the host computer

local git = "https://github.com/Hexaven/Hextech-Mining-Drones"



local files, folders

local allFolders = {
	["general"] = { 
		name = "general",
		files = {
            "bluenet.lua",
            "classBluenetNode.lua",
            "classList.lua",
            "utils.lua",
			"classPathFinder.lua",
			"classHeap.lua",
			"classLogger.lua",
			"classChunkyMap.lua",
			"blockTranslation.lua",
			"blockColor.lua",
			"utilsSerialize.lua",
			"classBreadthFirstSearch.lua",
			"classQueue.lua",
			"classStateMap.lua"
		}
	},
	["gui"] = { 
		name = "gui",
		files = {
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
		}
	},
	["pocket"] = { 
		name = "pocket",
		files = {
			"shellDisplay.lua",
		}
	},
	["turtle"] = { 
		name = "turtle",
		files = {
            "classCheckPointer.lua",
            "classMiner.lua",
            "classMinerTaskAssignment.lua",
            "classTaskQueue.lua",
            "classTurtleStorage.lua",
            "extTreeMining.lua",
            "extTurtleStorage.lua",
            "global.lua",
            "initialize.lua",
            "main.lua",
            "receive.lua",
            "send.lua",
            "testMine.lua",
            "testPerformance.lua",
            "update.lua"
		}
	},
}

if turtle then
	-- download turtle files, will be updated by host anyways
	files = {
		-- "turtle/startup.lua",
	}
	folders = {
		["turtle"] = {
		name = "turtle",
		files = {
            "classCheckPointer.lua",
            "classMiner.lua",
            "classMinerTaskAssignment.lua",
            "classTaskQueue.lua",
            "classTurtleStorage.lua",
            "extTreeMining.lua",
            "extTurtleStorage.lua",
            "global.lua",
            "initialize.lua",
            "main.lua",
            "receive.lua",
            "send.lua",
            "testMine.lua",
            "testPerformance.lua",
            "update.lua"
			}
		}
		,
		["general"] = {
		name = "general",
		files = {
            "bluenet.lua",
            "classBluenetNode.lua",
            "classList.lua",
            "utils.lua",
			"classPathFinder.lua",
			"classHeap.lua",
			"classLogger.lua",
			"classChunkyMap.lua",
			"blockTranslation.lua",
			"blockColor.lua",
			"utilsSerialize.lua",
			"classBreadthFirstSearch.lua",
			"classQueue.lua",
			"classStateMap.lua"
			}
		}
	}
else
	-- host computer
	files = {
		"startup.lua"
	}
	folders = allFolders
end

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
	print("downloading", filePath)

	local file = http.get(url)
	local fileData = file.readAll()
	return fileData
end

-- download folders
for _,folder in pairs(folders) do
	print("downloading folder", folder.name)
	if not fs.exists(folder.name) then
		fs.makeDir(folder.name)
	end
	
	for _,fileName in pairs(folder.files) do
		local filePath = folder.name.."/"..fileName
		local data = downloadFile(filePath)
		if turtle then
			if fileName == "startup.lua" then
				saveFile(fileName, data) -- save to root folder
			else
				saveFile("runtime/"..fileName, data)
			end
		else
			saveFile(filePath, data)
		end
	end
end

-- download single files
for _,fileName in pairs(files) do
	local data = downloadFile(fileName)
	saveFile(fileName, data)
end


os.reboot()