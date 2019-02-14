local OOP = require"Toolbox.OOP"

local Prototype, Class = OOP.Create"Stack"

function Prototype:Construct()
	self.Items = {}
end

function Prototype:Push(Item)
	table.insert(self.Items,Item)
end

function Prototype:Pop()
	return table.remove(self.Items)
end

function Prototype:Size()
	return #self.Items
end

function Prototype:GetTop()
	return self.Items[self:Size()]
end

function Prototype:AbsoluteIndex(Index)
	if Index < 0 then
		return #self.Items + 1 - Index
	else
		return Index
	end
end

function Prototype:Get(Index)
	return self.Items[self:AbsoluteIndex(Index)]
end

function Prototype:IterateToTop()
	return coroutine.wrap(
		function()
			for Index, Item in pairs(self.Items) do
				coroutine.yield(Index,Item)
			end
		end
	)
end

function Prototype:IterateToBottom()
	return coroutine.wrap(
		function()
			for Index = #self.Items,1,-1 do
				coroutine.yield(Index,self.Items[Index])
			end
		end
	)
end

return Class
