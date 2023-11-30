lottrings = {
  ring_funcs = {}
}




function lottrings.register_ring(name, def)
  minetest.register_craftitem("lottrings:"..name, { -- Testing Purpouses Only
    inventory_image = "lottrings_"..name..".png",
    groups = {armour_ring = 1},
    on_wear = def.on_wear,
    on_put_on = def.on_put_on or function() end,
    on_take_off = def.on_take_off or function() end,
  })
  lottrings.ring_funcs["lottrings:"..name] = {}
  lottrings.ring_funcs["lottrings:"..name].on_wear = def.on_wear
  lottrings.ring_funcs["lottrings:"..name].on_put_on = def.on_put_on
  lottrings.ring_funcs["lottrings:"..name].on_take_off = def.on_take_off
end

lottrings.register_ring("basic_power_ring", { -- Testing Purpouses Only
  on_wear = function(player)
  end,
  on_put_on = function(player)
    print("Put on!")
  end,
  on_take_off = function(player)
    print("Taken off!")
  end,
})

minetest.register_globalstep(function(dtime)
  for _,player in pairs(minetest.get_connected_players()) do
    local name = player:get_player_name()
    local inv = minetest.get_inventory({type="detached", name=name.."_armour"})
    local ring = inv:get_stack("armour", 6):get_name()
    if ring ~= "" and lottrings.ring_funcs[ring] then
      lottrings.ring_funcs[ring].on_wear(player)
    end
  end
end)
