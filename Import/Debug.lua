--[[local Utils = require"Import.Utils"
local Error = Utils.From("GenericUtilities",{"Error"})

local DebugPipes = require("DebugPipes")
local DebugChannel = DebugPipes.Central.AcquireChannel("MetaRequire.Debug")

local Package = {}

function Package.Require(ModuleName) 
	DebugChannel:Add("Loading ".. ModuleName)
	DebugChannel:Push()
	local Success, ModuleOrError = pcall(require,ModuleName)
	if Success then
		return ModuleOrError
	else
		Error.CallerError(ModuleOrError)
	end
	DebugChannel:Pop()
end

return Package]]
