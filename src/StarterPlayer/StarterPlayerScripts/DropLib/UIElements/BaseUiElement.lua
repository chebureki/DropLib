local BaseObject = require(script.Parent.Parent.BaseObject)
local TypeEnum = require(script.Parent.Parent.TypeEnum)

local BaseUiElement= {}
BaseUiElement.__index = BaseUiElement
setmetatable(BaseUiElement,BaseObject)

function BaseUiElement:New(size,position,title)
    local self = setmetatable(BaseObject:New(TypeEnum.UiElement), BaseUiElement)
    self.Value = nil
    self.Title = title
    self.Size = size
    self.Position = position
    return self
end

function BaseUiElement:SetValue()
    --supposed to be overwritten
end

function BaseUiElement:GetValue()
    return self.Value
end

return BaseUiElement