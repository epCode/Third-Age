lottmobs.register_mob("lottmobs:man", {
  visual = "mesh",
  mesh = "lottmobs_man.b3d",
  textures = {"lottplayer_elf_mirkwood.png"},
  animations = {
    idle = vector.new(0,60,24), -- x and y are start and end points, z is anim speed
    idle_mine = vector.new(80,140,24), -- x and y are start and end points, z is anim speed
    walk = vector.new(160,200,24), -- x and y are start and end points, z is anim speed
    walk_mine = vector.new(220,260,24), -- x and y are start and end points, z is anim speed
    run = vector.new(280,319,40), -- x and y are start and end points, z is anim speed
    run_mine = vector.new(340,381,24), -- x and y are start and end points, z is anim speed
    crouch = vector.new(400,460,24), -- x and y are start and end points, z is anim speed
    crouch_mine = vector.new(480,540,24), -- x and y are start and end points, z is anim speed
    crouch_walk = vector.new(560,600,24), -- x and y are start and end points, z is anim speed
    crouch_walk_mine = vector.new(620,660,24), -- x and y are start and end points, z is anim speed
    swim = vector.new(680,750,24), -- x and y are start and end points, z is anim speed
  },
  head_bone_pos = vector.new(0,8,0),
  personal_space = 3,
})
