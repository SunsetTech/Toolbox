local Utils = require"Toolbox.Import.Utils"
local DataStore = require"Toolbox.Import.DataStore"
local Module,Path = Utils.From("Toolbox.Utilities",{"Module","Path"})

local Package = {}

local ModuleStack = {}
local TrackedModules = {}

local function RetreiveModuleInfo(ModuleName)
	local ModuleData = DataStore.GetStore(ModuleName)
	ModuleData.DependencyInfo = ModuleData.DependencyInfo or MakeModuleInfo(ModuleName)
	return ModuleData.DependencyInfo
end

local function MakeModuleInfo(ModuleName)
	local Path
	if ModuleName == "Program Entry Point" then
		Path = lfs.currentdir()
	else
		Path = Path.RealPath(Module.Locate(ModuleName))
	end
	return {
		Name = ModuleName,
		Path = Path,
		Dependencies = {},
		RequiredBy = {},
		Dirty = false
	}
end

local function PushModuleInfo(ModuleInfo)
	table.insert(ModuleStack,1,ModuleInfo)
end		

local function EmitDependency()
	local RequiredModule = ModuleStack[1]
	local RequiringModule = ModuleStack[2]
	table.insert(RequiredModule.RequiredBy,RequiringModule)
	table.insert(RequiringModule.Dependencies,RequiredModule)
end

local function PopModuleInfo()
	table.remove(ModuleStack,1)
end

PushModuleInfo(MakeModuleInfo("Program Entry Point"))

local Package = {}

function Package.GetMainInfo()
	return ModuleStack[#ModuleStack]
end

function Package.GetCurrentModuleInfo()
	return ModuleStack[1]
end

function Package.GetModuleInfo(ModuleName)
	return DataStore.GetStore(ModuleName).DependencyInfo
end

function Package.Require(ModuleName)
	local ModuleInfo = RetreiveModuleInfo(ModuleName)
	if (ModuleInfo.Dirty) then
		for _,Dependency in pairs(ModuleInfo.Dependencies) do
			table.remove(
				DependencyName.RequiredBy,
				GenericUtilities.Table.FindFirst(
					Dependency.RequiredBy,
					ModuleInfo
				)
			)
		end
		ModuleInfo.Dependencies = {}
		ModuleInfo.Dirty = false
	end
	PushModuleInfo(ModuleInfo)
		EmitDependency()
		local Module = require(ModuleName)
	PopModuleInfo()
	return Module
end

function Package.Uncache(ModuleName)
	package.loaded[ModuleName] = nil
	DataStore.GetStore(ModuleName,"DependencyInfo").Dirty = true
end

return Package
