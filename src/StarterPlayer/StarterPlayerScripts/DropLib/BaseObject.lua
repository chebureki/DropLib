local TypeEnum = require(script.Parent.TypeEnum)

local BaseObject = {}
BaseObject.__index = BaseObject

function BaseObject:New(type,parent,guiObject)
    local self = setmetatable({},BaseObject)
    self.Type = type or TypeEnum.Unknown
    self.Parent = parent or self.Parent
    self.Children = {}
	self.GuiObject = guiObject or nil
	if parent then
		parent:AddChild(self)
	end
	return self
end

function BaseObject:AddChild(child)
    child.Parent = self
    table.insert(self.Children,child)
    if child.GuiObject and self.GuiObject then
        child.GuiObject.Parent = self.GuiObject
    end
end

function BaseObject:RecursiveUpdateGui()
    self:UpdateGui()
    for _,child in ipairs(self.Children) do
        child:RecursiveUpdateGui()
    end
end

function BaseObject:UpdateGui()
    --supposed to be overwritten
end

return BaseObject