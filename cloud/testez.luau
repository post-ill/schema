--!nonstrict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local testez = require(ReplicatedStorage.DevPackages.testez)

local results = testez.TestBootstrap:run({
	game:GetService("TestService"),
})

if results.failureCount == 0 then
	return
end

error(`Tests failed. Failure count: {results.failureCount}`)
