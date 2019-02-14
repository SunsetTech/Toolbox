local Package = {}

function Package.FindFirst(Table,What)
	for Key,Value in pairs(Table) do
		if (Value == What) then
			return Key
		end
	end
end

function Package.Keys(Table)
	local Results = {}
	for Key,_ in pairs(Table) do
		table.insert(Results,Key)
	end
	return Results
end

function Package.Values(Table)
	local Results = {}
	for _,Value in pairs(Table) do
		table.insert(Results,Value)
	end
	return Results
end

function Package.Apply(Modifier, Table)
	for Key,Value in pairs(Table) do
		Table[Key] = Modifier(Value)
	end
end

function Package.ForEach(Table,Function)
	for Key,Value in pairs(Table) do
		Function(Table,Key,Value)
	end
end

function Package.CachedCopy(Cache,Value,IncludeMetatable)
	if (not Cache[Value]) then
		Cache[Value] = {}
		Package.Copy(Value,IncludeMetatable,Cache,Cache[Value])
	end
	return Cache[Value]
end

function Package.Copy(Table,IncludeMetatable,Cache,Target)
	IncludeMetatable = IncludeMetatable or true
	Cache = Cache or {}
	Target = Target or {}
	for Key,Value in pairs(Table) do
		if (type(Key) == "table") then
			Key = Package.CachedCopy(Cache,Key,IncludeMetatable)
		end
		if (type(Value) == "table") then
			Value = Package.CachedCopy(Cache,Value,IncludeMetatable)
		end
		Target[Key] = Value
	end
	if (IncludeMetatable) then
		setmetatable(Target,getmetatable(Table))
	end
	return Target
end

Package.SimpleCopy = Package.Copy

function Package.Replace(TableA,TableB)
	local NewTable = {}
	for Key,_ in pairs(TableA) do
		NewTable[Key] = TableB[Key] or TableA[Key]
	end
	return NewTable
end

function Package.Merge(TableA,TableB)
	for Key,Value in pairs(TableB) do
		TableA[Key] = Value
	end
end

function Package.Concat(Combiner,Items)
	print(Combiner,Items)
	local Current = Items[1]
	for Index = 2, #Items do
		Current = Combiner(Current,Items[Index])
	end
	return Current
end

return Package
