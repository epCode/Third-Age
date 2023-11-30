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


minetest.register_tool("lotttools:test_sword_weak", {
	description = "a weak sword for test purpouses",
	inventory_image = "lotttools_pick.png",
	tool_capabilities = {

		damage_groups = {fleshy = 1},

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
minetest.register_tool("lotttools:test_sword_strong", {
	description = "a strong sword for test purpouses",
	inventory_image = "lotttools_pick.png",
	tool_capabilities = {

		damage_groups = {fleshy = 3},

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
minetest.register_tool("lotttools:test_sword_med", {
	description = "a medium sword for test purpouses",
	inventory_image = "lotttools_pick.png",
	tool_capabilities = {

		damage_groups = {fleshy = 2},

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
