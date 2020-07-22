local TypeEnum = require(script.Parent.TypeEnum)
local BaseObject = require(script.Parent.BaseObject)
local BaseContainer = require(script.Parent.BaseContainer)
local Section = require(script.Parent.Section)
local Category = require(script.Parent.Category)

--All required, comment them out if you dont want them!
local BaseEntry = require(script.Parent.UIElements.BaseEntry)
local BaseUiElement = require(script.Parent.UIElements.BaseUiElement)
local Button = require(script.Parent.UIElements.Button)
local ColorPicker = require(script.Parent.UIElements.ColorPicker)
local Selector = require(script.Parent.UIElements.Selector)
local Slider = require(script.Parent.UIElements.Slider)
local Switch = require(script.Parent.UIElements.Switch)
local TextBox = require(script.Parent.UIElements.TextBox)
local TextLabel = require(script.Parent.UIElements.TextLabel)
local KeyDetector = require(script.Parent.UIElements.KeyDetector)

local Gui = {}
Gui.__index = Gui
setmetatable(Gui,BaseObject)

function Gui:New(screenGuiParent)
    local self = setmetatable(BaseObject:New(TypeEnum.Root),Gui)
	self.ScreenGui = Instance.new("ScreenGui",screenGuiParent or game.Players.LocalPlayer.PlayerGui)
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

function Gui:LoadConfig(userConfig)
    for i,v in pairs(userConfig) do
        Config[i] = v
    end
end

function Gui:Init(userConfig,screenGuiParent)
    local droplib = Gui:New(screenGuiParent)
    droplib:LoadConfig(userConfig or {})
    droplib:RecursiveUpdateGui()
    return droplib
end

return Gui