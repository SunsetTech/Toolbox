local Package = {}

function Package.ReadAll(FileHandle,CloseAfter)
	local Lines = {}
	for Line in FileHandle:lines() do
		table.insert(Lines,Line)
	end
	if CloseAfter then
		FileHandle:close()
	end
	return table.concat(Lines,"\n")
end

return Package
