local Import = require("Toolbox.Import.Utils")

local lfs = require"lfs"
local posix = require"posix"
local String,Array = Import.From("Toolbox.Utilities",{"String","Array"})

local Package = {}

function Package.CollapsePathSeperators(Path)
	local Result = Path:gsub("/+","/")
	return Result
end

function Package.Join(Segments)
	return Package.CollapsePathSeperators(table.concat(Segments,"/"))
end

function Package.Parse(Path)
	return String.Explode(Path,"/")
end

Package.Split = Package.Parse

function Package.HasBase(Path)
	return (Path:find("^/") ~= nil)
end

function Package.IsRelative(Path)
	return not Package.HasBase(Path)
end

function Package.RelativePath(ToSegments,FromSegments)
	local CommonSegments = Array.FindMatch(ToSegments,FromSegments)
	local RelativeSegments = Array.Slice(ToSegments,#CommonSegments,#ToSegments)
	if (#CommonSegments == 0) then
		return nil
	end
	for i = 1, (#FromSegments - #CommonSegments) do
		table.insert(RelativeSegments,1,"..")
	end
	return RelativeSegments
end

--[[function Package.Canonicalize(Path)
	local PathSegments = Package.Parse(Path)
	if (Package.IsRelative(Path)) then
		local BaseSegments = Package.Parse(lfs.currentdir())
		PathSegments = Table.Append(PathSegments,BaseSegments)
	end
	local CanonicalizedSegments = {}
	for _,Segment in pairs(PathSegments) do
		if not (Segment == "" or Segment == ".") then
			if (Segment == "..") then
				if (#CanonicalizedSegments == 0) then
					return false, "Path falls out of root"
				end
				table.remove(CanonicalizedSegments)
			else
				table.insert(CanonicalizedSegments,Segment)
			end
		end
	end
	return Package.Join(CanonicalizedSegments)
end]]

function Package.RealPath(Path)
	if posix then
		return posix.realpath(Path)
	else
		local CanonicalPath = Package.Canonicalize(Path)
		return lfs.attributes(CanonicalPath) ~= nil and CanonicalPath or nil
	end
end

function Package.DirName(Path)
	local Segments = Package.Parse(Path)
	table.remove(Segments)
	return Segments
end

return Package
