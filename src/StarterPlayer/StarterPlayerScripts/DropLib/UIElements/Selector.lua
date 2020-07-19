local BaseUiElement = require(script.Parent.BaseUiElement)
local BaseEntry = require(script.Parent.BaseEntry)
local BaseContainer = require(script.Parent.Parent.BaseContainer)
local UIS = game:GetService("UserInputService")
local Config = require(script.Parent.Parent.Config)
local TextBox = require(script.Parent.TextBox)

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

return Selector