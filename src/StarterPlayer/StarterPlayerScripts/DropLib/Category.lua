local TypeEnum = require(script.Parent.TypeEnum)
local BaseContainer = require(script.Parent.BaseContainer)
local Config = require(script.Parent.Config)
local UIS = game:GetService("UserInputService")

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

return Category
