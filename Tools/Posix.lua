local posix = require("posix")

local Package = {}

function Package.Fork(ChildProcessFunction,ParentProcessFunction)
	local ChildPID = posix.fork()
	if (ChildPID == 0) then
		return ChildProcessFunction(ChildPID)
	else
		return ParentProcessFunction(ChildPID)
	end
end

function Package.BidirectionalOpen(Program,Arguments)
	local InputPipeR, InputPipeW = posix.pipe()
	local OutputPipeR, OutputPipeW = posix.pipe()
	return Package.Fork(
		function(PID)
			posix.close(InputPipeW)
			posix.close(OutputPipeR)
			posix.dup2(InputPipeR,posix.fileno(io.stdin))
			posix.dup2(OutputPipeW,posix.fileno(io.stdout))
			posix.exec(Program,unpack(Arguments or {}))
			posix.close(InputPipeR)
			posix.close(OutputPipeW)
			posix._exit(0)
		end,
		function(PID)
			posix.close(InputPipeR)
			posix.close(OutputPipeW)
			return PID,InputPipeW,OutputPipeR
		end
	)
end

function Package.CallScriptFunction(ScriptPath,FunctionName,Arguments)
	return os.execute(
		([[source "%s"; %s %s]]):format(ScriptPath,FunctionName,table.concat(Arguments," "))
	)
end

return Package
