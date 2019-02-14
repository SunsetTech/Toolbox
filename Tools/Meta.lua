local Package = {}

function Package.Deprecated(Message)
	local Called = debug.getinfo(2)
	local Caller = debug.getinfo(3)
	print(
		string.format(
			"---USE OF %s IN %s AT LINE %s IS DEPRECATED---",
				(Called.name or "?"),Caller.short_src,Caller.currentline
		)
	)
	print(Message)
end

function Package.Warning(Message)
	local Caller = debug.getinfo(2)
	print(
		string.format(
			"---WARNING (in %s @ %s:%s)---",
			(Caller.name or "?"), Caller.short_src, Caller.currentline
		)
	)
	print(Message)
end

function Package.DebugMessage(...)
	local Called = debug.getinfo(2)
	local Args = {...}
	Table.Apply(Args,tostring)
	print(
		string.format(
			[[(%s:%s@%s): %s]],
			string.match(Called.short_src,[[([^/]+/[^/]+%.lua)$]]),
			Called.name,
			Called.currentline,
			table.concat(Args,"\t")	
		)
	)
end

return Package
