# schema

*schema* is a minimal, highly composable runtime type checker for Roblox.

## Aim
- **Clean implementation**: Everything results in a function
- **Fast ship**: The library is a single file at *src/schema.luau*
- **Readable API**: The developer can figure out what each schema is about by just looking at its name

## Installation

*schema* is available on [wally](https://wally.run/package/post-ill/schema), so on [pesde](https://docs.pesde.dev/guides/dependencies/#wally-dependencies).
You can also just go to the latest release, pick the [script](https://github.com/post-ill/schema/blob/master/src/schema.luau) and drop it into your project ;)

## Usage

An schema is simply a function that expects a single argument and returns an error message in case something bad
happens.

```luau
local s = require(path.to.schema)

local yourType = s.whatever
local err = yourType(yourValue)

if not err then
   print("Your value matches your schema")
   return
end

print(`Schema error: {err}`)
```

## API

### 1. Primitives

| type        | accepts                  |
|-------------|--------------------------|
| `s.boolean` | `true` or `false`        |
| `s.integer` | numbers without decimals |
| `s.number`  | all numbers              |
| `s.string`  | all forms of string      |
| `s.any`     | anything                 |

### 2. Constraints

| type            | accepts                                                                     | example           |
|-----------------|-----------------------------------------------------------------------------|-------------------|
| `s.min(n)`      | numbers, strings or tables with a minimum size of `n` (inclusive)           | `s.min(5)`        |
| `s.max(n)`      | numbers, strings or tables with a maximum size of `n` (inclusive)           | `s.max(10)`       |
| `s.range(n, m)` | numbers, strings or tables with a size between `n` and `m` (both inclusive) | `s.range(5, 10)`  |
| `s.size(n)`     | strings or tables with a size of `n`                                        | `s.size(10)`      |
| `s.unsigned`    | numbers greater or equal to `0`                                             | `s.unsigned(0.5)` |

### 3. Combinators

| type                   | accepts                                                                                                                                                                                                                          | example                                                   |
|------------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|-----------------------------------------------------------|
| `s.array(t)`           | tables with consecutive integer keys whose elements match `t` schema                                                                                                                                                             | `s.array(s.integer)`                                      |
| `s.set(t, i?)`         | values matching `s.array(t)` schema with no duplicates based on `i` identity function. The callback defaults to `function(value) return value end`. Identity function allows storing complex objects while associating an unique key | `s.set(s.string)`                                         |
| `s.map(kt, vt)`        | regular tables whose keys matches `kt` schema and values `vt` schema                                                                                                                                                             | `s.map(s.string, s.boolean)`                              |
| `s.object(o)`          | tables matching at least all `o` keys and values                                                                                                                                                                                 | `s.object({ id = s.integer, vip = s.boolean })`           |
| `s.shape(o)`           | tables matching `s.object(o)` schema containing only `o` entries                                                                                                                                                                 | `s.shape({ key = s.string, value = s.number })`           |
| `s.union(...t)`        | values matching at least one of the `...t` schemas                                                                                                                                                                               | `s.union(s.literal("r"), s.literal("g"), s.literal("b"))` |
| `s.intersection(...t)` | values matching all `...t` schemas                                                                                                                                                                                               | `s.intersection(s.integer, s.unsigned)`                   |
| `s.optional(t)`        | values matching `t` or `nil`                                                                                                                                                                                                     | `s.optional(s.string)`                                    |

### 4. Roblox types

| type             | accepts                                   | example                        |
|------------------|-------------------------------------------|--------------------------------|
| `s.enum(e)`      | enum items of `e`                         | `s.enum(Enum.HumanoidRigType)` |
| `s.dataType(dt)` | data objects matching `dt`                | `s.dataType("Vector3")`        |
| `s.instance(c)`  | instances that match or inherit `c` class | `s.instance("GuiObject")`      |
| `s.class(c)`     | instance with class `c`                   | `s.class("Script")`            |

### Future plans

*schema* ended up looking more like [t](https://github.com/osyrisrblx/t/) than I expected. This is not a bad
thing at all, it's just something that happened. In a principle, it was supposed to have mixed explicit and
implicit typing (by explicit types meaning literals) using a builder `schema.build` function for instance.

```luau
local builtType = s.build({ -- This being a shape
   primitiveLiteral = 3.14,
   tuple = { s.number, s.integer, s.string },
   array = { s.number },
   set = { s.unique(s.number) }, -- Not really a thing, at that point just use s.set(type) lol
   map = { [s.string] = s.boolean },
   enum = Enum.HumanoidRigType,
   object = s.object({}) -- Objects could only be specified through this way
})
```

For the sake of consistency, combinators should also have to use this build function internally for the receiving types. At the
time **I decided to keep literals out**. If the library gets to somewhere I could maybe start thinking more about adding it
as a v2.

## Issues

Feel free to open an [issue](https://github.com/post-ill/schema/issues/new) if you find out that the library
is not behaving as expected or maybe you want a feature that would fit in.
