local Meta = require("Toolbox.Utilities.Meta")
local Package = {}

function Package.CreateProxy(Item)

	local Container = {
		Item = Item
	}
	--A meta table that translates all metafunctions to the proxied command
	local Interface = {}
	local InterfaceMetatable = {
		__add = function(LHS,RHS)
			if (RHS == Interface) then
				RHS=Container.Item
			else
				LHS=Container.Item
			end
			return LHS+RHS
		end,
		__sub = function(LHS,RHS)
			if (RHS == Interface) then
				RHS=Container.Item
			else
				LHS=Container.Item
			end
			return LHS-RHS
		end,
		__mul = function(LHS,RHS)
			if (RHS == Interface) then
				RHS=Container.Item
			else
				LHS=Container.Item
			end
			return LHS*RHS
		end,
		__div = function(LHS,RHS)
			if (RHS == Interface) then
				RHS=Container.Item
			else
				LHS=Container.Item
			end
			return LHS/RHS
		end,
		__mod = function(LHS,RHS)
			if (RHS == Interface) then
				RHS=Container.Item
			else
				LHS=Container.Item
			end
			return LHS%RHS
		end,
		__pow = function(LHS,RHS)
			if (RHS == Interface) then
				RHS=Container.Item
			else
				LHS=Container.Item
			end
			return LHS^RHS
		end,
		__unm = function(LHS)
			return -Container.Item
		end,
		__concat = function(LHS,RHS)
			if (RHS == Interface) then
				RHS=Container.Item
			else
				LHS=Container.Item
			end
			return LHS .. RHS
		end,
		__len = function(LHS)
			return #Container.Item
		end,
		__eq = function(LHS,RHS)
			if (RHS == Interface) then
				RHS=Container.Item
			else
				LHS=Container.Item
			end
			return LHS == RHS
		end,
		__lt = function(LHS,RHS)
			if (RHS == Interface) then
				RHS=Container.Item
			else
				LHS=Container.Item
			end
			return LHS < RHS
		end,
		__le = function(LHS,RHS)
			if (RHS == Interface) then
				RHS=Container.Item
			else
				LHS=Container.Item
			end
			return LHS <= RHS
		end,
		__index = function(LHS,Key)
			return Container.Item[Key]
		end,
		__newindex = function(LHS,Key,Value)
			Container.Item[Key] = Value
		end,
		__call = function(LHS,...)
			return Container.Item(...)
		end,
		__type = function(LHS,...)
			return Meta.Type(Container.Item)
		end
	}
	setmetatable(Interface,InterfaceMetatable)
	return Container,Interface
end

function Package.Const(Item,Silent)
	local Metatable = {
		__index = function(_,Key)
			local Value = Item[Key]
			if (type(Value) == "table") then
				Value = Package.Const(Value,Silent)
			end
			return Value
		end,
		__newindex = function(_,Key,Value)
			if (not Silent) then
				error("Tried to modify const object")
			end
		end,
	}
	return setmetatable({},Metatable)
end

return Package
