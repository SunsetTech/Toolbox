local Package = {}

function Package.Make(Prototype)
	return	setmetatable(
		{
		},
		{
			__index = function(Table,Key)
				if (Prototype[Key]) then
					return Prototype[Key]
				else
					return rawget(Table,Key)
				end
			end,
			__newindex = function(Table,Key,Value)
				if (Prototype[Key]) then
					error("Can't override fields set by prototypes")
				else
					rawset(Table,Key,Value)
				end
			end,
			__gc = function(Table)
				Table:Deconstruct()
			end,
			__type = "ClassInstance"
		}
	)
end

return Package
