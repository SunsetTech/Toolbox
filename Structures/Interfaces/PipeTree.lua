local Import = require"Toolbox.Import"
local OOP = require"Toolbox.OOP"

local Prototype,Class = OOP.Create(
	"PipeTree",
	OOP.Inherit{
		Import.Module.Sister"Tree"
	}
)

function Prototype:Write()
	error("This method must be implemented")
end

return Class

