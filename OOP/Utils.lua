local Package = {}

--Assumes parent modules export a class instancer
function Package.InheritModules(ModuleNames)
	local Map = {}
	for _,ModuleName in pairs(ModuleNames) do
		local Module = require(ModuleName)
		Map[ModuleName:match("([^.]+)$")] = Module.Prototype
	end
	return Map
end

function Package.Clone(Object)
	if (type(Object) == "table") then
		local CloneObject = {}
		for Key,Value in pairs(Object) do
			CloneObject[Key] = Package.Clone(Value)
		end
		if getmetatable(Object) then
			setmetatable(CloneObject,getmetatable(Object))
		end
		return CloneObject
	else
		return Object
	end
end

return Package
