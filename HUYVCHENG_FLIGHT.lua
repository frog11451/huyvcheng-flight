-- 胡宇程飞行脚本
-- 作者: 胡宇程
-- GitHub加载版本

if not game:IsLoaded() then
    game.Loaded:Wait()
end

local function MainScript()
    local Players = game:GetService("Players")
    local UserInputService = game:GetService("UserInputService")
    local RunService = game:GetService("RunService")
    local TweenService = game:GetService("TweenService")

    local player = Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoid = character:WaitForChild("Humanoid")
    local rootPart = character:WaitForChild("HumanoidRootPart")

    -- 飞行状态变量
    local flying = false
    local flightSpeed = 50
    local bodyVelocity
    local bodyGyro

    -- 检查是否已有GUI，避免重复创建
    local playerGui = player:WaitForChild("PlayerGui")
    if playerGui:FindFirstChild("胡宇程飞行脚本") then
        playerGui:FindFirstChild("胡宇程飞行脚本"):Destroy()
    end

    -- 创建主GUI
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "胡宇程飞行脚本"
    screenGui.Parent = playerGui

    -- 主框架
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 200, 0, 50)
    mainFrame.Position = UDim2.new(0, 10, 0, 10)
    mainFrame.BackgroundColor3 = Color3.new(0, 0, 0)
    mainFrame.BorderSizePixel = 2
    mainFrame.BorderColor3 = Color3.new(0.3, 0.3, 0.3)
    mainFrame.Parent = screenGui

    -- 主按钮
    local mainButton = Instance.new("TextButton")
    mainButton.Size = UDim2.new(1, 0, 1, 0)
    mainButton.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
    mainButton.BorderSizePixel = 0
    mainButton.Text = "胡宇程飞行脚本"
    mainButton.TextColor3 = Color3.new(1, 1, 1)
    mainButton.TextSize = 14
    mainButton.Font = Enum.Font.GothamBold
    mainButton.Parent = mainFrame

    -- 功能框架
    local functionFrame = Instance.new("Frame")
    functionFrame.Size = UDim2.new(0, 180, 0, 100)
    functionFrame.Position = UDim2.new(0, 0, 1, 5)
    functionFrame.BackgroundColor3 = Color3.new(0, 0, 0)
    functionFrame.BorderSizePixel = 2
    functionFrame.BorderColor3 = Color3.new(0.3, 0.3, 0.3)
    functionFrame.Visible = false
    functionFrame.Parent = mainFrame

    -- 飞行按钮
    local flyButton = Instance.new("TextButton")
    flyButton.Size = UDim2.new(0.8, 0, 0.3, 0)
    flyButton.Position = UDim2.new(0.1, 0, 0.1, 0)
    flyButton.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
    flyButton.BorderSizePixel = 0
    flyButton.Text = "飞行"
    flyButton.TextColor3 = Color3.new(1, 1, 1)
    flyButton.TextSize = 14
    flyButton.Font = Enum.Font.Gotham
    flyButton.Parent = functionFrame

    -- 关闭按钮
    local closeButton = Instance.new("TextButton")
    closeButton.Size = UDim2.new(0.8, 0, 0.3, 0)
    closeButton.Position = UDim2.new(0.1, 0, 0.6, 0)
    closeButton.BackgroundColor3 = Color3.new(0.3, 0, 0)
    closeButton.BorderSizePixel = 0
    closeButton.Text = "关闭"
    closeButton.TextColor3 = Color3.new(1, 1, 1)
    closeButton.TextSize = 14
    closeButton.Font = Enum.Font.Gotham
    closeButton.Parent = functionFrame

    -- 飞行功能
    local function startFlying()
        if flying then return end
        
        flying = true
        
        -- 创建飞行物理组件
        bodyVelocity = Instance.new("BodyVelocity")
        bodyVelocity.Velocity = Vector3.new(0, 0, 0)
        bodyVelocity.MaxForce = Vector3.new(4000, 4000, 4000)
        bodyVelocity.Parent = rootPart
        
        bodyGyro = Instance.new("BodyGyro")
        bodyGyro.MaxTorque = Vector3.new(4000, 4000, 4000)
        bodyGyro.P = 1000
        bodyGyro.D = 50
        bodyGyro.Parent = rootPart
        
        -- 禁用角色重力
        humanoid.PlatformStand = true
        
        flyButton.Text = "飞行中..."
        flyButton.BackgroundColor3 = Color3.new(0, 0.3, 0)
    end

    local function stopFlying()
        if not flying then return end
        
        flying = false
        
        -- 清理飞行组件
        if bodyVelocity then
            bodyVelocity:Destroy()
            bodyVelocity = nil
        end
        
        if bodyGyro then
            bodyGyro:Destroy()
            bodyGyro = nil
        end
        
        -- 恢复角色重力
        humanoid.PlatformStand = false
        
        flyButton.Text = "飞行"
        flyButton.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
    end

    -- 飞行控制
    local flightConnection
    local function setupFlightControls()
        flightConnection = RunService.Heartbeat:Connect(function()
            if not flying or not bodyVelocity or not bodyGyro then return end
            
            -- 更新陀螺仪朝向
            bodyGyro.CFrame = rootPart.CFrame
            
            -- 计算移动方向
            local direction = Vector3.new(0, 0, 0)
            
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                direction = direction + rootPart.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                direction = direction - rootPart.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                direction = direction - rootPart.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                direction = direction + rootPart.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                direction = direction + Vector3.new(0, 1, 0)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                direction = direction - Vector3.new(0, 1, 0)
            end
            
            -- 应用速度
            if direction.Magnitude > 0 then
                bodyVelocity.Velocity = direction.Unit * flightSpeed
            else
                bodyVelocity.Velocity = Vector3.new(0, 0, 0)
            end
        end)
    end

    -- 按钮点击事件
    mainButton.MouseButton1Click:Connect(function()
        functionFrame.Visible = not functionFrame.Visible
    end)

    flyButton.MouseButton1Click:Connect(function()
        if flying then
            stopFlying()
        else
            startFlying()
            if not flightConnection then
                setupFlightControls()
            end
        end
    end)

    closeButton.MouseButton1Click:Connect(function()
        functionFrame.Visible = false
    end)

    -- 角色重新生成时的处理
    player.CharacterAdded:Connect(function(newCharacter)
        character = newCharacter
        humanoid = character:WaitForChild("Humanoid")
        rootPart = character:WaitForChild("HumanoidRootPart")
        
        -- 角色重生时停止飞行
        stopFlying()
    end)

    -- 玩家离开时清理
    Players.PlayerRemoving:Connect(function(leavingPlayer)
        if leavingPlayer == player then
            stopFlying()
            if flightConnection then
                flightConnection:Disconnect()
            end
        end
    end)

    print("胡宇程飞行脚本已加载！")
end

-- 错误处理
local success, err = pcall(MainScript)
if not success then
    warn("胡宇程飞行脚本加载错误: " .. err)
end
