lottrings = {
  ring_funcs = {}
}

--[[ Nazgul rings
the names if all nine nazgul are:
  Murazor -- The Witch King of Angmar
  Khamûl
  Dwar
  Ji Indur
  Akhorahil
  Hoarmurath
  Adunaphel
  Ren
  Uvatha

Khamûl being the only named by Tolkien himself,
the others are, however generally accepted,
finding their origin in an old Middle-Earth
series of role-play and card-trading games
produced by Iron Crown Enterprises
]]


function lottrings.register_ring(name, def)
  minetest.register_craftitem("lottrings:"..name, { -- Testing Purpouses Only
    inventory_image = "lottrings_"..name..".png",
    description = def.description or name:gsub("_", " "),
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

lottrings.register_ring("the_ring_of_murazor", { -- Testing Purpouses Only
  description = "The Ring of Power of Murazor",
  on_wear = function(player)
  end,
  on_put_on = function(player)
    minetest.chat_send_player(player:get_player_name(), minetest.colorize("#ff1111",
    "*** You feel sure that you shall not be able to remove The Ring of Power of Murazor and live. ***"
    ))
  end,
  on_take_off = function(player)
    player:punch(player, 1, {damage_groups={fleshy=1000}})
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
