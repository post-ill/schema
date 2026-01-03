--!nonstrict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TestEZ = require(ReplicatedStorage.Shared.Dependencies.Test.TestEZ)

local results = TestEZ.TestBootstrap:run({
	game:GetService("TestService"),
})

if results.failureCount == 0 then
	return
end

error(`Tests failed. Failure count: {results.failureCount}`)
