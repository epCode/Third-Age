local chat = function(text)
  if type(text) == "table" then
    text = minetest.serialize(text)
  else
    text = tostring(text)
  end
  minetest.chat_send_all(text)
end

minetest.register_node("lotttools:tool_brace", {
  description = "Tool Brace",
  drawtype = "mesh",
  mesh = "lotttools_tool_brace.obj",
  tiles = {"lotttools_tool_brace.png"},
  visual_size = vector.new(0.5,0.5,0.5),
  paramtype2 = "4dir",
  groups = {axe = 1, hand = 2},
  sunlight_propagates = true,
  on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
    if minetest.get_item_group(itemstack:get_name(), "tool_blade") == 0 then return end

    local meta = minetest.get_meta(pos)
    meta:set_string("item", itemstack:get_name())

    local place_rot = minetest.get_node_or_nil(pos)
    if place_rot then
      place_rot = minetest.facedir_to_dir(place_rot.param2)
    else
      place_rot = vector.new(0,0,1)
    end
    chat(place_rot)
    local place_pos = vector.add(pos, vector.rotate_around_axis(vector.new(0,0.44,0.11), vector.new(0,1,0), vector.dir_to_rotation(place_rot).y))

    local obj = minetest.add_entity(place_pos, "lotttools:tool_brace_blade")
    obj:set_rotation(vector.new(0,vector.dir_to_rotation((place_rot)).y,math.rad(-45)))
    obj:get_luaentity()._node = pos
    obj:set_properties({textures={itemstack:get_name()}})

    itemstack:take_item()
    return itemstack
  end,
})

minetest.register_entity("lotttools:tool_brace_blade", {
  visual = "wielditem",
  textures = {"lotttools:sword_iron"},
  visual_size = vector.new(0.6,0.6,0.4),
  collisionbox = {
    -0.5,
    -0.5,
    -0.05,
    0.5,
    0.5,
    0.05,
  }
})

minetest.register_entity("lotttools:tool_brace_hilt", {
  visual = "wielditem",
  textures = {"air"},
  on_activate = function(self)
    minetest.after(0.1, function()
      if self._node then
        self.object:set_properties({minetest.get_meta(self._node):get_string("item")})
      else
        self.object:remove()
        return
      end
    end)
  end
})
