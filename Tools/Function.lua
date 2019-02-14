local Package = {}

function Package.ForUpvalues(Function)
	return coroutine.wrap(
		function()
			local Index = 1
			local Name, Value
			repeat
				Name, Value = debug.getupvalue(Function,Index)
				if Name then
					coroutine.yield(Index,Name,Value)
				end
				Index = Index + 1
			until Name == nil
		end
	)
end

function Package.Copy(Function,Env,ShareUpvalues)
	local Dump = string.dump(Function)
	local Copy = load(Dump,"Copy","b")
	for Index,Name,Value in Package.ForUpvalues(Function) do
		local SetName = debug.getupvalue(Copy,Index)
		if Env and Name == "_ENV" then
			debug.setupvalue(Copy,Index,Env)
		else
			if ShareUpvalues then
				debug.upvaluejoin(Copy,Index,Function,Index)
			else
				debug.setupvalue(Copy,Index,Value)
			end
		end
	end
	return Copy
end

return Package
