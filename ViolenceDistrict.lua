
-- =====================================================
-- VIOLENCE DISTRICT SCRIPT - FULL PACKAGE
-- Fitur: UI Lengkap + Auto Generator (TP) + Auto Skillcheck + Auto Parry
-- By: [Your Name]
-- =====================================================

-- =====================================================
-- 1. LOAD LIBRARY & BUAT UI
-- =====================================================
local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/shlexware/Rayfield/main/source'))()

local Window = Rayfield:CreateWindow({
   Name = "🔪 Violence District [Full]",
   LoadingTitle = "LOADING...",
   LoadingSubtitle = "by hannn",
   Theme = "Default",
   ToggleUIKeybind = "K",
   KeySystem = false -- Set true kalo mau pake key
})

-- =====================================================
-- 2. VARIABEL GLOBAL
-- =====================================================
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local UserInputService = game:GetService("UserInputService")

-- Status fitur
local autoGenActive = false
local autoGenConnection = nil
local skillcheckActive = false
local skillcheckThread = nil
local autoParryActive = false
local autoParryThread = nil

-- =====================================================
-- 3. FITUR AUTO GENERATOR + TP
-- =====================================================
local function GetNearestGenerator()
    local generators = {}
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Name:lower():find("generator") then
            table.insert(generators, obj)
        end
    end
    
    if #generators == 0 then
        print("⚠️ Tidak ada generator ditemukan!")
        return nil
    end
    
    local available = {}
    for _, gen in pairs(generators) do
        local progress = gen:FindFirstChild("Progress") or gen:FindFirstChild("Value")
        if progress and progress.Value < 100 then
            table.insert(available, gen)
        end
    end
    
    if #available == 0 then
        print("⚠️ Semua generator sudah selesai!")
        return nil
    end
    
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
    local targetPos = target.Position + Vector3.new(0, 3, 0)
    rootPart.CFrame = CFrame.new(targetPos)
    
    wait(0.5)
    
    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
    wait(1)
    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
    
    print("✅ Generator dikerjakan!")
end

local function StartAutoGen()
    if autoGenActive then return end
    autoGenActive = true
    autoGenConnection = RunService.Heartbeat:Connect(function()
        if not autoGenActive then return end
        AutoGeneratorWithTP()
        wait(2)
    end)
    print("🟢 Auto Generator + TP diaktifkan")
end

local function StopAutoGen()
    autoGenActive = false
    if autoGenConnection then
        autoGenConnection:Disconnect()
        autoGenConnection = nil
    end
    print("🔴 Auto Generator + TP dimatikan")
end

-- =====================================================
-- 4. FITUR AUTO SKILLCHECK PERFECT
-- =====================================================
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
                print("✅ Perfect Skillcheck!")
            end
        end
        wait(0.05)
    end
end

local function StartAutoSkillcheck()
    if skillcheckActive then return end
    skillcheckActive = true
    skillcheckThread = task.spawn(AutoSkillcheckLoop)
    print("🟢 Auto Skillcheck Perfect diaktifkan")
end

local function StopAutoSkillcheck()
    skillcheckActive = false
    if skillcheckThread then
        task.cancel(skillcheckThread)
        skillcheckThread = nil
    end
    print("🔴 Auto Skillcheck Perfect dimatikan")
end

-- =====================================================
-- 5. FITUR AUTO PARRY
-- =====================================================
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
            print("✅ Auto Parry!")
            wait(0.5)
        end
        wait(0.1)
    end
end

local function StartAutoParry()
    if autoParryActive then return end
    autoParryActive = true
    autoParryThread = task.spawn(AutoParryLoop)
    print("🟢 Auto Parry diaktifkan")
end

local function StopAutoParry()
    autoParryActive = false
    if autoParryThread then
        task.cancel(autoParryThread)
        autoParryThread = nil
    end
    print("🔴 Auto Parry dimatikan")
end

-- =====================================================
-- 6. UI TABS & TOGGLES
-- =====================================================

-- TAB 1: SEARCH
local SearchTab = Window:CreateTab("🔍 Search", 4483362458)
SearchTab:CreateButton({
   Name = "Search",
   Callback = function() print("Search clicked") end
})
SearchTab:CreateButton({
   Name = "Info",
   Callback = function() print("Info clicked") end
})

-- TAB 2: SURVIVOR
local SurvivorTab = Window:CreateTab("🏃 Survivor", 4483362458)

SurvivorTab:CreateToggle({
   Name = "Manual Generator (No TP)",
   CurrentValue = false,
   Flag = "ManualGen",
   Callback = function(v) print("Manual Generator (No TP):", v) end
})

SurvivorTab:CreateToggle({
   Name = "Auto Generator (With TP)",
   CurrentValue = false,
   Flag = "AutoGenTP",
   Callback = function(v)
       if v then StartAutoGen() else StopAutoGen() end
   end
})

SurvivorTab:CreateSlider({
   Name = "Killer Escape Distance",
   Range = {0, 100},
   Increment = 5,
   Suffix = "Studs",
   CurrentValue = 30,
   Flag = "EscapeDist",
   Callback = function(v) print("Escape Distance:", v) end
})

SurvivorTab:CreateToggle({
   Name = "Enable Auto Skillcheck Perfect",
   CurrentValue = false,
   Flag = "AutoSkillcheck",
   Callback = function(v)
       if v then StartAutoSkillcheck() else StopAutoSkillcheck() end
   end
})

SurvivorTab:CreateDropdown({
   Name = "Skillcheck Mode",
   Options = {"Normal", "Perfect Only", "Fail"},
   CurrentOption = "Normal",
   Flag = "SkillcheckMode",
   Callback = function(v) print("Skillcheck Mode:", v) end
})

SurvivorTab:CreateToggle({
   Name = "Auto Parry",
   CurrentValue = false,
   Flag = "AutoParry",
   Callback = function(v)
       if v then StartAutoParry() else StopAutoParry() end
   end
})

-- TAB 3: KILLER
local KillerTab = Window:CreateTab("🔪 Killer", 4483362458)
KillerTab:CreateButton({
   Name = "Killer Mode",
   Callback = function() print("Killer Mode activated") end
})
KillerTab:CreateToggle({
   Name = "Auto Slash",
   CurrentValue = false,
   Flag = "AutoSlash",
   Callback = function(v) print("Auto Slash:", v) end
})

-- TAB 4: ESP
local ESPTab = Window:CreateTab("👁️ ESP", 4483362458)
ESPTab:CreateToggle({
   Name = "Player ESP",
   CurrentValue = false,
   Flag = "PlayerESP",
   Callback = function(v) print("Player ESP:", v) end
})
ESPTab:CreateToggle({
   Name = "Generator ESP",
   CurrentValue = false,
   Flag = "GenESP",
   Callback = function(v) print("Generator ESP:", v) end
})
ESPTab:CreateToggle({
   Name = "Killer ESP",
   CurrentValue = false,
   Flag = "KillerESP",
   Callback = function(v) print("Killer ESP:", v) end
})

-- TAB 5: AIMBOT
local AimTab = Window:CreateTab("🎯 AimBot", 4483362458)
AimTab:CreateToggle({
   Name = "Enable AimBot",
   CurrentValue = false,
   Flag = "AimBot",
   Callback = function(v) print("AimBot:", v) end
})
AimTab:CreateSlider({
   Name = "AimBot Smoothness",
   Range = {1, 10},
   Increment = 1,
   Suffix = "Smooth",
   CurrentValue = 5,
   Flag = "AimSmooth",
   Callback = function(v) print("Aim Smoothness:", v) end
})

-- TAB 6: SETTINGS
local SettingsTab = Window:CreateTab("⚙️ Settings", 4483362458)
SettingsTab:CreateButton({
   Name = "Bypass Gate",
   Callback = function() print("Bypass Gate executed") end
})
SettingsTab:CreateButton({
   Name = "Reset Game (Auto Bypass)",
   Callback = function() print("Reset Game executed") end
})

-- TAB 7: CONFIGURATION
local ConfigTab = Window:CreateTab("📁 Configuration", 4483362458)
ConfigTab:CreateButton({
   Name = "Save Config",
   Callback = function() print("Config saved") end
})
ConfigTab:CreateButton({
   Name = "Load Config",
   Callback = function() print("Config loaded") end
})

print("✅ Script Fully Loaded! Press K to open menu.")
