local TypeEnum = require(script.Parent.TypeEnum)
local BaseObject = require(script.Parent.BaseObject)
local BaseContainer = require(script.Parent.BaseContainer)
local Section = require(script.Parent.Section)
local Category = require(script.Parent.Category)

--automatically require ui elements
for _,ui in pairs(script.Parent.UIElements:GetChildren())do
    require(ui)
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

local tmp = Gui:New()
tmp:UpdateGui()
return tmp