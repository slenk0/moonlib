local MenuLib = {}
MenuLib.__index = MenuLib

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local Theme = {
	Background = Color3.fromRGB(25, 25, 30),
	Accent = Color3.fromRGB(0, 170, 255),
	Text = Color3.fromRGB(255, 255, 255),
	Border = Color3.fromRGB(40, 40, 45),
	Hover = Color3.fromRGB(35, 35, 40),
	Click = Color3.fromRGB(20, 20, 25),
	Font = Enum.Font.Gotham,
	FontSize = 14,
	Corner = UDim.new(0, 6),
	Padding = UDim.new(0, 8),
	Anim = 0.18
}

local function Inst(class, props, parent)
	local obj = Instance.new(class)
	for k, v in pairs(props or {}) do
		obj[k] = v
	end
	if parent then obj.Parent = parent end
	return obj
end

local function Tween(obj, props, ease)
	local info = TweenInfo.new(Theme.Anim, ease or Enum.EasingStyle.Quint)
	local tween = TweenService:Create(obj, info, props)
	tween:Play()
	return tween
end

function MenuLib.new(title, pos, size)
	local self = setmetatable({}, MenuLib)
	self.Elements = {}
	self.Tabs = {}
	self.CurrentTab = nil
	self.Open = true
	self.Drag = false
	self.Offset = Vector2.new()

	self.Gui = Inst("ScreenGui", {
		Name = "CheatLib",
		ResetOnSpawn = false,
		IgnoreGuiInset = true
	}, LocalPlayer:WaitForChild("PlayerGui"))

	self.Frame = Inst("Frame", {
		Size = size or UDim2.new(0, 450, 0, 350),
		Position = pos or UDim2.new(0.5, -225, 0.5, -175),
		BackgroundColor3 = Theme.Background,
		BorderSizePixel = 0,
		ClipsDescendants = true
	}, self.Gui)

	Inst("UICorner", {CornerRadius = Theme.Corner}, self.Frame)

	self.TitleBar = Inst("Frame", {
		Size = UDim2.new(1, 0, 0, 36),
		BackgroundColor3 = Theme.Accent,
		BorderSizePixel = 0
	}, self.Frame)

	Inst("UICorner", {CornerRadius = Theme.Corner}, self.TitleBar)

	self.Title = Inst("TextLabel", {
		Size = UDim2.new(1, -80, 1, 0),
		Position = UDim2.new(0, 12, 0, 0),
		BackgroundTransparency = 1,
		Text = title or "Cheat UI",
		TextColor3 = Theme.Text,
		Font = Theme.Font,
		TextSize = Theme.FontSize + 2,
		TextXAlignment = Enum.TextXAlignment.Left
	}, self.TitleBar)

	self.Close = Inst("TextButton", {
		Size = UDim2.new(0, 36, 0, 36),
		Position = UDim2.new(1, -36, 0, 0),
		BackgroundTransparency = 1,
		Text = "×",
		TextColor3 = Theme.Text,
		Font = Theme.Font,
		TextSize = 20
	}, self.TitleBar)

	self.Close.MouseButton1Click:Connect(function()
		self:Toggle()
	end)

	self.Minimize = Inst("TextButton", {
		Size = UDim2.new(0, 36, 0, 36),
		Position = UDim2.new(1, -72, 0, 0),
		BackgroundTransparency = 1,
		Text = "−",
		TextColor3 = Theme.Text,
		Font = Theme.Font,
		TextSize = 20
	}, self.TitleBar)

	self.Minimize.MouseButton1Click:Connect(function()
		if self.Frame.Size.Y.Offset > 36 then
			self.MinSize = self.Frame.Size
			Tween(self.Frame, {Size = UDim2.new(0, self.Frame.Size.X.Offset, 0, 36)})
		else
			Tween(self.Frame, {Size = self.MinSize or UDim2.new(0, 450, 0, 350)})
		end
	end)

	self.TabBar = Inst("Frame", {
		Size = UDim2.new(1, 0, 0, 36),
		Position = UDim2.new(0, 0, 0, 36),
		BackgroundColor3 = Theme.Border,
		BorderSizePixel = 0
	}, self.Frame)

	self.Content = Inst("ScrollingFrame", {
		Size = UDim2.new(1, -12, 1, -72),
		Position = UDim2.new(0, 6, 0, 72),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 4,
		CanvasSize = UDim2.new(0, 0, 0, 0),
		ScrollingDirection = Enum.ScrollingDirection.Y
	}, self.Frame)

	self.Layout = Inst("UIListLayout", {
		Padding = Theme.Padding,
		SortOrder = Enum.SortOrder.LayoutOrder,
		HorizontalAlignment = Enum.HorizontalAlignment.Center
	}, self.Content)

	self.Layout.Changed:Connect(function()
		self.Content.CanvasSize = UDim2.new(0, 0, 0, self.Layout.AbsoluteContentSize.Y + 20)
	end)

	self.TitleBar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			self.Drag = true
			self.Offset = input.Position - self.Frame.AbsolutePosition
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			self.Drag = false
		end
	end)

	RunService.RenderStepped:Connect(function()
		if self.Drag then
			local mouse = UserInputService:GetMouseLocation()
			self.Frame.Position = UDim2.new(0, mouse.X - self.Offset.X, 0, mouse.Y - self.Offset.Y)
		end
	end)

	return self
end

function MenuLib:Toggle()
	self.Open = not self.Open
	self.Gui.Enabled = self.Open
end

function MenuLib:AddTab(name)
	local tab = {}
	tab.Name = name
	tab.Elements = {}
	tab.Button = Inst("TextButton", {
		Size = UDim2.new(0, 120, 1, 0),
		BackgroundColor3 = Theme.Background,
		Text = name,
		TextColor3 = Theme.Text,
		Font = Theme.Font,
		TextSize = Theme.FontSize,
		BorderSizePixel = 0
	}, self.TabBar)

	Inst("UICorner", {CornerRadius = Theme.Corner}, tab.Button)

	if not self.TabLayout then
		self.TabLayout = Inst("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			Padding = UDim.new(0, 4),
			SortOrder = Enum.SortOrder.LayoutOrder
		}, self.TabBar)
	end

	tab.Button.MouseButton1Click:Connect(function()
		self:SelectTab(tab)
	end)

	table.insert(self.Tabs, tab)
	if not self.CurrentTab then self:SelectTab(tab) end
	return tab
end

function MenuLib:SelectTab(tab)
	if self.CurrentTab then
		self.CurrentTab.Button.BackgroundColor3 = Theme.Background
		for _, el in ipairs(self.CurrentTab.Elements) do el.Visible = false end
	end
	self.CurrentTab = tab
	tab.Button.BackgroundColor3 = Theme.Accent
	for _, el in ipairs(tab.Elements) do el.Visible = true end
	self.Layout:ApplyLayout()
end

function MenuLib:AddSection(container, name)
	local section = Inst("Frame", {
		Size = UDim2.new(1, -16, 0, 0),
		BackgroundColor3 = Theme.Border,
		BorderSizePixel = 0,
		Visible = false
	}, self.Content)

	Inst("UICorner", {CornerRadius = Theme.Corner}, section)

	local title = Inst("TextLabel", {
		Size = UDim2.new(1, 0, 0, 24),
		BackgroundTransparency = 1,
		Text = name,
		TextColor3 = Theme.Accent,
		Font = Theme.Font,
		TextSize = Theme.FontSize + 1,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextWrapped = true
	}, section)

	local secLayout = Inst("UIListLayout", {
		Padding = Theme.Padding,
		SortOrder = Enum.SortOrder.LayoutOrder
	}, section)

	secLayout.Changed:Connect(function()
		section.Size = UDim2.new(1, -16, 0, secLayout.AbsoluteContentSize.Y + 24 + Theme.Padding.Offset * 2)
	end)

	table.insert(container.Elements, section)
	table.insert(self.Elements, section)
	return section
end

function MenuLib:AddButton(container, text, callback)
	local parent = (container.Elements and self.Content) or container
	local btn = Inst("TextButton", {
		Size = UDim2.new(1, 0, 0, 32),
		BackgroundColor3 = Theme.Border,
		Text = text,
		TextColor3 = Theme.Text,
		Font = Theme.Font,
		TextSize = Theme.FontSize,
		BorderSizePixel = 0,
		Visible = false
	}, parent)

	Inst("UICorner", {CornerRadius = Theme.Corner}, btn)

	btn.MouseEnter:Connect(function()
		Tween(btn, {BackgroundColor3 = Theme.Hover})
	end)

	btn.MouseLeave:Connect(function()
		Tween(btn, {BackgroundColor3 = Theme.Border})
	end)

	btn.MouseButton1Down:Connect(function()
		Tween(btn, {BackgroundColor3 = Theme.Click})
	end)

	btn.MouseButton1Up:Connect(function()
		Tween(btn, {BackgroundColor3 = Theme.Hover})
		if callback then callback() end
	end)

	if container.Elements then
		table.insert(container.Elements, btn)
	end
	table.insert(self.Elements, btn)
	return btn
end

function MenuLib:AddToggle(container, text, default, callback)
	local parent = (container.Elements and self.Content) or container
	local frame = Inst("Frame", {
		Size = UDim2.new(1, 0, 0, 32),
		BackgroundColor3 = Theme.Border,
		BorderSizePixel = 0,
		Visible = false
	}, parent)

	Inst("UICorner", {CornerRadius = Theme.Corner}, frame)

	local label = Inst("TextLabel", {
		Size = UDim2.new(1, -50, 1, 0),
		Position = UDim2.new(0, 8, 0, 0),
		BackgroundTransparency = 1,
		Text = text,
		TextColor3 = Theme.Text,
		Font = Theme.Font,
		TextSize = Theme.FontSize,
		TextXAlignment = Enum.TextXAlignment.Left
	}, frame)

	local toggle = Inst("Frame", {
		Size = UDim2.new(0, 40, 0, 20),
		Position = UDim2.new(1, -48, 0.5, -10),
		BackgroundColor3 = default and Theme.Accent or Theme.Background,
		BorderSizePixel = 0
	}, frame)

	Inst("UICorner", {CornerRadius = UDim.new(1, 0)}, toggle)

	local circle = Inst("Frame", {
		Size = UDim2.new(0, 16, 0, 16),
		Position = default and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8),
		BackgroundColor3 = Theme.Text,
		BorderSizePixel = 0
	}, toggle)

	Inst("UICorner", {CornerRadius = UDim.new(1, 0)}, circle)

	local state = default
	callback(state)

	frame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			state = not state
			Tween(toggle, {BackgroundColor3 = state and Theme.Accent or Theme.Background})
			Tween(circle, {Position = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)})
			if callback then callback(state) end
		end
	end)

	if container.Elements then
		table.insert(container.Elements, frame)
	end
	table.insert(self.Elements, frame)
	return frame
end

function MenuLib:AddSlider(container, text, min, max, default, callback)
	local parent = (container.Elements and self.Content) or container
	local frame = Inst("Frame", {
		Size = UDim2.new(1, 0, 0, 50),
		BackgroundColor3 = Theme.Border,
		BorderSizePixel = 0,
		Visible = false
	}, parent)

	Inst("UICorner", {CornerRadius = Theme.Corner}, frame)

	local label = Inst("TextLabel", {
		Size = UDim2.new(1, -60, 0, 20),
		Position = UDim2.new(0, 10, 0, 5),
		BackgroundTransparency = 1,
		Text = text,
		TextColor3 = Theme.Text,
		Font = Theme.Font,
		TextSize = Theme.FontSize,
		TextXAlignment = Enum.TextXAlignment.Left
	}, frame)

	local valueLabel = Inst("TextLabel", {
		Size = UDim2.new(0, 50, 0, 20),
		Position = UDim2.new(1, -60, 0, 5),
		BackgroundTransparency = 1,
		Text = tostring(default),
		TextColor3 = Theme.Accent,
		Font = Theme.Font,
		TextSize = Theme.FontSize,
		TextXAlignment = Enum.TextXAlignment.Right
	}, frame)

	local bar = Inst("Frame", {
		Size = UDim2.new(1, -20, 0, 6),
		Position = UDim2.new(0, 10, 1, -16),
		BackgroundColor3 = Theme.Background,
		BorderSizePixel = 0
	}, frame)

	Inst("UICorner", {CornerRadius = UDim.new(0, 3)}, bar)

	local fill = Inst("Frame", {
		Size = UDim2.new((default - min) / (max - min), 0, 1, 0),
		BackgroundColor3 = Theme.Accent,
		BorderSizePixel = 0
	}, bar)

	Inst("UICorner", {CornerRadius = UDim.new(0, 3)}, fill)

	local knob = Inst("Frame", {
		Size = UDim2.new(0, 16, 0, 16),
		Position = UDim2.new((default - min) / (max - min), -8, 0.5, -8),
		BackgroundColor3 = Theme.Text,
		BorderSizePixel = 0
	}, bar)

	Inst("UICorner", {CornerRadius = UDim.new(1, 0)}, knob)

	local dragging = false

	local function update(pos)
		local percent = math.clamp((pos.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
		local val = min + percent * (max - min)
		fill.Size = UDim2.new(percent, 0, 1, 0)
		knob.Position = UDim2.new(percent, -8, 0.5, -8)
		valueLabel.Text = string.format("%.2f", val)
		if callback then callback(val) end
		return val
	end

	update(Vector2.new(bar.AbsolutePosition.X + (default - min) / (max - min) * bar.AbsoluteSize.X, 0))

	bar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			update(input.Position)
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			update(input.Position)
		end
	end)

	if container.Elements then
		table.insert(container.Elements, frame)
	end
	table.insert(self.Elements, frame)
	return frame
end

function MenuLib:AddDropdown(container, text, options, default, callback)
	local parent = (container.Elements and self.Content) or container
	local frame = Inst("Frame", {
		Size = UDim2.new(1, 0, 0, 32),
		BackgroundColor3 = Theme.Border,
		BorderSizePixel = 0,
		Visible = false
	}, parent)

	Inst("UICorner", {CornerRadius = Theme.Corner}, frame)

	local label = Inst("TextLabel", {
		Size = UDim2.new(0.5, 0, 1, 0),
		Position = UDim2.new(0, 10, 0, 0),
		BackgroundTransparency = 1,
		Text = text,
		TextColor3 = Theme.Text,
		Font = Theme.Font,
		TextSize = Theme.FontSize,
		TextXAlignment = Enum.TextXAlignment.Left
	}, frame)

	local arrow = Inst("TextLabel", {
		Size = UDim2.new(0, 20, 1, 0),
		Position = UDim2.new(1, -30, 0, 0),
		BackgroundTransparency = 1,
		Text = "▼",
		TextColor3 = Theme.Text,
		Font = Theme.Font,
		TextSize = Theme.FontSize
	}, frame)

	local selected = Inst("TextLabel", {
		Size = UDim2.new(0.5, -40, 1, 0),
		Position = UDim2.new(0.5, 0, 0, 0),
		BackgroundTransparency = 1,
		Text = options[default] or options[1],
		TextColor3 = Theme.Accent,
		Font = Theme.Font,
		TextSize = Theme.FontSize,
		TextXAlignment = Enum.TextXAlignment.Right
	}, frame)

	local listFrame = Inst("ScrollingFrame", {
		Size = UDim2.new(1, 0, 0, math.min(#options * 32, 160)),
		Position = UDim2.new(0, 0, 1, 2),
		BackgroundColor3 = Theme.Background,
		BorderSizePixel = 0,
		Visible = false,
		ZIndex = 10,
		ScrollBarThickness = 4,
		CanvasSize = UDim2.new(0, 0, 0, #options * 32)
	}, frame)

	Inst("UICorner", {CornerRadius = Theme.Corner}, listFrame)

	local listLayout = Inst("UIListLayout", {
		Padding = UDim.new(0, 0),
		SortOrder = Enum.SortOrder.LayoutOrder
	}, listFrame)

	local open = false

	frame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			open = not open
			listFrame.Visible = open
			Tween(arrow, {Rotation = open and 180 or 0})
		end
	end)

	for i, opt in ipairs(options) do
		local btn = Inst("TextButton", {
			Size = UDim2.new(1, 0, 0, 32),
			BackgroundTransparency = 1,
			Text = opt,
			TextColor3 = Theme.Text,
			Font = Theme.Font,
			TextSize = Theme.FontSize,
			ZIndex = 11
		}, listFrame)

		btn.MouseButton1Click:Connect(function()
			selected.Text = opt
			open = false
			listFrame.Visible = false
			Tween(arrow, {Rotation = 0})
			if callback then callback(i, opt) end
		end)
	end

	if callback then callback(default, options[default] or options[1]) end

	if container.Elements then
		table.insert(container.Elements, frame)
	end
	table.insert(self.Elements, frame)
	return frame
end

function MenuLib:AddTextbox(container, text, default, callback)
	local parent = (container.Elements and self.Content) or container
	local frame = Inst("Frame", {
		Size = UDim2.new(1, 0, 0, 32),
		BackgroundColor3 = Theme.Border,
		BorderSizePixel = 0,
		Visible = false
	}, parent)

	Inst("UICorner", {CornerRadius = Theme.Corner}, frame)

	local label = Inst("TextLabel", {
		Size = UDim2.new(0.5, 0, 1, 0),
		Position = UDim2.new(0, 10, 0, 0),
		BackgroundTransparency = 1,
		Text = text,
		TextColor3 = Theme.Text,
		Font = Theme.Font,
		TextSize = Theme.FontSize,
		TextXAlignment = Enum.TextXAlignment.Left
	}, frame)

	local textbox = Inst("TextBox", {
		Size = UDim2.new(0.5, -20, 1, -8),
		Position = UDim2.new(0.5, 10, 0, 4),
		BackgroundColor3 = Theme.Background,
		Text = default or "",
		TextColor3 = Theme.Text,
		Font = Theme.Font,
		TextSize = Theme.FontSize,
		BorderSizePixel = 0,
		ClearTextOnFocus = false
	}, frame)

	Inst("UICorner", {CornerRadius = Theme.Corner}, textbox)

	textbox.FocusLost:Connect(function(enter)
		if enter and callback then callback(textbox.Text) end
	end)

	if container.Elements then
		table.insert(container.Elements, frame)
	end
	table.insert(self.Elements, frame)
	return frame
end

return MenuLib
