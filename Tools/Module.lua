local lfs = require("lfs")
local String = require("Toolbox.Utilities.String")
local Array = require("Toolbox.Utilities.Array")

local Package = {}

function Package.ModuleNameToPath(ModuleName)
	return ModuleName:gsub("%.","/")
end

function Package.GenerateSearchPath(Path,ModuleName)
	return Path:gsub("?",Package.ModuleNameToPath(ModuleName))
end

function Package.FindLoader(ModuleName)
	local Messages = {}
	for _,Searcher in pairs(package.searchers) do
		local Loader,Path = Searcher(ModuleName)
		if (type(Loader) == "function") then
			return Loader,Path
		elseif (type(Loader) == "string") then
			table.insert(Messages,Loader)
		end
	end
	error(table.concat(Messages,"\n"))
end

function Package.Locate(ModuleName)
	return package.searchpath(ModuleName,package.path) or package.searchpath(ModuleName,package.cpath)
end

function Package.ParseSearchPaths(SearchPaths)
	return String.Explode(SearchPaths,";")
end

function Package.ConcatSearchPaths(SearchPaths)
	return table.concat(SearchPaths,";")
end

function Package.Split(ModuleName)
	return String.Split(ModuleName,".")
end

function Package.Join(ModuleNameParts)
	return table.concat(ModuleNameParts,".")
end

function Package.ParentName(ModuleName)
	local ModuleNameParts = Package.Split(ModuleName)
	if #ModuleNameParts == 1 then
		return ""
	end
	return Package.Join(Array.Slice(ModuleNameParts,1,#ModuleNameParts-1))
end

return Package
