local Package = {}

local BaseTypeToMetamethodMap = {
	["function"] = {
		__eq = true,
		__call = true,
		__type = true
	},
	["string"] = {
		__eq = true,
		__len = true,
		__concat = true,
		__type = true
	},
	["nil"] = {
		__eq = true,
		__type = true
	},
	["number"] = {
		__eq = true,
		__lt = true,
		__le = true,
		__add = true,
		__sub = true,
		__mul = true,
		__div = true,
		__mod = true,
		__pow = true,
		__unm = true,
		__type = true
	},
	["table"] = {
		__eq = true,
		__index = true,
		__newindex = true,
		__len = true,
		__type = true
	},
	["boolean"] = {
		__eq = true,
		__type = true
	}
}

function Package.ImplementsMetamethod(Object,Metamethod)
	return (
		(getmetatable(Object) or {})[Metamethod] or
		(BaseTypeToMetamethodMap[type(Object)] or {})[Metamethod]
	) ~= nil
end

function Package.IsBaseType(TypeName)
	return BaseTypeToMetamethodMap[TypeName] ~= nil
end

function Package.IsBaseTypeEquivalent(Object,BaseType) --may not always be correct?
	assert(Package.IsBaseType(BaseType),"Argument 2 must be a base type")
	for Metamethod,_ in pairs(BaseTypeToMetamethodMap) do
		if (not Package.ImplementsMetamethod(Object,Metamethod)) then
			return false
		end
	end
	return true
end

function Package.GetType(Object)
	assert(type ~= Package.GetType, "Please don't globally override the type function with this")
	
	local Metatable = getmetatable(Object)
	local MetatableType = type(Metatable)
	
	if (Metatable and type(Metatable) == "table" and Metatable.__type) then
		local TypeMetamethod = Metatable.__type
		
		if (type(TypeMetamethod) == "function") then
			return TypeMetamethod(Object)
		else
			return TypeMetamethod
		end
	else
		return type(Object)
	end
end

function Package.Assert(Name,Object,Types)
	for _,Type in pairs(Types) do
		if (Package.GetType(Object) == Type) then
			return
		end
	end
	error(string.format([[Expected one of (%s) for '%s']],table.concat(Types,","),Name))
end

function Package.Check(ParameterTypesList)
	return function(Arguments)
		for Index,PossibleTypes in pairs(ParameterTypesList) do
			local Argument = Arguments[Index]
			local ArgumentType = Package.GetType(Argument)
			local Valid = false
			for _,PossibleType in pairs(PossibleTypes) do
				if (ArgumentType == PossibleType) then
					Valid = true
					break
				else
					local ArgumentIsBaseType = Package.IsBaseType(ArgumentType)
					local PossibleIsBaseType = Package.IsBaseType(PossibleType)
					if (not ArgumentIsBaseType and PossibleIsBaseType) then
						--Check for equivalency
						if (Package.IsBaseTypeEquivalent(Argument,PossibleType)) then
							Valid = true
							break
						end
					end
				end
			end
			if (not Valid) then
				error(
					("Expected one of (%s) for argument %i, got (%s) instead"):format(
						table.concat(PossibleTypes,", "),
						Index,
						Package.GetType(Argument)
					),
					3
				)
			end
		end
	end
end


return Package
