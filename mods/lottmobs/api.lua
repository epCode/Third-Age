
minetest.register_entity("lottmobs:wieldview", {
	initial_properties = {
		hp_max           = 1,
		visual           = "wielditem",
		physical         = false,
		is_visible       = false,
		pointable        = false,
		collide_with_objects = false,
		static_save = false,
		collisionbox = {-0.21, -0.21, -0.21, 0.21, 0.21, 0.21},
		selectionbox = {-0.21, -0.21, -0.21, 0.21, 0.21, 0.21},
		visual_size  = {x = 0.51, y = 0.51},
	}
})


local wieldview_luaentites = {}

local function update_wieldview_entity(object)
	local luaentity = wieldview_luaentites[object]
	if luaentity and luaentity.object:get_yaw() then
		local objlua = object
		if object:get_luaentity() then
			objlua = object:get_luaentity()
		end
		local item = objlua:get_wielded_item():get_name()

		if item == luaentity._item then return end

		luaentity._item = item


		local item_def = minetest.registered_items[item]
		luaentity.object:set_properties({
			glow = item_def and item_def.light_source or 0,
			wield_item = item,
			is_visible = item ~= ""
		})
	else
		-- If the object is running through an unloaded area,
		-- the wieldview entity will sometimes get unloaded.
		-- This code path is also used to initalize the wieldview.
		-- Creating entites from minetest.register_on_joinobject
		-- is unreliable as of Minetest 5.6
		local obj_ref = minetest.add_entity(object:get_pos(), "lottmobs:wieldview")
		if not obj_ref then return end
		obj_ref:set_attach(object, "Wield_Item")
		wieldview_luaentites[object] = obj_ref:get_luaentity()
	end
end


--helper functions:
local function shortest_term_of_yaw_rotation(self, rot_origin, rot_target, nums)

	if not rot_origin or not rot_target then
		return
	end

	rot_origin = math.deg(rot_origin)
	rot_target = math.deg(rot_target)

	if rot_origin < rot_target then
		if math.abs(rot_origin-rot_target)<180 then
			if nums then
				return rot_target-rot_origin
			else
				return 1
			end
		else
			if nums then
				return -(rot_origin-(rot_target-360))
			else
				return -1
			end
		end
	else
		if math.abs(rot_origin-rot_target)<180 then
			if nums then
				return rot_target-rot_origin
			else
				return -1
			end
		else
			if nums then
				return (rot_target-(rot_origin-360))
			else
				return 1
			end
		end
	end
end


local function get_wander_dir(pos, dir, length, self)
  dir.y = 0

  --ir = vector.add(dir, minetest.yaw_to_dir(self.object:get_yaw()))

  dir = vector.normalize(dir)
  local most_popular_dir = dir
  local most_popular_dir_num = -10
  for i=0, 20 do
    local current_dir = vector.rotate_around_axis(dir, vector.new(0,1,0), 18*i)


    local raycast = minetest.raycast(pos, vector.add(pos, vector.multiply(current_dir, length)), false, false)
    local distance = length
    for hitpoint in raycast do
      if hitpoint.type == "object" and hitpoint.ref:get_luaentity() and hitpoint.ref:get_luaentity() == self then
      else
        if hitpoint.type == "object" then
          distance = vector.distance(hitpoint.ref:get_pos(), pos)
        else
          distance = vector.distance(hitpoint.above, pos)
        end
      end
    end
    local finalscore = (distance*2)+(vector.dot(dir, current_dir)+4)
    if finalscore > most_popular_dir_num then
      most_popular_dir = current_dir
      most_popular_dir_num = finalscore
    end
  end

  return most_popular_dir
end


local function set_bone_position(obj, bone, pos, rot)
	local current_pos, current_rot = obj:get_bone_position(bone)
	local pos_equal = not pos or vector.equals(vector.round(current_pos), vector.round(pos))
	local rot_equal = not rot or vector.equals(vector.round(current_rot), vector.round(rot))
	if not pos_equal or not rot_equal then
		obj:set_bone_position(bone, pos or current_pos, rot or current_rot)
	end
end


local function dir_to_pitch(dir)
	--local dir2 = vector.normalize(dir)
	local xz = math.abs(dir.x) + math.abs(dir.z)
	return -math.atan2(-dir.y, xz)
end


local function _line_of_sight(pos1, pos2, ents, self)
	raycast = minetest.raycast(pos1, pos2, ents, false)
	for hitpoint in raycast do

		if hitpoint.type == "object" and self then
			if hitpoint.ref and not self:is_us(hitpoint.ref) then
				return hitpoint
			end
		else
			return hitpoint
		end

	end
	return
end

local function line_of_sight(pos1, pos2) -- custom l-o-s using raycast
	local raycast = minetest.raycast(pos1, pos2, false, false)
	for hitpoint in raycast do
		return false
	end
	return true
end


local function calculate_armor_value(armor)
	armor = ItemStack(armor)
	return
	(minetest.get_item_group(armor:get_name(), "armour_fleshy")+
	minetest.get_item_group(armor:get_name(), "armour_pierce")+
	minetest.get_item_group(armor:get_name(), "armour_blunt")+
	minetest.get_item_group(armor:get_name(), "armour_stab"))/4
end


local dir_to_yaw = minetest.dir_to_yaw


----------PERSONALITY TRAITS

local personality_traits = {
  frugality = 1, ----- (1-10) how carful with resources he is (the only negetive personality trait)
  honesty = 1, ------- (1-10) how honest he is
  dominance = 1, ----- (1-10) how assertive and dominant he is
  daringness = 1, ---- (1-10) how risky he is
  charisma = 1, ------ (1-10) how charming he is
  intelligence = 1, -- (1-10) effects the pathfinding and other
  patience = 1, ------ (1-10) effects how fast he is disatisfied
}



local personality_words = { -- used for easy reading
  frugality = {normal="frugal",non="careful"},
  honesty = {normal="honest",non="dishonest"},
  dominance = {normal="dominant",non="submissive"},
  daringness = {normal="daring",non="laid-back"},
  charisma = {normal="charismatic",non="repulsive"},
  intelligence = {normal="intelligent",non="unintelligent"},
  patience = {normal="patient",non="impatient"},
}

-----------------------------------------
----------PHYSICAL TRAITS

local physical_traits = {
  strength = 1, ----- (1-10)
    --[[ effects:
      knockback and damage of non ranged
      speed of arrows
      size
    ]]
  speed = 1, ------- (1-10)
    --[[ effects:
      hit interval
      speed of reloading ranged
      sprinting speed
    ]]
  stamina = 1, ----- (1-10)
    --[[ effects:
      the duration of full out running
      slight increase to running speed
    ]]
  constitution = 1, ---- (1-10)
    --[[ effects:
      health regeneration
      amount of health
      decreases damage done by natural means (such as falling, lava, drowning etc.)
    ]]
  dexterity = 1, ------ (1-10)
    --[[ effects:
      slight increase to non ranged damage
      accuracy with ranged
        slight increase to ranged reloading speed
    ]]
  keen_sense = 1, ------ (1-10)
    --[[ effects:
      view_range
    ]]
}



local physical_words = { -- used for easy reading
  strength = {normal="strong",non="weak"},
  speed = {normal="fast",non="slow"},
  stamina = {normal="resilient",non="fragile"},
  constitution = {normal="constitutional",non="vunerable"},
  dexterity = {normal="dexterous",non="clumsy"},
  keen_sense = {normal="sensitive",non="obtuse"},
}
-----------------------------------------

local color_tags = {
	extremely = minetest.colorize("#072e00", "Extremely"),
	very = minetest.colorize("#24f000", "Very"),
	saddly = minetest.colorize("#ff0000", "Saddly"),
	quite = minetest.colorize("#ff5e00", "Quite"),
	rarely = minetest.colorize("#ff8e00", "Rarely"),
	sometimes = minetest.colorize("#f0ff00", "Sometimes"),
	somewhat = minetest.colorize("#baff00", "Somewhat"),
	too = minetest.colorize("#ff0073", "Too"),
	fairly = minetest.colorize("#ff4a00", "Fairly"),
	pretty = minetest.colorize("#9df000", "Pretty"),
}


local scale_chart = { -- easy reading
  color_tags.too.."\n-  @non\n---------------------------------------",
  color_tags.saddly.."\n-  @non\n---------------------------------------",
  color_tags.quite.."\n-  @non\n---------------------------------------",
  color_tags.fairly.."\n-  @non\n---------------------------------------",
  color_tags.rarely.."\n-  @normal\n---------------------------------------",
  color_tags.sometimes.."\n-  @normal\n---------------------------------------",
  color_tags.somewhat.."\n-  @normal\n---------------------------------------",
  color_tags.pretty.."\n-  @normal\n---------------------------------------",
  color_tags.very.."\n-  @normal\n---------------------------------------",
  color_tags.extremely.."\n-  @normal\n---------------------------------------",
}




lottmobs.CharacterClass = {}
lottmobs.MetaCharacterClass = {__index = lottmobs.CharacterClass}
local CharacterClass = lottmobs.CharacterClass

lottmobs.MobClass = {}
lottmobs.MetaMobClass = {__index = lottmobs.MobClass}
local MobClass = lottmobs.MobClass



--*************************--
--*****CHARACTER funcs*****--
--*************************--

	--Caracter class funcs----------:

function CharacterClass:set_trait(trait, value)
	if self.personality_traits[trait] then
		self.personality_traits[trait] = value
	else
	  self.physical_traits[trait] = value
	end
end


function CharacterClass:get_trait(trait)
  return self.personality_traits[trait] or self.physical_traits[trait]
end


function CharacterClass:get_readable_trait(trait)
  local focused_trait = self.personality_traits[trait] or self.physical_traits[trait]
  if not focused_trait then
    print("No such personality trait!")
    return
  end
  local readable_trait = scale_chart[focused_trait]
  if self.personality_traits[trait] then
    readable_trait = readable_trait:gsub("@normal", personality_words[trait].normal)
    readable_trait = readable_trait:gsub("@non", personality_words[trait].non)
  else
    readable_trait = readable_trait:gsub("@normal", physical_words[trait].normal)
    readable_trait = readable_trait:gsub("@non", physical_words[trait].non)
  end

  return readable_trait
end


--Caracter misc----------:

local function initialize_character_object() -- create base character
  local character = {
    level = 1, -- increased with slain creatures and experience
    name = "", -- given name
    surname = "", -- surname if applicable
		texture = nil,
    personality_traits = {
      frugality = 1, ----- (1-10) how carful with resources he is (the only negetive personality trait)
      honesty = 1, ------- (1-10) how honest he is
      dominance = 1, ----- (1-10) how assertive and dominant he is
      daringness = 1, ---- (1-10) how risky he is
      charisma = 1, ------ (1-10) how charming he is
      intelligence = 1, -- (1-10) effects the pathfinding and other
      patience = 1, ------ (1-10) effects how fast he is disatisfied
    },
    physical_traits = {
      strength = 1,
      speed = 1,
      stamina = 1,
      constitution = 1,
      dexterity = 1,
      keen_sense = 1,
    },
    decision_making = {
      health_min_percent = 20, -- the minimum pecentage of health at which the mob will continue to fight, after that it will run.
    },
    history = {
      met_characters = {}, -- sentient creatures or players that have not been necessarily been slain, but met (contains known info on them)
      memorable_events = {}, -- possibly unnecessary?
      slain_creatures = {}, -- list of slain creatures
      slain_players = {}, -- experience gain is far more than creatures
    },
  }
  character = setmetatable(character, lottmobs.MetaCharacterClass)
  return character
end


local function get_random_trait_num()
	local num = 0
	for i=1, 5 do
		if i == 1 then
			num = num + math.random(1,2)
		else
			num = num + math.random(0,2)
		end
	end
	return num
end


function lottmobs.create_character()
  local character = initialize_character_object()


  for trait,value in pairs(personality_traits) do
    character.personality_traits[trait] = get_random_trait_num()
  end
  for trait,value in pairs(physical_traits) do
    character.physical_traits[trait] = get_random_trait_num()
  end
  return character
end

--*******************--
--*****MOB funcs*****--
--*******************--



-- Mob Class functions--------:

function MobClass:get_max_health()
	return self.base_health * (self.character:get_trait("constitution") * 0.12+0.14)
end

function MobClass:is_us(obj)
	local luaentity = obj:get_luaentity()
	if luaentity and luaentity.local_mob_id == self.local_mob_id then
		return true
	end
end


function MobClass:get_xz_vel()
	local vel = self.object:get_velocity()
	return math.abs(vel.x)+math.abs(vel.z)
end


function MobClass:distance_to(pos, ignore_y)
	local selfpos = self.pos
	if ignore_y then
		selfpos.y = 0
		pos.y = 0
	end
	return vector.distance(pos, selfpos)
end


function MobClass:show_character_form(clicker, formextra)


	local slist = ""
	local personality_traits_readable = {}
	local physical_traits_readable = {}
	for trait,value in pairs(personality_traits) do
		table.insert(personality_traits_readable,self.character:get_readable_trait(trait))
	end
	for trait,value in pairs(physical_traits) do
		table.insert(physical_traits_readable,self.character:get_readable_trait(trait))
	end
	table.insert(physical_traits_readable,self.health.."\n-  Health\n---------------------------------------")
	table.insert(physical_traits_readable,self:get_view_range().."\n-  View Range\n---------------------------------------")

	slist_personality = "hypertext[0.5,1.5;3,9;castables;<style><style color=#ffffff font=bold size=13>"..table.concat(personality_traits_readable,"\n").."</style>]"
	slist_physical = "hypertext[4.5,1.5;3,9;castables;<style><style color=#ffffff font=bold size=13>"..table.concat(physical_traits_readable,"\n").."</style>]"

	local formspec =
    "formspec_version[4]"..
    "size[8,13]"..

    "background[-0.5,-0;9,13;bg_paper.png]"..
		"image[0.4,1.4;3.2,9.2;lottmobs_ui_dark.png^[opacity:50]]"..
		slist_personality..
		"image[4.4,1.4;3.2,9.2;lottmobs_ui_dark.png^[opacity:50]"..
		slist_physical..

    "image[4.7,11.6;3.2,1.2;lottmobs_ui_dark.png]"..
    "image_button_exit[4.8,11.7;3,1;paper_button.png;close;Close]"..(formextra or "")
	minetest.show_formspec(clicker:get_player_name(), "lottmobs:character_form", formspec)
end

function MobClass:set_velocity(vel, offset)-- adds velocity based on the orientation of the object, offset turns that vector in degrees
  offset = offset or 0
  local dir = minetest.yaw_to_dir(self.object:get_yaw()+math.rad(offset))
	if self.swimming then
		self._swim_timer = self._swim_timer - (dtime or 0.05)

		self.object:add_velocity(
			vector.multiply(
				dir,
				vel*(self.character.physical_traits.speed/10+1) * (self._swim_timer/self.swim_rate)
			)
		)
		if self._swim_timer < 0 then

			self:set_animation("swim_idle")
			minetest.after(0.1, function() -- janky fix to play the same anim over again
				if self and self.object and self.object:get_velocity() then
					self:set_animation("swim")
				end
			end)
			self._swim_timer = self.swim_rate
		end
	else
		local _retreat_quick = self._retreat_quick or 0.5
		local rot = 0
		if self._retreat_quick and _retreat_quick < 0.5 then
			rot = 1.57/2
		elseif self._retreat_quick then
			rot = 3.14
		end
		self.object:add_velocity(
			vector.multiply(
				vector.rotate_around_axis(dir, vector.new(0,1,0), rot),
				vel*(self.character.physical_traits.speed/10+1)*(_retreat_quick*2)
			)
		)
	end
end


function MobClass:get_eye_pos(islocal)
	subtrand = 0
	if self.swimming then
		subtrand = self.eye_height
	end
	if islocal then
		return vector.new(0,self.eye_height-subtrand,0)
	else
		return vector.add(self.pos,vector.new(0,self.eye_height-subtrand,0))
	end
end


function MobClass:look_at(pos)
  local dir = vector.direction(self:get_eye_pos(), pos)
  local pitch = math.deg(dir_to_pitch(dir))
  local yaw = dir_to_yaw(dir)
  local localyaw = self.object:get_yaw()
  local oldp,oldr = self.object:get_bone_position(self.head_bone)
	local offset = vector.zero()
	local current_anim = self:get_current_animation()
	if self.animations[current_anim] and self.animations[current_anim].head_offset then
		offset = self.animations[current_anim].head_offset
	end
	oldr.y = ((oldr.y+180)%360)-180
  local yawfade = shortest_term_of_yaw_rotation(self, math.rad(oldr.y), -yaw, true)

	local head_rot = vector.new(vector.multiply(oldr, 0.9))
  if vector.dot(minetest.yaw_to_dir(localyaw), minetest.yaw_to_dir(yaw)) > 0.5 and not self.swimming then -- limit head rot to 45 degrees
		head_rot = vector.add(vector.new(-pitch,
      oldr.y+math.deg(localyaw)+yawfade
    , 0), offset)
	elseif self.swimming and self.head_bone_swim_rot then
		head_rot = self.head_bone_swim_rot
  end
	set_bone_position(self.object, self.head_bone, self.head_bone_pos, head_rot)
end


function MobClass:set_pos(pos)
	self.object:set_pos(pos)
	self.pos = pos
end

function MobClass:get_mood()
	if self.mood == "leisure" then
		return 1
	elseif self.mood == "determined" then
		return 2
	elseif self.mood == "disturbed" then
		return 3
	end
end

function MobClass:set_yaw(yaw, dtime)-- adds velocity based on the orientation of the object, offset turns that vector in degrees
  dtime = dtime or 0.05
  local selfyaw = self.object:get_yaw()

  selfyaw = math.rad(math.deg(selfyaw)%360)

  yaw = math.rad(math.deg(yaw)%360)

  local rot = shortest_term_of_yaw_rotation(self, selfyaw, yaw)
  local rot2 = shortest_term_of_yaw_rotation(self, selfyaw, yaw, true)

	local mood = self:get_mood()

  if math.abs(rot2) > 10 then
    self.object:set_yaw(selfyaw+
      (rot*(self.character.physical_traits.speed/20+0.5)/5*(mood/3))
    )
  end
end


function MobClass:go_to(pos, dtime) -- a hybrid way of going to a point without proper pathfinding
	local point_dir = vector.direction(self:get_eye_pos(),pos)
	wander_dir = get_wander_dir(self:get_eye_pos(), point_dir, 6, self) -- this is seeing if there are any obstructive obsticals
	local pushdir = self:_personal_space()

	if not vector.equals(pushdir, vector.zero()) then
		wander_dir = vector.normalize(vector.add(pushdir,wander_dir))
	end

	wander_dir = dir_to_yaw(wander_dir)

	self:set_yaw(wander_dir, dtime)
end


function MobClass:set_anim_speed(mult)
	self.object:set_animation_frame_speed(self:get_xz_vel()*6*mult)
end


function MobClass:_personal_space() -- returns the direction in which easiest to escape crowding
	local push_vector = vector.zero()
	local objs = minetest.get_objects_inside_radius(self.pos, self.personal_space)
	for _,obj in ipairs(objs) do
		local luaentity = obj:get_luaentity()
		if luaentity and luaentity ~= self and luaentity._cmi_is_mob then
			push_vector = vector.add(push_vector, vector.direction(obj:get_pos(), self.pos))
		end
	end
	push_vector = vector.normalize(push_vector)
	return push_vector
end


function MobClass:get_current_animation()
	local current_anim = self.object:get_animation()
	if not self.animations or not current_anim then return end
	for name,value in pairs(self.animations) do
		if current_anim.x == value.anim.x
	  and current_anim.y == value.anim.y then
			return name
		end
	end
	return ""
end



function MobClass:set_animation(name, fspeed, fade)
  if not self.animations[name] then return end

	fade = fade or 0.4

	local loop = true
	if self.animations[name].loop == false then
		loop = false
	end
  local current_anim = self.object:get_animation()
  if current_anim and current_anim.x == self.animations[name].anim.x -- make sure we aren't setting the current animation again
  and current_anim.y == self.animations[name].anim.y
  and current_anim.frame_speed == self.animations[name].anim.z
	and loop
  then return end

	self.object:set_animation({x=self.animations[name].anim.x, y=self.animations[name].anim.y}, self.animations[name].anim.z,fade,loop)
end


function MobClass:is_swimming(pos)
	local swimming_node = minetest.get_node(pos or self.pos)
	local noddef = minetest.registered_nodes[swimming_node.name]
	if noddef.liquidtype == "source" or noddef.liquidtype == "flowing" then
		return true
	end
end



function MobClass:get_swim_depth(pos)
	local pos = pos or self.pos
	pos = vector.add(pos, vector.new(0,-0.6,0)) -- make the caracter float just on the edge of the water to not swim under
	local depth = 0
	local floor_depth = 0
	for i=1, 16 do
		if not self:is_swimming(vector.add(pos, vector.new(0,i,0))) then
			break
		end
		depth = i
	end
	for i=1, 16 do
		if not self:is_swimming(vector.add(pos, vector.new(0,-i,0))) then
			break
		end
		floor_depth = i
	end
	return depth, floor_depth
end


function MobClass:remove_texture_mod(mod)
	local full_mod = ""
	local remove = {}
	for i=1, #self.texture_mods do
		if self.texture_mods[i] ~= mod then
			full_mod = full_mod .. self.texture_mods[i]
		else
			table.insert(remove, i)
		end
	end
	for i=#remove, 1 do
		table.remove(self.texture_mods, remove[i])
	end
	self.object:set_texture_mod(full_mod)
end


function MobClass:add_texture_mod(mod)
	local full_mod = ""
	local already_added = false
	for i=1, #self.texture_mods do
		if mod == self.texture_mods[i] then
			already_added = true
		end
		full_mod = full_mod .. self.texture_mods[i]
	end
	if not already_added then
		full_mod = full_mod .. mod
		table.insert(self.texture_mods, mod)
	end
	self.object:set_texture_mod(full_mod)
end


function MobClass:die()
	self:set_animation("die")
	self.on_die()
	self.health = 0
	local back_or_front = 0
	local rot = self.object:get_rotation()
	if self.swimming then
		back_or_front = math.rad(math.random(0,1)*180)
		self.yaw_vel=(math.random(100)-50)/40
	end
	self.object:set_rotation(vector.new(0,rot.y,back_or_front))
	self.object:set_bone_position(self.head_bone, self.head_bone_pos, self.death_head_bone_rot)
	self.dead = true
	if wieldview_luaentites[self.object] then
		wieldview_luaentites[self.object].object:remove()
	end
	wieldview_luaentites[self.object] = nil
end


function MobClass:check_for_death()
	if self.health and self.health <= 0 then
		if not self.dead then -- unless we have already run the die func, run it
			self:die()
		elseif self:get_current_animation() ~= "die" then
			self:set_animation("die", nil, 0)
		end
		return true
	end
	return
end


function MobClass:damage(tool_capabilities, puncher, dir)

	local num = tool_capabilities.damage_groups and tool_capabilities.damage_groups.fleshy or 1

	self.health = self.health-num-(self.armor_prot/100*num)

	if self:check_for_death() then return end

	if dir then
		self.object:add_velocity(vector.multiply(dir, 10))
	end


	self.damaged_timer = 0.2
	self:add_texture_mod(self.damage_texture_modifier)
end

function MobClass:inv_add_item(item) -- inserts an itemstack
	table.insert(item:to_string(),self.inventory)
end

function MobClass:get_best_melee() -- returns returns index in inv
	local best_weapon
	local best_weapon_ind
	for _,_item in ipairs(self.inventory) do
		local item = ItemStack(_item)
		local def = minetest.registered_tools[item:get_name()]
		if def then
			local current_value = item:get_tool_capabilities().damage_groups
			local best_weapon_value = best_weapon and best_weapon:get_tool_capabilities() and best_weapon:get_tool_capabilities().damage_groups
			if not best_weapon or best_weapon and current_value.fleshy and best_weapon_value.fleshy and current_value.fleshy > best_weapon_value.fleshy then
				best_weapon = item
				best_weapon_ind = _
			end
		end
	end
	return best_weapon_ind
end

function MobClass:get_best_armor() -- returns returns index in inv
	local final_list = {}
	local types = {"armour_helmet","armour_chestplate","armour_leggings","armour_boots"}
	for _,armor_type in ipairs(types) do
		local best_armor_val
		local best_armor_ind
		for _,_item in ipairs(self.inventory) do
			local item = ItemStack(_item)
			local def = minetest.registered_tools[item:get_name()]
			if def and minetest.get_item_group(item:get_name(), armor_type) ~= 0 then
				if not best_armor_val or best_armor_val < calculate_armor_value(item) then
					print(item:get_name()..":"..calculate_armor_value(item))
					best_armor_val = calculate_armor_value(item)
					best_armor_ind = _
				end
			end
			if best_armor_ind then
				table.insert(final_list, best_armor_ind)
			end
		end
	end
	return final_list
end


function MobClass:get_wielded_item() -- returns returns index in inv
	return ItemStack(self.wielditem)
end


function MobClass:set_wielded_item(item) -- returns returns index in inv
	self.wielditem = ItemStack(item):to_string()
end

function MobClass:get_view_range()
	return self.view_range*(self.character:get_trait("keen_sense")/10+0.5)
end

-- State Functions functions

local function do_jump(self, moveresult)
  local dir = minetest.yaw_to_dir(self.object:get_yaw())
  local vel = self.object:get_velocity()
  local need_to_jump_pos = vector.add(vector.add(self.pos, vector.new(0,0.4,0)), vector.add(vector.multiply(vel, 0.3), dir))
  local blockernode = vector.add(need_to_jump_pos, vector.new(0,1,0))

  local node = minetest.get_node(need_to_jump_pos)
  local blockernode = minetest.get_node(blockernode)
  local nodedef = minetest.registered_nodes[node.name]
  local nodedefblockernode = minetest.registered_nodes[blockernode.name]
  if nodedef and nodedef.walkable and moveresult.touching_ground and not nodedefblockernode.walkable then
    self.object:set_velocity(vector.new(vel.x,self.jump_height*5,vel.z))
  end
end


local function head_logic(self)
  if self.target_pos then
    self:look_at(self.target_pos)
  end
end


local function movement(self,dtime,moveresult)

  local vel = self.object:get_velocity()

	if self._retreat_quick then
		self._retreat_quick = self._retreat_quick - dtime
		if self._retreat_quick < 0 then
			self._retreat_quick = nil
		end
	end


  if self.state == "wander" then -- create wander behavior
    self.mood = "leisure"

		if self.target_pos and self:distance_to(self.target_pos, true) < 2 or not self.target_pos then
			if math.random(10) == 1 then
				self.target_pos = vector.add(self.pos, vector.new(math.random(-10,10), 0, math.random(-10,10)))
			end
		end
	elseif self.state == "runaway" then
		if self.target then
			self.target_pos = vector.add(self.pos, vector.multiply(vector.direction(self.target:get_pos(), self.pos), 10))
		elseif self.target_pos then
			self.target_pos = vector.add(self.pos, vector.multiply(vector.direction(self.target_pos, self.pos), 10))
		else
			self:set_velocity(0.6, dtime)
		end
	elseif self.target then
		self.mood = "disturbed"
  end
	if self.character.decision_making.health_min_percent/100*self:get_max_health() >= self.health then
		self.state = "runaway"
	end



	local anim_speed = 1
  if self.target_pos then -- go towards a target_pos if we deem it safe
		if not self.swimming or (self._swim_timer/self.swim_rate) > 0.5 then
			self:go_to(self.target_pos, dtime)
		end
    if self.mood == "leisure" then
      self:set_velocity(0.15, dtime)
			anim_speed = 0.5
    elseif self.mood == "determined" then
      self:set_velocity(0.4, dtime)
    elseif self.mood == "disturbed" then
      self:set_velocity(0.6, dtime)
    end
  end
	self:set_anim_speed(anim_speed)
end


local function do_animations(self)
	local animspeed
	if not self.swimming then

		local rot = self.object:get_rotation()
		if rot.x ~= 0 then
			self.object:set_rotation(vector.new(0,rot.y,rot.z))
		end


		if self.mood == "leisure" or
		self.mood == "determined" or
		self.mood == "disturbed"
		then
			if self.mood == "disturbed" and self:get_xz_vel() > 0.3 then
				if self._hit_anim then
					self:set_animation("run_mine", nil, 0)
				else
					self:set_animation("run")
					animspeed = 1.5
				end
			elseif self.mood ~= "disturbed" and self:get_xz_vel() > 0.3 then
				if self._hit_anim then
					self:set_animation("walk_mine", nil, 0)
				else
					self:set_animation("walk")
					animspeed = 1
				end
			else
				if self._hit_anim then
					self:set_animation("mine", nil, 0)
				else
					self:set_animation("idle")
				end
			end
		end
	end
end


local function do_physics(self)
	if self.swimming then


		local prefered_depth = self.swim_depth
		local final_depth, low_depth = self:get_swim_depth()
		if self.target_pos then
			local target_depth =  self:get_swim_depth(self.target_pos)
			if target_depth > final_depth then
				prefered_depth = target_depth
			end
		end

		if low_depth < 3 then
			prefered_depth = low_depth-2
		end

		if self:check_for_death() then -- if were dead and on the water then float
			prefered_depth = 0
		else
			local land = self:is_swimming(
				vector.add(self.pos, minetest.yaw_to_dir(self.object:get_yaw()))
			)

			if not land then
				prefered_depth = -1
			end
		end

		self.object:set_acceleration({x=0,y=(final_depth-prefered_depth)*1.3,z=0}) -- make sure we are on the right swim depth
		self.object:set_velocity(vector.new(self.vel.x, self.vel.y/1.1, self.vel.z))
	else
		self.object:set_acceleration({x=0,y=-self.gravity,z=0})
	end
	local vel = self.object:get_velocity()
	if not (self.swimming and self:check_for_death()) then
		if self:check_for_death() then
			self.object:set_velocity(vector.new(vel.x*0.95, vel.y, vel.z*0.95))
		else
			self.object:set_velocity(vector.new(vel.x*0.85, vel.y, vel.z*0.85))
		end
	else
		if self.yaw_vel then -- some rotation while simming in death for more imersion
			local yaw = self.object:get_yaw()
			self.object:set_properties({automatic_rotate=self.yaw_vel})
			self.yaw_vel = self.yaw_vel/1.01
		end
		self.object:set_velocity(vector.new(vel.x*0.99, vel.y, vel.z*0.99))
	end
end


local function do_attack(self)
	for _,obj in pairs(minetest.get_objects_inside_radius(self.pos, self:get_view_range())) do

		if self:is_us(obj) then return end

		local dir_to = vector.direction(self:get_eye_pos(),obj:get_pos())
		local dir = minetest.yaw_to_dir(self.object:get_yaw())
		local dot = (vector.dot(dir_to, dir)+1)*0.5
		if (obj:get_luaentity() and obj:get_luaentity()._cmi_is_mob or obj:is_player()) and self.field_of_view <= dot then
			if obj:is_player() and not (obj:get_hp() <= 0) or
			obj:get_luaentity() and obj:get_luaentity()._cmi_is_mob and not obj:get_luaentity().dead then
				self.target = obj
			end
		end
	end
end


local function mob_step(self, dtime, moveresult) -- defines on_step for mobs

	local vel = self.object:get_velocity()

	if self.vel and self.vel then
		local speed_change = math.abs(math.abs(self.vel.y)-math.abs(vel.y))*self.fall_damage
		if speed_change > 10 then
			self:damage({damage_groups={fleshy=speed_change-9}})
		end
	end

	self.pos = self.object:get_pos()
	self.vel = vel
	if self.damaged_timer ~= -100 and self.damaged_timer < 0 then -- if the damaged timer is below zero, reset texture mod
		self.damaged_timer = -100
		self:remove_texture_mod(self.damage_texture_modifier)
	elseif self.damaged_timer ~= -100 then
		self.damaged_timer = self.damaged_timer - dtime
	end

	self.hit_interval_timer = self.hit_interval_timer or 0
	self.hit_interval_timer = self.hit_interval_timer+dtime

	--tick timer for each mob
	self.mobtimer = self.mobtimer or 0
	self.mobtimer = self.mobtimer+1

	if self.mobtimer % 6 == 5 then -- one out of every 6 ticks

		if self:check_for_death() then
			if self:is_swimming() and not self.yaw_vel then
				self.swimming = true
				self:die() -- run the die function again now that we are out of the water
			end
		end
	end

	do_physics(self)
	if self:check_for_death() then return	end

  self.do_step(self, dtime, moveresult)





  do_jump(self, moveresult)
	do_animations(self)
  movement(self,dtime,moveresult)
  head_logic(self)
	self:get_current_animation()

  local pos = self.pos

	-- runs a veriable amount of ticks based on speed trait
	local speed = math.abs(self.character:get_trait("speed")-10)/8+0.2
	if self.hit_interval_timer > speed and self.target then
		self.hit_interval_timer = 0
		local target_eye_height = self.target:get_properties().eye_height or 0
		local ppos = vector.add(self.target:get_pos(), vector.new(0,target_eye_height*0.5,0))
		local dist
		local hit_pos = vector.add(vector.multiply(vector.direction(self:get_eye_pos(), ppos), self.reach), self:get_eye_pos())
		local los = _line_of_sight(self:get_eye_pos(),hit_pos,true, self) -- custom raycast line of sight

		if los and los.ref then -- use racast to see if mob can hit target

			local target = los.ref

			if (vector.dot(minetest.yaw_to_dir(self.object:get_yaw()), minetest.yaw_to_dir(minetest.dir_to_yaw(vector.multiply(vector.direction(self:get_eye_pos(), ppos), vector.new(1,0,1)))))+1)/2 < self.field_of_view then return end -- if to far turned way don't punch

			local wielditem = {
				full_punch_interval = 0.1,
				damage_groups = {fleshy = 1},
			}

			if self.wielditem then
				wielditem = self:get_wielded_item():get_tool_capabilities()
			end

			self._retreat_quick = 0.7 -- run back for one second

			self._hit_anim = true
			minetest.after(0.4, function()
				if self and self._hit_anim and self.object:get_yaw() and target and target:get_pos() then
					self._hit_anim = false
						if target:get_luaentity() and target:get_luaentity()._cmi_is_mob then
							target:get_luaentity():damage(wielditem, self.object, vector.zero())
						else
							target:punch(self.object,
							1,
							wielditem,
							self.pos)
						end

					local tarvel = target:get_velocity()
					local kb = vector.zero()

					if math.abs(tarvel.x) < 10 then
						kb.x = 10
					end
					if math.abs(tarvel.y) < 10 then
						kb.y = 10
					end
					if math.abs(tarvel.z) < 10 then
						kb.z = 10
					end
					target:add_velocity(vector.multiply(vector.direction(self.pos, ppos), tarvel))
				end
			end)
		end
	end



  -- runs ever 20 ticks
  if self.mobtimer % 20 == 1 then

		if self.objective == "" and not self.target and not self.state == "runaway" then
			self.state = "wander"
		elseif self.target then
			self.state = "attack"
		end

		update_wieldview_entity(self.object)

		if not self.target then
			do_attack(self)

		elseif self.target:is_player() and
		self.target:get_hp() <= 0 or

		self.target:get_luaentity() and
		self.target:get_luaentity()._cmi_is_mob and
		self.target:get_luaentity().health <= 0 or

		vector.distance(self.target:get_pos(), self.pos) > self:get_view_range() then
			 --if we no longer have a living target then set target to nil
			self.target = nil
			self.target_pos = nil
		end



		local swim_depth, swim_low = self:get_swim_depth()
		local swimpos = self.pos
		if not self.swimming then
			swimpos = self:get_eye_pos()
		end
		if self:is_swimming(swimpos) then
			self.swimming = true
		else
			self.swimming = false
		end

		if self.target then
			local target_pos = vector.add(self.target:get_pos(), vector.new(0,1.4,0))
			if self.target:is_player() then
				target_pos = vector.add(self.target:get_pos(), vector.new(0,self.target:get_properties().eye_height,0))
			end
	    if line_of_sight(vector.add(pos, vector.new(0,0.1,0)), target_pos) or
	    line_of_sight(vector.add(pos, vector.new(0,0.4,0)), target_pos) or
	    line_of_sight(vector.add(pos, vector.new(0,0.8,0)), target_pos) or
	    line_of_sight(vector.add(pos, vector.new(0,1.3,0)), target_pos)
	    then
	      self.target_pos = target_pos
	    end
	  end





  end
end





--******Register Mob******--

function lottmobs.register_mob(name, def) -- main function to create new mob

    local mob_define = {
    ---------Default engine Cells

    hp_min = def.hp_min or 10, -- unused by our mobs. all health functions are in the lua
    hp_max = def.hp_max or 10, -- unused by our mobs. all health functions are in the lua
    visual = def.visual or "sprite",
    mesh = def.mesh,
		textures = def.textures,
    textures_random = def.textures_random or {{""}},
    physical = def.physical or true,
    collide_with_objects = def.collide_with_objects or false,
    collision_box = def.collision_box or {-0.3,-0,-0.3,0.3,1.6,0.3},
    selection_box = def.selection_box or {-0.3,-0,-0.3,0.3,1.6,0.3},
    collisionbox = def.collision_box or {-0.3,-0,-0.3,0.3,1.6,0.3},
    selectionbox = def.selection_box or {-0.3,-0,-0.3,0.3,1.6,0.3},
    pointable = def.pointable or true,
    visual_size = def.visual_size or {x=1,y=1},
    spritediv = def.spritediv or {x=1,y=1},
    initial_sprite_basepos = def.initial_sprite_basepos or {x=0,y=0},
    use_texture_alpha = def.use_texture_alpha,
    is_visible = def.is_visible or true,
    makes_footstep_sound = def.makes_footstep_sound or true,
    automatic_rotate = def.automatic_rotate,
    stepheight = def.stepheight or 0,
    --automatic_face_movement_dir = def.automatic_face_movement_dir or 0.0,
    --automatic_face_movement_max_rotation_per_sec = def.automatic_face_movement_max_rotation_per_sec or -1,
    backface_culling = def.backface_culling or true,
    glow = def.glow or 0,
    nametag = def.nametag or "",
    static_save = def.static_save or true,
    show_on_minimap = def.show_on_minimap,
		damage_texture_modifier = "^[colorize:#ff0000:120",
    -----------Custom Mob Cells

		-----------CLASS/RACE stuff
		race = def.race or "man",
		faction = def.faction or "gondor",
		faction_group = def.faction_group or "minas_tirith",

    ----------- MOVMENT/ATTACK
		texture_mods = {},
		fall_damage = def.fall_damage or 1,
		damaged_timer = 0,
		death_head_bone_rot = def.death_head_bone_rot or vector.new(90,0,0), -- what rotation the head will go to when dead
		head_bone_swim_rot = def.head_bone_swim_rot,
		armor_prot = 0,
		base_health = def.base_health or 20,
    gravity = def.gravity or 9.81, -- gravity strength (none if nil or 0)
    max_speed = def.max_speed or 3, -- All-out sprint speed
    run_speed = def.run_speed or 2, -- Purousful walking
    default_speed = def.default_speed or 1, -- default wander speed
    jump_height = def.jump_height or 1, -- in block height, eg. value of 2 jumps over two blocks etc.
    view_range = def.view_range or 20, -- distance which the mob can see (effected by keen_sense)
    field_of_view = def.field_of_view or 0.4, -- how far to the sides the mob can see. 0 is nonexistant, 1 is 360 view so (0-1)
		_swim_timer = 0,
		swim_rate = def.swim_rate or 3, -- make sure you swim rate is at least a little longer than the swim animation otherwise they will be out of sync
		swim_depth = def.swim_depth or 1,
    --eg. a value of 180 would see all around, 45 would only see a quarter chunk in front of them.
    reach = def.reach or 1, -- the maximum length that they can strike
    base_damage = def.base_damage or 1, -- damage inflicted without a weapon
    --(used with strength to calculate overall damage)

    can_use_ranged = def.can_use_ranged or false,
    ranged_skill = def.ranged_skill or 1, -- base skill with ranged based on mob race.
    --(used with dexterity to calculate overall skill)

    ranged_reload_interval = def.ranged_reload_interval or 3, --base interval in seconds between each shot.
    --(used with dexterity to calculate overall interval)

		inventory = {
			ItemStack("lottitems:dirt"):to_string(),
			ItemStack("lotttools:test_sword_med"):to_string(),
			ItemStack("lotttools:test_sword_strong"):to_string(),
			ItemStack("lotttools:test_sword_weak"):to_string(),
			ItemStack("lottarmour:boots_wood"):to_string(),
			ItemStack("lottarmour:chestplate_wood"):to_string(),
		},

		--------------MISC


		pos = vector.zero(),
		vel = vector.zero(),
		_cmi_is_mob = true,

    --------------- ANIMATION

		_textures = nil,
    animations = def.animations or {},
    head_bone = def.head_bone or "Head_Control",
    head_bone_pos = def.head_bone_pos or vector.new(0,0,0),
    eye_height = def.eye_height or 1.4,
		personal_space = def.personal_space or 2,

    ----------------TASK/OBJECTIVE RELATED
    objective = "",


    ---Functions
    on_spawn = def.on_spawn or function() end,
    do_step = def.do_step or function() end,
    on_die = def.on_die or function() end,


    on_step = mob_step,
    on_activate = function(self, staticdata, dtime_s)

			self.local_mob_id = math.random(10000)/100

			self:set_wielded_item(self.inventory[self:get_best_melee()])
			--MAKE aRMOR WPORK
			self:get_best_armor()

			if not self._textures then
				self._textures = self.textures_random[math.random(#self.textures_random)]
			end


      self.object:set_armor_groups({immortal=1})
      local tmp = minetest.deserialize(staticdata)

      if tmp then
       for _,stat in pairs(tmp) do
         self[_] = stat
        end
      end

      if not self.character then
        self.character = lottmobs.create_character()
				self.health = self:get_max_health() -- largest multiple = 1.3 and lowest = 0.76
				self.character.texture = self._textures
      end
			self.object:set_properties({
				textures = self.character.texture
			})
			self.character = setmetatable(self.character, lottmobs.MetaCharacterClass)
      if not self._no_more_on_spawn and self.on_spawn(self, staticdata, dtime_s) then
        -- run per mob defined on_spawn(self, etc.) but if returned true don't run again
        self._no_more_on_spawn = true
      end
    end,
    get_staticdata = function(self)
      local tmp = {}
      for _,stat in pairs(self) do

        local t = type(stat)

        if  t ~= "function"
        and t ~= "nil"
        and t ~= "userdata"
        and _ ~= "_cmi_components" then
          tmp[_] = self[_]
        end
      end

      return minetest.serialize(tmp)
    end,
    on_punch = function(self, puncher, time_from_last_punch, tool_capabilities, dir, damage)
			if puncher:is_player() then
				local puncher_pos = puncher:get_pos()
				local witem = puncher:get_wielded_item()
				local range = minetest.registered_items[witem:get_name()].range or 4.5
				local raycast = minetest.raycast(vector.add(puncher_pos, vector.new(0,puncher:get_properties().eye_height,0)),
				vector.add(puncher_pos, vector.multiply(puncher:get_look_dir(), range/1.5)), true, false) -- try to get the same raycast for normal hitting with a 1.5 times shorter range
				local hit
				for hitpoint in raycast do
					if hitpoint.type == "object" and hitpoint.ref:get_luaentity() and hitpoint.ref:get_luaentity() == self then
						hit = true
					end
				end
				if not hit then return end
				self:damage({damage_groups={fleshy=math.random(5)}}, puncher, dir)
			else
				self:damage(tool_capabilities, puncher, dir)
			end

			return true
    end,
		on_rightclick = function(self, clicker)
			self:show_character_form(clicker)
		end,
  }

  minetest.register_entity(name, setmetatable(mob_define, lottmobs.MetaMobClass))
end
