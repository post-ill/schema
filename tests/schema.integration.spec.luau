local ReplicatedStorage = game:GetService("ReplicatedStorage")
local s = require(ReplicatedStorage.schema)

return function()
	describe("combinators", function()
		it("should validate arrays containing complex objects on schema.array", function()
			local arraySchema = s.array(s.shape({
				name = s.intersection(s.string, s.range(3, 10)),
				score = s.intersection(s.integer, s.unsigned),
				inventory = s.array(s.shape({
					id = s.intersection(s.integer, s.min(1)),
					amount = s.intersection(s.integer, s.unsigned),
				})),
			}))
			expect(arraySchema({
				{
					name = "John Doe",
					score = 10,
					inventory = {
						{ id = 1, amount = 5 },
						{ id = 2, amount = 3 },
					},
				},
				{
					name = "Tom",
					score = 0,
					inventory = {
						{ id = 5, amount = 21 },
						{ id = 9, amount = 23 },
					},
				},
			})).to.equal(nil)
		end)

		it("should validate sets containing combined objects on schema.set", function()
			local objectSchema = s.shape({
				name = s.intersection(s.string, s.range(3, 10)),
				lastJoin = s.intersection(s.integer, s.unsigned),
				meta = s.object({
					id = s.intersection(s.integer, s.min(1)),
				}),
			})
			local setSchema = s.set(objectSchema, function(data: any)
				return data.meta.id
			end)
			expect(setSchema({
				{
					name = "player_1",
					lastJoin = os.time(),
					meta = {
						id = 1,
						rest = {},
					},
				},
				{
					name = "player_2",
					lastJoin = os.time(),
					meta = {
						id = 1,
					},
				},
			})).to.be.a("string")
		end)

		it("should validate combined key-value objects on schema.map", function()
			local mapSchema =
				s.map(s.intersection(s.string, s.range(3, 5)), s.intersection(s.array(s.number), s.max(5)))
			expect(mapSchema({
				one = { 0, 10, 15, 20 },
				two = { 1, 20, 25.5, 30 },
				third = { 2.75, 10, 15, 20 },
			})).to.equal(nil)
			expect(mapSchema({
				one = { 0, 10, 15, 20 },
				two = { 1, 20, 25.5, 30 },
				third = { 2.75, 10, 15, 20 },
				fourth = { 1, 2, 3, 4, 5, 6 },
			})).to.be.a("string")
		end)

		it("should validate deeply nested objects on schema.object", function()
			local objectSchema = s.object({
				more = s.object({
					than = s.object({
						a = s.object({
							deeply = s.object({
								nested = s.object({
									object = s.number,
								}),
							}),
						}),
						an = s.object({
							object = s.string,
						}),
					}),
				}),
			})
			expect(objectSchema({
				more = {
					than = {
						a = {
							deeply = {
								nested = {
									object = math.pi,
								},
							},
						},
						an = {
							object = "string",
						},
					},
				},
			})).to.equal(nil)
			expect(objectSchema({
				more = {
					than = {
						an = {
							object = "string",
						},
					},
				},
			})).to.be.a("string")
		end)

		it("should validate tagged unions on schema.union", function()
			local unionSchema = s.union(
				s.shape({
					type = s.literal("tuple"),
					data = s.shape({ s.number, s.integer, s.boolean }),
				}),
				s.shape({
					type = s.literal("map"),
					data = s.map(s.string, s.number),
				}),
				s.shape({
					type = s.literal("set"),
					data = s.set(s.intersection(s.integer, s.range(5, 10))),
				})
			)
			expect(unionSchema({
				type = "tuple",
				data = { math.pi, -5, false },
			})).to.equal(nil)
			expect(unionSchema({
				type = "map",
				data = {
					a = 1,
					b = 2,
				},
			})).to.equal(nil)
			expect(unionSchema({
				type = "set",
				data = { 7, 9, 10 },
			})).to.equal(nil)
			expect(unionSchema({
				type = "map",
				data = { 7, 9, 10 },
			})).to.be.a("string")
		end)

		it("should validate combined constituents on schema.intersection", function()
			local intersectionSchema = s.intersection(
				s.set(s.integer),
				s.set(s.unsigned),
				s.union(s.intersection(s.min(3), s.max(5)), s.size(1))
			)
			expect(intersectionSchema({ 0, 1, 2 })).to.equal(nil)
			expect(intersectionSchema({ 7 })).to.equal(nil)
			expect(intersectionSchema({ 0, 1, 2, 3, 4, 5 })).to.be.a("string")
			expect(intersectionSchema({ math.pi })).to.be.a("string")
		end)
	end)
end
