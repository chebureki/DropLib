local BaseUiElement = require(script.Parent.BaseUiElement)
local BaseEntry = require(script.Parent.BaseEntry)
local BaseContainer = require(script.Parent.Parent.BaseContainer)
local Config = require(script.Parent.Parent.Config)

local TextLabel = {}
TextLabel.__index = TextLabel
setmetatable(TextLabel,BaseUiElement)

function TextLabel:New(size,pos,title)
    local self = setmetatable(BaseUiElement:New(size,pos,title), TextLabel)
    self.GuiObject = Instance.new("TextLabel")
    return self
end

function TextLabel:UpdateGui()
    self.GuiObject.BorderSizePixel = 0
    self.GuiObject.BackgroundTransparency = 1
    self.GuiObject.TextColor3 = Config.TextColor
    self.GuiObject.Size = self.Size
    self.GuiObject.Position = self.Position
    self.GuiObject.Text = self.Title
    self.GuiObject.TextSize = Config.TextSize
    self.GuiObject.Font = Config.Font
end

function BaseContainer:CreateTextLabel(title)
    local entry = BaseEntry:New()
    entry:AddChild(TextLabel:New(UDim2.new(1,-10,1,-10),UDim2.new(0,5,0,5),title))
    self:AddEntry(entry)
    return entry
end

return TextLabel