-- LocalScript
-- Place inside StarterPlayerScripts

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

local aimAssistEnabled = false
local MAX_DISTANCE = 150
local FOV_RADIUS = 250 -- pixels

----------------------------------------------------
-- UI
----------------------------------------------------

local gui = Instance.new("ScreenGui")
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local button = Instance.new("TextButton")
button.Size = UDim2.new(0,150,0,50)
button.Position = UDim2.new(0.5,-75,1,-80)
button.Text = "Aim Assist: OFF"
button.Parent = gui

button.MouseButton1Click:Connect(function()
    aimAssistEnabled = not aimAssistEnabled
    button.Text = aimAssistEnabled and "Aim Assist: ON" or "Aim Assist: OFF"
end)

----------------------------------------------------
-- Visibility Check
----------------------------------------------------

local function isVisible(character)

    local head = character:FindFirstChild("Head")
    if not head then
        return false
    end

    local origin = camera.CFrame.Position
    local direction = head.Position - origin

    local params = RaycastParams.new()
    params.FilterDescendantsInstances = {
        player.Character
    }

    params.FilterType = Enum.RaycastFilterType.Blacklist

    local result = workspace:Raycast(origin, direction, params)

    if result then
        return result.Instance:IsDescendantOf(character)
    end

    return true
end

----------------------------------------------------
-- Find Target
----------------------------------------------------

local function getBestTarget()

    local bestPlayer = nil
    local bestDistance = math.huge

    for _,plr in ipairs(Players:GetPlayers()) do

        if plr ~= player and plr.Character then

            local head = plr.Character:FindFirstChild("Head")
            local humanoid = plr.Character:FindFirstChild("Humanoid")

            if head and humanoid and humanoid.Health > 0 then

                local screenPos,onScreen = camera:WorldToViewportPoint(head.Position)

                if onScreen then

                    local distance3D =
                        (head.Position-player.Character.Head.Position).Magnitude

                    if distance3D <= MAX_DISTANCE then

                        if isVisible(plr.Character) then

                            local mousePos = UserInputService:GetMouseLocation()

                            local dist2D =
                                (Vector2.new(screenPos.X,screenPos.Y)-mousePos).Magnitude

                            if dist2D < FOV_RADIUS then

                                if dist2D < bestDistance then
                                    bestDistance = dist2D
                                    bestPlayer = plr
                                end

                            end
                        end
                    end
                end
            end
        end
    end

    return bestPlayer
end

----------------------------------------------------
-- Aim Assist
----------------------------------------------------

RunService.RenderStepped:Connect(function()

    if not aimAssistEnabled then
        return
    end

    if not player.Character then
        return
    end

    local target = getBestTarget()

    if target and target.Character then

        local head = target.Character:FindFirstChild("Head")

        if head then

            local current = camera.CFrame

            local goal = CFrame.lookAt(
                current.Position,
                head.Position
            )

            camera.CFrame = current:Lerp(goal,0.15)
        end
    end

end)