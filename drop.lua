local UIS = game:GetService("UserInputService")

local Config = {}
Config.PrimaryColor = Color3.fromRGB(27, 38, 59)
Config.SecondaryColor = Color3.fromRGB(13, 27, 42)
Config.AccentColor = Color3.fromRGB(41, 115, 115)
Config.TextColor =  Color3.new(1,1,1)
Config.Font = Enum.Font.Gotham
Config.TextSize = 13
Config.HeaderWidth = 300
Config.HeaderHeight = 32
Config.EntryMargin = 1
Config.AnimationDuration = 0.4
Config.AnimationEasingStyle = Enum.EasingStyle.Quint
Config.DefaultEntryHeight = 35


local TypeEnum = {
	Unknown= 0,
	Root= 1,
	Category=2,
	Section = 3,
	Header = 4,
	Entry = 5,
	UiElement = 6,
}
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

local CollapseButton = {}
CollapseButton.__index = CollapseButton
setmetatable(CollapseButton,BaseUiElement)

function CollapseButton:New()
    local self = setmetatable(BaseUiElement:New(UDim2.new(0,20,0,20),UDim2.new(1,-20-5,0.5,-20/2),""), CollapseButton)
	self.GuiObject = Instance.new("TextButton")
	self.GuiObject.MouseButton1Click:Connect(function()
		self.Parent.Parent.Collapsed = not self.Parent.Parent.Collapsed
		if self.Parent.Parent.Collapsed then self.Parent.Parent:Collapse() else self.Parent.Parent:Expand() end
	end)
	
	return self
end

function CollapseButton:Collapse()
    self.GuiObject.Text = "+"
end

function CollapseButton:Expand()
    self.GuiObject.Text = "-"
end

function CollapseButton:UpdateGui()
    self.GuiObject.TextScaled = true
    self.GuiObject.TextColor3 = Config.TextColor
    self.GuiObject.BackgroundTransparency =1
    self.GuiObject.Size = self.Size
    self.GuiObject.Position = self.Position
    if self.Parent.Parent.Collapsed then
        self.GuiObject.Text = "+"
    else
        self.GuiObject.Text = "-"
    end
end

local Header = {}
Header.__index = Header
setmetatable(Header,BaseObject)

function Header:New(title)
	local self = setmetatable(BaseObject:New(TypeEnum.Header), Header)
	self.GuiObject = Instance.new("TextLabel")
	self.CollapseButton = CollapseButton:New()
	self:AddChild(self.CollapseButton)
    return self
end

function Header:UpdateGui()
	self.GuiObject.Size = UDim2.new(1,0,0,Config.HeaderHeight)
	self.GuiObject.Text=self.Parent.Title
	self.GuiObject.TextSize = Config.TextSize * 1.25
	self.GuiObject.TextColor3 = Config.TextColor
	self.GuiObject.Font = Config.Font
	self.GuiObject.BorderSizePixel = 0
	self.GuiObject.BackgroundColor3 = Config.SecondaryColor
	if self.Parent.Type == TypeEnum.Category then
		self.TextSize = Config.TextSize*1.5
	end
end

local BaseContainer = {}
BaseContainer.__index = BaseContainer
setmetatable(BaseContainer,BaseObject)

function BaseContainer:New(title,type)
    local self = setmetatable(BaseObject:New(type),BaseContainer)
    self.Collapsed = false
    self.Height = 0 --dynamically set
    self.GuiObject = Instance.new("Frame")  
    self.Header = Header:New()
    self.Title = title or ""
    self:AddChild(self.Header)
      
    return self
end

function BaseContainer:UpdateGui()
    self.GuiObject.Size = UDim2.new(0,Config.HeaderWidth,0,0)
	self.GuiObject.BackgroundColor3 = Config.SecondaryColor
	self.GuiObject.BorderSizePixel = 0
    self.GuiObject.ClipsDescendants = true
    self:ReorderGui(true)
end

function BaseContainer:ReorderGui(instant)
	instant = instant or false
	local deltaTime = Config.AnimationDuration
	if instant then
		deltaTime = 0
	end
	self.Height = Config.HeaderHeight --reserve height for the header
	if not self.Collapsed then
		for _,child in pairs(self.Children)do
			if child.Type ~= TypeEnum.Header then
				child.GuiObject:TweenPosition(UDim2.new(0,0,0,self.Height),Enum.EasingDirection.InOut,Config.AnimationEasingStyle,deltaTime,true)
				self.Height = self.Height+child.Height+Config.EntryMargin
			end
		end
		self.Height = self.Height-Config.EntryMargin --removes wasted space on the bottom
	end
    self.GuiObject:TweenSize(UDim2.new(0,Config.HeaderWidth,0,self.Height),Enum.EasingDirection.InOut,Config.AnimationEasingStyle,deltaTime,true)
    if self.Parent.Type ~= TypeEnum.Root then
        self.Parent:ReorderGui(instant)
    end
end

function BaseContainer:Collapse()
    self.Collapsed = true
    self.Header.CollapseButton:Collapse()
    self:ReorderGui()
end

function BaseContainer:Expand()
    self.Collapsed = false
    self.Header.CollapseButton:Expand()
    self:ReorderGui()
end

function BaseContainer:AddEntry(entry)
    self:AddChild(entry)
    entry:RecursiveUpdateGui()
    self:ReorderGui(true)
end

--The methods for creating the ui elements, like CreateButton and such,
--are defined in their respective file, e.g. UIElements/Button.lua

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

local Category = {}
Category.__index = Category
setmetatable(Category,BaseContainer)

function Category:New(title,draggable)
    local self = setmetatable(BaseContainer:New(title,TypeEnum.Category), Category)
	self.Draggable = draggable or true
	self.Position = UDim2.new(0,0,00)
    self:ApplyDraggability()
    return self
end

function Category:MoveTo(position)
    self.Position = position
    self.GuiObject.Position = position
end

function Category:AutoMove()
	self:MoveTo(UDim2.fromOffset(100+(#self.Parent.Children-1)*(Config.HeaderWidth*1.25),36))
end

function Category:ApplyDraggability()
	self.LastMousePosition = UIS:GetMouseLocation()
	self.DragActive = false
		
	self.Header.GuiObject.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 and self.Draggable then
			self.DragActive = true
		end
	end)
		
	self.Header.GuiObject.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			self.DragActive = false
		end
	end)
	UIS.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then	
			if self.DragActive then
				local delta = UIS:GetMouseLocation() - self.LastMousePosition
				self:MoveTo(UDim2.new(self.GuiObject.Position.X.Scale,self.GuiObject.Position.X.Offset+delta.X,self.GuiObject.Position.Y.Scale,self.GuiObject.Position.Y.Offset+delta.Y))
			end
			self.LastMousePosition=UIS:GetMouseLocation()
		end
	end)
end

local BaseEntry= {}
BaseEntry.__index = BaseEntry
setmetatable(BaseEntry,BaseObject)

function BaseEntry:New(height)
    local self = setmetatable(BaseObject:New(TypeEnum.Entry), BaseEntry)
    self.Value = nil
    self.Height = height or Config.DefaultEntryHeight
    self.GuiObject = Instance.new("Frame")
    return self
end

function BaseEntry:SetValue()
    --supposed to be overwritten
end

function BaseEntry:GetValue()
    --supposed to be overwritten
end

function BaseEntry:UpdateGui()
    self.GuiObject.BackgroundColor3 = Config.PrimaryColor
    self.GuiObject.BorderSizePixel = 0
    self.GuiObject.Size = UDim2.new(1,0,0,self.Height)
end

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

local function FilterForPattern(from,pattern)
	local valid = {}
	for _,v in pairs(from)do
		if string.match(string.lower(tostring(v)),string.lower(pattern)) then
			table.insert(valid,v)
		end
	end
	return valid
end

local Selector = {}
Selector.__index = Selector
setmetatable(Selector,BaseUiElement)

function Selector:New(size,pos,title,callback,getcall)
    local self = setmetatable(BaseUiElement:New(size,pos,title), Selector)
    self.Callback = callback
    self.Getcall = getcall
    self.GuiObject = Instance.new("Frame")
	self.ScrollBox = Instance.new("ScrollingFrame",self.GuiObject)
	self.SearchBox = TextBox:New(UDim2.new(1,0,0,30),UDim2.new(0,0,0,0),"Search",function(txt)self:SetList(FilterForPattern(getcall(),txt))end,nil,true)
	self:AddChild(self.SearchBox)
	return self
end

function Selector:SetList(list)
	local counter = 0
	self.ScrollBox:ClearAllChildren()
	for i,v in pairs(list) do
		local button = Instance.new("TextButton",self.ScrollBox)
		button.Text = tostring(v)
		button.BackgroundColor3 = Config.SecondaryColor
		button.TextColor3 = Config.TextColor
		button.BorderColor3 = Config.PrimaryColor
		button.Size = UDim2.new(1,-4,0,30)
		button.Position = UDim2.new(0,2,0,button.AbsoluteSize.Y*(counter))
		button.MouseButton1Click:Connect(function() self.Callback(v) self:SetList(FilterForPattern(self.Getcall(),self.SearchBox.Value))end)
		counter=counter+1
	end
	self.ScrollBox.CanvasSize = UDim2.new(0,0,0,#list*30)
end

function Selector:UpdateGui()
    self.GuiObject.BorderSizePixel =0
	self.GuiObject.BackgroundTransparency = 1
	self.GuiObject.Size = self.Size
	self.GuiObject.Position= self.Position
	self.ScrollBox.Position = UDim2.new(0,0,0,30+2)
	self.ScrollBox.BackgroundTransparency = 1
	self.ScrollBox.BorderSizePixel = 0
	self.ScrollBox.ScrollBarThickness = 3
	self.ScrollBox.Size = UDim2.new(1,0,1,-30)
	self:SetList(self.Getcall())
end

local SelectorEntry= {}
SelectorEntry.__index = SelectorEntry
setmetatable(SelectorEntry,BaseEntry)

function SelectorEntry:New(title,callback,getcall,initial)
    local self = setmetatable(BaseEntry:New(), SelectorEntry)
    self.Title = title
    self.Callback = callback
    self.Selector = Selector:New(UDim2.new(1,0,0,Config.DefaultEntryHeight*5),UDim2.new(0,0,0,Config.DefaultEntryHeight),title,function(v)
        if not UIS:IsKeyDown(Enum.KeyCode.LeftShift) then
            self:Toggle()
        end
        self:SetValue(v)
        self.Callback(v)
    end,getcall)
    self:AddChild(self.Selector)
    self.Button = Instance.new("TextButton",self.GuiObject)
    self.Indicator = Instance.new("TextLabel",self.Button)
    self.Indicator.Text = "▼"
    self.Toggled = false
    self.Button.MouseButton1Click:Connect(function()
        self:Toggle()
        self.Selector:SetList(FilterForPattern(self.Selector.Getcall(),self.Selector.SearchBox.Value))
    end)
    self:SetValue(initial)

    return self
end

function SelectorEntry:Toggle()
    if self.Toggled then
        self.Height = Config.DefaultEntryHeight
        self.Indicator.Text= "▼"
    else
        self.Height = Config.DefaultEntryHeight*6
        self.Indicator.Text= "▲"
    end
    
    self.GuiObject:TweenSize(UDim2.new(1,0,0,self.Height),Enum.EasingDirection.InOut,Config.AnimationEasingStyle,Config.AnimationDuration,true)
    self.Parent:ReorderGui()
    self.Toggled = not self.Toggled
end

function SelectorEntry:SetValue(value)
    self.Button.Text = string.format("%s [%s]",self.Title,tostring(value or "Empty"))
    self.Value = value
end

function SelectorEntry:GetValue()
    return self.Value
end

function SelectorEntry:UpdateGui()
    self.GuiObject.ClipsDescendants = true
    self.GuiObject.BackgroundColor3 = Config.PrimaryColor
    self.GuiObject.BorderSizePixel = 0
    self.GuiObject.Size = UDim2.new(1,0,0,self.Height)
    self.Button.Position = UDim2.new(0,5,0,5)
    self.Button.BorderSizePixel = 0
    self.Button.Font = Config.Font
    self.Button.TextSize = Config.TextSize
    self.Button.Size = UDim2.new(1,-10,0,self.Height-10)
    self.Button.BackgroundColor3 = Config.SecondaryColor
    self.Button.TextColor3 = Config.TextColor
    self.Button.AutoButtonColor = false
    self.Indicator.Size = UDim2.new(0,20,0,20)
    self.Indicator.Position = UDim2.new(0,0,0.5,-10)
    self.Indicator.BackgroundTransparency = 1
    self.Indicator.TextColor3 = Config.TextColor
end

function BaseContainer:CreateSelector(title,callback,getcall,initial)
    local entry = SelectorEntry:New(title, callback,getcall,initial)
    self:AddEntry(entry)
    return entry
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

local TextLabel = {}
TextLabel.__index = TextLabel
setmetatable(TextLabel,BaseUiElement)

function TextLabel:New(size,pos,title)
    local self = setmetatable(BaseUiElement:New(size,pos,title), TextLabel)
    self.Callback = callback
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

local Gui = {}
Gui.__index = Gui
setmetatable(Gui,BaseObject)

function Gui:New()
    local self = setmetatable(BaseObject:New(TypeEnum.Root),Gui)
	self.ScreenGui = Instance.new("ScreenGui",game.Players.LocalPlayer.PlayerGui)
    self.GuiObject = Instance.new("Frame",self.ScreenGui)
    return self
end

function Gui:UpdateGui()
    self.ScreenGui.ResetOnSpawn = false
    self.ScreenGui.IgnoreGuiInset = true
    self.GuiObject.Size = UDim2.new(1,0,1,0)
	self.GuiObject.BackgroundTransparency = 1
end

function Gui:Hide()
    self.ScreenGui.Enabled = false
end

function Gui:Show()
    self.ScreenGui.Enabled = true
end

function Gui:CleanUp()
    self.ScreenGui:Destroy()
    self = nil
end

function Gui:CreateCategory(name,position)
    local cat = Category:New(name,position)
    self:AddChild(cat)
    if position then
        cat:MoveTo(position)
    else
        cat:AutoMove()
    end
    cat:RecursiveUpdateGui()
    return cat
end

local droplib = Gui:New()
droplib:RecursiveUpdateGui()
return droplib