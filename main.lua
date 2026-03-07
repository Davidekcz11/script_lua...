local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "david_cz11",
   LoadingTitle = "david_cz11",
   LoadingSubtitle = "Fly & Highlight Script",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = nil,
      FileName = "RayfieldConfig"
   },
   Discord = {
      Enabled = false,
      Invite = "noinvitelink",
      RememberJoins = true
   },
   KeySystem = false,
   KeySettings = {
      Title = "Untitled",
      Subtitle = "Key System",
      Note = "No method to get the key",
      FileName = "Key",
      SaveKey = true,
      SaveKeyUI = true,
      GetKeyFunction = nil
   }
})

local FlyTab = Window:CreateTab("Fly", 4483362458)
local HighlightTab = Window:CreateTab("Highlight", 0)
local AntiTab = Window:CreateTab("Anti", 0)

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

-- FLY VARIABLES
local flying = false
local speed = 50
local flyConnection = nil

-- WALK SPEED VARIABLES
local walkspeedEnabled = false
local walkSpeed = 20

-- NOCLIP VARIABLES
local noclipEnabled = false
local noclipConnection = nil

-- HIGHLIGHT VARIABLES
local bodyHighlightEnabled = false
local highlightedPlayers = {}
local bodyHighlightColor = Color3.fromRGB(255, 0, 0)

-- USERNAME/ESP VARIABLES
local usernamesEnabled = false
local playerUsernames = {}
local espColor = Color3.fromRGB(255, 255, 255)

-- ANTI FEATURES VARIABLES
local antiSitEnabled = false
local antiFlingEnabled = false

-- FLY FUNCTIONALITY
local function startFly()
   if flying then return end
   flying = true
   
   character = player.Character or player.CharacterAdded:Wait()
   humanoidRootPart = character:WaitForChild("HumanoidRootPart")
   
   local existingVelocity = humanoidRootPart:FindFirstChild("BodyVelocity")
   if existingVelocity then
      existingVelocity:Destroy()
   end
   local existingGyro = humanoidRootPart:FindFirstChild("BodyGyro")
   if existingGyro then
      existingGyro:Destroy()
   end
   
   local bodyVelocity = Instance.new("BodyVelocity")
   bodyVelocity.Velocity = Vector3.new(0, 0, 0)
   bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
   bodyVelocity.Parent = humanoidRootPart
   
   local bodyGyro = Instance.new("BodyGyro")
   bodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
   bodyGyro.CFrame = humanoidRootPart.CFrame
   bodyGyro.Parent = humanoidRootPart
   
   local camera = workspace.CurrentCamera
   
   flyConnection = RunService.RenderStepped:Connect(function()
      if not flying or not character.Parent then
         flying = false
         bodyVelocity:Destroy()
         bodyGyro:Destroy()
         if flyConnection then
            flyConnection:Disconnect()
         end
         return
      end
      
      local moveDirection = Vector3.new(0, 0, 0)
      
      if UserInputService:IsKeyDown(Enum.KeyCode.W) then
         moveDirection = moveDirection + (camera.CFrame.LookVector * Vector3.new(1, 0, 1)).Unit
      end
      if UserInputService:IsKeyDown(Enum.KeyCode.S) then
         moveDirection = moveDirection - (camera.CFrame.LookVector * Vector3.new(1, 0, 1)).Unit
      end
      if UserInputService:IsKeyDown(Enum.KeyCode.A) then
         moveDirection = moveDirection - camera.CFrame.RightVector
      end
      if UserInputService:IsKeyDown(Enum.KeyCode.D) then
         moveDirection = moveDirection + camera.CFrame.RightVector
      end
      if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
         moveDirection = moveDirection + Vector3.new(0, 1, 0)
      end
      if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
         moveDirection = moveDirection - Vector3.new(0, 1, 0)
      end
      
      if moveDirection.Magnitude > 0 then
         moveDirection = moveDirection.Unit
      end
      
      bodyVelocity.Velocity = moveDirection * speed
      bodyGyro.CFrame = camera.CFrame
   end)
end

local function stopFly()
   flying = false
   if flyConnection then
      flyConnection:Disconnect()
      flyConnection = nil
   end
   
   if character and character.Parent then
      humanoidRootPart = character:WaitForChild("HumanoidRootPart")
      
      local existingVelocity = humanoidRootPart:FindFirstChild("BodyVelocity")
      if existingVelocity then
         existingVelocity:Destroy()
      end
      
      local existingGyro = humanoidRootPart:FindFirstChild("BodyGyro")
      if existingGyro then
         existingGyro:Destroy()
      end
   end
end

-- NOCLIP FUNCTIONALITY
local function enableNoclip()
   noclipEnabled = true
   
   noclipConnection = RunService.RenderStepped:Connect(function()
      if not noclipEnabled or not character or not character.Parent then
         noclipEnabled = false
         if noclipConnection then
            noclipConnection:Disconnect()
            noclipConnection = nil
         end
         return
      end
      
      for _, part in pairs(character:GetDescendants()) do
         if part:IsA("BasePart") then
            part.CanCollide = false
         end
      end
   end)
end

local function disableNoclip()
   noclipEnabled = false
   
   if noclipConnection then
      noclipConnection:Disconnect()
      noclipConnection = nil
   end
   
   if character then
      for _, part in pairs(character:GetDescendants()) do
         if part:IsA("BasePart") then
            part.CanCollide = true
         end
      end
   end
end

-- HIGHLIGHT FUNCTIONALITY
local function highlightPlayer(targetPlayer)
   if targetPlayer == player or not targetPlayer.Character then return end
   
   local targetCharacter = targetPlayer.Character
   
   local existingHighlight = targetCharacter:FindFirstChild("PlayerHighlight")
   if existingHighlight then
      existingHighlight:Destroy()
   end
   
   local highlight = Instance.new("Highlight")
   highlight.Name = "PlayerHighlight"
   highlight.FillColor = bodyHighlightColor
   highlight.OutlineColor = bodyHighlightColor
   highlight.FillTransparency = 0.5
   highlight.OutlineTransparency = 0
   highlight.Parent = targetCharacter
   
   highlightedPlayers[targetPlayer.UserId] = highlight
end

local function removeHighlight(targetPlayer)
   if highlightedPlayers[targetPlayer.UserId] then
      highlightedPlayers[targetPlayer.UserId]:Destroy()
      highlightedPlayers[targetPlayer.UserId] = nil
   end
end

local function highlightAllPlayers()
   for _, targetPlayer in pairs(Players:GetPlayers()) do
      if targetPlayer ~= player then
         highlightPlayer(targetPlayer)
      end
   end
end

local function removeAllHighlights()
   for userId, highlight in pairs(highlightedPlayers) do
      if highlight and highlight.Parent then
         highlight:Destroy()
      end
   end
   highlightedPlayers = {}
end

local function updateAllBodyHighlights()
   for userId, highlight in pairs(highlightedPlayers) do
      if highlight and highlight.Parent then
         highlight.FillColor = bodyHighlightColor
         highlight.OutlineColor = bodyHighlightColor
      end
   end
end

-- USERNAME/ESP FUNCTIONALITY
local function createUsernameLabel(targetPlayer)
   if not targetPlayer or not targetPlayer.Character then return end
   
   local targetHead = targetPlayer.Character:FindFirstChild("Head")
   if not targetHead then return end
   
   local existingLabel = targetHead:FindFirstChild("UsernameLabel")
   if existingLabel then
      existingLabel:Destroy()
   end
   
   local billboardGui = Instance.new("BillboardGui")
   billboardGui.Name = "UsernameLabel"
   billboardGui.Size = UDim2.new(0, 120, 0, 30)
   billboardGui.MaxDistance = math.huge
   billboardGui.StudsOffset = Vector3.new(0, 4, 0)
   billboardGui.Parent = targetHead
   
   local textLabel = Instance.new("TextLabel")
   textLabel.Size = UDim2.new(1, 0, 1, 0)
   textLabel.BackgroundTransparency = 1
   textLabel.TextColor3 = espColor
   textLabel.TextSize = 22
   textLabel.Font = Enum.Font.GothamBold
   textLabel.Text = targetPlayer.Name
   textLabel.Parent = billboardGui
   
   local textStroke = Instance.new("UIStroke")
   textStroke.Thickness = 2
   textStroke.Color = Color3.fromRGB(0, 0, 0)
   textStroke.Parent = textLabel
   
   playerUsernames[targetPlayer.UserId] = billboardGui
end

local function removeUsernameLabel(targetPlayer)
   if playerUsernames[targetPlayer.UserId] then
      playerUsernames[targetPlayer.UserId]:Destroy()
      playerUsernames[targetPlayer.UserId] = nil
   end
end

local function removeAllUsernameLabels()
   for userId, label in pairs(playerUsernames) do
      if label and label.Parent then
         label:Destroy()
      end
   end
   playerUsernames = {}
end

local function updateAllUsernameColors()
   for userId, label in pairs(playerUsernames) do
      if label and label.Parent then
         local textLabel = label:FindFirstChild("TextLabel")
         if textLabel then
            textLabel.TextColor3 = espColor
         end
      end
   end
end

-- ANTI FEATURES
local function enableAntiSit()
   antiSitEnabled = true
   if character and character:FindFirstChild("Humanoid") then
      character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, false)
   end
end

local function disableAntiSit()
   antiSitEnabled = false
   if character and character:FindFirstChild("Humanoid") then
      character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
   end
end

local antiFlingConnection = nil

local function startAntiFlingProtection()
   if antiFlingConnection then
      antiFlingConnection:Disconnect()
   end
   
   antiFlingConnection = RunService.RenderStepped:Connect(function()
      if not antiFlingEnabled or not character or not character.Parent then
         if antiFlingConnection then
            antiFlingConnection:Disconnect()
            antiFlingConnection = nil
         end
         return
      end
      
      local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
      if humanoidRootPart then
         local velocity = humanoidRootPart.AssemblyLinearVelocity.Magnitude
         if velocity > 300 then
            humanoidRootPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
         end
      end
   end)
end

local function stopAntiFlingProtection()
   if antiFlingConnection then
      antiFlingConnection:Disconnect()
      antiFlingConnection = nil
   end
end

local function enableAntiFling()
   antiFlingEnabled = true
   startAntiFlingProtection()
end

local function disableAntiFling()
   antiFlingEnabled = false
   stopAntiFlingProtection()
end

-- ======== FLY TAB GUI ========
FlyTab:CreateSection("Fly")

FlyTab:CreateToggle({
   Name = "Fly",
   CurrentValue = false,
   Flag = "FlyToggle",
   Callback = function(Value)
      if Value then
         startFly()
      else
         stopFly()
      end
   end
})

FlyTab:CreateSlider({
   Name = "Fly Speed",
   Range = {1, 200},
   Increment = 1,
   Suffix = " studs/s",
   CurrentValue = 50,
   Flag = "FlySpeed",
   Callback = function(Value)
      speed = Value
   end
})

FlyTab:CreateSection("Movement")

FlyTab:CreateToggle({
   Name = "Walk Speed",
   CurrentValue = false,
   Flag = "WalkSpeedToggle",
   Callback = function(Value)
      walkspeedEnabled = Value
      if Value then
         if character and character:FindFirstChild("Humanoid") then
            character.Humanoid.WalkSpeed = walkSpeed
         end
         Rayfield:Notify({
            Title = "Walk Speed Enabled",
            Content = "Walk speed is now " .. walkSpeed .. " studs/s",
            Duration = 2,
            Image = 4483362458,
         })
      else
         if character and character:FindFirstChild("Humanoid") then
            character.Humanoid.WalkSpeed = 16
         end
         Rayfield:Notify({
            Title = "Walk Speed Disabled",
            Content = "Walk speed reset to normal!",
            Duration = 2,
            Image = 4483362458,
         })
      end
   end
})

FlyTab:CreateSlider({
   Name = "Walk Speed Value",
   Range = {20, 200},
   Increment = 1,
   Suffix = " studs/s",
   CurrentValue = 20,
   Flag = "WalkSpeedValue",
   Callback = function(Value)
      walkSpeed = Value
      if walkspeedEnabled and character and character:FindFirstChild("Humanoid") then
         character.Humanoid.WalkSpeed = walkSpeed
      end
   end
})

FlyTab:CreateToggle({
   Name = "NoClip",
   CurrentValue = false,
   Flag = "NoclipToggle",
   Callback = function(Value)
      if Value then
         enableNoclip()
         Rayfield:Notify({
            Title = "NoClip Enabled",
            Content = "You can now walk through walls!",
            Duration = 2,
            Image = 4483362458,
         })
      else
         disableNoclip()
         Rayfield:Notify({
            Title = "NoClip Disabled",
            Content = "Collision is back to normal!",
            Duration = 2,
            Image = 4483362458,
         })
      end
   end,
})

FlyTab:CreateSection("Controls")

FlyTab:CreateParagraph({
   Title = "Keyboard Controls",
   Content = "W/A/S/D - Move forward/left/back/right\nSpace - Move up\nCtrl - Move down"
})

-- ======== HIGHLIGHT TAB GUI ========
HighlightTab:CreateSection("Highlight Body Colors")

HighlightTab:CreateToggle({
   Name = "Red Body Highlight",
   CurrentValue = false,
   Flag = "RedBodyToggle",
   Callback = function(Value)
      if Value then
         bodyHighlightEnabled = true
         bodyHighlightColor = Color3.fromRGB(255, 0, 0)
         highlightAllPlayers()
         Rayfield:Notify({
            Title = "Body Highlight Enabled",
            Content = "Body highlight is now Red!",
            Duration = 1,
            Image = 4483362458,
         })
      else
         bodyHighlightEnabled = false
         removeAllHighlights()
         Rayfield:Notify({
            Title = "Body Highlight Disabled",
            Content = "Body highlights removed!",
            Duration = 1,
            Image = 4483362458,
         })
      end
   end
})

HighlightTab:CreateToggle({
   Name = "Blue Body Highlight",
   CurrentValue = false,
   Flag = "BlueBodyToggle",
   Callback = function(Value)
      if Value then
         bodyHighlightEnabled = true
         bodyHighlightColor = Color3.fromRGB(0, 0, 255)
         highlightAllPlayers()
         Rayfield:Notify({
            Title = "Body Highlight Enabled",
            Content = "Body highlight is now Blue!",
            Duration = 1,
            Image = 4483362458,
         })
      else
         bodyHighlightEnabled = false
         removeAllHighlights()
         Rayfield:Notify({
            Title = "Body Highlight Disabled",
            Content = "Body highlights removed!",
            Duration = 1,
            Image = 4483362458,
         })
      end
   end
})

HighlightTab:CreateToggle({
   Name = "Green Body Highlight",
   CurrentValue = false,
   Flag = "GreenBodyToggle",
   Callback = function(Value)
      if Value then
         bodyHighlightEnabled = true
         bodyHighlightColor = Color3.fromRGB(0, 255, 0)
         highlightAllPlayers()
         Rayfield:Notify({
            Title = "Body Highlight Enabled",
            Content = "Body highlight is now Green!",
            Duration = 1,
            Image = 4483362458,
         })
      else
         bodyHighlightEnabled = false
         removeAllHighlights()
         Rayfield:Notify({
            Title = "Body Highlight Disabled",
            Content = "Body highlights removed!",
            Duration = 1,
            Image = 4483362458,
         })
      end
   end
})

HighlightTab:CreateToggle({
   Name = "Yellow Body Highlight",
   CurrentValue = false,
   Flag = "YellowBodyToggle",
   Callback = function(Value)
      if Value then
         bodyHighlightEnabled = true
         bodyHighlightColor = Color3.fromRGB(255, 255, 0)
         highlightAllPlayers()
         Rayfield:Notify({
            Title = "Body Highlight Enabled",
            Content = "Body highlight is now Yellow!",
            Duration = 1,
            Image = 4483362458,
         })
      else
         bodyHighlightEnabled = false
         removeAllHighlights()
         Rayfield:Notify({
            Title = "Body Highlight Disabled",
            Content = "Body highlights removed!",
            Duration = 1,
            Image = 4483362458,
         })
      end
   end
})

HighlightTab:CreateToggle({
   Name = "Cyan Body Highlight",
   CurrentValue = false,
   Flag = "CyanBodyToggle",
   Callback = function(Value)
      if Value then
         bodyHighlightEnabled = true
         bodyHighlightColor = Color3.fromRGB(0, 255, 255)
         highlightAllPlayers()
         Rayfield:Notify({
            Title = "Body Highlight Enabled",
            Content = "Body highlight is now Cyan!",
            Duration = 1,
            Image = 4483362458,
         })
      else
         bodyHighlightEnabled = false
         removeAllHighlights()
         Rayfield:Notify({
            Title = "Body Highlight Disabled",
            Content = "Body highlights removed!",
            Duration = 1,
            Image = 4483362458,
         })
      end
   end
})

HighlightTab:CreateToggle({
   Name = "Purple Body Highlight",
   CurrentValue = false,
   Flag = "PurpleBodyToggle",
   Callback = function(Value)
      if Value then
         bodyHighlightEnabled = true
         bodyHighlightColor = Color3.fromRGB(255, 0, 255)
         highlightAllPlayers()
         Rayfield:Notify({
            Title = "Body Highlight Enabled",
            Content = "Body highlight is now Purple!",
            Duration = 1,
            Image = 4483362458,
         })
      else
         bodyHighlightEnabled = false
         removeAllHighlights()
         Rayfield:Notify({
            Title = "Body Highlight Disabled",
            Content = "Body highlights removed!",
            Duration = 1,
            Image = 4483362458,
         })
      end
   end
})

HighlightTab:CreateColorPicker({
   Name = "Custom Body Highlight",
   Color = Color3.fromRGB(255, 0, 0),
   Flag = "CustomBodyHighlight",
   Callback = function(Value)
      bodyHighlightEnabled = true
      bodyHighlightColor = Value
      highlightAllPlayers()
      Rayfield:Notify({
         Title = "Body Highlight Enabled",
         Content = "Body highlight color updated!",
         Duration = 1,
         Image = 4483362458,
      })
   end
})

HighlightTab:CreateSection("User Highlight Colors")

HighlightTab:CreateToggle({
   Name = "Red User Highlight",
   CurrentValue = false,
   Flag = "RedUserToggle",
   Callback = function(Value)
      if Value then
         usernamesEnabled = true
         espColor = Color3.fromRGB(255, 0, 0)
         for _, targetPlayer in pairs(Players:GetPlayers()) do
            if targetPlayer ~= player then
               createUsernameLabel(targetPlayer)
            end
         end
         Rayfield:Notify({
            Title = "User Highlight Enabled",
            Content = "User highlight is now Red!",
            Duration = 1,
            Image = 4483362458,
         })
      else
         usernamesEnabled = false
         removeAllUsernameLabels()
         Rayfield:Notify({
            Title = "User Highlight Disabled",
            Content = "User highlights removed!",
            Duration = 1,
            Image = 4483362458,
         })
      end
   end
})

HighlightTab:CreateToggle({
   Name = "Blue User Highlight",
   CurrentValue = false,
   Flag = "BlueUserToggle",
   Callback = function(Value)
      if Value then
         usernamesEnabled = true
         espColor = Color3.fromRGB(0, 0, 255)
         for _, targetPlayer in pairs(Players:GetPlayers()) do
            if targetPlayer ~= player then
               createUsernameLabel(targetPlayer)
            end
         end
         Rayfield:Notify({
            Title = "User Highlight Enabled",
            Content = "User highlight is now Blue!",
            Duration = 1,
            Image = 4483362458,
         })
      else
         usernamesEnabled = false
         removeAllUsernameLabels()
         Rayfield:Notify({
            Title = "User Highlight Disabled",
            Content = "User highlights removed!",
            Duration = 1,
            Image = 4483362458,
         })
      end
   end
})

HighlightTab:CreateToggle({
   Name = "Green User Highlight",
   CurrentValue = false,
   Flag = "GreenUserToggle",
   Callback = function(Value)
      if Value then
         usernamesEnabled = true
         espColor = Color3.fromRGB(0, 255, 0)
         for _, targetPlayer in pairs(Players:GetPlayers()) do
            if targetPlayer ~= player then
               createUsernameLabel(targetPlayer)
            end
         end
         Rayfield:Notify({
            Title = "User Highlight Enabled",
            Content = "User highlight is now Green!",
            Duration = 1,
            Image = 4483362458,
         })
      else
         usernamesEnabled = false
         removeAllUsernameLabels()
         Rayfield:Notify({
            Title = "User Highlight Disabled",
            Content = "User highlights removed!",
            Duration = 1,
            Image = 4483362458,
         })
      end
   end
})

HighlightTab:CreateToggle({
   Name = "Yellow User Highlight",
   CurrentValue = false,
   Flag = "YellowUserToggle",
   Callback = function(Value)
      if Value then
         usernamesEnabled = true
         espColor = Color3.fromRGB(255, 255, 0)
         for _, targetPlayer in pairs(Players:GetPlayers()) do
            if targetPlayer ~= player then
               createUsernameLabel(targetPlayer)
            end
         end
         Rayfield:Notify({
            Title = "User Highlight Enabled",
            Content = "User highlight is now Yellow!",
            Duration = 1,
            Image = 4483362458,
         })
      else
         usernamesEnabled = false
         removeAllUsernameLabels()
         Rayfield:Notify({
            Title = "User Highlight Disabled",
            Content = "User highlights removed!",
            Duration = 1,
            Image = 4483362458,
         })
      end
   end
})

HighlightTab:CreateToggle({
   Name = "Cyan User Highlight",
   CurrentValue = false,
   Flag = "CyanUserToggle",
   Callback = function(Value)
      if Value then
         usernamesEnabled = true
         espColor = Color3.fromRGB(0, 255, 255)
         for _, targetPlayer in pairs(Players:GetPlayers()) do
            if targetPlayer ~= player then
               createUsernameLabel(targetPlayer)
            end
         end
         Rayfield:Notify({
            Title = "User Highlight Enabled",
            Content = "User highlight is now Cyan!",
            Duration = 1,
            Image = 4483362458,
         })
      else
         usernamesEnabled = false
         removeAllUsernameLabels()
         Rayfield:Notify({
            Title = "User Highlight Disabled",
            Content = "User highlights removed!",
            Duration = 1,
            Image = 4483362458,
         })
      end
   end
})

HighlightTab:CreateToggle({
   Name = "Purple User Highlight",
   CurrentValue = false,
   Flag = "PurpleUserToggle",
   Callback = function(Value)
      if Value then
         usernamesEnabled = true
         espColor = Color3.fromRGB(255, 0, 255)
         for _, targetPlayer in pairs(Players:GetPlayers()) do
            if targetPlayer ~= player then
               createUsernameLabel(targetPlayer)
            end
         end
         Rayfield:Notify({
            Title = "User Highlight Enabled",
            Content = "User highlight is now Purple!",
            Duration = 1,
            Image = 4483362458,
         })
      else
         usernamesEnabled = false
         removeAllUsernameLabels()
         Rayfield:Notify({
            Title = "User Highlight Disabled",
            Content = "User highlights removed!",
            Duration = 1,
            Image = 4483362458,
         })
      end
   end
})

HighlightTab:CreateColorPicker({
   Name = "Custom User Highlight",
   Color = Color3.fromRGB(255, 255, 255),
   Flag = "CustomUserHighlight",
   Callback = function(Value)
      usernamesEnabled = true
      espColor = Value
      updateAllUsernameColors()
      for _, targetPlayer in pairs(Players:GetPlayers()) do
         if targetPlayer ~= player and not playerUsernames[targetPlayer.UserId] then
            createUsernameLabel(targetPlayer)
         end
      end
      Rayfield:Notify({
         Title = "User Highlight Enabled",
         Content = "User highlight color updated!",
         Duration = 1,
         Image = 4483362458,
      })
   end
})

-- ======== ANTI TAB GUI ========
AntiTab:CreateSection("Anti Features")

AntiTab:CreateToggle({
   Name = "Anti Sit",
   CurrentValue = false,
   Flag = "AntiSitToggle",
   Callback = function(Value)
      if Value then
         enableAntiSit()
         Rayfield:Notify({
            Title = "Anti Sit Enabled",
            Content = "You cannot sit anymore!",
            Duration = 2,
            Image = 4483362458,
         })
      else
         disableAntiSit()
         Rayfield:Notify({
            Title = "Anti Sit Disabled",
            Content = "You can sit again!",
            Duration = 2,
            Image = 4483362458,
         })
      end
   end
})

AntiTab:CreateToggle({
   Name = "Anti Fling",
   CurrentValue = false,
   Flag = "AntiFlingToggle",
   Callback = function(Value)
      if Value then
         enableAntiFling()
         Rayfield:Notify({
            Title = "Anti Fling Enabled",
            Content = "You are protected from fling attacks!",
            Duration = 2,
            Image = 4483362458,
         })
      else
         disableAntiFling()
         Rayfield:Notify({
            Title = "Anti Fling Disabled",
            Content = "Anti fling protection disabled!",
            Duration = 2,
            Image = 4483362458,
         })
      end
   end
})

AntiTab:CreateParagraph({
   Title = "Anti Features",
   Content = "Anti Sit - Prevents you from sitting on chairs or vehicles\nAnti Fling - Protects you from fling scripts and attacks"
})

-- ======== CONNECTIONS ========

-- Auto-highlight new players
Players.PlayerAdded:Connect(function(newPlayer)
   if bodyHighlightEnabled and newPlayer ~= player then
      task.wait(0.5)
      highlightPlayer(newPlayer)
   end
   if usernamesEnabled and newPlayer ~= player then
      task.wait(0.5)
      createUsernameLabel(newPlayer)
   end
end)

-- Remove highlights when player leaves
Players.PlayerRemoving:Connect(function(leavingPlayer)
   removeHighlight(leavingPlayer)
   removeUsernameLabel(leavingPlayer)
end)

-- Cleanup on character respawn
player.CharacterAdded:Connect(function(newCharacter)
   character = newCharacter
   humanoidRootPart = character:WaitForChild("HumanoidRootPart")
   
   if flying then
      stopFly()
      startFly()
   end
   
   if walkspeedEnabled then
      local humanoid = character:WaitForChild("Humanoid")
      humanoid.WalkSpeed = walkSpeed
   end
   
   if noclipEnabled then
      enableNoclip()
   end
   
   if antiSitEnabled then
      local humanoid = character:WaitForChild("Humanoid")
      humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, false)
   end
   
   if antiFlingEnabled then
      startAntiFlingProtection()
   end
   
   if bodyHighlightEnabled then
      highlightAllPlayers()
   end
end)

Rayfield:Notify({
   Title = "Script Loaded",
   Content = "david_cz11 script loaded successfully!",
   Duration = 2,
   Image = 4483362458,
})
