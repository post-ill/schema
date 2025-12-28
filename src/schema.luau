type Schema = (data: any) -> string?

type Object = { [any]: Schema }

type S = {
	boolean: Schema,
	integer: Schema,
	number: Schema,
	string: Schema,
	any: Schema,

	min: (bound: number) -> Schema,
	max: (bound: number) -> Schema,
	range: (min: number, max: number) -> Schema,
	size: (size: number) -> Schema,
	unsigned: Schema,
	literal: (data: any) -> Schema,

	array: (schema: Schema) -> Schema,
	set: (schema: Schema, identity: ((data: any) -> any)?) -> Schema,
	map: (keySchema: Schema, valueSchema: Schema) -> Schema,
	object: (object: Object) -> Schema,
	shape: (object: Object) -> Schema,
	union: (...Schema) -> Schema,
	intersection: (...Schema) -> Schema,
	optional: (Schema) -> Schema,

	enum: (name: Enum) -> Schema,
	dataType: (name: string) -> Schema,
	instance: (name: string) -> Schema,
	class: (name: string) -> Schema,
}

local s = {}
s.__index = s

-- Primitives
function s.boolean(data)
	return if type(data) == "boolean" then nil else `boolean expected, got {type(data)}`
end

function s.integer(data)
	return if type(data) == "number" and data % 1 == 0 then nil else `integer number >= 0 expected, got '{data}'`
end

function s.number(data)
	return if type(data) == "number" then nil else `number expected, got {type(data)}`
end

function s.string(data)
	return if type(data) == "string" then nil else `string expected, got {type(data)}`
end

function s.any(_)
	return nil
end

-- Constraints
function s.min(bound)
	return function(data)
		if type(data) == "number" then
			return if data >= bound then nil else `expected number >= {bound}, got {data}`
		end

		if type(data) == "string" then
			return if #data >= bound then nil else `expected string length >= {bound}, got '{data}' ({#data})`
		end

		if type(data) == "table" then
			return if #data >= bound then nil else `expected table length >= {bound}, got '{data}' ({#data})`
		end

		return nil
	end
end

function s.max(bound)
	return function(data)
		if type(data) == "number" then
			return if data <= bound then nil else `expected number <= {bound}, got {data}`
		end

		if type(data) == "string" then
			return if #data <= bound then nil else `expected string length <= {bound}, got {#data}`
		end

		if type(data) == "table" then
			return if #data <= bound then nil else `expected table length <= {bound}, got {#data}`
		end

		return nil
	end
end

function s.range(min, max)
	return s.intersection(s.min(min), s.max(max))
end

function s.size(size)
	return function(data)
		if type(data) == "string" then
			return if #data == size then nil else `expected string length == {size}, got {#data}`
		end

		if type(data) == "table" then
			return if #data == size then nil else `expected table length == {size}, got {#data}`
		end

		return nil
	end
end

function s.unsigned(data)
	return if type(data) == "number" and data >= 0 then nil else `expected unsigned, got '{data}'`
end

function s.literal(literal)
	return function(data)
		return if data == literal then nil else `'{literal}' expected, got '{data}'`
	end
end

-- Combinators
function s.array(schema)
	return function(data): string?
		if type(data) ~= "table" then
			return `array expected, got {type(data)}`
		end

		local index = 1

		for key, _ in data do
			if key ~= index then
				return `array expected, got table`
			end

			local err = schema(data[key])

			if err then
				return err
			end

			index += 1
		end

		return nil
	end
end

function s.set(schema, identity: (any) -> any)
	identity = identity or function(data)
		return data
	end

	return function(data): string?
		if type(data) ~= "table" then
			return `array expected, got {type(data)}`
		end

		local index = 1
		local set = {}

		for key, value in data do
			if key ~= index then
				return `array expected, got table`
			end

			local err = schema(data[key])

			if err then
				return err
			end

			index += 1

			if set[identity(value)] ~= nil then
				return `set expected, got duplicates`
			end

			set[identity(value)] = data
		end

		return nil
	end
end

function s.map(keySchema, valueSchema)
	return function(data): string?
		if type(data) ~= "table" then
			return `table expected, got {type(data)}`
		end

		for key, value in data do
			local keyErr = keySchema(key)

			if keyErr then
				return keyErr
			end

			local valueErr = valueSchema(value)

			if valueErr then
				return valueErr
			end
		end

		return nil
	end
end

function s.object(object: Object)
	return function(data): string?
		if type(data) ~= "table" then
			return `table expected, got {type(data)}`
		end

		for field, schema in object do
			local err = schema(data[field])

			if err then
				return err
			end
		end

		return nil
	end
end

function s.shape(object: Object)
	return s.intersection(s.object(object), function(data): string?
		for key, _ in data do
			if object[key] == nil then
				return `expected shape, got table`
			end
		end

		return nil
	end)
end

function s.union(...)
	local schemas = { ... }

	return function(data): string?
		for _, schema in schemas do
			if schema(data) == nil then
				return nil
			end
		end

		return "union expected, got no match"
	end
end

function s.intersection(...)
	local schemas = { ... }

	return function(data): string?
		for _, schema in schemas do
			local err = schema(data)

			if err then
				return err
			end
		end

		return nil
	end
end

function s.optional(schema)
	return function(data): string?
		return if data == nil then nil else schema(data)
	end
end

-- Roblox types
function s.enum(enum: Enum)
	return function(data): string?
		if typeof(data) ~= "EnumItem" then
			return `Enum expected, got {typeof(data)}`
		end

		return if data.EnumType == enum then nil else `Enum.{type} expected, got Enum.{data}`
	end
end

function s.dataType(name)
	return function(data)
		return if typeof(data) == name then nil else `{name} expected, got {typeof(data)}`
	end
end

function s.instance(name)
	return function(data): string?
		if typeof(data) ~= "Instance" then
			return `Instance expected, got {typeof(data)}`
		end

		return if data:IsA(name) then nil else `{name} expected, got {typeof(data)}`
	end
end

function s.class(name)
	return function(data): string?
		if typeof(data) ~= "Instance" then
			return `Instance expected, got {typeof(data)}`
		end

		return if data.ClassName == name then nil else `{name} expected, got {typeof(data)}`
	end
end

return s :: S
