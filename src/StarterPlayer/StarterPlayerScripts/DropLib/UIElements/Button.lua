local BaseUiElement = require(script.Parent.BaseUiElement)
local BaseEntry = require(script.Parent.BaseEntry)
local BaseContainer = require(script.Parent.Parent.BaseContainer)
local Config = require(script.Parent.Parent.Config)

local Button = {}
Button.__index = Button
setmetatable(Button,BaseUiElement)

function Button:New(size,pos,title,callback)
    local self = setmetatable(BaseUiElement:New(size,pos,title), Button)
    self.Callback = callback
    self.GuiObject = Instance.new("TextButton")
    self.GuiObject.MouseButton1Click:Connect(self.Callback)
    return self
end

function Button:UpdateGui()
    self.GuiObject.BorderSizePixel = 0
    self.GuiObject.BackgroundColor3 = Config.SecondaryColor
    self.GuiObject.TextColor3 = Config.TextColor
    self.GuiObject.Size = self.Size
    self.GuiObject.Position = self.Position
    self.GuiObject.Text = self.Title
    self.GuiObject.TextSize = Config.TextSize
    self.GuiObject.Font = Config.Font
end

function BaseContainer:CreateButton(title,callback)
    local entry = BaseEntry:New()
    entry:AddChild(Button:New(UDim2.new(1,-10,1,-10),UDim2.new(0,5,0,5),title,callback))
    self:AddEntry(entry)
    return entry
end

return Button