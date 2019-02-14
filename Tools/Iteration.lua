local Package = {}

local function YieldResult(ShouldYield,Key,...)
	if ShouldYield then
		coroutine.yield(Key,...)
	end
	return Key
end

function Package.NoOp(...)
	return true,...
end

function Package.MakeFilter(FilterFunc,Iterator,...)
	local Args = {...}
	return coroutine.wrap(
		function()
			local Iterator, Arg, Key = Iterator(unpack(Args))
			repeat
				Key = YieldResult(FilterFunc(Iterator(Arg,Key)))
			until Key == nil
		end
	)
end

function Package.ToTable(Iterator,Object,State)
	local Values = {}
	repeat
		local ReturnValues = {Iterator(Object,State)}
		State = ReturnValues[1]
		if State then
			table.insert(Values,ReturnValues)
		end
	until State == nil
	return Values
end

function Package.Recurse(Table)
	return coroutine.wrap(
		function()
			for Key,Value in pairs(Table) do
				if (type(Value) == "table") then
					for SubTable,SubKey,SubValue in Package.Recurse(Value) do
						coroutine.yield(SubTable,SubKey,SubValue)
					end
				else
					coroutine.yield(Table,Key,Value)
				end
			end
		end
	)
end

return Package
