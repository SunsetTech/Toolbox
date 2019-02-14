local Package = {}

function Package.CallerError(Message)
	error(Message,3)
end

function Package.Assert(Flag,Message,Level) --add level information to assert like error has
	if (not Flag) then
		error(Message,Level + 1)
	end
end

function Package.CallerAssert(Flag,Message,Offset)
	Package.Assert(Flag,Message,3+(Offset or 0))
end

function Package.NotImplemented()
	error("Function not implemented",3)
end

return Package
