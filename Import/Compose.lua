local Utils = require"Toolbox.Import.Utils"

local Function, Env = Utils.From("Toolbox.Utilities",{"Function","Env"})

local Package = {}

function Package.Override(Require,OverrideRequire)
	local NewEnv = Env.MakeOverlay(
		{require=OverrideRequire},
		_ENV
	)
	return Function.Copy(Require,NewEnv,true)
end

local OldRequire = require

local function DefaultRequire(...)
	return OldRequire(...)
end

function Package.Pipeline(Functions,InnerRequire)
	--Create a copy of require to ensure the env is the current env
	InnerRequire = InnerRequire or DefaultRequire
	local Pipeline = Function.Copy(InnerRequire,_ENV,true)
	for Index = 1, #Functions do
		Pipeline = Package.Override(Functions[Index],Pipeline)
	end
	return Pipeline
end

return Package
