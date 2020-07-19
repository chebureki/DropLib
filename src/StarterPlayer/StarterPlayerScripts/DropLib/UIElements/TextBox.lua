local BaseUiElement = require(script.Parent.BaseUiElement)
local BaseEntry = require(script.Parent.BaseEntry)
local BaseContainer = require(script.Parent.Parent.BaseContainer)
local UIS = game:GetService("UserInputService")
local Config = require(script.Parent.Parent.Config)

local TextBox = {}
TextBox.__index = TextBox
setmetatable(TextBox,BaseUiElement)

function TextBox:New(size,pos,title,callback,acceptFormat,dynamic,initial)
    local self = setmetatable(BaseUiElement:New(size,pos,title), TextBox)
    self.Callback = callback
    self.Dynamic = dynamic or false
	self.Value = initial or ""
	self.AcceptFormat = acceptFormat or "^.*$"
	self.GuiObject = Instance.new("TextBox")
			
	self.GuiObject.FocusLost:Connect(function()
		if string.match(self.GuiObject.Text,self.AcceptFormat)then
				self:SetValue(self.GuiObject.Text)
				self.Callback(self.Value)
		else
			self.GuiObject.Text = self.Value
		end
	end)
	
	self.GuiObject.Changed:Connect(function(prop)
		if self.Dynamic and prop == "Text" and self.GuiObject:IsFocused() then
			if string.match(self.GuiObject.Text,self.AcceptFormat)then			
				self:SetValue(self.GuiObject.Text)
				self.Callback(self.Value)
			else
				self.GuiObject.Text = self.Value
			end
		end
	end)

	return self
end

function TextBox:SetValue(val)
    self.GuiObject.Text = val
    self.Value = val
end

function TextBox:UpdateGui()
    self.GuiObject.BackgroundColor3 = Config.SecondaryColor
    self.GuiObject.TextColor3 = Config.TextColor
    
    self.GuiObject.PlaceholderText = self.Title
    self.GuiObject.Position = self.Position
    self.GuiObject.Size = self.Size
    self.GuiObject.TextSize = Config.TextSize
    self.GuiObject.Font = Config.Font
    self.GuiObject.BorderSizePixel = 0
    self:SetValue(self.Value)
end

local TextBoxEntry= {}
TextBoxEntry.__index = TextBoxEntry
setmetatable(TextBoxEntry,BaseEntry)

function TextBoxEntry:New(title,callback,acceptFormat,dynamic,initial)
    local self = setmetatable(BaseEntry:New(), TextBoxEntry)
    self.TextBox = TextBox:New(UDim2.new(1,-10,1,-10),UDim2.new(0,5,0,5),title,callback,acceptFormat,dynamic,initial)
    self:AddChild(self.TextBox)
    return self
end

function TextBoxEntry:SetValue(val)
    self.TextBox:SetValue(val)
end

function TextBoxEntry:GetValue()
    return self.TextBox.Value
end

function BaseContainer:CreateTextBox(title,callback,acceptFormat,dynamic,initial)
    local entry = TextBoxEntry:New(title,callback,acceptFormat,dynamic,initial)
    self:AddEntry(entry)
    return entry
end

return TextBox