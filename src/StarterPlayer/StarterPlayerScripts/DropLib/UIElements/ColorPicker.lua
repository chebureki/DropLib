local BaseUiElement = require(script.Parent.BaseUiElement)
local BaseEntry = require(script.Parent.BaseEntry)
local BaseContainer = require(script.Parent.Parent.BaseContainer)
local Slider = require(script.Parent.Slider)
local TextBox = require(script.Parent.TextBox)
local UIS = game:GetService("UserInputService")
local Config = require(script.Parent.Parent.Config)

local ColorPicker = {}
ColorPicker.__index = ColorPicker
setmetatable(ColorPicker,BaseUiElement)

function ColorPicker:New(size,pos,title,callback,acceptFormat,dynamic,initialColor)
    local self = setmetatable(BaseUiElement:New(size,pos,title), ColorPicker)
    self.Callback = callback
    self.Dynamic = dynamic or false
	self.Value = initialColor or Config.AccentColor	
	self.GuiObject = Instance.new("Frame")
	self.ColorImg = Instance.new("ImageLabel",self.GuiObject)
	self.Cursor = Instance.new("Frame",self.ColorImg)
	self.RSlider = Slider:New(UDim2.new(0.5,-10,1/6,0),UDim2.new(0.5,5,0/6,2),"Red",function(r) self:SetValue(Color3.new(r/255,self.Value.G,self.Value.B))end,0,255,1,true,self.Value.R,Color3.new(0.75,0,0))
	self:AddChild(self.RSlider)
	self.GSlider = Slider:New(UDim2.new(0.5,-10,1/6,0),UDim2.new(0.5,5,1/6,4),"Green",function(g) self:SetValue(Color3.new(self.Value.R,g/255,self.Value.B))end,0,255,1,true,self.Value.G,Color3.new(0,0.75,0))
	self:AddChild(self.GSlider)
	self.BSlider = Slider:New(UDim2.new(0.5,-10,1/6,0),UDim2.new(0.5,5,2/6,6),"Blue",function(b) self:SetValue(Color3.new(self.Value.R,self.Value.G,b/255))end,0,255,1,true,self.Value.B,Color3.new(0,0,0.75))
	self:AddChild(self.BSlider)
	self.HexBox = TextBox:New(UDim2.new(0.5,-10,1/6,0),UDim2.new(0.5,5,3/6,8),"",function(txt) 
		local nums = {}
		for hex in txt:gmatch("%x%x") do
			table.insert(nums,tonumber("0x"..hex))
		end
		self:SetValue(Color3.fromRGB(unpack(nums)))
	end,"^%x%x%x%x%x%x$")
	self:AddChild(self.HexBox)
	self.VSlider = Slider:New(UDim2.new(0.5,-10,1/6,0),UDim2.new(0.5,5,5/6,-2),"Value",function(v) local h,s = Color3.toHSV(self.Value) self:SetValue(Color3.fromHSV(h,s,v/255))end,0,255,1,true,({Color3.toHSV(self.Value)})[3],Color3.new(0.75,0.75,0.75))
	self:AddChild(self.VSlider)
	
	self.ColorImg.MouseMoved:Connect(function(x,y)
		if UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
			local rp = Vector2.new(x,y-36)-self.ColorImg.AbsolutePosition
			local hue,sat = 1-rp.X/self.ColorImg.AbsoluteSize.X, 1-rp.Y/self.ColorImg.AbsoluteSize.Y
			self:SetValue(Color3.fromHSV(hue,sat,self.VSlider.Value/255))
		end
	end)
	
	self.ColorImg.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			local rp = Vector2.new(input.Position.X,input.Position.Y)-self.ColorImg.AbsolutePosition
			local hue,sat = 1-rp.X/self.ColorImg.AbsoluteSize.X, 1-rp.Y/self.ColorImg.AbsoluteSize.Y
			self:SetValue(Color3.fromHSV(hue,sat,self.VSlider.Value/255))
		end
	end)

	self:SetValue(self.Value)
	return self
end

function ColorPicker:SetValue(color)
    self.Value = color
	local h,s,v = Color3.toHSV(color)
	self.Cursor.Position = UDim2.new(1-h,-2,1-s,-2)
	self.VSlider:SetValue(v*255)
	self.RSlider:SetValue(color.R*255)
	self.GSlider:SetValue(color.G*255)
	self.BSlider:SetValue(color.B*255)
	self.HexBox:SetValue(string.format("%02x%02x%02x",self.Value.R*255,self.Value.G*255,self.Value.B*255))
	self.Callback(self.Value)
end

function ColorPicker:UpdateGui()
    self.GuiObject.Size = self.Size
	self.GuiObject.Position = self.Position
	self.GuiObject.BackgroundTransparency = 1
	self.ColorImg.Image = "rbxassetid://698052001"
	self.ColorImg.Size = UDim2.new(0.5,-10,1,-10)
	self.ColorImg.BorderSizePixel = 0
	self.ColorImg.Position = UDim2.new(0,5,0,5)
	self.Cursor.Size = UDim2.new(0,4,0,4,0)
	self.Cursor.BorderSizePixel = 0
	self.Cursor.BackgroundColor3 = Color3.new(1,1,1)
	self:SetValue(self.Value)
end

local ColorPickerEntry= {}
ColorPickerEntry.__index = ColorPickerEntry
setmetatable(ColorPickerEntry,BaseEntry)

function ColorPickerEntry:New(title,callback,dynamic,initial)
    local self = setmetatable(BaseEntry:New(), ColorPickerEntry)
	self.Title = title
	self.Dynamic = dynamic
	self.Callback = callback
	self.Label = Instance.new("TextLabel",self.GuiObject)
	self.ColorButton = Instance.new("TextButton",self.Label)
    self.ColorPicker = ColorPicker:New(UDim2.new(1,0,0,Config.HeaderWidth/2),UDim2.new(0,0,0,Config.DefaultEntryHeight),title,function(color)
        self.ColorButton.BackgroundColor3 = color
		self.Value = color
        if self.Dynamic and self.Toggled then
            pcall(self.Callback,color)
        end
    end,initial)
    self.Toggled = false
    self.ColorButton.MouseButton1Click:Connect(function()
        if self.Toggled then
            self.Height = Config.DefaultEntryHeight
            pcall(callback,self.Value)
        else
            self.Height = Config.HeaderWidth/2 + Config.DefaultEntryHeight
        end
        
        self.GuiObject:TweenSize(UDim2.new(1,0,0,self.Height),Enum.EasingDirection.InOut,Config.AnimationEasingStyle,Config.AnimationDuration,true)
        self.Parent:ReorderGui()
        self.Toggled = not self.Toggled
	end)
	
	self:SetValue(initial or self:GetValue())
    self:AddChild(self.ColorPicker)
    return self
end

function ColorPickerEntry:SetValue(val)
    self.ColorPicker:SetValue(val)
end

function ColorPickerEntry:GetValue()
    return self.ColorPicker.Value
end

function ColorPickerEntry:UpdateGui()
    self.Label.Size = UDim2.new(1,-16,0,Config.DefaultEntryHeight)
    self.Label.Position = UDim2.new(0,0,0,0)
    self.Label.BackgroundTransparency = 1
    self.Label.Font = Config.Font
    self.Label.Text = self.Title
    self.GuiObject.ClipsDescendants = true
    self.GuiObject.BackgroundColor3 = Config.PrimaryColor
    self.GuiObject.BorderSizePixel = 0
    self.GuiObject.Size = UDim2.new(1,0,0,self.Height)
    self.Label.TextSize = Config.TextSize
    self.Label.TextColor3 = Config.TextColor
    self.ColorButton.Size = UDim2.new(0,16,0,16,0)
    self.ColorButton.Position = UDim2.new(1,-37,0.5,-8)
    self.ColorButton.Text = ""
    self.ColorButton.AutoButtonColor = false
end

function BaseContainer:CreateColorPicker(title,callback,dynamic,initial)
    local entry = ColorPickerEntry:New(title,callback,dynamic,initial)
    self:AddEntry(entry)
    entry:RecursiveUpdateGui()
    return entry
end

return ColorPicker