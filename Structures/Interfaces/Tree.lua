local OOP = require"Toolbox.OOP"

local Prototype, Class = OOP.Create("Tree")

function Prototype:Push()
	error("This method must be implemented")
end

function Prototype:Add()
	error("This method must be implemented")
end

function Prototype:Pop()
	error("This method must be implemented")
end

return Class
