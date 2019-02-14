local Package = {}

local function Try(Function,...)
	local Success, ModuleOrError = pcall(Function,...)
	if Success then
		return ModuleOrError
	else
		error(ModuleOrError,3)
	end
end

function Package.ImportFrom(BaseModule,SubModules)
	local Module = {}
	
	for Key,Value in pairs(SubModules) do
		if (type(Key) == "string") then
			local SubmoduleName = BaseModule ..".".. Key

			if type(Value) == "table" then
				Module[Key] = Try(Package.ImportFrom,SubmoduleName,Value)
			elseif type(Value) == "function" then
				Module[Key] = Try(Value,SubmoduleName)
			end
		elseif (type(Value) == "string") then
			local SubmoduleName = BaseModule ..".".. Value

			Module[Value] = Try(require,SubmoduleName)
			Module[Key] = Module[Value]
		end
	end
	
	return Module
end

function Package.From(BaseModule,SubModules)
	local Packed = Try(Package.ImportFrom,BaseModule,SubModules)
	return table.unpack(Packed)
end

function Package.Want(ModuleName)
	local Success, ModuleOrError = pcall(require,ModuleName)
	print(ModuleOrError)
	return Success and ModuleOrError or nil
end

return Package
