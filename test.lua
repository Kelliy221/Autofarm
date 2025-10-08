local Players = game:GetService("Players")
local player = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local remote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("RecieveCoin")
local UserInputService = game:GetService("UserInputService")

local autoFarmEnabled = false
local fireDelay = 0.0001
local PassengerValues
local seconds = 0

local function getPassengerValues()
    local success, result
    repeat
        success, result = pcall(function()
            return workspace:WaitForChild("Jeepnies")
                :WaitForChild(player.Name)
                :WaitForChild("PassengerValues")
        end)
        task.wait(0.5)
    until success and result
    return result
end

PassengerValues = getPassengerValues()

local function formatTime(s)
    local h = math.floor(s / 3600)
    local m = math.floor((s % 3600) / 60)
    local sec = s % 60
    return string.format("%02d:%02d:%02d", h, m, sec)
end

local function runAutoFarm()
    coroutine.wrap(function()
        while autoFarmEnabled do
            local args = {{
                Password = 5486964568496,
                Value = 300,
                PassengerValues = PassengerValues
            }}
            pcall(function()
                remote:FireServer(unpack(args))
            end)
            task.wait(fireDelay)
        end
    end)()
end

local function startTimer(label, toggleButton)
    coroutine.wrap(function()
        seconds = 0
        while autoFarmEnabled do
            task.wait(1)
            seconds += 1
            label.Text = "" .. formatTime(seconds)
            if seconds >= 175 then
                autoFarmEnabled = false
                toggleButton.Text = "OFF"
                for i = 5, 1, -1 do
                    label.Text = " Kicking in " .. i .. "s..."
                    task.wait(1)
                end
                player:Kick("Tapos na. Change account kana.")
                break
            end
        end
    end)()
end

local ScreenGui = Instance.new("ScreenGui")
local Frame = Instance.new("Frame")
local UICorner = Instance.new("UICorner")
local ToggleButton = Instance.new("TextButton")
local TimerLabel = Instance.new("TextLabel")
local BackgroundImage = Instance.new("ImageLabel")

ScreenGui.Parent = player:WaitForChild("PlayerGui")
ScreenGui.Name = "AutoFarmGUI"
ScreenGui.ResetOnSpawn = false

Frame.Parent = ScreenGui
Frame.BackgroundTransparency = 1
Frame.Position = UDim2.new(0.75, 0, 0.4, 0)
Frame.Size = UDim2.new(0, 200, 0, 150)

UICorner.CornerRadius = UDim.new(0, 18)
UICorner.Parent = Frame

BackgroundImage.Parent = Frame
BackgroundImage.Size = UDim2.new(1, 0, 1, 0)
BackgroundImage.Position = UDim2.new(0, 0, 0, 0)
BackgroundImage.Image = "rbxassetid://114609721673100"
BackgroundImage.BackgroundTransparency = 1
BackgroundImage.ImageTransparency = 0
BackgroundImage.ScaleType = Enum.ScaleType.Crop
BackgroundImage.ZIndex = 0

ToggleButton.Parent = Frame
ToggleButton.Position = UDim2.new(0.1, 0, 0.45, 0)
ToggleButton.Size = UDim2.new(0.8, 0, 0.25, 0)
ToggleButton.Text = "OFF"
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.TextSize = 18
ToggleButton.BackgroundTransparency = 1
ToggleButton.ZIndex = 2

TimerLabel.Parent = Frame
TimerLabel.Position = UDim2.new(0, 0, 0.78, 0)
TimerLabel.Size = UDim2.new(1, 0, 0.2, 0)
TimerLabel.BackgroundTransparency = 1
TimerLabel.Text = "00:00:00"
TimerLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TimerLabel.Font = Enum.Font.GothamBold
TimerLabel.TextSize = 16
TimerLabel.ZIndex = 2

ToggleButton.MouseButton1Click:Connect(function()
    autoFarmEnabled = not autoFarmEnabled
    if autoFarmEnabled then
        ToggleButton.Text = "ON"
        runAutoFarm()
        startTimer(TimerLabel, ToggleButton)
    else
        ToggleButton.Text = "OFF"
    end
end)

local dragging = false
local dragStart, startPos

local function update(input)
    local delta = input.Position - dragStart
    Frame.Position = UDim2.new(
        startPos.X.Scale,
        startPos.X.Offset + delta.X,
        startPos.Y.Scale,
        startPos.Y.Offset + delta.Y
    )
end

Frame.InputBegan:Connect(function(input)
    if
        input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch
    then
        dragging = true
        dragStart = input.Position
        startPos = Frame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if
        dragging
        and (input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch)
    then
        update(input)
    end
end)
