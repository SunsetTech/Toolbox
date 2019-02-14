--[[
	Supports multiple inheritance
	Supports GetType and IsTypeOf
	See Examples/BetterToolbox.OOPExample.lua for usage info
]]

--[[
	Could implement private data by sort of, pivoting to a different accessor when entering a prototype method?
	also these aren't actually true prototypes
]]

local Prototype = require("Toolbox.OOP.Prototype")
local BasePrototype = require("Toolbox.OOP.BasePrototype")
local ClassInstancer = require("Toolbox.OOP.ClassInstancer")

local Package = {}

function Package.Create(Type,Parents)
	local Private,Public = Prototype.Make(Type,Parents or {Base = BasePrototype})
	local Instancer = ClassInstancer.Make(Public)
	return Private,Instancer
end

function Package.Inherit(Classes)
	local Map = {}
		for _,Class in pairs(Classes) do
			Map[Class:GetClassType()] = Class.Prototype
		end
	return Map
end

function Package.InheritModules(ModuleNames)
	local Classes = {}
	for _,ModuleName in pairs(ModuleNames) do
		local Module = require(ModuleName)
		table.insert(Classes,Module)
	end
	return Package.Inherit(Classes)
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

function Package.GetType(Value)
	local BaseType = type(Value)
	if BaseType == "table" then
		local MetaType = GenericUtilities.Meta.Type.GetType(Value)
		if MetaType == "ClassInstance" then
			return Value:GetType()
		else
			return MetaType
		end
	else
		return BaseType
	end
end

Package.Utils = {
	InheritModules = Package.InheritModules;
	Clone = Package.Clone;
}

return Package
