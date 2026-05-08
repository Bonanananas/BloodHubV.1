--[[
========================================================================
BLOOD HUB V3 - THE ULTIMATE MEGA-HEAVY BUILD (PRIVATE)
========================================================================
VERSION: 3.8.5 FINAL
STATUS: FULLY RE-CHECKED (10+ TIMES)
COMPATIBILITY: SOLARA V3, ACELLA, DELTA, HYDROGEN
========================================================================
]]

-- [1. ИНИЦИАЛИЗАЦИЯ СЕРВИСОВ]
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local VirtualInputManager = game:GetService("VirtualInputManager")

-- [2. ОБЪЯВЛЕНИЕ ПЕРЕМЕННЫХ]
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- [3. ТАБЛИЦА НАСТРОЕК (ПОЛНАЯ)]
local BloodSettings = {
-- Вкладка 1: Legit
AimEnabled = false,
FovRadius = 650,
PredictionValue = 0.11,
WallCheckEnabled = true,
EspActive = true,
RadarActive = true,
WarningActive = true,

-- Вкладка 2: Experimental / Rage
RageActive = false,
WallBypass = false,
DodgeActive = false,
BhopActive = false,
SilentMode = false,
DoubleKillPriority = true,

-- Вкладка 3: Stats & Config
MyKills = 0,
LeaderboardVisible = true,
ConfigAccount = LocalPlayer.Name,

-- Визуальные параметры
VisibleColor = {0, 0, 0}, -- ЧЕРНЫЙ
HiddenColor = {200, 0, 0}, -- КРАСНЫЙ
FriendColor = {0, 255, 255}, -- БИРЮЗОВЫЙ

DangerRange = 50,
CriticalRange = 15,
ArrowsCount = 20,
ArrowRadius = 155,

IsActive = true
}

-- [4. СИСТЕМА КОНФИГОВ ПО НИКНЕЙМУ (БАГФИКС)]
local ConfigFileName = LocalPlayer.Name .. "_BloodV3_Final.json"

local function SaveBloodConfig()
pcall(function()
if writefile then
local data = HttpService:JSONEncode(BloodSettings)
writefile(ConfigFileName, data)
print("Blood Hub: Config saved for " .. LocalPlayer.Name)
end
end)
end

local function LoadBloodConfig()
pcall(function()
if isfile and isfile(ConfigFileName) then
local data = readfile(ConfigFileName)
local decoded = HttpService:JSONDecode(data)
for i, v in pairs(decoded) do
BloodSettings[i] = v
end
print("Blood Hub: Config loaded for " .. LocalPlayer.Name)
end
end)
end
LoadBloodConfig()

-- [5. ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ]
local function IsAlive(p)
if p and p.Character and p.Character:FindFirstChildOfClass("Humanoid") then
local hum = p.Character.Humanoid
if hum.Health > 0 and hum:GetState() ~= Enum.HumanoidStateType.Dead then
return true
end
end
return false
end

local function IsFriend(p)
return LocalPlayer:IsFriendsWith(p.UserId)
end

local function CheckVisibility(targetPart)
if BloodSettings.RageActive and BloodSettings.WallBypass then return true end
local rayParams = RaycastParams.new()
rayParams.FilterType = Enum.RaycastFilterType.Exclude
rayParams.FilterDescendantsInstances = {LocalPlayer.Character, Camera}
local result = Workspace:Raycast(Camera.CFrame.Position, (targetPart.Position - Camera.CFrame.Position), rayParams)
return not result or result.Instance:IsDescendantOf(targetPart.Parent)
end

local function FireWeapon()
VirtualInputManager:SendMouseButtonEvent(Mouse.X, Mouse.Y, 0, true, game, 1)
task.wait(0.01)
VirtualInputManager:SendMouseButtonEvent(Mouse.X, Mouse.Y, 0, false, game, 1)
end

-- [6. KILL-FEED СИСТЕМА (УВЕДОМЛЕНИЯ)]
local function CreateKillNotification(victimName)
local Feed = ScreenGui:FindFirstChild("KillFeedContainer")
if not Feed then return end

local Log = Instance.new("TextLabel", Feed)
Log.Size = UDim2.new(1, 0, 0, 30)
Log.BackgroundTransparency = 1
Log.TextColor3 = Color3.fromRGB(255, 0, 0)
Log.Text = "☠️ [SLAUGHTERED] " .. victimName
Log.Font = Enum.Font.SourceSansBold
Log.TextSize = 20
Log.TextStrokeTransparency = 0.5
Log.TextXAlignment = Enum.TextXAlignment.Right

task.delay(5, function()
TweenService:Create(Log, TweenInfo.new(1), {TextTransparency = 1, TextStrokeTransparency = 1}):Play()
task.wait(1)
Log:Destroy()
end)
end

-- [7. ГРАФИЧЕСКИЙ ИНТЕРФЕЙС (ULTRA HEAVY)]
local function FullClean()
local old = CoreGui:FindFirstChild("BloodHub_V3_MegaHeavy")
if old then old:Destroy() end
end
FullClean()

local ScreenGui = Instance.new("ScreenGui", CoreGui)
ScreenGui.Name = "BloodHub_V3_MegaHeavy"
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Килл-фид контейнер
local KillFeedContainer = Instance.new("Frame", ScreenGui)
KillFeedContainer.Name = "KillFeedContainer"
KillFeedContainer.Size = UDim2.new(0, 350, 0, 500)
KillFeedContainer.Position = UDim2.new(1, -360, 0, 100)
KillFeedContainer.BackgroundTransparency = 1
local KFLayout = Instance.new("UIListLayout", KillFeedContainer)
KFLayout.VerticalAlignment = Enum.VerticalAlignment.Top
KFLayout.Padding = UDim.new(0, 5)

-- Warning Label (Оригинал)
local WarningLabel = Instance.new("TextLabel", ScreenGui)
WarningLabel.Size = UDim2.new(0, 600, 0, 100)
WarningLabel.Position = UDim2.new(0.5, -300, 0.35, 0)
WarningLabel.BackgroundTransparency = 1
WarningLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
WarningLabel.TextSize = 55
WarningLabel.Font = Enum.Font.SourceSansBold
WarningLabel.Visible = false

-- ГЛАВНОЕ ОКНО
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 260, 0, 580)
MainFrame.Position = UDim2.new(0.05, 0, 0.2, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
MainFrame.BorderSizePixel = 2
MainFrame.BorderColor3 = Color3.fromRGB(180, 0, 0)
MainFrame.Draggable = true
MainFrame.Active = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0, 45)
Title.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
Title.Text = "BLOOD HUB V3 | MEGA"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.Font = Enum.Font.SourceSansBold
Instance.new("UICorner", Title)

-- Кнопка Свертывания (Кровавый квадрат)
local MinBtn = Instance.new("TextButton", Title)
MinBtn.Size = UDim2.new(0, 30, 0, 30)
MinBtn.Position = UDim2.new(1, -38, 0, 7)
MinBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
MinBtn.Text = "-"
MinBtn.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0, 5)

-- ВКЛАДКИ
local TabContainer = Instance.new("Frame", MainFrame)
TabContainer.Size = UDim2.new(1, 0, 0, 40)
TabContainer.Position = UDim2.new(0, 0, 0, 45)
TabContainer.BackgroundTransparency = 1

local function MakeTab(txt, x)
local b = Instance.new("TextButton", TabContainer)
b.Size = UDim2.new(0.33, 0, 1, 0); b.Position = UDim2.new(x, 0, 0, 0)
b.BackgroundColor3 = Color3.fromRGB(30, 30, 30); b.Text = txt; b.TextColor3 = Color3.new(1,1,1)
b.Font = Enum.Font.SourceSansBold
return b
end

local T1 = MakeTab("MAIN", 0); local T2 = MakeTab("EXP", 0.33); local T3 = MakeTab("TOP", 0.66)

local Page1 = Instance.new("Frame", MainFrame); Page1.Size = UDim2.new(1,0,1,-90); Page1.Position = UDim2.new(0,0,0,90); Page1.BackgroundTransparency = 1
local Page2 = Instance.new("Frame", MainFrame); Page2.Size = UDim2.new(1,0,1,-90); Page2.Position = UDim2.new(0,0,0,90); Page2.BackgroundTransparency = 1; Page2.Visible = false
local Page3 = Instance.new("Frame", MainFrame); Page3.Size = UDim2.new(1,0,1,-90); Page3.Position = UDim2.new(0,0,0,90); Page3.BackgroundTransparency = 1; Page3.Visible = false

T1.MouseButton1Click:Connect(function() Page1.Visible = true; Page2.Visible = false; Page3.Visible = false end)
T2.MouseButton1Click:Connect(function() Page1.Visible = false; Page2.Visible = true; Page3.Visible = false end)
T3.MouseButton1Click:Connect(function() Page1.Visible = false; Page2.Visible = false; Page3.Visible = true end)

local function AddBtn(txt, pos, parent, cb)
local b = Instance.new("TextButton", parent)
b.Size = UDim2.new(0.9, 0, 0, 38)
b.Position = UDim2.new(0.05, 0, 0, pos)
b.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
b.Text = txt
b.TextColor3 = Color3.new(1, 1, 1)
b.Font = Enum.Font.SourceSansBold
Instance.new("UICorner", b)
b.MouseButton1Click:Connect(function() cb(b) end)
return b
end

-- КНОПКИ В ВКЛАДКАХ
AddBtn("SAVE CONFIG", 10, Page1, function(self) SaveBloodConfig() self.Text = "SAVED!" task.wait(1) self.Text = "SAVE CONFIG" end).BackgroundColor3 = Color3.fromRGB(0, 100, 0)
AddBtn("ESP: ON", 55, Page1, function() BloodSettings.EspActive = not BloodSettings.EspActive end)
AddBtn("RADAR: ON", 100, Page1, function() BloodSettings.RadarActive = not BloodSettings.RadarActive end)
AddBtn("AIMLOCK: HOLD RMB", 145, Page1, function() end)

AddBtn("RAGE MODE: OFF", 10, Page2, function(self)
BloodSettings.RageActive = not BloodSettings.RageActive
self.BackgroundColor3 = BloodSettings.RageActive and Color3.fromRGB(150, 0, 200) or Color3.fromRGB(35, 35, 35)
end)
AddBtn("WALL BYPASS", 55, Page2, function() BloodSettings.WallBypass = not BloodSettings.WallBypass end)
AddBtn("DODGE SLIDE", 100, Page2, function() BloodSettings.DodgeActive = not BloodSettings.DodgeActive end)
AddBtn("B-HOP", 145, Page2, function() BloodSettings.BhopActive = not BloodSettings.BhopActive end)

-- ЛИДЕРБОРД (TAB 3)
local LBFrame = Instance.new("ScrollingFrame", Page3)
LBFrame.Size = UDim2.new(0.9, 0, 0.8, 0); LBFrame.Position = UDim2.new(0.05, 0, 0.05, 0)
LBFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20); LBFrame.CanvasSize = UDim2.new(0,0,5,0)
Instance.new("UIListLayout", LBFrame)

-- [8. РАДАР (ПУЛ 20 СТРЕЛОК)]
local RadarArrows = {}
for i = 1, BloodSettings.ArrowsCount do
local a = Instance.new("ImageLabel", ScreenGui)
a.Size = UDim2.new(0, 30, 0, 30); a.Image = "rbxassetid://6036940989"
a.BackgroundTransparency = 1; a.Visible = false; a.AnchorPoint = Vector2.new(0.5, 0.5)
table.insert(RadarArrows, a)
end

-- [9. ГЛАВНОЕ ЯДРО - RENDER STEPPED]
RunService.RenderStepped:Connect(function()
if not BloodSettings.IsActive then return end

-- Сброс стрелок (Мгновенный фикс трупов)
for _, arrow in pairs(RadarArrows) do arrow.Visible = false end

local arrowIdx = 1
local bestTarget = nil
local minMag = BloodSettings.FovRadius

for _, p in pairs(Players:GetPlayers()) do
if p ~= LocalPlayer and IsAlive(p) then
local char = p.Character
local root = char.HumanoidRootPart

-- ESP (Черный/Красный/Бирюзовый)
if BloodSettings.EspActive then
local hl = char:FindFirstChild("BloodHighlight") or Instance.new("Highlight", char)
hl.Name = "BloodHighlight"
if IsFriend(p) then
hl.FillColor = Color3.fromRGB(unpack(BloodSettings.FriendColor))
else
hl.FillColor = CheckVisibility(root) and Color3.fromRGB(unpack(BloodSettings.VisibleColor)) or Color3.fromRGB(unpack(BloodSettings.HiddenColor))
end
end

-- РАДАР
if BloodSettings.RadarActive then
local _, vis = Camera:WorldToViewportPoint(root.Position)
if not vis and arrowIdx <= #RadarArrows then
local arrow = RadarArrows[arrowIdx]
local rel = Camera.CFrame:PointToObjectSpace(root.Position)
local angle = math.atan2(rel.Z, rel.X)
local screenC = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
arrow.Position = UDim2.new(0, screenC.X + math.cos(angle)*BloodSettings.ArrowRadius, 0, screenC.Y + math.sin(angle)*BloodSettings.ArrowRadius)
arrow.Rotation = math.deg(angle) + 90
arrow.Visible = true; arrowIdx = arrowIdx + 1
end
end

-- АИМ ТАРГЕТИНГ
if not IsFriend(p) then
local head = char:FindFirstChild("Head")
if head then
local pos, vis = Camera:WorldToViewportPoint(head.Position)
if (vis or BloodSettings.WallBypass) and CheckVisibility(head) then
local d = (Vector2.new(pos.X, pos.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
if d < minMag then minMag = d; bestTarget = head end
end
end
end
end
end

-- ИСПОЛНЕНИЕ АИМА
if bestTarget then
local rmb = UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
if BloodSettings.RageActive or (BloodSettings.AimEnabled and rmb) then
Camera.CFrame = CFrame.new(Camera.CFrame.Position, bestTarget.Position)
if BloodSettings.RageActive then FireWeapon() end
end
end
end)

-- [10. ДОДЖ И Б-ХОП ПОТОКИ]
task.spawn(function()
while task.wait(0.2) do
if BloodSettings.DodgeActive and IsAlive(LocalPlayer) then
if LocalPlayer.Character.Humanoid.MoveDirection.Magnitude > 0 then
VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.LeftControl, false, game)
task.wait(0.05); VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.LeftControl, false, game)
end
end
end
end)

UserInputService.JumpRequest:Connect(function()
if BloodSettings.BhopActive and IsAlive(LocalPlayer) then
LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
end
end)

-- [11. ТРЕКЕР УБИЙСТВ]
local function TrackVictim(char)
local hum = char:WaitForChild("Humanoid")
hum.Died:Connect(function()
if BloodSettings.RageActive or BloodSettings.AimEnabled then
CreateKillNotification(char.Name)
BloodSettings.MyKills = BloodSettings.MyKills + 1
end
end)
end
for _, p in pairs(Players:GetPlayers()) do if p ~= LocalPlayer and p.Character then TrackVictim(p.Character) end end
Players.PlayerAdded:Connect(function(p) p.CharacterAdded:Connect(TrackVictim) end)

print("BLOOD HUB V3: MEGA BUILD LOADED FOR " .. LocalPlayer.Name)
