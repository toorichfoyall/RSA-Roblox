-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- Variables
local silentAimActive = true
local espActive = false
local espList = {} -- Keep track of ESP drawings

-- Function to get the nearest target's head
local function getNearestHead()
local closestPlayer = nil
local shortestDistance = math.huge

for _, player in pairs(Players:GetPlayers()) do
if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
local distance = (player.Character.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
if distance < shortestDistance then
shortestDistance = distance
closestPlayer = player
end
end
end

if closestPlayer and closestPlayer.Character and closestPlayer.Character:FindFirstChild("Head") then
return closestPlayer.Character.Head
end

return nil
end

-- Silent aim functionality with headshots
UserInputService.InputBegan:Connect(function(input)
if input.UserInputType == Enum.UserInputType.MouseButton1 and silentAimActive then
local targetHead = getNearestHead()
if targetHead then
local aimPosition = targetHead.Position
Camera.CFrame = CFrame.new(Camera.CFrame.Position, aimPosition)
ReplicatedStorage.Remotes.Attack:FireServer(targetHead)
end
end
end)

-- ESP Function for a player
local function createESP(player)
if player ~= LocalPlayer then
local espBox = Drawing.new("Quad")
espBox.Thickness = 2
espBox.Color = Color3.fromRGB(0, 0, 255) -- Blue color for ESP
espBox.Transparency = 1
espBox.Visible = true

espList[player.Name] = espBox

RunService.RenderStepped:Connect(function()
if espActive and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
local rootPart = player.Character.HumanoidRootPart
local head = player.Character:FindFirstChild("Head")

if rootPart and head then
local rootPos, rootVisible = Camera:WorldToViewportPoint(rootPart.Position)
local headPos, headVisible = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))

if rootVisible and headVisible then
espBox.PointA = Vector2.new(rootPos.X - 15, rootPos.Y + 30)
espBox.PointB = Vector2.new(rootPos.X + 15, rootPos.Y + 30)
espBox.PointC = Vector2.new(headPos.X + 15, headPos.Y)
espBox.PointD = Vector2.new(headPos.X - 15, headPos.Y)
espBox.Visible = true
else
espBox.Visible = false
end
else
espBox.Visible = false
end
else
espBox.Visible = false
end
end)
end
end

for _, player in pairs(Players:GetPlayers()) do
createESP(player)
end

Players.PlayerAdded:Connect(function(player)
createESP(player)
end)

Players.PlayerRemoving:Connect(function(player)
if espList[player.Name] then
espList[player.Name]:Remove()
espList[player.Name] = nil
end
end)

print("Silent Aim and ESP Script for Rivals loaded successfully.")
