local lfs = require"lfs"
local posix = require"posix"

local Iteration = require"Toolbox.Utilities.Iteration"
local Path = require"Toolbox.Utilities.Path"

local Debug = require"Toolbox.Debug"
local DebugSink = Debug.Registry.Acquire"Toolbox.Utilities.Filesystem"

local Package = {}

function Package.Attributes(Name)
	return lfs.symlinkattributes(Name)
end

function Package.Exists(Name)
	return Package.Attributes(Name) ~= nil
end

function Package.Type(Name)
	if Package.Exists(Name) then
		return Package.Attributes(Name).mode
	else
		return nil
	end
end

function Package.IsType(Name,Type)
	return Package.Attributes(Name).mode == Type
end

function Package.FilterSpecial(Name)
	if (Name ~= "." and Name ~= "..") then
		return true, Name
	else
		return false, Name
	end
end

function Package.FilterHidden(Name)
	if not Name:match("^%.") then
		return true, Name
	else
		return false, Name
	end
end

function Package.List(Name,FilterSpecial,FilterHidden)
	return Iteration.MakeFilter(
		(
			FilterHidden and Package.FilterHidden 
			or (
				FilterSpecial and Package.FilterSpecial
				or Filters.NoOp
			)
		),
		lfs.dir,Name
	)
end

function Package.Recurse(BaseName,FilterSpecial,FilterHidden,BaseSubName)
	return coroutine.wrap(
		function()
			local ListName
			if BaseSubName then
				ListName = BaseName .."/".. BaseSubName
			else
				ListName = BaseName
			end
			local CurrentSubName
			if BaseSubName then
				CurrentSubName = BaseSubName
			else
				CurrentSubName = "."
			end
			for SubName in Package.List(ListName,FilterSpecial,FilterHidden) do
				coroutine.yield(CurrentSubName,SubName)
				local FullName = ListName .."/".. SubName
				if Package.Exists(FullName) and Package.IsType(FullName,"directory")  then
					local RecurseName
					if BaseSubName then
						RecurseName = BaseSubName .."/".. SubName
					else
						RecurseName = SubName
					end
					for RecurseName,RecurseSubName in Package.Recurse(BaseName,FilterSpecial,FilterHidden,RecurseName) do
						coroutine.yield(RecurseName,RecurseSubName)
					end
				end
			end
		end
	)
end

function Package.Copy(From,To,Dry)
	DebugSink:Add("Copying %s to %s",From,To)
	if not Dry then
		local FromFile = io.open(From,"r")
		local ToFile = io.open(To,"w")
		ToFile:write(FromFile:read("a"))
		FromFile:close()
		ToFile:close()
	end
end

function Package.Write(Name,Contents,Dry)
	DebugSink:Add("Writing to %s", Name)
	if not Dry then
		Mode = Mode or "w+"
		local File = io.open(Name,Mode)
		File:write(Contents)
		File:close()
	end
end

local function Execute(String,...)
	String = String:format(...)
	DebugSink:Add("Executing: %s",String)
	return os.execute(String)
end

function Package.CreateDirectory(Name,Dry)
	DebugSink:Add("Creating directory %s", Name)
	if not Dry then
		Execute([[mkdir -p "%s"]],Name)
	end
end

function Package.ChangePath(Root,Function,...)
	DebugSink:Add("Changing to %s", Root)
	DebugSink:Push()
		local Current = lfs.currentdir()
		lfs.chdir(Root)
		local Returns = {Function(...)}
		lfs.chdir(Current)
	DebugSink:Pop()
	return table.unpack(Returns)
end


function Package.Delete(Name,Dry)
	if Package.Exists(Name) then
		DebugSink:Add("Deleting %s", Name)
		if not Dry then
			return Execute([[rm -rf "%s"]],Name)
		end
	end
end

function Package.SymbolicLink(Name,Target,Absolute,Dry)
	DebugSink:Add("Linking %s to %s",Name,Target)
	if not Dry then
		Absolute = Absolute or true
		if Absolute then 
			Target = posix.realpath(Target)
		end
		lfs.link(Target,Name,true)
	end
end

return Package
