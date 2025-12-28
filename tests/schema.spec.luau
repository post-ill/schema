local ReplicatedStorage = game:GetService("ReplicatedStorage")
local s = require(ReplicatedStorage.schema)

return function()
	describe("primitives", function()
		it("should validate booleans on s.boolean", function()
			local booleanSchema = s.boolean
			expect(booleanSchema(true)).to.equal(nil)
			expect(booleanSchema(false)).to.equal(nil)
			expect(booleanSchema(7)).to.be.a("string")
			expect(booleanSchema("true")).to.be.a("string")
			expect(booleanSchema({})).to.be.a("string")
			expect(booleanSchema(nil)).to.be.a("string")
		end)

		it("should validate integers on schema.integer", function()
			local integerSchema = s.integer
			expect(integerSchema(0)).to.equal(nil)
			expect(integerSchema(7)).to.equal(nil)
			expect(integerSchema(false)).to.be.a("string")
			expect(integerSchema(0.7)).to.be.a("string")
			expect(integerSchema("true")).to.be.a("string")
			expect(integerSchema({})).to.be.a("string")
			expect(integerSchema(nil)).to.be.a("string")
		end)

		it("should validate numbers on schema.number", function()
			local numberSchema = s.number
			expect(numberSchema(0)).to.equal(nil)
			expect(numberSchema(7)).to.equal(nil)
			expect(numberSchema(-0.7)).to.equal(nil)
			expect(numberSchema(false)).to.be.a("string")
			expect(numberSchema("true")).to.be.a("string")
			expect(numberSchema({})).to.be.a("string")
			expect(numberSchema(nil)).to.be.a("string")
		end)

		it("should validate strings on schema.string", function()
			local stringSchema = s.string
			expect(stringSchema("true")).to.equal(nil)
			expect(stringSchema(false)).to.be.a("string")
			expect(stringSchema(7)).to.be.a("string")
			expect(stringSchema({})).to.be.a("string")
			expect(stringSchema(nil)).to.be.a("string")
		end)

		it("should validate anything on schema.any", function()
			local anySchema = s.any
			expect(anySchema(false)).to.equal(nil)
			expect(anySchema(7)).to.equal(nil)
			expect(anySchema("true")).to.equal(nil)
			expect(anySchema({})).to.equal(nil)
			expect(anySchema(nil)).to.equal(nil)
		end)
	end)

	describe("constraints", function()
		it("should validate minimum contextual size on schema.min", function()
			local minSchema = s.min(5)
			expect(minSchema(7)).to.equal(nil)
			expect(minSchema("seven")).to.equal(nil)
			expect(minSchema({ 1, 2, 3, 4, 5 })).to.equal(nil)
			expect(minSchema(1)).to.be.a("string")
			expect(minSchema("four")).to.be.a("string")
			expect(minSchema({ 1, 2 })).to.be.a("string")
		end)

		it("should validate maximum contextual size on schema.max", function()
			local maxSchema = s.max(5)
			expect(maxSchema(1)).to.equal(nil)
			expect(maxSchema("four")).to.equal(nil)
			expect(maxSchema({ 1, 2 })).to.equal(nil)
			expect(maxSchema(7)).to.be.a("string")
			expect(maxSchema("seventy")).to.be.a("string")
			expect(maxSchema({ 1, 2, 3, 4, 5, 6 })).to.be.a("string")
		end)

		it("should validate contextual size range on schema.range", function()
			local rangeSchema = s.range(5, 10)
			expect(rangeSchema(7)).to.equal(nil)
			expect(rangeSchema("seven")).to.equal(nil)
			expect(rangeSchema({ 1, 2, 3, 4, 5 })).to.equal(nil)
			expect(rangeSchema("four")).to.be.a("string")
			expect(rangeSchema({ 1, 2, 3 })).to.be.a("string")
			expect(rangeSchema(12)).to.be.a("string")
		end)

		it("should validate exact contextual size on schema.size", function()
			local sizeSchema = s.size(3)
			expect(sizeSchema("111")).to.equal(nil)
			expect(sizeSchema({ 2, 3, 5 })).to.equal(nil)
			expect(sizeSchema("five")).to.be.a("string")
			expect(sizeSchema({ 1 })).to.be.a("string")
		end)

		it("should validate unsigned numbers on schema.unsigned", function()
			local unsignedSchema = s.unsigned
			expect(unsignedSchema(0)).to.equal(nil)
			expect(unsignedSchema(1)).to.equal(nil)
			expect(unsignedSchema(1.5)).to.equal(nil)
			expect(unsignedSchema(-1.5)).to.be.a("string")
			expect(unsignedSchema(-5)).to.be.a("string")
		end)

		it("should validate literals on schema.literal", function()
			local literalSchema = s.literal(math.pi)
			expect(literalSchema(math.pi)).to.equal(nil)
			expect(literalSchema(0)).to.be.a("string")
			expect(literalSchema(math.pi - 1)).to.be.a("string")
		end)
	end)

	describe("combinators", function()
		it("should validate arrays on schema.array", function()
			local arraySchema = s.array(s.integer)
			expect(arraySchema({ 1, 2, 3, 4 })).to.equal(nil)
			expect(arraySchema({ 1, 2, "three", 4 })).to.be.a("string")
			expect(arraySchema({ ["key"] = "value" })).to.be.a("string")
		end)

		it("should validate sets on schema.set", function()
			local setSchema = s.set(s.integer)
			expect(setSchema({ 1, 2, 3, 4 })).to.equal(nil)
			expect(setSchema({ 1, 1, 2, 3, 4 })).to.be.a("string")
			expect(setSchema({ 5, "six", 7, 8 })).to.be.a("string")
			expect(setSchema({ ["key"] = "value" })).to.be.a("string")
		end)

		it("should validate maps on schema.map", function()
			local mapSchema = s.map(s.string, s.number)
			expect(mapSchema({
				one = 1,
				two = math.pi,
				three = 3,
			})).to.equal(nil)
			expect(mapSchema({
				one = 1,
				two = math.pi,
				three = "3",
			})).to.be.a("string")
		end)

		it("should validate tables on schema.object", function()
			local tableSchema = s.object({
				name = s.string,
				age = s.intersection(s.integer, s.unsigned),
				balance = s.number,
			})
			expect(tableSchema({
				name = "John Doe",
				age = 19,
				balance = -10.5,
				extra = true,
			})).to.equal(nil)
		end)

		it("should validate tuples on schema.object", function()
			local tupleSchema = s.object({ s.number, s.number, s.string })
			expect(tupleSchema({ 10, 100, "1000", true })).to.equal(nil)
			expect(tupleSchema({ 10, 100, 1000, true })).to.be.a("string")
		end)

		it("should validate shape tables on schema.shape", function()
			local tableSchema = s.shape({
				name = s.string,
				age = s.intersection(s.integer, s.unsigned),
				balance = s.number,
			})
			expect(tableSchema({
				name = "John Doe",
				age = 19,
				balance = -10.5,
			})).to.equal(nil)
			expect(tableSchema({
				name = "John Doe",
				age = 19.5,
				balance = -10.5,
			})).to.be.a("string")
			expect(tableSchema({
				name = "John Doe",
				age = 19,
				balance = -10.5,
				extra = true,
			})).to.be.a("string")
		end)

		it("should validate shape tuples on schema.shape", function()
			local tupleSchema = s.shape({ s.number, s.number, s.string })
			expect(tupleSchema({ 10, 100, "1000" })).to.equal(nil)
			expect(tupleSchema({ 10, 100, 1000 })).to.be.a("string")
			expect(tupleSchema({ 10, 100, "1000", math.pi })).to.be.a("string")
		end)

		it("should validate at least one schema on schema.union", function()
			local unionSchema = s.union(s.number, s.string, s.boolean)
			expect(unionSchema(7)).to.equal(nil)
			expect(unionSchema("string")).to.equal(nil)
			expect(unionSchema(false)).to.equal(nil)
			expect(unionSchema({})).to.be.a("string")
			expect(unionSchema(nil)).to.be.a("string")
		end)

		it("should validate all schemas on schema.intersection", function()
			local intersectionSchema = s.intersection(s.integer, s.unsigned)
			expect(intersectionSchema(0)).to.equal(nil)
			expect(intersectionSchema(10)).to.equal(nil)
			expect(intersectionSchema(-10)).to.be.a("string")
			expect(intersectionSchema(10.5)).to.be.a("string")
		end)

		it("should validate schema or nil on schema.optional", function()
			local optionalSchema = s.optional(s.integer)
			expect(optionalSchema(10)).to.equal(nil)
			expect(optionalSchema(nil)).to.equal(nil)
			expect(optionalSchema("mismatch")).to.be.a("string")
		end)
	end)

	describe("roblox types", function()
		it("should validate enum items on schema.enum", function()
			local enumSchema = s.enum(Enum.HumanoidRigType)
			expect(enumSchema(Enum.HumanoidRigType.R6)).to.equal(nil)
			expect(enumSchema(Enum.HumanoidRigType.R15)).to.equal(nil)
			expect(enumSchema(1)).to.be.a("string")
			expect(enumSchema(Enum.HumanoidRigType)).to.be.a("string")
		end)

		it("should validate data type instances on schema.dataType", function()
			local dataTypeSchema = s.dataType("Vector3")
			expect(dataTypeSchema(Vector3.zero)).to.equal(nil)
			expect(dataTypeSchema(CFrame.identity)).to.be.a("string")
		end)

		it("should validate equal or subclass instances on schema.instance", function()
			local dataTypeSchema = s.instance("GuiObject")
			expect(dataTypeSchema(Instance.new("Frame"))).to.equal(nil)
			expect(dataTypeSchema(Instance.new("TextButton"))).to.equal(nil)
			expect(dataTypeSchema(Instance.new("Model"))).to.be.a("string")
		end)

		it("should validate exact class instances on schema.class", function()
			local dataTypeSchema = s.class("Script")
			expect(dataTypeSchema(Instance.new("Script"))).to.equal(nil)
			expect(dataTypeSchema(Instance.new("LocalScript"))).to.be.a("string")
		end)
	end)
end
