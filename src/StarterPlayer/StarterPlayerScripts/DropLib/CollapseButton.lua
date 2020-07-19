local BaseUiElement = require(script.Parent.UIElements.BaseUiElement)
local Config = require(script.Parent.Config)

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

return CollapseButton   