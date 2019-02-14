local l = require"lpeg"

local Package = {}

function Package.Explode(String,Divider) -- credit: http://richard.warburton.it
	if (Divider=='') then
		local Results = {}
		for I = 1, #String do
			table.insert(Results,String:sub(I,I))
		end
		return Results
	end
	local Position = 0
	local Results = {}
	-- for each divider found
	for StartPos,EndPos in function() return string.find(String,Divider,Position,true) end do
		table.insert(Results,string.sub(String,Position,StartPos-1)) -- Attach chars left of current divider
		Position = EndPos + 1 -- Jump past current divider
	end
	table.insert(Results,string.sub(String,Position)) -- Attach chars right of last divider
	return Results
end

Package.Split = Package.Explode

function Package.TokenReplace(String,Tokens)
	return string.gsub(
		String,
		"%$(%w+)",
		Tokens
	)
end

function Package.PatternEscape(String)
	return String:gsub("([%^%$%(%)%.%[%]%*%+%-%?%%])","%%%1")
end

function Package.PatternUnescape(String)
	return String:gsub("%%(.)","%1")
end

function Package.TrimWhitespace(String)
	return String:match("%s*(.*)%s*")
end

function Package.CollapseWhitespace(String)
	return String:gsub("%s+"," ")
end

function Package.Splice(String,Start,End,Replacement) --Replace everything >>between<< Start & End positions with Replacement
	local Prefix = string.sub(String,1,Start)
	local Suffix = string.sub(String,End,#String)
	return Prefix .. Replacement .. Suffix
end

Package.Unescapes = {}

function Package.Unescapes.Basic(Code)
	if Code == [[\]] then return [[\]]
	elseif Code == "a" then return "\a"
	elseif Code == "b" then return "\b"
	elseif Code == "f" then return "\f"
	elseif Code == "n" then return "\n"
	elseif Code == "r" then return "\r"
	elseif Code == "t" then return "\t"
	elseif Code == "v" then return "\v"
	elseif Code == "0" then return "\0"
	end
end

function Package.Unescapes.Byte(Code)
	return string.char(Code)
end

function Package.Unescapes.Unicode(Code)
	return utf8.char(Code)
end

function Package.Unescapes.Discard()
	return ""
end

local function HexToDec(Hex)
	return tonumber("0x".. Hex)
end

Package.UnescapeGrammar = {
	"STRING";
	ESCAPE_BASIC = l.S[[\abfnrtv]] / Package.Unescapes.Basic;
	ESCAPE_NEWLINE = l.S"\r\n" / Package.Unescapes.Discard;
	ESCAPE_INSERT_BYTE =
		(
			(l.R"09"^-3) / tonumber
			+ (
				l.P"x" 
				* ((l.R"af" + l.R"AF") * (l.R"af" + l.R"AF")) / HexToDec
			)
		)
		/ Package.Unescapes.Byte;

	ESCAPE_INSERT_UNICODE = 
		l.P"u" * l.P"{"
		* ((l.R"af" + l.R"AF")^1) / HexToDec / Package.Unescapes.Unicode
		* l.P"}";
	
	ESCAPE_WHITESPACE = 
		l.P"z" * (l.S"\r\n\t ") / Package.Unescapes.Discard;

	ESCAPE_SEQUENCE = 
		l.P[[\]] / Package.Unescapes.Discard
		* (
			l.V"ESCAPE_BASIC" 
			+ l.V"ESCAPE_NEWLINE" + l.V"ESCAPE_WHITESPACE" 
			+ l.V"ESCAPE_INSERT_BYTE" + l.V"ESCAPE_INSERT_UNICODE"
		);

	STRING = l.Cs( (l.V"ESCAPE_SEQUENCE" + l.P(1))^0 );
}

function Package.Unescape(String)
	return l.match(Package.UnescapeGrammar,String)
end

function Package.Format(String)
	return function(...)
		return String:format(...)
	end
end

return Package
