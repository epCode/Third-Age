lotttools = {}

dofile(minetest.get_modpath("lotttools").."/crafting.lua")

function lotttools.register_tool(name, def)

	local modname = minetest.get_current_modname()

	local type = def.type

	minetest.register_tool(modname..":"..name, {
		description = def.description or "Unknown Tool",
		inventory_image = modname.."_"..name..",png",
		tool_capabilities = def.tool_capabilities
	})

	lotttools.register_craft(modname..":"..name, def)
end

lotttools.register_tool("iron_sword", {
	description = "Iron Sword",
	material = "lottitems:apple",
	type = "sword",
	tool_capabilities = {
		full_punch_interval = 0.5,
		groupcaps = {
			plant = {maxlevel = 0, uses = 100,
				times = {[1] = 0.5, [2] = 0.75, [3] = 1, [4] = 0.2}
			},
		},
	},
})

-- Tmp dig all pick!
minetest.register_tool("lotttools:omni_pick", {
	description = "Digs all!",
	inventory_image = "lotttools_pick.png",
	tool_capabilities = {
		full_punch_interval = 0.5,
		groupcaps = {
			pickaxe = {maxlevel = 0, uses = 100,
				times = {[1] = 0.5, [2] = 0.75, [3] = 1, [4] = 0.2}},
			axe = {maxlevel = 0, uses = 100,
				times = {[1] = 0.5, [2] = 0.75, [3] = 1, [4] = 0.2}},
			plant = {maxlevel = 0, uses = 100,
				times = {[1] = 0.5, [2] = 0.75, [3] = 1, [4] = 0.2}},
		}
	},
})
