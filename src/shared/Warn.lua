-- Written 01/09/2021
-- Last edited 11/26/2021

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local SoundService = game:GetService("SoundService")
local RunService = game:GetService("RunService")

local PlaySound = ReplicatedStorage.PlaySound
local Sounds = ReplicatedStorage.Sounds

local sounds = { Sounds.errorSound, Sounds.successSound }

return function(player, message, colour, sound)
	local warning = player.PlayerGui.Main.Warning
	local tween = TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)

	warning.TextTransparency = 0
	warning.Text = message
	warning.TextColor3 = colour
	warning.Visible = true

	if sound then
		if RunService:IsClient() then
			SoundService:PlayLocalSound(sounds[sound])
		else
			PlaySound:FireClient(player, sounds[sound])
		end
	end

	wait(2)

	tween:Play()
	tween.Completed:Wait()
	warning.Visible = false
	warning.TextTransparency = 0
end
