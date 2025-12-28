local ReplicatedStorage = game:GetService("ReplicatedStorage")
local library = require(ReplicatedStorage.library)

return function()
	describe("This library", function()
		it("should match math.pi on library.getNumber", function()
			expect(library.getNumber()).to.equal(math.pi)
		end)
	end)
end
