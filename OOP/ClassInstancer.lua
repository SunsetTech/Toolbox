local ClassInstance = require("Toolbox.OOP.ClassInstance")

local function NoConstructorError()
	error"No constructor"
end

local Prototype = {
	New = function(self,...)
		local Instance = ClassInstance.Make(self.Prototype)
		local Success, Error = pcall(
			Instance.Construct or NoConstructorError,
			Instance,...
		)
		if Success then
			return Instance
		else
			error("Error constructing an ".. Instance:GetType() ..": ".. Error)
		end
	end,
	GetClassType = function(self)
		return self.Prototype.GetType()
	end
}

local Metatable = {
	__index = Prototype,
	__type = "ClassInstancer",
	__newindex = function(Self,Key,Value)
		error("Cannot modify a class instancer")
	end,
	__call = function(Self,...)
		return Self:New(...)
	end
}

local Package = {}

function Package.Make(PublicPrototype)
	return setmetatable(
		{
			Prototype = PublicPrototype
		},
		Metatable
	)
end

return Package
