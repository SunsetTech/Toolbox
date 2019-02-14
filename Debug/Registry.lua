local Import = require"Toolbox.Import"

local DebugPrintTree = Import.Module.Sister"DebugPrintTree"

local Package = {}

local Channels = {}

local DefaultPipe = DebugPrintTree:New()

function Package.GetDefaultPipe(Name)
	return DefaultPipe
end

function Package.SetPipe(Name,Pipe)
	Channels[Name] = Pipe
end

function Package.Acquire(Name)
	Channels[Name] = Channels[Name] or Package.GetDefaultPipe(Name)
	return Channels[Name]
end

return Package
