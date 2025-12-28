local process = require("@lune/process")
local net = require("@lune/net")
local fs = require("@lune/fs")
local serde = require("@lune/serde")
local task = require("@lune/task")

local function logError(response: net.FetchResponse)
	print(`[Code {response.statusCode}] {response.statusMessage}`)
	print(`[Body] {response.body}`)
end

local binaryPath, apiKey, universeId, placeId = table.unpack(process.args)

local uploadResponse = net.request({
	url = `https://apis.roblox.com/universes/v1/{universeId}/places/{placeId}/versions?versionType=Saved`,
	method = "POST",
	headers = {
		["Content-Type"] = "application/json",
		["x-api-key"] = apiKey,
	},
	body = fs.readFile(binaryPath),
})

if not uploadResponse.ok then
	logError(uploadResponse)
	process.exit(1)
end

local uploadBody = serde.decode("json", uploadResponse.body)
local placeVersion = uploadBody.versionNumber

local queueResponse = net.request({
	url = `https://apis.roblox.com/cloud/v2/universes/{universeId}/places/{placeId}/versions/{placeVersion}/luau-execution-session-tasks`,
	method = "POST",
	headers = {
		["Content-Type"] = "application/json",
		["x-api-key"] = apiKey,
	},
	body = serde.encode("json", {
		script = fs.readFile("./cloud/testez.luau"),
	}),
})

if not queueResponse.ok then
	logError(queueResponse)
	process.exit(1)
end

local taskPath = serde.decode("json", queueResponse.body).path

repeat
	local pollResponse = net.request({
		url = `https://apis.roblox.com/cloud/v2/{taskPath}`,
		method = "GET",
		headers = {
			["Content-Type"] = "application/json",
			["x-api-key"] = apiKey,
		},
	})

	if not pollResponse.ok then
		logError(pollResponse)
		process.exit(1)
	end

	local pollBody = serde.decode("json", pollResponse.body)

	if pollBody.state == "PROCESSING" then
		print("Processing cloud tests...")
		task.wait(3)
		continue
	end

	local logsResponse = net.request({
		url = `https://apis.roblox.com/cloud/v2/{taskPath}/logs`,
		method = "GET",
		headers = {
			["Content-Type"] = "application/json",
			["x-api-key"] = apiKey,
		},
	})

	if not logsResponse.ok then
		logError(logsResponse)
		process.exit(1)
	end

	local logBody = serde.decode("json", logsResponse.body)
	print(table.concat(logBody.luauExecutionSessionTaskLogs[1].messages, "\n"))

	if pollBody.state ~= "COMPLETE" then
		error(pollBody.error.message)
	end
until pollBody.state == "COMPLETE"
