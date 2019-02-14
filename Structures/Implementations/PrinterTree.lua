local Import = require"Toolbox.Import"
local OOP = require"Toolbox.OOP"

local Prototype, Class = OOP.Create(
	"PrinterTree",
	OOP.Inherit{
		Import.Module.Relative"Interfaces.Tree"
	}
)

function Prototype:Construct()
	self.Indent = 0
end

function Prototype:Push()
	self.Indent = self.Indent + 1
end

function Prototype:Add(Item)
	assert(type(Item) == "string","Expected a string here")
	print(string.rep("  ",self.Indent) .. Item)
end

function Prototype:Pop()
	self.Indent = self.Indent - 1
end

return Class
