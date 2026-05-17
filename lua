local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local WHITELIST = {
    "harpromax",
    "razerxboy",
    "KINGxKEPET",
    "nuyuldulu",
    "PlayerLima654",
}

local allowed = false
for _, name in ipairs(WHITELIST) do
    if LocalPlayer.Name == name then
        allowed = true
        break
    end
end

if not allowed then
    local denyGui = Instance.new("ScreenGui")
    denyGui.Name = "HayuDeny"
    denyGui.ResetOnSpawn = false
    denyGui.DisplayOrder = 999
    denyGui.Parent = PlayerGui
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 280, 0, 90)
    frame.Position = UDim2.new(0.5, -140, 0.5, -45)
    frame.BackgroundColor3 = Color3.fromRGB(8, 18, 40)
    frame.BorderSizePixel = 0
    frame.Parent = denyGui
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)
    local stroke = Instance.new("UIStroke", frame)
    stroke.Color = Color3.fromRGB(180, 40, 40)
    stroke.Thickness = 1.5
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = "🔥 HAYU Store\n\nAkses Ditolak: " .. LocalPlayer.Name
    lbl.TextColor3 = Color3.fromRGB(255, 80, 80)
    lbl.TextSize = 13
    lbl.Font = Enum.Font.GothamBold
    lbl.TextXAlignment = Enum.TextXAlignment.Center
    lbl.Parent = frame
    task.delay(4, function() denyGui:Destroy() end)
    return
end

if PlayerGui:FindFirstChild("HayuStoreGUI") then
    PlayerGui:FindFirstChild("HayuStoreGUI"):Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "HayuStoreGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.IgnoreGuiInset = true
ScreenGui.DisplayOrder = 999
ScreenGui.Parent = PlayerGui

local function makeDraggable(dragFrame, targetFrame)
    local dragging = false
    local dragInput = nil
    local mousePos = nil
    local framePos = nil
    dragFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            mousePos = input.Position
            framePos = targetFrame.Position
        end
    end)
    dragFrame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    dragFrame.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - mousePos
            targetFrame.Position = UDim2.new(
                framePos.X.Scale, framePos.X.Offset + delta.X,
                framePos.Y.Scale, framePos.Y.Offset + delta.Y
            )
        end
    end)
end

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 300, 0, 265)
MainFrame.Position = UDim2.new(0.5, -150, 0.5, -132)
MainFrame.BackgroundColor3 = Color3.fromRGB(8, 18, 40)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.ZIndex = 100
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)
local mainStroke = Instance.new("UIStroke", MainFrame)
mainStroke.Color = Color3.fromRGB(30, 100, 220)
mainStroke.Thickness = 1.5
makeDraggable(MainFrame, MainFrame)

local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 40)
TopBar.Position = UDim2.new(0, 0, 0, 0)
TopBar.BackgroundColor3 = Color3.fromRGB(12, 35, 80)
TopBar.BorderSizePixel = 0
TopBar.ZIndex = 101
TopBar.Parent = MainFrame
Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 10)

local topFiller = Instance.new("Frame")
topFiller.Size = UDim2.new(1, 0, 0, 12)
topFiller.Position = UDim2.new(0, 0, 1, -12)
topFiller.BackgroundColor3 = Color3.fromRGB(12, 35, 80)
topFiller.BorderSizePixel = 0
topFiller.ZIndex = 101
topFiller.Parent = TopBar

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -80, 1, 0)
TitleLabel.Position = UDim2.new(0, 12, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "🔥 HAYU Store"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 15
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.ZIndex = 102
TitleLabel.Parent = TopBar

local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 28, 0, 28)
MinBtn.Position = UDim2.new(1, -62, 0, 6)
MinBtn.BackgroundColor3 = Color3.fromRGB(30, 60, 120)
MinBtn.Text = "—"
MinBtn.TextColor3 = Color3.fromRGB(180, 210, 255)
MinBtn.TextSize = 14
MinBtn.Font = Enum.Font.GothamBold
MinBtn.BorderSizePixel = 0
MinBtn.ZIndex = 103
MinBtn.Parent = TopBar
Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0, 6)

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 28, 0, 28)
CloseBtn.Position = UDim2.new(1, -30, 0, 6)
CloseBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize = 13
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.BorderSizePixel = 0
CloseBtn.ZIndex = 103
CloseBtn.Parent = TopBar
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)

local ContentFrame = Instance.new("Frame")
ContentFrame.Size = UDim2.new(1, 0, 1, -40)
ContentFrame.Position = UDim2.new(0, 0, 0, 40)
ContentFrame.BackgroundTransparency = 1
ContentFrame.ZIndex = 101
ContentFrame.Parent = MainFrame

local pad = Instance.new("UIPadding", ContentFrame)
pad.PaddingLeft = UDim.new(0, 12)
pad.PaddingRight = UDim.new(0, 12)
pad.PaddingTop = UDim.new(0, 10)
pad.PaddingBottom = UDim.new(0, 10)

local layout = Instance.new("UIListLayout", ContentFrame)
layout.FillDirection = Enum.FillDirection.Vertical
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Padding = UDim.new(0, 8)

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, 0, 0, 18)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Status: Idle"
StatusLabel.TextColor3 = Color3.fromRGB(120, 150, 200)
StatusLabel.TextSize = 11
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.TextXAlignment = Enum.TextXAlignment.Center
StatusLabel.LayoutOrder = 0
StatusLabel.ZIndex = 102
StatusLabel.Parent = ContentFrame

local COLOR_CLAIM   = Color3.fromRGB(220, 130, 0)
local COLOR_HATCH   = Color3.fromRGB(40, 100, 210)
local COLOR_AFK     = Color3.fromRGB(30, 130, 80)
local COLOR_RUNNING = Color3.fromRGB(60, 60, 80)

local function createBtn(text, color, order)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, 0, 0, 46)
    Btn.BackgroundColor3 = color
    Btn.Text = text
    Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Btn.TextSize = 14
    Btn.Font = Enum.Font.GothamBold
    Btn.BorderSizePixel = 0
    Btn.LayoutOrder = order
    Btn.AutoButtonColor = false
    Btn.ZIndex = 102
    Btn.Parent = ContentFrame
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 8)
    return Btn
end

local ClaimBtn = createBtn("⚡  AUTO CLAIM", COLOR_CLAIM, 1)
local HatchBtn = createBtn("🥚  AUTO HATCH", COLOR_HATCH, 2)
local AfkBtn   = createBtn("🏃  CLAIM AFK",  COLOR_AFK,   3)

local claimRunning = false
ClaimBtn.MouseButton1Click:Connect(function()
    if claimRunning then return end
    claimRunning = true
    ClaimBtn.BackgroundColor3 = COLOR_RUNNING
    ClaimBtn.Text = "RUNNING"
    StatusLabel.Text = "AUTO CLAIM berjalan..."
    StatusLabel.TextColor3 = Color3.fromRGB(255, 200, 80)
    task.spawn(function()
        for i = 1, 15 do
            pcall(function()
                game:GetService("ReplicatedStorage").Msg.RemoteFunction:InvokeServer(
                    "ClaimOnceEventPassAward", { i, false }
                )
            end)
            task.wait(0.05)
        end
        claimRunning = false
        ClaimBtn.BackgroundColor3 = COLOR_CLAIM
        ClaimBtn.Text = "⚡  AUTO CLAIM"
        StatusLabel.Text = "Status: Idle"
        StatusLabel.TextColor3 = Color3.fromRGB(120, 150, 200)
    end)
end)

local hatchRunning = false
HatchBtn.MouseButton1Click:Connect(function()
    if hatchRunning then return end
    hatchRunning = true
    HatchBtn.BackgroundColor3 = COLOR_RUNNING
    HatchBtn.Text = "RUNNING"
    StatusLabel.Text = "AUTO HATCH berjalan..."
    StatusLabel.TextColor3 = Color3.fromRGB(100, 180, 255)
    task.spawn(function()
        for i = 1, 10 do
            pcall(function()
                game:GetService("ReplicatedStorage").Msg.RemoteFunction:InvokeServer(
                    "SystemEventCraftHatch"
                )
            end)
            task.wait(0.05)
        end
        hatchRunning = false
        HatchBtn.BackgroundColor3 = COLOR_HATCH
        HatchBtn.Text = "🥚  AUTO HATCH"
        StatusLabel.Text = "Status: Idle"
        StatusLabel.TextColor3 = Color3.fromRGB(120, 150, 200)
    end)
end)

local afkRunning = false
AfkBtn.MouseButton1Click:Connect(function()
    if afkRunning then return end
    afkRunning = true
    AfkBtn.BackgroundColor3 = COLOR_RUNNING
    AfkBtn.Text = "RUNNING"
    StatusLabel.Text = "CLAIM AFK berjalan..."
    StatusLabel.TextColor3 = Color3.fromRGB(80, 255, 150)
    task.spawn(function()
        pcall(function()
            game:GetService("ReplicatedStorage").Msg.RemoteFunction:InvokeServer(
                "ClaimCurrentEventAFKReward"
            )
        end)
        task.wait(0.05)
        afkRunning = false
        AfkBtn.BackgroundColor3 = COLOR_AFK
        AfkBtn.Text = "🏃  CLAIM AFK"
        StatusLabel.Text = "Status: Idle"
        StatusLabel.TextColor3 = Color3.fromRGB(120, 150, 200)
    end)
end)

CloseBtn.MouseButton1Click:Connect(function()
    claimRunning = false
    hatchRunning = false
    afkRunning   = false
    ScreenGui:Destroy()
end)

local MiniBtn = Instance.new("TextButton")
MiniBtn.Name = "MiniBtn"
MiniBtn.Size = UDim2.new(0, 44, 0, 44)
MiniBtn.Position = MainFrame.Position
MiniBtn.BackgroundColor3 = Color3.fromRGB(12, 35, 80)
MiniBtn.Text = "🔥"
MiniBtn.TextSize = 24
MiniBtn.Font = Enum.Font.GothamBold
MiniBtn.BorderSizePixel = 0
MiniBtn.Visible = false
MiniBtn.ZIndex = 200
MiniBtn.Parent = ScreenGui
Instance.new("UICorner", MiniBtn).CornerRadius = UDim.new(0, 10)
local miniStroke = Instance.new("UIStroke", MiniBtn)
miniStroke.Color = Color3.fromRGB(30, 100, 220)
miniStroke.Thickness = 1.5
makeDraggable(MiniBtn, MiniBtn)

MinBtn.MouseButton1Click:Connect(function()
    MiniBtn.Position = UDim2.new(
        MainFrame.Position.X.Scale, MainFrame.Position.X.Offset,
        MainFrame.Position.Y.Scale, MainFrame.Position.Y.Offset
    )
    MainFrame.Visible = false
    MiniBtn.Visible = true
end)

MiniBtn.MouseButton1Click:Connect(function()
    MainFrame.Position = UDim2.new(
        MiniBtn.Position.X.Scale, MiniBtn.Position.X.Offset,
        MiniBtn.Position.Y.Scale, MiniBtn.Position.Y.Offset
    )
    MainFrame.Visible = true
    MiniBtn.Visible = false
end)
