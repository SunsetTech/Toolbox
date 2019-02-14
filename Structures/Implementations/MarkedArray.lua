local OOP = require"Toolbox.OOP"

local Prototype, Class = OOP.Create"MarkedArray"

function Prototype:Construct(Items)
	self.Items = Items or {}
	self.Marks = {}
end

function Prototype:InsertItem(Item,Index)
	table.insert(self.Items,Index or #self.Items,Items)
	if Index < #self.Items then
		for MarkIndex,ItemIndex in pairs(self.Marks) do
			if ItemIndex >= Index then
				self.Marks[MarkIndex] = ItemIndex+1
			end
		end
	end
end

function Prototype:RemoveItem(Index)
	for MarkIndex,ItemIndex in GenericUtilities.Iteration.Atomic(self.Marks) do
		if ItemIndex == Index then
			table.remove(self.Marks,MarkIndex)
		elseif ItemIndex > Index then
			self.Marks[MarkIndex] = ItemIndex-1
		end
	end
end

function Prototype:InsertMark(ItemIndex,Index)
	table.insert(self.Marks,Index,ItemIndex)
end

function Prototype:RemoveMark(Index)
	table.remove(self.Marks,Index)
end

function Prototype:GetMarkedItem(Index)
	return self.Items[self.Marks[Index]]
end

function Prototype:AddMarkedItem(Item)
	self:InsertItem(Item)
	self:InsertMark(#self.Items)
end

function Prototype:RemoveMarkedItem(Index)
	self:RemoveItem(self.Marks[Index])
end

function Prototype:IterateMarkedItems()
	return coroutine.wrap(
		function()
			for _,Index in pairs(self.Marks) do
				coroutine.yield(Index,self.Items[Index])
			end
		end
	)
end

return Class

