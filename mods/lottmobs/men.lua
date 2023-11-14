lottmobs.register_mob("lottmobs:man", {
  visual = "mesh",
  mesh = "lottmobs_man.b3d",
  textures_random = {
    {"elf_female_basic.png"},
    {"elf_female_basic_green.png"},
    {"galadriel.png"},
    {"rivendell_elf_armor_hair.png"},
    {"rivendell_elf_armor_helmet.png"},
    {"tauriel.png"},
  },
  collision_box = {-0.3,-0,-0.3,0.3,1.6,0.3},
  animations = {
    idle = {
      anim=vector.new(0,60,24)
    }, -- x and y are start and end points, z is anim speed
    idle_mine = {
      anim=vector.new(80,140,24)
    }, -- x and y are start and end points, z is anim speed
    walk = {
      anim=vector.new(160,200,24)
    }, -- x and y are start and end points, z is anim speed
    walk_mine = {
      anim=vector.new(220,260,24)
    }, -- x and y are start and end points, z is anim speed
    run = {
      anim=vector.new(280,319,40), head_offset = vector.new(-15,0,0)
    }, -- x and y are start and end points, z is anim speed
    run_mine = {
      anim=vector.new(340,381,24)
    }, -- x and y are start and end points, z is anim speed
    crouch = {
      anim=vector.new(400,460,24)
    }, -- x and y are start and end points, z is anim speed
    crouch_mine = {
      anim=vector.new(480,540,24)
    }, -- x and y are start and end points, z is anim speed
    crouch_walk = {
      anim=vector.new(560,600,24)
    }, -- x and y are start and end points, z is anim speed
    crouch_walk_mine = {
      anim=vector.new(620,660,24)
    }, -- x and y are start and end points, z is anim speed
    swim = {
      anim=vector.new(680,750,64), head_offset = vector.new(-90,0,0), loop = false
    }, -- x and y are start and end points, z is anim speed
    swim_idle = {
      anim=vector.new(680,680,24), head_offset = vector.new(-90,0,0)
    }, -- x and y are start and end points, z is anim speed
  },
  head_bone_pos = vector.new(0,8,0),
  personal_space = 2,
  swim_depth = 0,
  swim_rate = 2,
})
