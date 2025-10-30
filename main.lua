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
		Name = "MoonLib",
		ResetOnSpawn = false,
		IgnoreGuiInset = true
	}, LocalPlayer:WaitForChild("PlayerGui"))

	self.Frame = Inst("Frame", {
		Size = size or UDim2.new(0, 420, 0, 320),
		Position = pos or UDim2.new(0.5, -210, 0.5, -160),
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
		Text = title or "Moon",
		TextColor3 = Theme.Text,
		Font = Theme.Font,
		TextSize = Theme.FontSize,
		TextXAlignment = Enum.TextXAlignment.Left
	}, self.TitleBar)

	self.Close = Inst("TextButton", {
		Size = UDim2.new(0, 36, 0, 36),
		Position = UDim2.new(1, -36, 0, 0),
		BackgroundTransparency = 1,
		Text = "×",
		TextColor3 = Theme.Text,
		Font = Theme.Font,
		TextSize = 18
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
		TextSize = 18
	}, self.TitleBar)

	self.Minimize.MouseButton1Click:Connect(function()
		Tween(self.Frame, {Size = UDim2.new(0, self.Frame.Size.X.Offset, 0, 36)})
	end)

	self.TabBar = Inst("Frame", {
		Size = UDim2.new(1, 0, 0, 36),
		Position = UDim2.new(0, 0, 0, 36),
		BackgroundColor3 = Theme.Border,
		BorderSizePixel = 0
	}, self.Frame)

	self.Content = Inst("ScrollingFrame", {
		Size = UDim2.new(1, -12, 1, -84),
		Position = UDim2.new(0, 6, 0, 78),
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

	self.Content:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
		self.Content.CanvasSize = UDim2.new(0, 0, 0, self.Layout.AbsoluteContentSize.Y + 20)
	end)

	self.TitleBar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			self.Drag = true
			self.Offset = input.Position - self.Frame.AbsolutePosition
		end
	end)

	self.TitleBar.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
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
		Size = UDim2.new(0, 110, 1, 0),
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
	end
	self.CurrentTab = tab
	tab.Button.BackgroundColor3 = Theme.Accent
	for _, el in ipairs(self.Elements) do el.Visible = false end
	for _, el in ipairs(tab.Elements) do el.Visible = true end
end

function MenuLib:AddButton(tab, text, callback)
	local btn = Inst("TextButton", {
		Size = UDim2.new(1, -16, 0, 32),
		BackgroundColor3 = Theme.Border,
		Text = text,
		TextColor3 = Theme.Text,
		Font = Theme.Font,
		TextSize = Theme.FontSize,
		BorderSizePixel = 0,
		Visible = false
	}, self.Content)

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

	table.insert(tab.Elements, btn)
	table.insert(self.Elements, btn)
	return btn
end

function MenuLib:AddToggle(tab, text, default, callback)
	local frame = Inst("Frame", {
		Size = UDim2.new(1, -16, 0, 32),
		BackgroundColor3 = Theme.Border,
		BorderSizePixel = 0,
		Visible = false
	}, self.Content)

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

	frame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			state = not state
			Tween(toggle, {BackgroundColor3 = state and Theme.Accent or Theme.Background})
			Tween(circle, {Position = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)})
			if callback then callback(state) end
		end
	end)

	table.insert(tab.Elements, frame)
	table.insert(self.Elements, frame)
	return frame
end

function MenuLib:AddSlider(tab, text, min, max, default, callback)
	local frame = Inst("Frame", {
		Size = UDim2.new(1, -16, 0, 50),
		BackgroundColor3 = Theme.Border,
		BorderSizePixel = 0,
		Visible = false
	}, self.Content)

	Inst("UICorner", {CornerRadius = Theme.Corner}, frame)

	local label = Inst("TextLabel", {
		Size = UDim2.new(1, -20, 0, 20),
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
		local val = math.floor(min + percent * (max - min))
		fill.Size = UDim2.new(percent, 0, 1, 0)
		knob.Position = UDim2.new(percent, -8, 0.5, -8)
		valueLabel.Text = tostring(val)
		if callback then callback(val) end
		return val
	end

	knob.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
		end
	end)

	knob.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			update(input.Position)
		end
	end)

	table.insert(tab.Elements, frame)
	table.insert(self.Elements, frame)
	return frame
end

function MenuLib:AddDropdown(tab, text, options, default, callback)
	local frame = Inst("Frame", {
		Size = UDim2.new(1, -16, 0, 36),
		BackgroundColor3 = Theme.Border,
		BorderSizePixel = 0,
		Visible = false
	}, self.Content)

	Inst("UICorner", {CornerRadius = Theme.Corner}, frame)

	local label = Inst("TextLabel", {
		Size = UDim2.new(1, -60, 1, 0),
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
		Size = UDim2.new(1, -40, 1, 0),
		Position = UDim2.new(0, 10, 0, 0),
		BackgroundTransparency = 1,
		Text = options[default] or options[1],
		TextColor3 = Theme.Accent,
		Font = Theme.Font,
		TextSize = Theme.FontSize,
		TextXAlignment = Enum.TextXAlignment.Right
	}, frame)

	local list = Inst("Frame", {
		Size = UDim2.new(1, -16, 0, #options * 30),
		Position = UDim2.new(0, 0, 1, 4),
		BackgroundColor3 = Theme.Background,
		BorderSizePixel = 0,
		Visible = false,
		ZIndex = 10
	}, frame)

	Inst("UICorner", {CornerRadius = Theme.Corner}, list)

	local layout = Inst("UIListLayout", {
		Padding = UDim.new(0, 0),
		SortOrder = Enum.SortOrder.LayoutOrder
	}, list)

	local open = false

	frame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			open = not open
			list.Visible = open
			Tween(arrow, {Rotation = open and 180 or 0})
		end
	end)

	for i, opt in ipairs(options) do
		local btn = Inst("TextButton", {
			Size = UDim2.new(1, 0, 0, 30),
			BackgroundTransparency = 1,
			Text = opt,
			TextColor3 = Theme.Text,
			Font = Theme.Font,
			TextSize = Theme.FontSize,
			ZIndex = 11
		}, list)

		btn.MouseButton1Click:Connect(function()
			selected.Text = opt
			open = false
			list.Visible = false
			Tween(arrow, {Rotation = 0})
			if callback then callback(i, opt) end
		end)
	end

	table.insert(tab.Elements, frame)
	table.insert(self.Elements, frame)
	return frame
end

return MenuLib
