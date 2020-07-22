local BaseUiElement = require(script.Parent.BaseUiElement)
local BaseEntry = require(script.Parent.BaseEntry)
local BaseContainer = require(script.Parent.Parent.BaseContainer)
local UIS = game:GetService("UserInputService")
local Config = require(script.Parent.Parent.Config)

local KeyDetector = {}
KeyDetector.__index = KeyDetector
setmetatable(KeyDetector,BaseUiElement)

function KeyDetector:New(size,pos, title, callback,initial)
    local self = setmetatable(BaseUiElement:New(size,pos,title), KeyDetector)
    self.Callback = callback
    self.Value = initial or Enum.KeyCode.Unknown
    self.GuiObject = Instance.new("Frame")
	self.Label = Instance.new("TextLabel",self.GuiObject)
	self.Button = Instance.new("TextButton",self.GuiObject)

    self.Button.MouseButton1Click:Connect(function()
        self.Button.Text = "..."
		local pressed
		repeat
			pressed = UIS.InputBegan:Wait()
		until pressed.UserInputType == Enum.UserInputType.Keyboard
		self:SetValue(pressed.KeyCode)
		self.Callback(self.Value)
	end)

	return self
end

function KeyDetector:SetValue(value)
    self.Value = value
    self.Button.Text = value.Name
end

function KeyDetector:UpdateGui()
    self.GuiObject.BackgroundTransparency = 1
	self.GuiObject.Size = self.Size
	self.GuiObject.Position = self.Position
	self.Label.Size = UDim2.new(0.8,0,1,0)
	self.Label.BackgroundTransparency = 1
	self.Label.TextSize = Config.TextSize
	self.Label.Text = self.Title
    self.Label.Font = Config.Font
    self.Label.TextColor3 = Config.TextColor
	self.Button.Size = UDim2.new(0.2,0,1,0)
	self.Button.BorderSizePixel = 0
	self.Button.TextColor3 = Config.TextColor
	self.Button.BackgroundColor3 = Config.SecondaryColor
	self.Button.Position = UDim2.new(0.8,0,0,0)
	self:SetValue(self.Value)
end

local KeyDetectorEntry= {}
KeyDetectorEntry.__index = KeyDetectorEntry
setmetatable(KeyDetectorEntry,BaseEntry)

function KeyDetectorEntry:New(title, callback,initial)
    local self = setmetatable(BaseEntry:New(), KeyDetectorEntry)
    self.KeyDetector = KeyDetector:New(UDim2.new(1,-10,1,-10),UDim2.new(0,5,0,5),title, callback,initial)
    self:AddChild(self.KeyDetector)
    return self
end

function KeyDetectorEntry:SetValue(val)
    self.KeyDetector:SetValue(val)
end

function KeyDetectorEntry:GetValue()
    return self.KeyDetector.Value
end

function BaseContainer:CreateKeyDetector(title, callback,initial)
    local entry = KeyDetectorEntry:New(title, callback,initial)
    self:AddEntry(entry)
    return entry
end

return KeyDetector