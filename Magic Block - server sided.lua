-- Make a Script in ServerScriptService or Workspace and paste all of this in

-- Made by zdenekporajch123

-- SETTINGS
local BLOCK_SIZE = 1
local BLOCK_HEIGHT = 10
local GRID_SIZE = 50
local HOLE_RADIUS = 10
local MOVE_DEPTH = 9.5
local MOVE_SPEED = 0.15

local runService = game:GetService("RunService")

-- Remove old MagicBlocks folder
local oldFolder = workspace:FindFirstChild("MagicBlocks")
if oldFolder then
	oldFolder:Destroy()
end

-- Create new folder for blocks
local workspaceFolder = Instance.new("Folder")
workspaceFolder.Name = "MagicBlocks"
workspaceFolder.Parent = workspace

-- Store block data
local blocks = {}

-- Generate grid
for x = 1, GRID_SIZE do
	for z = 1, GRID_SIZE do
		local block = Instance.new("Part")
		block.Size = Vector3.new(BLOCK_SIZE, BLOCK_HEIGHT, BLOCK_SIZE)
		block.Anchored = true
		block.Position = Vector3.new(x * BLOCK_SIZE, BLOCK_HEIGHT / 2, z * BLOCK_SIZE)
		block.Color = Color3.new(1, 1, 1) -- Start white
		block.Material = Enum.Material.SmoothPlastic
		block.Parent = workspaceFolder

		table.insert(blocks, {
			part = block,
			originalY = block.Position.Y
		})
	end
end

-- Function to lerp colors
local function LerpColor3(c1, c2, t)
	return Color3.new(
		c1.R + (c2.R - c1.R) * t,
		c1.G + (c2.G - c1.G) * t,
		c1.B + (c2.B - c1.B) * t
	)
end

-- Main animation loop
runService.Heartbeat:Connect(function()
	local players = game.Players:GetPlayers()

	for _, data in ipairs(blocks) do
		local block = data.part
		local bestFalloff = 0 -- Closest player's effect

		for _, player in ipairs(players) do
			if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
				local rootPos = player.Character.HumanoidRootPart.Position
				local dist = (Vector3.new(block.Position.X, rootPos.Y, block.Position.Z) 
					- Vector3.new(rootPos.X, rootPos.Y, rootPos.Z)).Magnitude

				if dist <= HOLE_RADIUS then
					local falloff = math.cos((dist / HOLE_RADIUS) * (math.pi / 2))
					if falloff > bestFalloff then
						bestFalloff = falloff
					end
				end
			end
		end

		local targetY = data.originalY - (MOVE_DEPTH * bestFalloff)
		local newPos = block.Position:Lerp(Vector3.new(block.Position.X, targetY, block.Position.Z), MOVE_SPEED)
		block.Position = newPos

		-- Depth-based color change
		local depthRatio = math.clamp((data.originalY - newPos.Y) / MOVE_DEPTH, 0, 1)
		block.Color = LerpColor3(Color3.new(1, 1, 1), Color3.new(0, 0, 0), depthRatio)
	end
end)


-- Saw someone selling one of these on TikTok unoptimized so i tried to make one better (this may be also lag heavy)