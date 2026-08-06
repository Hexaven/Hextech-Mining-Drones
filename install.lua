
-- installation using github for host computers and turtles

local git = "https://raw.githubusercontent.com/Hexaven/Hextech-Mining-Drones/main"



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
	-- fresh turtle install: root startup plus turtle/general runtime files
	files = {
		"turtle/startup.lua",
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
	if not file then
		print("WARNING: unable to download", filePath)
		return nil
	end
	local fileData = file.readAll()
	file.close()
	return fileData
end

if turtle and not fs.exists("runtime") then
	fs.makeDir("runtime")
end

-- download folders
for _,folder in pairs(folders) do
	print("downloading folder", folder.name)
	if not turtle and not fs.exists(folder.name) then
		fs.makeDir(folder.name)
	end
	
	for _,fileName in pairs(folder.files) do
		local filePath = folder.name.."/"..fileName
		local data = downloadFile(filePath)
		if data then
			if turtle then
				if fileName == "startup.lua" then
					saveFile(fileName, data)
				else
					saveFile("runtime/"..fileName, data)
				end
			else
				saveFile(filePath, data)
			end
		end
	end
end

-- download single files
for _,fileName in pairs(files) do
	local data = downloadFile(fileName)
	if data then
		if turtle and fileName == "turtle/startup.lua" then
			saveFile("startup.lua", data)
		else
			saveFile(fileName, data)
		end
	end
end


os.reboot()