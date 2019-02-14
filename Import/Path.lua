local lfs = require"lfs"
local From = require"Toolbox.Import.Utils".From
local Compose,DataStore = From("Toolbox.Import",{"Compose","DataStore"});
local Module,Path,Meta,Error = From("Toolbox.Utilities",{"Module","Path","Meta","Error"})

local Package = {}

--Enabled status
local Enabled

function Package.IsEnabled()
	return Enabled
end

function Package.RequireEnabled()
	Error.Assert(Enabled,"Not enabled",3)
end

--Path information systems
local ModuleDirectoryStack = {}

local function PushModuleDirectory(Path)
	table.insert(ModuleDirectoryStack,Path)
end

local function PopModuleDirectory()
	table.remove(ModuleDirectoryStack)
end

function Package.GetModuleDirectory()
	return ModuleDirectoryStack[1]
end

function Package.Expose(ModuleName)
	local ModulePath = Module.Locate(ModuleName)
	local RealPath = Path.RealPath(ModulePath)
	
	local AlreadyEnabled = Enabled
	Enabled = true
	
	PushModuleDirectory(RealPath)
		local Success,ModuleOrError = require(ModuleName)
	PopModuleDirectory()

	Enabled = AlreadyEnabled or false
	
	if Success then
		return ModuleOrError
	else
		Error.CallerError(ModuleOrError)
	end
end

function Package.Decycle(ModuleName)
	Package.RequireEnabled()
	local ModulePath = Module.Locate(ModuleName)
	for Index,CheckPath in pairs(ModuleDirectoryStack) do
		if CheckPath == ModulePath then
			local CyclePath = Array.Slice(ModuleDirectoryStack,Index,#ModuleDirectoryStack)
			local CycleString = table.concat(CyclePath,"\n\t")
			local ErrorMessage = ("Dependency cycle detected between:\n%s"):format(CycleString)
			Meta.CallerError(ErrorMessage)
		end
	end
	return require(ModuleName)
end

function Package.Cache(ModuleName)
	local ModuleLoader,ModulePath = Module.FindLoader(ModuleName)
	local ModuleData = DataStore.GetStore(ModuleName)
	ModuleData.Module = ModuleData.Module or package.loaded[ModuleName] or ModuleLoader(ModulePath)
	return ModuleData.Module
end

function Package.MakePipeline()
	return Compose.Pipeline{Package.Decycle,Package.Expose,Package.Cache}
end

Package.Require = Package.MakePipeline()

--Path based utilities
function Package.Relative(ModuleName)
	Package.RequireEnabled()
	local CurrentModuleDirectory = Package.GetModuleDirectory()
	local CurrentDir = lfs.currentdir()
	lfs.chdir(CurrentModuleDirectory)
	local Success,ModuleOrError = require(ModuleName)
	lfs.chdir(CurrentDir)
	if Success then
		return Module
	else
		Meta.CallerError(ModuleOrError)
	end
end

function Package.RelativeDescent(ModuleName)
	Package.RequireEnabled()
	local CurrentDir = lfs.currentdir()
	for Index = #ModuleDirectoryStack,1,-1 do
		local ModuleDirectory = ModuleDirectoryStack[Index]
		lfs.chdir(ModuleDirectory)
		local Success,ModuleOrError = require(ModuleName)
		if Success then
			lfs.chdir(CurrentDir)
			return ModuleOrError
		end
	end
	lfs.chdir(CurrentDir)
	Meta.CallerError("Unable to locate ".. ModuleName)
end

return Package
