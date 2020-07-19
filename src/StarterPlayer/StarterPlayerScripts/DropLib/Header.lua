local TypeEnum = require(script.Parent.TypeEnum)
local BaseObject = require(script.Parent.BaseObject)
local CollapseButton = require(script.Parent.CollapseButton)
local Config = require(script.Parent.Config)

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

return Header