local Import = require"Toolbox.Import"

local OOP = require"Toolbox.OOP"

local Prototype, Class = OOP.Create(
	"DebugPrintTree",
	OOP.Inherit{
		Import.Module.Sister"DebugTree";
		require"Toolbox.Structures.Implementations.PrinterTree";
	}
)

function Prototype:Construct()
	Prototype.Parents.PrinterTree.Construct(self)
	self.Enabled = true
	self.IncludeSource = true
	self.Filters = {}
end

function Prototype:SetEnabled(Toggle)
	self.Enabled = Toggle
end

function Prototype:SetIncludeSource(Toggle)
	self.IncludeSource = Toggle
end

function Prototype:SetFilter(Name,Filter)
	self.Filters[Name] = Filter
end

Prototype.Push = Prototype.Parents.PrinterTree.Push
function Prototype:Add(Format,...) 
	Prototype.Parents.DebugTree.Add(self,Format:format(...))
end

function Prototype:ShouldFilter(Item)
	for _,Filter in pairs(self.Filters) do
		if Filter(Item) then
			return true
		end
	end
	return false
end

function Prototype:Write(Item)
	if self.Enabled and not self:ShouldFilter(Item) then
		local SourceMessage = ""
		if self.IncludeSource then
			SourceMessage = ("[%s:%s] "):format(Item.Info.short_src,Item.Info.currentline)
		end
		local Message = SourceMessage .. Item.Message
		Prototype.Parents.PrinterTree.Add(self,Message)
	end
end

Prototype.Pop = Prototype.Parents.PrinterTree.Pop

return Class
