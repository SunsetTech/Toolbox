local Package = {}

function Package.MakePrivate(PrototypeMetadata,PrototypeData)
	return setmetatable(
		{
		},
		{
			__index = function(Table,Key)
				if (PrototypeMetadata[Key]) then
					return PrototypeMetadata[Key]
				elseif (PrototypeData[Key]) then
					return PrototypeData[Key]
				else
					for ParentName,Parent in pairs(PrototypeMetadata.Parents) do
						if (Parent[Key]) then
							return Parent[Key]
						end
					end
				end
				return nil
			end,
			__newindex = function(Table,Key,Value)
				if (PrototypeMetadata[Key]) then
					error("Can't overwrite prototype metadata")
				else
					PrototypeData[Key] = Value
				end
			end,
			__type = "PrivatePrototype"
		}
	)
end

function Package.MakePublic(PrototypeMetadata,PrototypeData)
	return setmetatable(
		{
		},
		{
			__index = function(Table,Key)
				if (PrototypeData[Key]) then
					return PrototypeData[Key]
				else
					for ParentName,Parent in pairs(PrototypeMetadata.Parents) do
						if (Parent[Key]) then
							return Parent[Key]
						end
					end
				end
				return nil
			end,
			__newindex = function(Table,Key,Value)
				error("Can't mutate a Public Prototype")
			end,
			__type = "PublicPrototype"
		}
	)
end

function Package.Make(Type,Parents)
	local PrototypeMetadata = {
		Type = Type,
		Parents = Parents
	}
	
	local PrototypeData = { --would be nice if these were public but not overwriteable
		GetType = function(_)
			return PrototypeMetadata.Type
		end,
		GetTypeHierarchy = function(_)
			local ParentTypeHierarchies = {}
			for ParentName,Parent in pairs(PrototypeMetadata.Parents) do
				table.insert(ParentTypeHierarchies,Parent.GetTypeHierarchy(_))
			end
			return {Type=PrototypeMetadata.Type,Parents=ParentTypeHierarchies}
		end,
		IsTypeOf = function(_,Type)
			if (PrototypeMetadata.Type == Type) then
				return true
			else
				for ParentName,Parent in pairs(PrototypeMetadata.Parents) do
					if (Parent.IsTypeOf(_,Type)) then
						return true
					end
				end
			end
			return false
		end,
		Construct = function(self,...)
			for ParentName,Parent in pairs(PrototypeMetadata.Parents) do
				for k,v in pairs(Parent) do print(k,v) end
				Parent.Construct(self,...)
			end
		end,
		Deconstruct = function(self,...)
			for ParentName,Parent in pairs(PrototypeMetadata.Parents) do
				Parent.Deconstruct(self,...)
			end
		end
	}

	return Package.MakePrivate(PrototypeMetadata,PrototypeData), Package.MakePublic(PrototypeMetadata,PrototypeData)
end

return Package
