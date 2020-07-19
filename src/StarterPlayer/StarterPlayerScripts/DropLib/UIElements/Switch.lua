local BaseUiElement = require(script.Parent.BaseUiElement)
local BaseEntry = require(script.Parent.BaseEntry)
local BaseContainer = require(script.Parent.Parent.BaseContainer)
local UIS = game:GetService("UserInputService")
local Config = require(script.Parent.Parent.Config)

local Switch = {}
Switch.__index = Switch
setmetatable(Switch,BaseUiElement)

function Switch:New(size,pos, title, callback,initial)
    local self = setmetatable(BaseUiElement:New(size,pos,title), Switch)
    self.Callback = callback
    self.Value = initial or false
    self.GuiObject = Instance.new("Frame")
	self.Label = Instance.new("TextLabel",self.GuiObject)
	self.Button = Instance.new("TextButton",self.GuiObject)

    self.Button.MouseButton1Click:Connect(function()
        self:SetValue(not self.Value)
		self.Callback(self.Value)
	end)

	return self
end

function Switch:SetValue(value)
    self.Value = value
	if self.Value then
		self.Button.BackgroundColor3 = Config.AccentColor
	else
		self.Button.BackgroundColor3 = Config.SecondaryColor
	end
end

function Switch:UpdateGui()
    self.GuiObject.Size = self.Size
    self.GuiObject.BackgroundTransparency = 1
    self.GuiObject.Position = self.Position
    self.Label.Text = self.Title
    self.Label.TextSize = Config.TextSize
    self.Label.Font = Config.Font
    self.Label.BackgroundTransparency = 1
    self.Label.Size = UDim2.new(0.8,0,1,0)
    self.Label.TextColor3 = Config.TextColor
    self.Button.Size = UDim2.new(0,20,0,20)
    self.Button.BorderSizePixel = 2
    self.Button.BorderColor3 = Config.SecondaryColor
    self.Button.Position = UDim2.new(0.9,-10,0.5,-10)
    self.Button.Text = ""
    self:SetValue(self.Value)
end

local SwitchEntry= {}
SwitchEntry.__index = SwitchEntry
setmetatable(SwitchEntry,BaseEntry)

function SwitchEntry:New(title, callback,initial)
    local self = setmetatable(BaseEntry:New(), SwitchEntry)
    self.Switch = Switch:New(UDim2.new(1,-10,1,-10),UDim2.new(0,5,0,5),title, callback,initial)
    self:AddChild(self.Switch)
    return self
end

function SwitchEntry:SetValue(val)
    self.Switch:SetValue(val)
end

function SwitchEntry:GetValue()
    return self.Switch.Value
end

function BaseContainer:CreateSwitch(title, callback,initial)
    local entry = SwitchEntry:New(title, callback,initial)
    self:AddEntry(entry)
    return entry
end

return Switch