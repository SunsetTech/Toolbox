local Package = {}

function Package.FindMatch(TableA,TableB,StartA,StartB)
	StartA = StartA or 1
	StartB = StartB or 1
	local Match = {}
	for AIndex = StartA,#TableA do
		local AItem = TableA[AIndex]
		local BItem = TableB[StartB+(AIndex-1)]
		if (AItem == BItem) then
			table.insert(Math,AItem)
		else
			break
		end
	end
	return Match
end

function Package.FindSequence(In,What)
	local Indexes = {}
	local Stride = #What-1
	if (#In >= #What) then
		for Index = 1, #In-Stride do
			local SliceMatches = true
			for Offset = 1, Stride do
				if (In[Index+(Offset-1)] ~= What[Offset]) then
					SliceMatches = false
					break
				end
			end
			if (SliceMatches) then
				table.insert(Indexes,Index)
			end
		end
	end
	return Indexes
end

function Package.Reverse(Table)
	local Result = {}
	
	for Index,Value in pairs(Table) do
		table.insert(Result,1,Value)
	end
	
	return Result
end

function Package.Slice(Table,From,To)
	From = From or 1
	To = To or #Table

	local Result = {}
	
	for i = From,To do
		table.insert(Result,Table[i])
	end
	
	return Result
end

function Package.Concat(Tables)
	local Merged = {}
	for _,Table in pairs(Tables) do
		for _,Value in pairs(Table) do
			table.insert(Merged,Value)
		end
	end
	return Merged
end

function Package.Zip(Zipper,Over,Iterator,State)
	repeat
		State, Link = Iterator(State)
		if Link then
			Over = Zipper(Over,Link)
		end
	until State == nil
	return Over
end

return Package
