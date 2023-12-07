local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local TableState = {}

for _, TablesWorkspace in pairs(game.Workspace:WaitForChild("TablesInWorkspace"):GetChildren()) do
	
	if TablesWorkspace:IsA("Model") then
		
		TableState[tostring(TablesWorkspace.Name)] = {["State"] = false}
		
	end
	
end

RunService.Heartbeat:Connect(function()
	
	for _, TableModel in pairs(CollectionService:GetTagged("Table")) do
		
		if TableModel:IsA("Model") then	
			
			local TI = TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
			
			local RE_Folder = ReplicatedStorage:WaitForChild("RemoteEvents")
			local ModelToClone_Folder = ReplicatedStorage:WaitForChild("ModelToClone")
			
			local PlayerChangeCameraEvent = RE_Folder:WaitForChild("ChangePlrCamera")
			local CheckCorrectsEvent = RE_Folder:WaitForChild("CheckCorrects")
			local LeaveEvent = RE_Folder:WaitForChild("LeaveEvent")
			
			local BottleModel = ModelToClone_Folder:WaitForChild("Bottle")
			
			local Table = TableModel
			
			local PlayerValues = Table:WaitForChild("PlayerValues")
			local PlayerObj = PlayerValues:WaitForChild("Player")
			local PlayerBottleToReplace = PlayerValues:WaitForChild("BottleToReplace")
			local PlayerBottleInHand = PlayerValues:WaitForChild("BottleInHand")
			local PlayerCorrectNum = PlayerValues:WaitForChild("NumberOfCorrects")
			
			local NPC = Table:WaitForChild("Rig")
			local InGame = Table:WaitForChild("InGame")
			local PlayerPos = Table:WaitForChild("PlayerPos")
			local cam = Table:WaitForChild("Cam")
			local PartTrigger = Table:WaitForChild("Trigger")
			
			local TriggerPrompt = PartTrigger:WaitForChild("ProximityPrompt")
			
			local box = Table:WaitForChild("Box")
			local BottlePositionsFolder = box:WaitForChild("BottlePositions")
			local TopBottlesFolder = box:WaitForChild("TopBottles")
			local BoxBottles = box:WaitForChild("BelowBottles")
			
			local numberInUse = {}
			
			local ColorInUse = {
				["BottlesBelow"] = {},
				["BottlesTop"] = {}
			}
			
			local BottlesColors = {
				Color3.fromRGB(255, 0, 0),
				Color3.fromRGB(0, 0, 255),
				Color3.fromRGB(255, 255, 0),
				Color3.fromRGB(0, 255, 0),
				Color3.fromRGB(255, 85, 0)
			}
			
			local function GenerateBottles ()
				
				if #TopBottlesFolder:GetChildren() == 0 then
					
					for i = 1, #BoxBottles:GetChildren(), 1 do
						
						local randomColor
						
						repeat 
							
							randomColor = math.random(1, #BottlesColors)
							
						until not table.find(ColorInUse["BottlesBelow"], randomColor)
						
						table.insert(ColorInUse["BottlesBelow"], randomColor)
						
						BoxBottles:FindFirstChild(tostring("Bottle")..i):WaitForChild("Liquid").Color = BottlesColors[randomColor]
						
						BoxBottles:FindFirstChild(tostring("Bottle")..i).Color.Value = BrickColor.new(BottlesColors[randomColor]).Name
						
					end
					
					for i = 1, #BoxBottles:GetChildren(), 1 do
						
						local randomPos
						local randomColor
						
						repeat 
							
							randomPos = math.random(1, #BoxBottles:GetChildren())
							
						until not table.find(numberInUse, randomPos)
						
						table.insert(numberInUse, randomPos)
						
						local NewBottle = BottleModel:Clone()
						
						NewBottle.Name = "Bottle"..i
						NewBottle.PrimaryPart.CFrame = BottlePositionsFolder:FindFirstChild(tostring("BottlePos")..tostring(randomPos)).CFrame * CFrame.new(-0.6, 0, 0)
						NewBottle.PositionNumber.Value = BottlePositionsFolder:FindFirstChild(tostring("BottlePos")..tostring(randomPos)).PositionNumber.Value
						
						BottlePositionsFolder:FindFirstChild(tostring("BottlePos")..tostring(randomPos)).Bottle.Value = NewBottle
						
						for index, bottleBelow in pairs(BoxBottles:GetChildren()) do
							
							if bottleBelow:IsA("Model") then
								
								if bottleBelow.PositionNumber.Value == NewBottle.PositionNumber.Value and bottleBelow.BottleOnTop.Value == nil and NewBottle.BottleBelow.Value == nil then
									
									NewBottle.BottleBelow.Value = bottleBelow
									bottleBelow.BottleOnTop.Value = NewBottle
									
								end
								
							end
							
						end
						
						repeat 
							
							randomColor = math.random(1, #BottlesColors)
							
						until not table.find(ColorInUse["BottlesTop"], randomColor)
						
						table.insert(ColorInUse["BottlesTop"], randomColor)
						
						NewBottle:WaitForChild("Liquid").Color = BottlesColors[randomColor]
						
						NewBottle.Color.Value = BrickColor.new(BottlesColors[randomColor]).Name
						
						NewBottle.Parent = box:WaitForChild("TopBottles")
						
					end
				end
			end
			
			local function MoveBottles(BottleHand, BottleReplace)
				
				local Bottle1Pos = BottleHand.PositionNumber.Value
				local Bottle2Pos = BottleReplace.PositionNumber.Value
				
				local g1 = {
					
					CFrame = BottlePositionsFolder:FindFirstChild(tostring("BottlePos")..tostring(BottleReplace.PositionNumber.Value)).CFrame * CFrame.new(-1.6, 0, 0)
					
				}
				
				local g2 = {
					
					CFrame = BottlePositionsFolder:FindFirstChild(tostring("BottlePos")..tostring(BottleHand.PositionNumber.Value)).CFrame * CFrame.new(-1.6, 0, 0)
					
				}
				
				local BottleTween1 = TweenService:Create(BottleHand.PrimaryPart, TI, g1)
				local BottleTween2 = TweenService:Create(BottleReplace.PrimaryPart, TI, g2)
				
				task.spawn(function()
					
					BottleTween1:Play()
					
				end)
				
				BottleTween2:Play()
				
				wait(0.2)
				
				g1 = {
					
					CFrame = BottleHand.PrimaryPart.CFrame * CFrame.new(1, 0, 0)
					
				}
				
				g2 = {
					
					CFrame = BottleReplace.PrimaryPart.CFrame * CFrame.new(1, 0, 0)
					
				}
				
				BottleHand.PositionNumber.Value = Bottle2Pos
				BottleReplace.PositionNumber.Value = Bottle1Pos
				
				BottleTween1 = TweenService:Create(BottleHand.PrimaryPart, TI, g1)
				BottleTween2 = TweenService:Create(BottleReplace.PrimaryPart, TI, g2)
				
				task.spawn(function()
					
					BottleTween1:Play()
					
				end)
				
				BottleTween2:Play()
				
				PlayerBottleInHand.Value = nil
				PlayerBottleToReplace.Value = nil
				
			end
			
			local function CleanTable()
				
				for index, TopBottle in pairs(TopBottlesFolder:GetChildren()) do
					
					if TopBottle:IsA("Model") then
						
						TopBottle:Destroy()
						
					end
					
				end
				
				for index, BottomBottle in pairs(BoxBottles:GetChildren()) do
					
					if BottomBottle:IsA("Model") then
						
						BottomBottle.Liquid.Color = Color3.fromRGB(85, 170, 255)
						BottomBottle.BottleOnTop.Value = nil
						BottomBottle.Color.Value = ""
						
					end	
					
				end
				
			end
			
			CheckCorrectsEvent.OnServerEvent:Connect(function(Player)
				
				if PlayerObj.Value == Player then
					
					PlayerCorrectNum.Value = 0
					
					Player.PlayerGui.ScreenGui.CorrectDisplay:TweenSize(UDim2.fromScale(0.3, 0.15), Enum.EasingDirection.InOut, Enum.EasingStyle.Sine, 0.2)
					
					for index, TopBottle in pairs(TopBottlesFolder:GetChildren()) do
						for index2, BottomBottle in pairs(BoxBottles:GetChildren()) do
							
							if TopBottle.PositionNumber.Value == BottomBottle.PositionNumber.Value and TopBottle.Color.Value == BottomBottle.Color.Value then
								PlayerCorrectNum.Value += 1
							end
							
						end
					end
					
					task.delay(1, function()
						
						if PlayerCorrectNum.Value == 5 then
							
							PlayerChangeCameraEvent:FireClient(Player, "Ended")
							
							Player.PlayerGui.ScreenGui.CheckButton.Visible = false
							Player.PlayerGui.ScreenGui.CorrectDisplay.Visible = false
							Player.PlayerGui.ScreenGui.ExitButton.Visible = false
							
							Player.PlayerGui.ScreenGui.CorrectDisplay.TextButton.Text = "Corrects: 0"
							
							PlayerObj.Value = nil
							InGame.Value = false
							PlayerCorrectNum.Value = 0
							
							TriggerPrompt.Enabled = true
							
							TableState[tostring(TableModel.Name)]["State"] = false
							
							table.clear(ColorInUse["BottlesTop"])
							table.clear(ColorInUse["BottlesBelow"])
							table.clear(numberInUse)
							
							CleanTable()
							
						end
						
					end)
					
					Player.PlayerGui.ScreenGui.CorrectDisplay.TextButton.Text = "Corrects: "..PlayerCorrectNum.Value
					wait(0.2)
					Player.PlayerGui.ScreenGui.CorrectDisplay:TweenSize(UDim2.fromScale(0.3, 0.1), Enum.EasingDirection.InOut, Enum.EasingStyle.Sine, 0.2)
					
				end
			end)
			
			LeaveEvent.OnServerEvent:Connect(function(Player)
				
				PlayerChangeCameraEvent:FireClient(Player, "Ended")
				
				Player.PlayerGui.ScreenGui.CheckButton.Visible = false
				Player.PlayerGui.ScreenGui.CorrectDisplay.Visible = false
				Player.PlayerGui.ScreenGui.ExitButton.Visible = false
				
				Player.PlayerGui.ScreenGui.CorrectDisplay.TextButton.Text = "Corrects: 0"
				
				PlayerObj.Value = nil
				InGame.Value = false
				PlayerCorrectNum.Value = 0
				
				TriggerPrompt.Enabled = true
				
				TableState[tostring(TableModel.Name)]["State"] = false
				
				table.clear(ColorInUse["BottlesTop"])
				table.clear(ColorInUse["BottlesBelow"])
				table.clear(numberInUse)
				
				CleanTable()
			end)
			
			TriggerPrompt.Triggered:Connect(function(Player)
				
				local PlayerCharacter = Player.Character
				local PlayerHRP = PlayerCharacter:WaitForChild("HumanoidRootPart")
				
				if PlayerHRP then
					
					Player.Table.Value = Table
					InGame.Value = true
					PlayerObj.Value = Player
					
					PlayerChangeCameraEvent:FireClient(Player, "Start", cam)
					
					TriggerPrompt.Enabled = false
					
					PlayerHRP.CFrame = PlayerPos.CFrame * CFrame.new(0, 3, 0)
					PlayerHRP.CFrame = CFrame.lookAt(PlayerHRP.Position, NPC.HumanoidRootPart.Position)
					
					Player.PlayerGui.ScreenGui.CheckButton.Visible = true
					Player.PlayerGui.ScreenGui.CorrectDisplay.Visible = true
					Player.PlayerGui.ScreenGui.ExitButton.Visible = true
					
					GenerateBottles()
					
				end
			end)
			
			if InGame.Value == true then
				
				for index, bottle in pairs(CollectionService:GetTagged("TopBottle")) do
					
					if bottle:IsA("Model") then
						
						bottle.ClickDetector.MouseClick:Connect(function(Player)
							
							if TableState[tostring(TableModel.Name)]["State"] == false then
								
								TableState[tostring(TableModel.Name)]["State"] = true
								
								if Player == PlayerValues.Player.Value then
									
									if PlayerBottleInHand.Value == nil then
										
										PlayerBottleInHand.Value = bottle
										bottle.Highlight.FillColor = Color3.fromRGB(255, 255, 255)
										bottle.Highlight.FillTransparency = 1
										bottle.Highlight.Enabled = true
										
										local Goal = {
											CFrame = bottle.PrimaryPart.CFrame * CFrame.new(-1, 0, 0)
										}
										
										local Playtween = TweenService:Create(bottle.PrimaryPart, TI, Goal)
										
										Playtween:Play()
										Player.PlayerGui.ScreenGui.CheckButton.Visible = false
										
									elseif PlayerBottleInHand.Value == bottle then
										
										PlayerBottleInHand.Value = nil
										bottle.Highlight.Enabled = false
										
										local Goal = {
											CFrame = bottle.PrimaryPart.CFrame * CFrame.new(1, 0, 0)
										}
										
										local Playtween = TweenService:Create(bottle.PrimaryPart, TI, Goal)
										
										Playtween:Play()
										Player.PlayerGui.ScreenGui.CheckButton.Visible = true
										
									elseif PlayerBottleInHand.Value ~= nil and PlayerBottleToReplace.Value == nil and PlayerBottleInHand.Value ~= bottle then
										
										PlayerBottleToReplace.Value = bottle
										bottle.Highlight.FillColor = Color3.fromRGB(255, 255, 255)
										bottle.Highlight.FillTransparency = 1
										bottle.Highlight.Enabled = true
										
										local Goal = {
											CFrame = bottle.PrimaryPart.CFrame * CFrame.new(-1, 0, 0)
										}
										
										local Playtween = TweenService:Create(bottle.PrimaryPart, TI, Goal)
										
										Playtween:Play()
										Player.PlayerGui.ScreenGui.CheckButton.Visible = false
										TopBottlesFolder:FindFirstChild(tostring(PlayerBottleInHand.Value)).Highlight.Enabled = false
										TopBottlesFolder:FindFirstChild(tostring(PlayerBottleToReplace.Value)).Highlight.Enabled = false
										wait(.2)
										MoveBottles(PlayerBottleInHand.Value, PlayerBottleToReplace.Value)
										wait(.4)
										Player.PlayerGui.ScreenGui.CheckButton.Visible = true
										
									end
								end
								
								wait(0.4)
								TableState[tostring(TableModel.Name)]["State"] = false
								
							end
						end)
						
						bottle.ClickDetector.MouseHoverEnter:Connect(function(Player)
							
							if Player == PlayerValues.Player.Value then
								
								if PlayerBottleInHand.Value ~= nil and PlayerBottleInHand.Value ~= bottle and PlayerBottleToReplace.Value == nil then
									
									bottle.Highlight.FillColor = Color3.fromRGB(255, 0, 0)
									bottle.Highlight.FillTransparency = 0.5
									bottle.Highlight.Enabled = true
									
								elseif PlayerBottleInHand.Value == nil then
									
									bottle.Highlight.FillColor = Color3.fromRGB(255, 255, 255)
									bottle.Highlight.FillTransparency = 1
									bottle.Highlight.Enabled = true
									
								end
								
							end
							
						end)
						
						bottle.ClickDetector.MouseHoverLeave:Connect(function(Player)
							
							if Player == PlayerValues.Player.Value then
								
								if PlayerBottleInHand.Value ~= nil and PlayerBottleInHand.Value ~= bottle and PlayerBottleToReplace.Value == nil then
									bottle.Highlight.Enabled = false
								elseif PlayerBottleInHand.Value == nil then
									bottle.Highlight.Enabled = false
								end
								
							end
							
						end)
						
					end
					
				end
				
			end
			
		end
		
	end
	
end)