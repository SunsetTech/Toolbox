local l = require("lpeg")

local Anything = l.P(1)
local Package = {}

Package.URLGrammar = {
	"URL";
	Protocol = 
		l.Cg((Anything - l.P("://"))^0,"Protocol") 
		* l.P"://";
	DomainPart = l.C((Anything - l.S"./:")^0);
	Domain = 
		l.Cg(
			l.Ct(
				l.V"DomainPart" * (l.P"." * l.V"DomainPart")^0
			),
			"Domain"
		);
	Port = l.P":" * l.Cg(l.S"1234567890"^1,"Port");
	PathPart = l.C((Anything - l.S"/?")^0);
	Path = l.Cg(
		l.Ct((l.P"/"^1 * l.V"PathPart")^1),
		"Path"
	);
	ParameterKey = l.Cg((Anything - l.P"=")^1,"Key");
	ParameterValue = l.Cg((Anything - l.P"&")^1,"Value");
	Parameter = l.Ct(l.V"ParameterKey" * l.P"=" * l.V"ParameterValue");
	Parameters =
		l.Cg(
			l.P"?"
			* l.Ct(
				l.V"Parameter" * (l.P"&" * l.V"Parameter")^0
			),
			"Parameters"
		);
	URL = l.Ct(l.V"Protocol"^-1 * l.V"Domain"^-1 * l.V"Port"^-1 * l.V"Path"^-1 * l.V"Parameters"^-1)
}

function Package.Parse(URL)
	return l.match(Package.URLGrammar, URL)
end

return Package


