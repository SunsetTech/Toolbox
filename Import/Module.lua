local From = require"Toolbox.Import.Utils".From
local Compose = From("Toolbox.Import",{"Compose"})
local Module, Error = From("Toolbox.Utilities",{"Module","Error"})
local Package = {}

local Enabled = false

function Package.IsEnabled()
	return Enabled
end

local CurrentModule

function Package.GetCurrentModule()
	return CurrentModule
end

function Package.Expose(ModuleName)
	local AlreadyEnabled = Enabled
	Enabled = true
	local PreviousModule = CurrentModule
	CurrentModule = ModuleName
	local Success, ModuleOrError = pcall(require,ModuleName)
	CurrentModule = PreviousModule
	Enabled = AlreadyEnabled or false
	if Success then
		return ModuleOrError
	else
		error(ModuleOrError,2)
	end
end

Package.Require = Compose.Pipeline{Package.Expose}

function Package.Child(ModuleName)
	assert(Enabled,"Not enabled")
	return require(CurrentModule ..".".. ModuleName)
end

function Package.Sister(ModuleName)
	assert(Enabled,"Not enabled")
	local Parent = Module.ParentName(CurrentModule)
	if Parent == "" then
		return require(ModuleName)
	else
		return require(Parent ..".".. ModuleName)
	end
end

function Package.Relative(ModuleName,Parent)
	Error.CallerAssert(Enabled,"Not enabled")
	Parent = Parent or CurrentModule
	while Parent ~= "" do
		SearchName = Parent ..".".. ModuleName
		if Module.Locate(SearchName) then
			return require(SearchName)
		else
			Parent = Module.ParentName(Parent)
		end
	end
	if Module.Locate(ModuleName) then
		return require(ModuleName)
	else
		Error.CallerError("Unable to locate module ".. ModuleName .." in parent tree")
	end
end

return Package
