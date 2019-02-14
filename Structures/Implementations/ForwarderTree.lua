--[[local ClassLibrary = require"ClassLibrary"

local Prototype, Class = ClassLibrary.Create
function Prototype:Construct(Sink)
	self.Sink = Sink
end

function Prototype:Push()
	self.Sink:Push()
end

function Prototype:Add(Item)
	self.Sink:Add(Item)
end

function Prototype:Pop()
	return self.Sink:Pop()
end]]
