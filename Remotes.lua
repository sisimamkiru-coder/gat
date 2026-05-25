remote 1

local args = {
	1
}
game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("Rewards"):WaitForChild("SpinRewards"):FireServer(unpack(args))


remote 2

game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("Game"):WaitForChild("CaseTriggered"):FireServer()


remote 3

game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("Game"):WaitForChild("SellAll"):FireServer()


remote 4

game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("Game"):WaitForChild("SellThis"):FireServer()


remote 5

local args = {
	4
}
game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("Rewards"):WaitForChild("TimeRewards"):FireServer(unpack(args))


remote 6

local args = {
	"Storage"
}
game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("Game"):WaitForChild("GemPurchase"):FireServer(unpack(args))


remote 7

local args = {
	"Base"
}
game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("Game"):WaitForChild("GemPurchase"):FireServer(unpack(args))
