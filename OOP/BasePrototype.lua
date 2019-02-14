local Prototype = require("Toolbox.OOP.Prototype")

local Private,Public = Prototype.Make("Base",{})

function Private:Construct()
end

function Private:Deconstruct()
end

return Public
