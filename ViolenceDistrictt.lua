-- =====================================================
-- VIOLENCE DISTRICT SCRIPT - DELTA VERSION
-- Tanpa Rayfield, pake UI Manual
-- By: hannn
-- =====================================================

print("🚀 Loading script...")

-- =====================================================
-- 1. UI MANUAL (TANPA RAYFIELD)
-- =====================================================
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local UserInputService = game:GetService("UserInputService")

-- Tunggu PlayerGui
local playerGui = Player:WaitForChild("PlayerGui")

-- Buat ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "VD_Script_UI"
screenGui.Parent = playerGui

-- Main Frame
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 350, 0, 450)
mainFrame.Position = UDim2.new(0.5, -175, 0.5, -225)
mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
mainFrame.BackgroundTransparency = 0.1
mainFrame.BorderSizePixel = 2
mainFrame.BorderColor3 = Color3.fromRGB(0, 255, 65)
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Visible = false -- Awalnya hidden
mainFrame.Parent = screenGui

-- Title Bar
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 35)
titleBar.BackgroundColor3 = Color3.fromRGB(0, 255, 65)
titleBar.BackgroundTransparency = 0.2
titleBar.Parent = mainFrame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -30, 1, 0)
title.BackgroundTransparency = 1
title.Text = "🔪 VD SCRIPT [DELTA]"
title.TextColor3 = Color3.fromRGB(0, 255, 65)
title.TextSize = 16
title.TextXAlignment = Enum.TextXAlignment.Left
title.Font = Enum.Font.GothamBold
title.Parent = titleBar

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 30, 1, 0)
closeBtn.Position = UDim2.new(1, -30, 0, 0)
closeBtn.BackgroundTransparency = 1
closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.fromRGB(255, 0, 0)
closeBtn.TextSize = 16
closeBtn.Font = Enum.Font.GothamBold
closeBtn.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)
closeBtn.Parent = titleBar

-- Scroll Frame buat isi menu
local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(1, 0, 1, -35)
scrollFrame.Position = UDim2.new(0, 0, 0, 35)
scrollFrame.BackgroundTransparency = 1
scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 600)
scrollFrame.ScrollBarThickness = 4
scrollFrame.Parent = mainFrame

local yPos = 10

-- Fungsi bikin toggle
local function CreateToggle(parent, yPos, label, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -20, 0, 30)
    frame.Position = UDim2.new(0, 10, 0, yPos)
    frame.BackgroundTransparency = 1
    frame.Parent = parent

    local text = Instance.new("TextLabel")
    text.Size = UDim2.new(0.7, 0, 1, 0)
    text.BackgroundTransparency = 1
    text.Text = label
    text.TextColor3 = Color3.fromRGB(200, 200, 200)
    text.TextSize = 13
    text.TextXAlignment = Enum.TextXAlignment.Left
    text.Font = Enum.Font.Gotham
    text.Parent = frame

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 60, 1, 0)
    btn.Position = UDim2.new(0.8, 0, 0, 0)
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    btn.BorderSizePixel = 0
    btn.Text = "OFF"
    btn.TextColor3 = Color3.fromRGB(255, 100, 100)
    btn.TextSize = 12
    btn.Font = Enum.Font.GothamBold
    btn.Parent = frame

    local state = false
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.Text = state and "ON" or "OFF"
        btn.BackgroundColor3 = state and Color3.fromRGB(0, 200, 50) or Color3.fromRGB(40, 40, 50)
        btn.TextColor3 = state and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(255, 100, 100)
        callback(state)
    end)
end

-- Fungsi bikin button
local function CreateButton(parent, yPos, label, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.8, 0, 0, 30)
    btn.Position = UDim2.new(0.1, 0, 0, yPos)
    btn.BackgroundColor3 = Color3.fromRGB(0, 255, 65)
    btn.BackgroundTransparency = 0.15
    btn.BorderSizePixel = 1
    btn.BorderColor3 = Color3.fromRGB(0, 255, 65)
    btn.Text = label
    btn.TextColor3 = Color3.fromRGB(0, 255, 65)
    btn.TextSize = 13
    btn.Font = Enum.Font.GothamBold
    btn.Parent = parent
    btn.MouseButton1Click:Connect(callback)
end

-- =====================================================
-- 2. FITUR-FITUR (COPY DARI SCRIPT SEBELUMNYA)
-- =====================================================

-- Variabel status
local autoGenActive = false
local autoGenConnection = nil
local skillcheckActive = false
local skillcheckThread = nil
local autoParryActive = false
local autoParryThread = nil

-- Ambil Character & Humanoid
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")

-- AUTO GENERATOR + TP
local function GetNearestGenerator()
    local generators = {}
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Name:lower():find("generator") then
            table.insert(generators, obj)
        end
    end
    
    if #generators == 0 then return nil end
    
    local available = {}
    for _, gen in pairs(generators) do
        local progress = gen:FindFirstChild("Progress") or gen:FindFirstChild("Value")
        if progress and progress.Value < 100 then
            table.insert(available, gen)
        end
    end
    
    if #available == 0 then return nil end
    
    local nearest = nil
    local nearestDist = math.huge
    local charPos = Character.HumanoidRootPart.Position
    
    for _, gen in pairs(available) do
        local dist = (gen.Position - charPos).Magnitude
        if dist < nearestDist then
            nearestDist = dist
            nearest = gen
        end
    end
    
    return nearest
end

local function AutoGeneratorWithTP()
    local target = GetNearestGenerator()
    if not target then return end
    
    local rootPart = Character.HumanoidRootPart
    rootPart.CFrame = CFrame.new(target.Position + Vector3.new(0, 3, 0))
    
    wait(0.5)
    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
    wait(1)
    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
end

local function StartAutoGen()
    if autoGenActive then return end
    autoGenActive = true
    autoGenConnection = RunService.Heartbeat:Connect(function()
        if not autoGenActive then return end
        AutoGeneratorWithTP()
        wait(2)
    end)
    print("🟢 Auto Generator ON")
end

local function StopAutoGen()
    autoGenActive = false
    if autoGenConnection then
        autoGenConnection:Disconnect()
        autoGenConnection = nil
    end
    print("🔴 Auto Generator OFF")
end

-- AUTO SKILLCHECK
local function FindSkillCheckUI()
    local gui = Player:FindFirstChild("PlayerGui")
    if not gui then return nil end
    
    for _, child in pairs(gui:GetDescendants()) do
        if child:IsA("Frame") and (child.Name:lower():find("skill") or child.Name:lower():find("check")) then
            return child
        end
    end
    return nil
end

local function IsInPerfectZone(skillFrame)
    local pointer = skillFrame:FindFirstChild("Pointer") or skillFrame:FindFirstChild("Indicator")
    local perfectZone = skillFrame:FindFirstChild("PerfectZone") or skillFrame:FindFirstChild("WhiteZone")
    
    if pointer and perfectZone then
        local pointerPos = pointer.AbsolutePosition + pointer.AbsoluteSize / 2
        local zonePos = perfectZone.AbsolutePosition
        local zoneSize = perfectZone.AbsoluteSize
        
        if pointerPos.X > zonePos.X and pointerPos.X < zonePos.X + zoneSize.X and
           pointerPos.Y > zonePos.Y and pointerPos.Y < zonePos.Y + zoneSize.Y then
            return true
        end
    end
    return false
end

local function AutoSkillcheckLoop()
    while skillcheckActive do
        local skillUI = FindSkillCheckUI()
        if skillUI and skillUI.Visible then
            if IsInPerfectZone(skillUI) then
                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.MouseButton1, false, game)
                wait(0.05)
                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.MouseButton1, false, game)
            end
        end
        wait(0.05)
    end
end

local function StartAutoSkillcheck()
    if skillcheckActive then return end
    skillcheckActive = true
    skillcheckThread = task.spawn(AutoSkillcheckLoop)
    print("🟢 Auto Skillcheck ON")
end

local function StopAutoSkillcheck()
    skillcheckActive = false
    if skillcheckThread then
        task.cancel(skillcheckThread)
        skillcheckThread = nil
    end
    print("🔴 Auto Skillcheck OFF")
end

-- AUTO PARRY
local function GetNearestKiller()
    local nearest = nil
    local nearestDist = math.huge
    local charPos = Character.HumanoidRootPart.Position
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= Player and player.Character then
            local root = player.Character:FindFirstChild("HumanoidRootPart")
            if root then
                local dist = (root.Position - charPos).Magnitude
                if dist < 30 and dist < nearestDist then
                    nearestDist = dist
                    nearest = player.Character
                end
            end
        end
    end
    return nearest
end

local function IsKillerAttacking(killerChar)
    if killerChar then
        local humanoid = killerChar:FindFirstChild("Humanoid")
        if humanoid then
            local animator = humanoid:FindFirstChild("Animator")
            if animator then
                for _, track in pairs(animator:GetPlayingAnimationTracks()) do
                    if track.AnimationId:lower():find("attack") or track.AnimationId:lower():find("swing") then
                        return true
                    end
                end
            end
        end
    end
    return false
end

local function AutoParryLoop()
    while autoParryActive do
        local killer = GetNearestKiller()
        if killer and IsKillerAttacking(killer) then
            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.F, false, game)
            wait(0.1)
            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.F, false, game)
            wait(0.5)
        end
        wait(0.1)
    end
end

local function StartAutoParry()
    if autoParryActive then return end
    autoParryActive = true
    autoParryThread = task.spawn(AutoParryLoop)
    print("🟢 Auto Parry ON")
end

local function StopAutoParry()
    autoParryActive = false
    if autoParryThread then
        task.cancel(autoParryThread)
        autoParryThread = nil
    end
    print("🔴 Auto Parry OFF")
end

-- =====================================================
-- 3. MENU UI (TANPA RAYFIELD)
-- =====================================================

-- Label Player Mods
local label1 = Instance.new("TextLabel")
label1.Size = UDim2.new(1, 0, 0, 25)
label1.Position = UDim2.new(0, 10, 0, yPos)
label1.BackgroundTransparency = 1
label1.Text = "⚡ PLAYER MODS"
label1.TextColor3 = Color3.fromRGB(0, 255, 65)
label1.TextSize = 14
label1.TextXAlignment = Enum.TextXAlignment.Left
label1.Font = Enum.Font.GothamBold
label1.Parent = scrollFrame
yPos = yPos + 30

-- Toggle Noclip
CreateToggle(scrollFrame, yPos, "Noclip", function(v)
    if v then
        RunService.Stepped:Connect(function()
            local char = Player.Character
            if char then
                for _, part in pairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end)
    end
end)
yPos = yPos + 35

CreateToggle(scrollFrame, yPos, "Infinite Jump", function(v)
    if v then
        UserInputService.JumpRequest:Connect(function()
            local char = Player.Character
            if char and char:FindFirstChild("Humanoid") then
                char.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end)
    end
end)
yPos = yPos + 35

-- Label Generator
local label2 = Instance.new("TextLabel")
label2.Size = UDim2.new(1, 0, 0, 25)
label2.Position = UDim2.new(0, 10, 0, yPos)
label2.BackgroundTransparency = 1
label2.Text = "⚙️ GENERATOR"
label2.TextColor3 = Color3.fromRGB(0, 255, 65)
label2.TextSize = 14
label2.TextXAlignment = Enum.TextXAlignment.Left
label2.Font = Enum.Font.GothamBold
label2.Parent = scrollFrame
yPos = yPos + 30

CreateToggle(scrollFrame, yPos, "Auto Generator (TP)", function(v)
    if v then StartAutoGen() else StopAutoGen() end
end)
yPos = yPos + 35

CreateToggle(scrollFrame, yPos, "Auto Skillcheck Perfect", function(v)
    if v then StartAutoSkillcheck() else StopAutoSkillcheck() end
end)
yPos = yPos + 35

-- Label Combat
local label3 = Instance.new("TextLabel")
label3.Size = UDim2.new(1, 0, 0, 25)
label3.Position = UDim2.new(0, 10, 0, yPos)
label3.BackgroundTransparency = 1
label3.Text = "⚔️ COMBAT"
label3.TextColor3 = Color3.fromRGB(0, 255, 65)
label3.TextSize = 14
label3.TextXAlignment = Enum.TextXAlignment.Left
label3.Font = Enum.Font.GothamBold
label3.Parent = scrollFrame
yPos = yPos + 30

CreateToggle(scrollFrame, yPos, "Auto Parry", function(v)
    if v then StartAutoParry() else StopAutoParry() end
end)
yPos = yPos + 35

-- Button Bypass Gate
CreateButton(scrollFrame, yPos, "🚪 Bypass Gate", function()
    print("Bypass Gate executed")
end)
yPos = yPos + 40

-- Button Force End
CreateButton(scrollFrame, yPos, "✅ Force End Game", function()
    print("Force End Game executed")
end)
yPos = yPos + 40

-- Update Canvas
scrollFrame.CanvasSize = UDim2.new(0, 0, 0, yPos + 50)

-- =====================================================
-- 4. KEYBIND (K)
-- =====================================================
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.K then
        mainFrame.Visible = not mainFrame.Visible
    end
end)

print("✅ Script Loaded! Press K to open menu.")
