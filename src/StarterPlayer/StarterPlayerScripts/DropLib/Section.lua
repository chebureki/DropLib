local TypeEnum = require(script.Parent.TypeEnum)
local BaseContainer = require(script.Parent.BaseContainer)
local Config = require(script.Parent.Config)

local Section = {}
Section.__index = Section
setmetatable(Section,BaseContainer)

function Section:New(title)
    local self = setmetatable(BaseContainer:New(title,TypeEnum.Section), Section)
    return self
end

function BaseContainer:CreateSection(title)
    local sec = Section:New(title)
    self:AddChild(sec)
    sec:RecursiveUpdateGui()
    return sec
end

return Section