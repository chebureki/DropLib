local BaseUiElement = require(script.Parent.BaseUiElement)
local BaseEntry = require(script.Parent.BaseEntry)
local BaseContainer = require(script.Parent.Parent.BaseContainer)
local UIS = game:GetService("UserInputService")
local Config = require(script.Parent.Parent.Config)

local Slider = {}
Slider.__index = Slider
setmetatable(Slider,BaseUiElement)

function Slider:New(size,pos,title,callback,min,max,step,dynamic,initialValue,customColor)
    local self = setmetatable(BaseUiElement:New(size,pos,title), Slider)
    self.Callback = callback
	self.Dynamic = dynamic or false
	initialValue = initialValue or min
    self.Step = step or 0.01
    self.Max = max
    self.Min = min
    self.CustomColor = customColor
	self.Value = initialValue or self.Min
	self.GuiObject = Instance.new("Frame")
	self.Bg = Instance.new("Frame",self.GuiObject)
	self.Box = Instance.new("TextBox",self.GuiObject)
	self.Overlay = Instance.new("Frame",self.Bg)
	self.Handle = Instance.new("Frame",self.Overlay)
	self.Label = Instance.new("TextLabel",self.Bg)
	self.Active = false
	self.Bg.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
            self.Active = true
            local ratio = math.clamp(input.Position.X - self.Bg.AbsolutePosition.X,0,self.Bg.AbsoluteSize.X)/self.Bg.AbsoluteSize.X
			self:SetValue(self.Min+(ratio*(self.Max-self.Min)))
		end
	end)
		
	self.Bg.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			self.Active = false
			self.Callback(self.Value)
		end
	end)
	
	UIS.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then	
            if self.Active then
                local ratio = math.clamp(input.Position.X - self.Bg.AbsolutePosition.X,0,self.Bg.AbsoluteSize.X)/self.Bg.AbsoluteSize.X
                self:SetValue(self.Min+(ratio*(self.Max-self.Min)))
				if self.Dynamic then
					self.Callback(self.Value)
				end
			end
		end
	end)
	
	self.Box.FocusLost:Connect(function()
		local num = tonumber(self.Box.Text)
		if num then
			self:SetValue(num)
			self.Callback(self.Value)
		else
			self.Box.Text=self.Value
		end
    end)
	return self
end

function Slider:SetValue(value)
    self.Value = math.clamp(value-value%self.Step,self.Min,self.Max)
    self.Overlay.Size = UDim2.new((self.Value-self.Min)/(self.Max-self.Min),0,1,0)
    self.Box.Text = tostring(self.Value)
end

function Slider:UpdateGui()
    self.GuiObject.BackgroundColor3 = Config.SecondaryColor
    self.GuiObject.Size = self.Size
    self.GuiObject.Position = self.Position
    self.GuiObject.BorderSizePixel = 0
    self.GuiObject.BackgroundTransparency = 1	
    self.Bg.BorderSizePixel = 0
    self.Bg.Size = UDim2.new(1-0.2,0,1,0)
    self.Bg.BackgroundColor3 = Config.SecondaryColor
    self.Box.Size = UDim2.new(0.2,-5,1,0)
    self.Box.Position = UDim2.new(0.8,5,0,0)
    self.Box.BorderSizePixel = 0
    self.Box.BackgroundColor3 = Config.SecondaryColor
    self.Box.TextColor3 = Config.TextColor
    self.Box.TextWrapped = true
    self.Overlay.BorderSizePixel = 0
    self.Overlay.BackgroundColor3 = self.CustomColor or Config.AccentColor
    self.Handle.Size = UDim2.new(0,5,1,0)
    self.Handle.Position = UDim2.new(1,-(5/2),0,0)
    self.Handle.BackgroundColor3 = Color3.new(1,1,1)
    self.Handle.BorderSizePixel = 0
    self.Label.Text = self.Title
    self.Label.Font = Config.Font
    self.Label.TextSize = Config.TextSize
    self.Label.BackgroundTransparency = 1
    self.Label.Size = UDim2.new(1,0,1,0)
    self.Label.TextColor3 = Config.TextColor
    self:SetValue(self.Value)
end

local SliderEntry= {}
SliderEntry.__index = SliderEntry
setmetatable(SliderEntry,BaseEntry)

function SliderEntry:New(title,callback,min,max,step,dynamic,initialValue)
    local self = setmetatable(BaseEntry:New(), SliderEntry)
    self.Slider = Slider:New(UDim2.new(1,-10,1,-14),UDim2.new(0,5,0,7),title,
    function(val)
        self.Value = val pcall(callback,self.Value)
    end,
    min,max,step,dynamic,initialValue)
    self:SetValue(initialValue or self:GetValue())
    self:AddChild(self.Slider)
    return self
end

function SliderEntry:SetValue(val)
    self.Slider:SetValue(val)
end

function SliderEntry:GetValue()
    return self.Slider.Value
end

function BaseContainer:CreateSlider(title,callback,min,max,step,dynamic,initial)
    local entry = SliderEntry:New(title,callback,min,max,step,dynamic,initial)
    self:AddEntry(entry)
    return entry
end

return Slider