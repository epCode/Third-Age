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





function CharacterClass:set_trait(trait, value)
  self.personality_traits[trait] = value
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

local function initialize_character_object() -- create base character
  local character = {
    level = 1, -- increased with slain creatures and experience
    name = "", -- given name
    surname = "", -- surname if applicable
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
			if math.random(2) == 1 then
			else
			end
			self._swim_timer = self.swim_rate
		end
	else
		self.object:add_velocity(
			vector.multiply(
				dir,
				vel*(self.character.physical_traits.speed/10+1)
			)
		)
	end
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

local dir_to_yaw = minetest.dir_to_yaw

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
  if vector.dot(minetest.yaw_to_dir(localyaw), minetest.yaw_to_dir(yaw)) > 0.5 then -- limit head rot to 45 degrees
    set_bone_position(self.object, self.head_bone, self.head_bone_pos, vector.add(vector.new(-pitch,
      oldr.y+math.deg(localyaw)+yawfade
    , 0), offset))
	else
		set_bone_position(self.object, self.head_bone, self.head_bone_pos, vector.new(vector.multiply(oldr, 0.9)))
  end
end

local function head_logic(self)
  if self.target_pos then
    self:look_at(self.target_pos)
  end
end

function MobClass:set_pos(pos)
	self.object:set_pos(pos)
	self.pos = pos
end

function MobClass:set_yaw(yaw, dtime)-- adds velocity based on the orientation of the object, offset turns that vector in degrees
  dtime = dtime or 0.05
  local selfyaw = self.object:get_yaw()

  selfyaw = math.rad(math.deg(selfyaw)%360)

  yaw = math.rad(math.deg(yaw)%360)

  local rot = shortest_term_of_yaw_rotation(self, selfyaw, yaw)
  local rot2 = shortest_term_of_yaw_rotation(self, selfyaw, yaw, true)

  if math.abs(rot2) > 10 then
    self.object:set_yaw(selfyaw+
      (rot*(self.character.physical_traits.speed/20+0.5)/5)
    )
  end
end

local function movement(self,dtime,moveresult)
  local vel = self.object:get_velocity()

  self.mood = "leisure"

  self.object:set_velocity(vector.new(vel.x*0.85, vel.y, vel.z*0.85))
  if self.state == "wander" then
    -- WANDER code
  end





  if self.target_pos then -- go towards a target_pos if we deem it safe
		if not self.swimming or (self._swim_timer/self.swim_rate) > 0.5 then
			self:go_to(self.target_pos, dtime)
		end
    if self.mood == "leisure" then
      self:set_velocity(0.4, dtime)
    elseif self.mood == "determined" then
      self:set_velocity(0.5, dtime)
    elseif self.mood == "disturbed" then
      self:set_velocity(0.7, dtime)
    end
  end

end

function MobClass:get_xz_vel()
	local vel = self.object:get_velocity()
	return math.abs(vel.x)+math.abs(vel.z)
end

function MobClass:go_to(pos, dtime) -- a hybrid way of going to a point without proper pathfinding
	local point_dir = vector.direction(self:get_eye_pos(),pos)
	wander_dir = get_wander_dir(self:get_eye_pos(), point_dir, 6, self) -- this is seeing if there are any obstructive obsticals
	local pushdir = self:_personal_space()

	if not vector.equals(pushdir, vector.zero()) then
		wander_dir = vector.normalize(vector.add(pushdir,wander_dir))
	end

	self:set_yaw(dir_to_yaw(wander_dir), dtime)
end

function MobClass:set_anim_speed(mult)
	self.object:set_animation_frame_speed(self:get_xz_vel()*6*mult)
end

local function do_animations(self)
	local animspeed
	if self.swimming then

		local rot = self.object:get_rotation()
		self.object:set_rotation(vector.new(dir_to_pitch(self.vel),rot.y,rot.z))

	else

		local rot = self.object:get_rotation()
		if rot.x ~= 0 then
			self.object:set_rotation(vector.new(0,rot.y,rot.z))
		end

		if self.mood == "leisure" or
		self.mood == "determined" or
		self.mood == "disturbed"
		then
			if self.mood == "disturbed" and self:get_xz_vel() > 0.3 then
				self:set_animation("run")
				animspeed = 1.5
			elseif self.mood ~= "disturbed" and self:get_xz_vel() > 0.3 then
				self:set_animation("walk")
				animspeed = 1
			else
				self:set_animation("idle")
			end
		end
		if animspeed then
			self:set_anim_speed(1)
		end
	end
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

function MobClass:set_animation(name, fspeed)
  if not self.animations[name] then return end

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

	self.object:set_animation({x=self.animations[name].anim.x, y=self.animations[name].anim.y}, self.animations[name].anim.z,0.1,loop)

end

function MobClass:is_swimming(pos)
	local swimming_node = minetest.get_node(pos or self.pos)
	local noddef = minetest.registered_nodes[swimming_node.name]
	if noddef.liquidtype == "source" or noddef.liquidtype == "flowing" then
		return true
	end
end

local function line_of_sight(pos1, pos2)
	local raycast = minetest.raycast(pos1, pos2, false, false)
	for hitpoint in raycast do
		if hitpoint.type == "node" then
			return
		end
	end
	return true
end

function MobClass:get_swim_depth(pos)
	local pos = pos or self.pos
	local depth = 0
	local floor_depth = 0
	for i=0, 16 do
		if not self:is_swimming(vector.add(pos, vector.new(0,i,0))) then
			break
		end
		depth = i
	end
	for i=0, 16 do
		if not self:is_swimming(vector.add(pos, vector.new(0,-i,0))) then
			break
		end
		floor_depth = i
	end
	return depth, floor_depth
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
		self.object:set_acceleration({x=0,y=(final_depth-prefered_depth)*3,z=0}) -- make sure we are on the right swim depth
		self.object:set_velocity(vector.new(self.vel.x, self.vel.y/1.1, self.vel.z))
	else
		self.object:set_acceleration({x=0,y=-self.gravity,z=0})
	end
end

local function mob_step(self, dtime, moveresult) -- defines on_step for mobs
	self.pos = self.object:get_pos()
	self.vel = self.object:get_velocity() -- unused



  self.do_step(self, dtime, moveresult)


  --tick timer for each mob
  self.mobtimer = self.mobtimer or 0
  self.mobtimer = self.mobtimer+1

  if self.objective == "" then
    self.state = "wander"
  end

	do_physics(self)
  do_jump(self, moveresult)
  movement(self,dtime,moveresult)
  head_logic(self)
	do_animations(self)
	self:get_current_animation()

  local pos = self.pos


  -- runs ever 6 ticks
  if self.mobtimer % 6 == 1 then

		local swim_depth, swim_low = self:get_swim_depth()
		if self:is_swimming() then
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

    for _,obj in pairs(minetest.get_objects_inside_radius(self.pos, 40)) do
      if obj:is_player() then
        self.target = obj
      end
    end



  end

end


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

    -----------Custom Mob Cells

    ----------- MOVMENT/ATTACK
    gravity = def.gravity or 9.81, -- gravity strength (none if nil or 0)
    max_speed = def.max_speed or 3, -- All-out sprint speed
    run_speed = def.run_speed or 2, -- Purousful walking
    default_speed = def.default_speed or 1, -- default wander speed
    jump_height = def.jump_height or 1, -- in block height, eg. value of 2 jumps over two blocks etc.
    view_range = def.view_range or 20, -- distance which the mob can see (effected by keen_sense)
    field_of_view = def.field_of_view or 60, -- how far to the sides the mob can see.
    --eg. a value of 180 would see all around, 45 would only see a quarter chunk in front of them.
    reach = def.reach or 1, -- the maximum length that they can strike
    base_damage = def.base_damage or 1, -- damage inflicted without a weapon
    --(used with strength to calculate overall damage)

    can_use_ranged = def.can_use_ranged or false,
    ranged_skill = def.ranged_skill or 1, -- base skill with ranged based on mob race.
    --(used with dexterity to calculate overall skill)

    ranged_reload_interval = def.ranged_reload_interval or 3, --base interval in seconds between each shot.
    --(used with dexterity to calculate overall interval)

		--------------MISC

		_swim_timer = 0,
		swim_rate = def.swim_rate or 3, -- make sure you swim rate is at least a little longer than the swim animation otherwise they will be out of sync

		pos = vector.zero(),
		vel = vector.zero(),
		_cmi_is_mob = true,
		swim_depth = def.swim_depth or 1,

    --------------- ANIMATION

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



    on_step = mob_step,
    on_activate = function(self, staticdata, dtime_s)
			if not self.textures then
				self.object:set_properties({
					textures = self.textures_random[math.random(#self.textures_random)]
				})
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
      end
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
      return true
    end,
		on_rightclick = function(self, clicker)
			self:show_character_form(clicker)
		end,
  }

  minetest.register_entity(name, setmetatable(mob_define, lottmobs.MetaMobClass))
end
