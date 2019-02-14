local OOP = require"Toolbox.OOP"

local Prototype, Class = OOP.Create"TableTree"

function Prototype:Construct()
	self.Tree = {}
	self.Stack = {self.Tree}
end

function Prototype:Push()
	local Branch = {}
	table.insert(self.Tree,Branch)
	table.insert(self.Stack,Branch)
end

function Prototype:Add(Item)
	table.insert(self.Tree,Item)
end

function Prototype:Pop()
	return table.remove(self.Stack)
end

return Class
