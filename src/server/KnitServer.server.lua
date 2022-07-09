local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)

Knit.AddServices(game:GetService("ServerScriptService").Server.Services)

Knit.Start()
	:andThen(function()
		print("[Knit] Server started")
	end)
	:catch(warn)
