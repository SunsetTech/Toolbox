local Package = {}

local function GetOption(Argument)
	return Argument:match"-+(.+)"
end

local function IsOption(Argument)
	return GetOption(Argument) ~= nil
end

function Package.ParseOptions(Arguments,Options)
	local Orphans = {}
	local Map = {}
	while #Arguments > 0 do
		local Argument = table.remove(Arguments,1)
		if IsOption(Argument) then
			local Name = GetOption(Argument)
			local Option = Options[Name]
			local Setting
			if not IsOption(Arguments[1]) then
				local Convert = Option.Convert or tostring
				Setting = Convert(table.remove(Arguments,1))
			end
			Map[Name] = Setting or true
		else
			table.insert(Orphans,Argument)
		end
	end
	local Settings =  {}
	for Name,Option in pairs(Options) do
		Settings[Name] = Map[Name] or Option.Default
	end
	return Settings, Orphans
end

return Package
