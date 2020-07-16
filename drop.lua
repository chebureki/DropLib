local UIS = game:GetService("UserInputService")
--
local DefaultConfig = {}
DefaultConfig.PrimaryColor = Color3.fromRGB(27, 38, 59)
DefaultConfig.SecondaryColor = Color3.fromRGB(13, 27, 42)
DefaultConfig.AccentColor = Color3.fromRGB(41, 115, 115)
DefaultConfig.TextColor =  Color3.new(1,1,1)
DefaultConfig.Font = Enum.Font.Gotham
DefaultConfig.TextSize = 13
DefaultConfig.HeaderWidth = 300
DefaultConfig.HeaderHeight = 32
DefaultConfig.EntryMargin = 1
DefaultConfig.AnimationDuration = 0.4
DefaultConfig.AnimationEasingStyle = Enum.EasingStyle.Quint
DefaultConfig.DefaultEntryHeight = 35

--enum since string comparisisons aint cool dawg
local TypeEnum = {
	["Custom"]	= 0,
	["Root"] 	= 1,
	["Category"]= 2,
	["BaseContainer"] = 3,
	["Section"] = 4,
	["Header"] = 5,
	["Entry"] 	= 6,
	["UiElement"] = 7,
}
local Gui = {}
Gui.Categories = nil
Gui.ScreenGui = nil
Gui.Config = DefaultConfig
Config = Gui.Config

--For whenever you just want the value
local function NullFunc(...)
	return
end

local function ReorderGui(container,instant)
	if container.Type == TypeEnum.Root then
		return
	end
	instant = instant or false
	local deltaTime = Config.AnimationDuration
	if instant then
		deltaTime = 0
	end
	container.Height = Config.HeaderHeight
	if not container.Collapsed then
		for _,child in pairs(container.Children)do
			if child.Type ~= TypeEnum.Header then
				child.GuiObject:TweenPosition(UDim2.new(0,0,0,container.Height),Enum.EasingDirection.InOut,Config.AnimationEasingStyle,deltaTime,true)
				container.Height = container.Height+child.Height+Config.EntryMargin
			end
		end
		container.Height = container.Height-Config.EntryMargin --bottom margin aint cool dawg
	end
	container.GuiObject:TweenSize(UDim2.new(0,Config.HeaderWidth,0,container.Height),Enum.EasingDirection.InOut,Config.AnimationEasingStyle,deltaTime,true)
	ReorderGui(container.Parent,instant)
end

local function BaseObject(Type,parent,children,guiObject)
	local obj = {}
	obj.Type = Type
	obj.Children = children or {}
	obj.GuiObject = guiObject
	if parent then
		parent:AddChild(obj)
	end
	function obj.AddChild(self,child)
		child.Parent = obj
		table.insert(self.Children,child)
		if child.GuiObject and self.GuiObject then
			child.GuiObject.Parent = self.GuiObject
		end
	end
	obj.UpdateGui = nil
	return obj
end

local function BaseUiElement()
	local ui = BaseObject(TypeEnum.UiElement)
	ui.Callback = NullFunc
	ui.Value = nil	
	ui.SetValue = nil
	return ui
end

local function Button(size,pos,title,callback)
	local button = BaseUiElement()
	button.GuiObject = Instance.new("TextButton")
	button.GuiObject.MouseButton1Click:Connect(callback)
	function button.UpdateGui(self)
		self.GuiObject.BorderSizePixel =0
		self.GuiObject.BackgroundColor3 = Config.SecondaryColor
		self.GuiObject.TextColor3 = Config.TextColor
		self.GuiObject.Size = size
		self.GuiObject.Position = pos
		self.GuiObject.Text = title
		self.GuiObject.TextSize = Config.TextSize
		self.GuiObject.Font = Config.Font
	end
	button:UpdateGui()
	return button
end

local function TextBox(size,pos,title,callback,acceptFormat,dynamic,initial)
	local box = BaseUiElement()
	box.Value = initial or ""
	acceptFormat = acceptFormat or "^.*$"
	box.GuiObject = Instance.new("TextBox")
	
	function box.SetValue(self,val)
		box.GuiObject.Text = val
		box.Value = val
	end
			
	function box.UpdateGui(self)
		box.GuiObject.BackgroundColor3 = Config.SecondaryColor
		box.GuiObject.TextColor3 = Config.TextColor
		
		box.GuiObject.PlaceholderText = title
		box.GuiObject.Position = pos
		box.GuiObject.Size = size
		box.GuiObject.TextSize = Config.TextSize
		box.GuiObject.Font = Config.Font
		box.GuiObject.BorderSizePixel = 0
		box:SetValue(box.Value)
	end
	
	box.GuiObject.FocusLost:Connect(function()
		if string.match(box.GuiObject.Text,acceptFormat)then
				box:SetValue(box.GuiObject.Text)
				callback(box.Value)
		else
			box.GuiObject.Text = box.Value
		end
	end)
	
	box.GuiObject.Changed:Connect(function(prop)
		if dynamic and prop == "Text" and box.GuiObject:IsFocused() then
			if string.match(box.GuiObject.Text,acceptFormat)then			
				box:SetValue(box.GuiObject.Text)
				callback(box.Value)
			else
				box.GuiObject.Text = box.Value
			end
		end
	end)
	
	box:UpdateGui()
	return box
end

local function Label(size,pos,title)
	local label = BaseUiElement()
	label.GuiObject = Instance.new("TextLabel")
	function label.UpdateGui(self)
		self.GuiObject.BorderSizePixel =0
		self.GuiObject.BackgroundTransparency = 1
		self.GuiObject.TextColor3 = Config.TextColor
		self.GuiObject.Size = size
		self.GuiObject.Position =  pos
		self.GuiObject.TextSize = Config.TextSize
		self.GuiObject.Text = title
		self.GuiObject.Font = Config.Font
	end
	label:UpdateGui()
	return label
end

local function KeyDetector(size,pos,title,callback,initial)
	local det = BaseUiElement()
	det.Value = initial or Enum.KeyCode.Unknown
	det.GuiObject = Instance.new("Frame")
	local label = Instance.new("TextLabel",det.GuiObject)
	local button = Instance.new("TextButton",det.GuiObject)
	
	function det.SetValue(self,val)
		det.Value = val
		button.Text = val.Name
	end
	
	function det.UpdateGui(self)
		det.GuiObject.BackgroundTransparency = 1
		det.GuiObject.Size = size
		det.GuiObject.Position = pos
		label.Size = UDim2.new(0.8,0,1,0)
		label.BackgroundTransparency = 1
		label.TextSize = Config.TextSize
		label.TextColor3 = Config.TextColor
		label.Text = title
		label.Font = Config.Font
		button.Size = UDim2.new(0.2,0,1,0)
		button.BorderSizePixel = 0
		button.TextColor3 = Config.TextColor
		button.BackgroundColor3 = Config.SecondaryColor
		button.Position = UDim2.new(0.8,0,0,0)
		det:SetValue(det.Value)
	end
	
	button.MouseButton1Click:Connect(function()
		button.Text = "..."
		local pressed
		repeat
			pressed = UIS.InputBegan:Wait()
		until pressed.UserInputType == Enum.UserInputType.Keyboard
		det:SetValue(pressed.KeyCode)
		callback(det.Value)
	end)
	
	det:UpdateGui()
	return det
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

local function Selector(size,pos,title,callback,getcall)
	callback = callback or NullFunc
	local sc = BaseUiElement()
	sc.Value = nil
	sc.GuiObject = Instance.new("Frame")	
	local scroll = Instance.new("ScrollingFrame",sc.GuiObject)
	local box = TextBox(UDim2.new(1,0,0,30),UDim2.new(0,0,0,0),"Search",function(txt)sc:SetList(FilterForPattern(getcall(),txt))end,nil,true)
	sc:AddChild(box)
	function sc.SetList(self,list)
		local counter = 0
		scroll:ClearAllChildren()
		for i,v in pairs(list) do
			local button = Instance.new("TextButton")
			button.Parent = scroll
			button.Text = tostring(v)
			button.BackgroundColor3 = Config.SecondaryColor
			button.TextColor3 = Config.TextColor
			button.BorderColor3 = Config.PrimaryColor
			button.Size = UDim2.new(1,-4,0,30)
			button.Position = UDim2.new(0,2,0,button.AbsoluteSize.Y*(counter))
			button.MouseButton1Click:Connect(function() pcall(callback,v) sc:SetList(FilterForPattern(getcall(),box.Value))end)
			counter=counter+1
		end
		scroll.CanvasSize = UDim2.new(0,0,0,#list*30)
	end
	
	function sc.UpdateGui(self)
		self.GuiObject.BorderSizePixel =0
		self.GuiObject.BackgroundTransparency = 1
		sc.GuiObject.Size = size
		sc.GuiObject.Position= pos
		scroll.Position = UDim2.new(0,0,0,30+2)
		scroll.BackgroundTransparency = 1
		scroll.BorderSizePixel = 0
		scroll.ScrollBarThickness = 3
		scroll.Size = UDim2.new(1,0,1,-30)
		sc:SetList(getcall())
	end
	sc:UpdateGui()
	return sc
end

local function Slider(size,pos,title,callback,min,max,step,dynamic,initialValue,customColor)
	dynamic = dynamic or false
	initialValue = initialValue or min
	step = step or 0.01
	local slider = BaseUiElement()
	slider.Value = initialValue or 0
	
	slider.GuiObject = Instance.new("Frame")
	local sliderBg = Instance.new("Frame",slider.GuiObject)
	local box = Instance.new("TextBox",slider.GuiObject)
	local overlay = Instance.new("Frame",sliderBg)
	local handle = Instance.new("Frame",overlay)
	local label = Instance.new("TextLabel",sliderBg)
	
	function slider.UpdateGui(self)
		slider.GuiObject.BackgroundColor3 = Config.SecondaryColor
		slider.GuiObject.Size = size
		slider.GuiObject.Position = pos
		slider.GuiObject.BorderSizePixel = 0
		slider.GuiObject.BackgroundTransparency = 1	
		sliderBg.BorderSizePixel = 0
		sliderBg.Size = UDim2.new(1-0.2,0,1,0)
		sliderBg.BackgroundColor3 = Config.SecondaryColor
		box.Size = UDim2.new(0.2,-5,1,0)
		box.Position = UDim2.new(0.8,5,0,0)
		box.BorderSizePixel = 0
		box.BackgroundColor3 = Config.SecondaryColor
		box.TextColor3 = Config.TextColor
		box.TextWrapped = true
		overlay.BorderSizePixel = 0
		overlay.BackgroundColor3 = customColor or Config.AccentColor
		handle.Size = UDim2.new(0,5,1,0)
		handle.Position = UDim2.new(1,-(5/2),0,0)
		handle.BackgroundColor3 = Color3.new(1,1,1)
		handle.BorderSizePixel = 0
		handle.Parent = overlay
		label.Parent = sliderBg
		label.Text = title
		label.Font = Config.Font
		label.TextSize = Config.TextSize
		label.BackgroundTransparency = 1
		label.Size = UDim2.new(1,0,1,0)
		label.TextColor3 = Config.TextColor
		slider:SetValue(slider.Value)
	end
		
	slider.SetValue = function(self,value)
		slider.Value = math.max(min,math.min(value-value%step,max))
		overlay.Size = UDim2.new((slider.Value-min)/(max-min),0,1,0)
		box.Text = tostring(slider.Value)
	end
	
	local active = false
	sliderBg.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			active = true
			local ratio = ((math.max(0,math.min(input.Position.X - sliderBg.AbsolutePosition.X,sliderBg.AbsoluteSize.X)))/sliderBg.AbsoluteSize.X)
			slider:SetValue(min+(ratio*(max-min)))
		end
	end)
		
	sliderBg.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			active = false
			callback(slider.Value)
		end
	end)
	
	UIS.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then	
			if active then
				local ratio = ((math.max(0,math.min(input.Position.X - sliderBg.AbsolutePosition.X,sliderBg.AbsoluteSize.X)))/sliderBg.AbsoluteSize.X)
				slider:SetValue(min+(ratio*(max-min)))
				if dynamic then
					callback(slider.Value)
				end
			end
		end
	end)
	
	box.FocusLost:Connect(function()
		local num = tonumber(box.Text)
		if num then
			slider:SetValue(num)
			callback(slider.Value)
		else
			box.Text=slider.Value
		end
	end)
	
	slider:UpdateGui()
	return slider
end

local function Switch(size,pos, title, callback,initialValue)
	initialValue = initialValue or false
	local switch = BaseUiElement()
	switch.Value = initialValue
	switch.GuiObject = Instance.new("Frame")
	local label = Instance.new("TextLabel",switch.GuiObject)
	local button = Instance.new("TextButton",switch.GuiObject)
	
	function switch.UpdateGui(self)
		switch.GuiObject.Size = size
		switch.GuiObject.BackgroundTransparency = 1
		switch.GuiObject.Position = pos
		label.Text = title
		label.TextSize = Config.TextSize
		label.Font = Config.Font
		label.BackgroundTransparency = 1
		label.Size = UDim2.new(0.8,0,1,0)
		label.TextColor3 = Config.TextColor
		button.Size = UDim2.new(0,20,0,20)
		button.BorderSizePixel = 2
		button.BorderColor3 = Config.SecondaryColor
		button.Position = UDim2.new(0.9,-10,0.5,-10)
		button.Text = ""
		switch:SetValue(switch.Value)
	end
	
	switch.SetValue = function(self,value)
		self.Value = value
		if self.Value then
			button.BackgroundColor3 = Config.AccentColor
		else
			button.BackgroundColor3 = Config.SecondaryColor
		end
	end
	button.MouseButton1Click:Connect(function()
		switch.Value = not switch.Value
		callback(switch.Value)
		switch:SetValue(switch.Value)
	end)
	switch:UpdateGui()
	return switch
end

local function ColorPicker(size,pos,title,callback,initialColor)
	initialColor = initialColor or Config.AccentColor
	local cp = BaseUiElement()
	cp.Value = initialColor or Color3.new(1,0,0)	
	local frame = Instance.new("Frame",cp.GuiObject)
	cp.GuiObject = frame
	local colimg = Instance.new("ImageLabel",frame)
	local cursor = Instance.new("Frame",colimg)
	local rSlider = Slider(UDim2.new(0.5,-10,1/6,0),UDim2.new(0.5,5,0/6,2),"Red",function(r) cp:SetValue(Color3.new(r/255,cp.Value.G,cp.Value.B))end,0,255,1,true,initialColor.R,Color3.new(0.75,0,0))
	cp:AddChild(rSlider)
	local gSlider = Slider(UDim2.new(0.5,-10,1/6,0),UDim2.new(0.5,5,1/6,4),"Green",function(g) cp:SetValue(Color3.new(cp.Value.R,g/255,cp.Value.B))end,0,255,1,true,initialColor.G,Color3.new(0,0.75,0))
	cp:AddChild(gSlider)
	local bSlider = Slider(UDim2.new(0.5,-10,1/6,0),UDim2.new(0.5,5,2/6,6),"Blue",function(b) cp:SetValue(Color3.new(cp.Value.R,cp.Value.G,b/255))end,0,255,1,true,initialColor.B,Color3.new(0,0,0.75))
	cp:AddChild(bSlider)
	local hexBox = TextBox(UDim2.new(0.5,-10,1/6,0),UDim2.new(0.5,5,3/6,8),"",function(txt) 
		local nums = {}
		for hex in txt:gmatch("%x%x") do
			table.insert(nums,tonumber("0x"..hex))
		end
		cp:SetValue(Color3.fromRGB(unpack(nums)))
	end,"^%x%x%x%x%x%x$")
	cp:AddChild(hexBox)
	local vSlider = Slider(UDim2.new(0.5,-10,1/6,0),UDim2.new(0.5,5,5/6,-2),"Value",function(v) local h,s = Color3.toHSV(cp.Value) cp:SetValue(Color3.fromHSV(h,s,v/255))end,0,255,1,true,({Color3.toHSV(initialColor)})[3],Color3.new(0.75,0.75,0.75))
	cp:AddChild(vSlider)
	
	function cp.SetValue(self,color)
		self.Value = color
		local h,s,v = Color3.toHSV(color)
		cursor.Position = UDim2.new(1-h,-2,1-s,-2)
		vSlider:SetValue(v*255)
		rSlider:SetValue(color.R*255)
		gSlider:SetValue(color.G*255)
		bSlider:SetValue(color.B*255)
		hexBox:SetValue(string.format("%02x%02x%02x",cp.Value.R*255,cp.Value.G*255,cp.Value.B*255))
		callback(self.Value)
	end
	
	function cp.UpdateGui(self)
		frame.Size = size
		frame.Position = pos
		frame.BackgroundTransparency = 1
		colimg.Image = "rbxassetid://698052001"
		colimg.Size = UDim2.new(0.5,-10,1,-10)
		colimg.BorderSizePixel = 0
		colimg.Position = UDim2.new(0,5,0,5)
		cursor.Size = UDim2.new(0,4,0,4,0)
		cursor.BorderSizePixel = 0
		cursor.BackgroundColor3 = Color3.new(1,1,1)
		cp:SetValue(cp.Value)
	end
	
	colimg.MouseMoved:Connect(function(x,y)
		if UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
			local rp = Vector2.new(x,y-36)-colimg.AbsolutePosition
			local hue,sat = 1-rp.X/colimg.AbsoluteSize.X, 1-rp.Y/colimg.AbsoluteSize.Y
			cp:SetValue(Color3.fromHSV(hue,sat,vSlider.Value/255))
		end
	end)
	
	colimg.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			local rp = Vector2.new(input.Position.X,input.Position.Y)-colimg.AbsolutePosition
			local hue,sat = 1-rp.X/colimg.AbsoluteSize.X, 1-rp.Y/colimg.AbsoluteSize.Y
			cp:SetValue(Color3.fromHSV(hue,sat,vSlider.Value/255))
		end
	end)
	cp:UpdateGui()
	return cp
end

local function Header(container, title)
	local header = BaseUiElement()
	header.Type = TypeEnum.Header
	header.GuiObject = Instance.new("TextLabel")
	function header.UpdateGui(self)
		header.GuiObject.Size = UDim2.new(1,0,0,Config.HeaderHeight)
		header.GuiObject.Text=title
		header.GuiObject.TextSize = Config.TextSize * 1.25
		header.GuiObject.TextColor3 = Config.TextColor
		header.GuiObject.Font = Config.Font
		header.GuiObject.BorderSizePixel = 0
		header.GuiObject.BackgroundColor3 = Config.SecondaryColor
		if container.Type == TypeEnum.Category then
			header.TextSize = Config.TextSize*1.5
		end
	end
	
	header:UpdateGui()
	return header
end

local function CollapseButton(container,header)
	local button = BaseUiElement()
	button.GuiObject = Instance.new("TextButton")
	
	function button.UpdateGui(self)
		button.GuiObject.Position = UDim2.new(1,-20-5,0.5,-20/2)
		button.GuiObject.Size = UDim2.new(0,20,0,20)
		button.GuiObject.TextScaled = true
		button.GuiObject.Text= "-"
		button.GuiObject.TextColor3 = Config.TextColor
		button.GuiObject.BackgroundTransparency =1
	end
	
	button.Expand = function(self)
		button.GuiObject.Text = "-"
	end
	
	button.Collapse = function(self)
		button.GuiObject.Text = "+"
	end
	
	button.GuiObject.MouseButton1Click:Connect(function()
		container.Collapsed = not container.Collapsed
		if container.Collapsed then	container:Collapse() else container:Expand() end
	end)
	
	button:UpdateGui()
	return button
end

local function ApplyDraggability(container,header,body)
	local lastMousePos = UIS:GetMouseLocation()
	local active = false
		
	header.GuiObject.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 and container.Draggable then
			active = true
		end
	end)
		
	header.GuiObject.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			active = false
		end
	end)
	UIS.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then	
			if active then
				local delta = UIS:GetMouseLocation() - lastMousePos
				container:MoveTo(UDim2.new(body.Position.X.Scale,body.Position.X.Offset+delta.X,body.Position.Y.Scale,body.Position.Y.Offset+delta.Y))
			end
			lastMousePos=UIS:GetMouseLocation()
		end
	end)
end

local function BaseContainer(title,parent,children)	
	local body = Instance.new("Frame")
	local con = BaseObject(TypeEnum.BaseContainer,parent,children,body)
	con.GuiObject = body
	
	con.Title = title or ""
	con.Height =  0
	con.Collapsed = false
	
	function con.UpdateGui(self)
		body.Size = UDim2.new(0,Config.HeaderWidth,0,0)
		body.BackgroundColor3 = Config.SecondaryColor
		body.BorderSizePixel = 0
		body.ClipsDescendants = true
		ReorderGui(con,true)
	end
	
	con:UpdateGui()
	
	function con.Expand(self)
		self.Collapsed = false
		ReorderGui(self)
	end
	
	function con.Collapse(self)
		self.Collapsed = true
		ReorderGui(self)
	end
	
	function con.CreateEntry(self,entry)
		self:AddChild(entry)
		ReorderGui(self,true)
	end
		
	function con.CreateSection(self,title)
		local sec = BaseContainer(title,self)
		sec.Type = TypeEnum.Section
		local header = Header(sec,title)
		sec:AddChild(header)
		local button = CollapseButton(sec,header)
		function sec.Expand(self)
			self.Collapsed = false
			button:Expand()
			ReorderGui(self)
		end
	
		function sec.Collapse(self)
			self.Collapsed = true
			button:Collapse()
			ReorderGui(self)
		end
		header:AddChild(button)
		ReorderGui(sec)
		return sec
	end
	
	function con.CreateDefaultEntry(self)
		local de = BaseObject(TypeEnum.Entry)
		de.Height = 0
		de.SetValue = nil
		de.Value = nil	

		de.Height = Config.DefaultEntryHeight
		de.GuiObject = Instance.new("Frame")
		
		function de.UpdateGui(self)
			de.GuiObject.BackgroundColor3 = Config.PrimaryColor
			de.GuiObject.BorderSizePixel = 0
			de.GuiObject.Size = UDim2.new(1,0,0,de.Height)
		end
		
		de:UpdateGui()
		self:CreateEntry(de)
		return de
	end

	function con.CreateSlider(self, title,callback,min,max,step,dynamic,initialValue)
		local entry = self:CreateDefaultEntry()
		
		local slider = Slider(UDim2.new(1,-10,1,-14),UDim2.new(0,5,0,7),title,
			function(val)
				entry.Value = val pcall(callback or NullFunc,entry.Value)
			end,
			min,max,step,dynamic,initialValue
		)
		entry:AddChild(slider)
		return entry
	end
	
	function con.CreateButton(self,title,callback)
		local entry = self:CreateDefaultEntry()
		local button = Button(UDim2.new(1,-10,1,-10),UDim2.new(0,5,0,5),title,callback)
		
		function entry.UpdateGui(self)
			button.GuiObject.Position = UDim2.new(1,-10,1,-10)
			button.GuiObject.Size = UDim2.new(0,5,0,5)
		end
		entry:AddChild(button)
		return entry
	end
	
	function con.CreateSwitch(self,title,callback,initialValue)
		local entry = self:CreateDefaultEntry()
		entry.Value = initialValue or false
		local switch = Switch(UDim2.new(1,-10,1,-10),UDim2.new(0,5,0,5),title,
			function(val)
				entry.Value = val
				callback(entry.Value)
			end
		,initialValue)
		
		function entry.UpdateGui(self)
			switch.GuiObject.Position = UDim2.new(1,-10,1,-10)
			switch.GuiObject.Size = UDim2.new(0,5,0,5)
		end
		entry:AddChild(switch)
		return entry
	end
	
	function con.CreateColorPicker(self,title,callback,dynamic,initialValue)
		local entry = self:CreateDefaultEntry()
		entry.Value = initialValue or Color3.new(1,0,0)
		local label = Instance.new("TextLabel",entry.GuiObject)
		local cb = Instance.new("TextButton",label)
		
		function entry.UpdateGui(self)
			label.Size = UDim2.new(1,-16,0,Config.DefaultEntryHeight)
			label.Position = UDim2.new(0,0,0,0)
			label.BackgroundTransparency = 1
			label.Font = Config.Font
			label.Text = title
			entry.GuiObject.ClipsDescendants = true
			label.TextSize = Config.TextSize
			label.TextColor3 = Config.TextColor
			cb.Size = UDim2.new(0,16,0,16,0)
			cb.Position = UDim2.new(1,-37,0.5,-8)
			cb.Text = ""
			cb.AutoButtonColor = false
		end
		
		local toggled = false
		local cp = ColorPicker(UDim2.new(1,0,0,Config.HeaderWidth/2),UDim2.new(0,0,0,Config.DefaultEntryHeight),title,function(color)
			cb.BackgroundColor3 = color
			entry.Value = color
			if dynamic and toggled then
				pcall(callback,color)
			end
		end,initialValue)
		
		function entry.SetValue(self,value)
			cp:SetValue(value)
		end
		
		cb.MouseButton1Click:Connect(function()
			if toggled then
				entry.Height = Config.DefaultEntryHeight
				pcall(callback,entry.Value)
			else
				entry.Height = Config.HeaderWidth/2 + Config.DefaultEntryHeight
			end
			
			entry.GuiObject:TweenSize(UDim2.new(1,0,0,entry.Height),Enum.EasingDirection.InOut,Config.AnimationEasingStyle,Config.AnimationDuration,true)
			ReorderGui(self)
			toggled = not toggled
		end)
		
		entry:UpdateGui()
		entry:AddChild(cp)
		return entry
	end
	
	function con.CreateSelector(self,title,callback,getcall,initialValue)
		local entry = self:CreateDefaultEntry()
		local button = Instance.new("TextButton",entry.GuiObject)
		local indicator = Instance.new("TextLabel",button)
		indicator.Text = "▼"
		local toggled = false
		
		function entry.SetValue(self,value)
			button.Text = string.format("%s [%s]",title,tostring(value or "Empty"))
			self.Value = value
		end
		local function toggle()
			if toggled then
				entry.Height = Config.DefaultEntryHeight
				indicator.Text= "▼"
			else
				entry.Height = Config.DefaultEntryHeight*6
				indicator.Text= "▲"
			end
			
			entry.GuiObject:TweenSize(UDim2.new(1,0,0,entry.Height),Enum.EasingDirection.InOut,Config.AnimationEasingStyle,Config.AnimationDuration,true)
			ReorderGui(self)
			toggled = not toggled
		end
		local sc = Selector(UDim2.new(1,0,0,Config.DefaultEntryHeight*5),UDim2.new(0,0,0,Config.DefaultEntryHeight),title,function(v)
			if not UIS:IsKeyDown(Enum.KeyCode.LeftShift) then
				toggle()
			end
			entry:SetValue(v)
			callback(v)
		end,getcall)
		
		function entry.UpdateGui(self)
			entry.GuiObject.ClipsDescendants = true
			button.Position = UDim2.new(0,5,0,5)
			button.BorderSizePixel = 0
			button.Font = Config.Font
			button.TextSize = Config.TextSize
			button.Size = UDim2.new(1,-10,0,entry.Height-10)
			button.BackgroundColor3 = Config.SecondaryColor
			button.TextColor3 = Config.TextColor
			button.AutoButtonColor = false
			indicator.Size = UDim2.new(0,20,0,20)
			indicator.Position = UDim2.new(0,0,0.5,-10)
			indicator.BackgroundTransparency = 1
			indicator.TextColor3 = Config.TextColor
		end	
		button.MouseButton1Click:Connect(toggle)
		
		entry:SetValue(initialValue)
		entry:AddChild(sc)
		entry:UpdateGui()
		ReorderGui(self)	
		return entry	
	end
	
	function con.CreateLabel(self,title,height)
		local entry = self:CreateDefaultEntry()
		entry.Height = height or entry.Height
		local label = Label(UDim2.new(1,0,1,0),UDim2.new(0,0,0,0),title)
		
		entry:AddChild(label)
		entry:UpdateGui()
		ReorderGui(self)	
		return entry	
	end
	
	function con.CreateKeyDetector(self,title,callback,initial)
		local entry = self:CreateDefaultEntry()
		entry.Value = initial or Enum.KeyCode.Unknown
		local dc = KeyDetector(UDim2.new(1,-10,1,-10),UDim2.new(0,5,0,5),title,function(v)
			entry.Value = v
			pcall(callback,v)
		end)
		function entry.SetValue(self,val)
			dc:SetValue(val)	
		end
		
		entry:AddChild(dc)
		entry:UpdateGui()
		return entry	
	end
	
	function con.CreateTextBox(self,title,callback,acceptFormat,dynamic,initial)
		local entry = self:CreateDefaultEntry()
		local box = TextBox(UDim2.new(1,-10,1,-10),UDim2.new(0,5,0,5),title,callback,acceptFormat,dynamic,initial)
		entry:AddChild(box)	
		return entry
	end
	
	return con
end

function Gui.CreateCategory(self,title,initialPos)
	local cat = BaseContainer(title,Gui.Categories)
	cat.Type = TypeEnum.Category
	cat.Position = UDim2.new(0,0,0,0)
	cat.Draggable = true
	local header = Header(cat,title)
	cat:AddChild(header)
	local button = CollapseButton(cat,header)
	function cat.Expand(self)
		self.Collapsed = false
		button:Expand()
		ReorderGui(self)
	end
	
	function cat.Collapse(self)
		self.Collapsed = true
		button:Collapse()
		ReorderGui(self)
	end
	header:AddChild(button)
	ApplyDraggability(cat,header,cat.GuiObject)
	
	function cat.MoveTo(self,pos)
		self.GuiObject.Position = pos
		cat.Position= pos
	end
	
	function cat.AutoMove(self)
		cat:MoveTo(UDim2.fromOffset(100+(#Gui.Categories.Children-1)*(Config.HeaderWidth*1.25),36))
	end
	
	function cat.EnableDraggability(self)
		self.Draggable = true
	end
	
	function cat.DisableDraggability(self)
		self.Draggable = false
	end
	
	function cat.HideCollapseButton(self)
		button.GuiObject.Visible = false
	end
	
	function cat.ShowCollapseButton(self)
		button.GuiObject.Visible = true
	end
	
	if initialPos then
		cat:MoveTo(initialPos)
	else
		cat:AutoMove()
	end
	
	ReorderGui(cat)
	return cat
end

function Gui.CleanUp(self)
	Gui.ScreenGui:Destroy()
	Gui = nil
end

function Gui.UpdateGui(obj)
	if obj == Gui then
		obj = Gui.Categories
	end
	if obj.UpdateGui then
		obj:UpdateGui()
	end
	for i,v in pairs(obj.Children)do
		Gui.UpdateGui(v)
	end
	return
end

function Gui.Hide(self)
	Gui.ScreenGui.Enabled = false
end

function Gui.Show(self)
	Gui.ScreenGui.Enabled = true
end

local function Init(userConf)
	Gui.ScreenGui = Instance.new("ScreenGui")
	Gui.ScreenGui.ResetOnSpawn = false
	Gui.ScreenGui.IgnoreGuiInset = true
	
	local rootFrame = Instance.new("Frame")
	rootFrame.Size = UDim2.new(1,0,1,0)
	rootFrame.BackgroundTransparency = 1
	
	Gui.ScreenGui.Parent = game.Players.LocalPlayer.PlayerGui
	rootFrame.Parent = Gui.ScreenGui
	Gui.Categories = BaseObject(TypeEnum.Root,nil,nil,rootFrame)
	
	userConf = userConf or {}
	for i,v in pairs(userConf) do
		Gui.Config[i] = v
	end
	return Gui
end

return Init