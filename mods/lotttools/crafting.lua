local pattern_types = {
  axe = {
    blade = {
      {"m", "m", "m"},
      {"m", "m", ""},
    },
  },

 pickaxe = {
    blade = {
      {"m", "m", "m"},
      {"m", "", "m"},
    },
  },

  sword = {
    blade = {
      {"", "", "m"},
      {"", "m", ""},
      {"m", "", ""},
    },
  },

}

function lotttools.register_craft(name, def)
  local type = def.type
  if not pattern_types[type] then minetest.log("warning", "Trying to register invalid tool type: "..tostring(type)) end

  local blade_pattern = pattern_types[type].blade
  local material = def.material

  local theblade = {{},{},{}}

  for index,row in pairs(blade_pattern) do
    for i_,mat in pairs(blade_pattern[index]) do
      if mat ~= "" then
        theblade[index][i_] = material
      else
        theblade[index][i_] = ""
      end
    end
  end


  minetest.register_craft({
      output = name,
      recipe = def.craft_pattern or theblade,
  })
end
