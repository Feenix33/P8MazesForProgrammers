pico-8 cartridge // http://www.pico-8.com
version 33
__lua__
-- linkball.p8
--[[
Bouncing balls are linked
]]--
-- colors
-- 0=black  1=dk blue  2=purple   3=dk green
-- 4=brown  5=dk grey  6=lgrey    7=white
-- 8=red    9=orange   10=yellow  11=lgreen
-- 12=lblue 13=mgrey   14=pink    15=peach
--

-- ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== =====
-- Globals
-- ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== =====
numballs = 0
run = false
totalballs=6
links = {}


-- ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== =====
-- Generics
-- ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== =====

function add_ball(_x,_y)
  add(balls, {
    x=_x,
    y=_y,
    c=flr(rnd(14))+1,
    r=4,
    vx=plusminus(),
    vy=plusminus(),
    draw=function(self)
      circfill(self.x, self.y, self.r, self.c)
    end,
    update=function(self)
      self.x+=self.vx
      self.y+=self.vy
      if self.x+self.r >= 128 then self.vx=-self.vx end
      if self.x-self.r <=   0 then self.vx=-self.vx end
      if self.y+self.r >= 128 then self.vy=-self.vy end
      if self.y-self.r <=   0 then self.vy=-self.vy end
    end,
    label=function(self, n)
      print(n, self.x-self.r/2, self.y-self.r/2, 0)
    end,
    adist=function(self, ball)
      return abs(self.x-ball.x) + abs(self.y-ball.y)
    end,
  })
end

function plusminus()
  x = flr(rnd(2))
  if x == 0 then x = -1 end
  return x
end

function ball_dist(a, b)
  return abs(a.x-b.x) + abs(a.y-b.y)
end


function compute_area(j, k, m)
  return ball_dist(balls[j], balls[k]) +
         ball_dist(balls[j], balls[m]) +
         ball_dist(balls[m], balls[k])
end

function compute_costs()
  --sets = {{{1,2,3},{4,5,6}}, {{1,2,4},{3,5,6}}, {{1,2,5},{4,3,6}}}
  sets = {{{1,2,3},{4,5,6}}, {{1,2,4},{3,5,6}}, {{1,2,5},{4,3,6}}, 
          {{1,2,6},{4,5,3}}, {{1,3,4},{2,5,6}}, {{1,3,5},{2,4,6}}, 
          {{1,3,6},{2,4,5}}, {{1,4,5},{2,3,6}}, {{1,4,6},{2,3,5}}, {{1,5,6},{2,3,4}}} 
  amin = 10000
  kmin = -1
  for k,s in pairs(sets) do
    area = compute_area(s[1][1], s[1][2], s[1][3]) + 
           compute_area(s[2][1], s[2][2], s[2][3])
    --printh (k..": "..": "..s[1][1]..","..s[1][2]..","..s[1][3]..
    --    " | "..s[2][1]..","..s[2][2]..","..s[2][3]..
    --    "  = "..area)
    if area < amin then
      amin = area
      kmin = k
    end
  end
  --printh("kmin="..kmin.."   amin="..amin .. "  "..
  --  sets[kmin][1][1]..","..
  --  sets[kmin][1][2]..","..
  --  sets[kmin][1][3])
  links[1] = sets[kmin][1]
  links[2] = sets[kmin][2]
end

-- ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== =====
-- base functions
-- ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== =====

function _init()
    -- print a runtime note
    --[[
    ]]--
    local div,m
    m=stat(94)
    if m < 10 then div=":0" else div=":" end
    printh (stat(93)..div..stat(94).." ---------------------------------------- ")

    srand(rnd(20))
    balls = {}
    for n=1,totalballs do
      add_ball(flr(rnd(100))+10, flr(rnd(100))+10)
    end
    run = false
    dtbl = {}
    for j=1,#balls do
      dtbl[j] = {}
      for k=1,#balls do
        dtbl[j][k] = 500
      end
    end
end

function _update()

    if btnp(0) then
      printh("Btn 0 left")
      printh ("links  "..
          links[1][1]..", "..links[1][2]..", "..links[1][3].."  "..
          links[2][1]..", "..links[2][2]..", "..links[2][3])

    elseif btnp(1) then
        printh("Btn 1 right")
        for j=1,#balls do
          balls[j].x = flr(rnd(100))+10
          balls[j].y = flr(rnd(100))+10
          balls[j].c=flr(rnd(14))+1
        end

    elseif btnp(2) then 
      printh("Btn 2 up")

    elseif btnp(3) then --printh("Btn 3 left")
      printh("toggle run")
      run = not run

    elseif btnp(4) then
      printh("Btn 4")

    elseif btnp(5) then
        printh("button 5")
    end

    if run then
      for b in all(balls) do
        b:update()
      end
    end
    compute_costs()
end

function _draw()
    cls()

    -- draw the links
    for j=1,2 do
      line(balls[links[j][1]].x, balls[links[j][1]].y, 
          balls[links[j][2]].x, balls[links[j][2]].y, balls[links[j][1]].c)
      line(balls[links[j][1]].x, balls[links[j][1]].y, 
          balls[links[j][3]].x, balls[links[j][3]].y, balls[links[j][3]].c)
      line(balls[links[j][2]].x, balls[links[j][2]].y, 
          balls[links[j][3]].x, balls[links[j][3]].y, balls[links[j][2]].c)
    end

    for j=1,#balls do
      balls[j]:draw()
      balls[j]:label(j)
    end
end

__gfx__
00000000000000004444444444444444444444444444444444444444444444444444444444444444999999994949494900000000000000000000000000000000
00000000000000004499994444999944499999944444444449494944449494944999999449999994444444444949494900000000000000000000000000000000
00700700000000004949949449499494444444444999999449494944449494944944449449444494999999994949494900000000000000000000000000000000
00077000000000004994499449994994499999944444444449494944449494944949449449449494444444444949494900000000000000000000000000000000
00077000000000004994499449949994444444444999999449494944449494944944949449494494999999994949494900000000000000000000000000000000
00700700000000004949949449499494499999944444444449494944449494944944449449444494444444444949494900000000000000000000000000000000
00000000000000004499994444999944444444444999999449494944449494944999999449999994999999994949494900000000000000000000000000000000
00000000000000004444444444444444444444444444444444444444444444444444444444444444444444444949494900000000000000000000000000000000
00000000000000000066660000000000000000000000000000000000006666000066660000000000006666000066660000666600000000000066660000666600
0000000000000000006666000000000000dddd000000000000000000006666000066660000000000006666000066660000666600000000000066660000666600
00000000666666d0006666000d666666006666000066666666666600666666000066666666666666666666006666666600666666666666660066660066666666
00000000666666d0006666000d666666006666000066666666666600666666000066666666666666666666006666666600666666666666660066660066666666
00000000666666d0006666000d666666006666000066666666666600666666000066666666666666666666006666666600666666666666660066660066666666
00000000666666d0006666000d666666006666000066666666666600666666000066666666666666666666006666666600666666666666660066660066666666
000000000000000000dddd0000000000006666000066660000666600000000000000000000666600006666000000000000666600000000000066660000666600
00000000000000000000000000000000006666000066660000666600000000000000000000666600006666000000000000666600000000000066660000666600
0000000000000000008778000000000000a77a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000077770000000000007777000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000008777cc7a00777700a7cc777800cccc0000aab00000aaaa00000baa00000bb00000e77a0000e77e0000a77e0000a77a00000000000000000000000000
0000000077777c770077770077c7777700c77c0000aaab0000aaaa0000baaa0000baab000077c70000777700007c7700007cc700000000000000000000000000
0000000077777c7700c77c0077c777770077770000aaab0000baab0000baaa0000aaaa000077c700007cc700007c770000777700000000000000000000000000
000000008777cc7a00cccc00a7cc77780077770000aab000000bb000000baa0000aaaa0000e77a0000a77a0000a77e0000e77e00000000000000000000000000
00000000000000000077770000000000007777000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000a77a0000000000008778000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000aa000000aa000000aa000000aa00000888800008888000088880000888800e77a0000e77e0000a77e0000a77a0000000000000000000000000000
00000000000cc000000aa000000ac000000ca0000088880000888800008888800888880077c70000777700007c7700007cc70000000000000000000000000000
00000000000aa000000aa000000aaa0000aaa00000caac00008888000088ac0000ca880077c700007cc700007c77000077770000000000000000000000000000
000000000077770000777700000770000007700000aaaa0000aaaa0000aaaaa00aaaaa00e77a0000a77a0000a77e0000e77e0000000000000000000000000000
00000000007777000077770000077000000770000bbbbbb00bbbbbb0000bb000000bb00000000000000000000000000000000000000000000000000000000000
0000000000a33a0000a33a00000a30000003a0000bbbbbb00bbbbbb0000bbbbaabbbb00000000000000000000000000000000000000000000000000000000000
00000000000330000003300000033000000330000abbbba00abbbba000bbbbb00bbbbb0000000000000000000000000000000000000000000000000000000000
00000000002222000022220000022200002220000880088008800880008800888800880000000000000000000000000000000000000000000000000000000000
00000000ccccccccccccccccccccccccccccccccccccccccc111111ccccccccccccccccccccccccc11111111ccc11cccccc11cccccc11cccccc11cccccc11ccc
00000000c111111cc1cccc1ccccccc1cc111111cc111111cc1cccc1cc111111cc1cccc1ccccccccc11111111cc1111cccc1111cccc1111cccc1111cccc1111cc
00000000cc1111ccc11cc11cccccc11cc11111ccc1cccc1cc111111cc1cccc1ccc1cc1cccccccccc11111111c1cccc1cc1cccc1cc1cccc1cc1cccc1cc1cccc1c
00000000ccc11cccc111111ccccc111cc1111cccc1c11c1cccccccccc1cccc1cccc11ccccccccccc1111111111cccc1111c11c1111c11c1111c11c1111cc1c11
00000000ccc11cccc111111cccc1111cc111ccccc1c11c1cc111111cc1cccc1cccc11ccccccccccc1111111111cccc1111c11c1111c1cc1111cc1c1111c11c11
00000000cc1111ccc11cc11ccc11111cc11cccccc1cccc1cc1cccc1cc1cccc1ccc1cc1cccccccccc11111111c1cccc1cc1cccc1cc1cccc1cc1cccc1cc1cccc1c
00000000c111111cc1cccc1cc111111cc1ccccccc111111cc111111cc111111cc1cccc1ccccccccc11111111cc1111cccc1111cccc1111cccc1111cccc1111cc
00000000cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc11111111ccc11cccccc11cccccc11cccccc11cccccc11ccc
ccc11cccdddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd00000000000000000000000000000000
cc1111ccddd99ddddd9999dddd9999dddd9dd9dddd9999dddd9999dddd9999dddd9999dddd9999ddd9d9999ddd9999dd00000000000000000000000000000000
c1cccc1cddd99dddddddd9ddddddd9dddd9dd9dddd9ddddddd9dddddddddd9dddd9dd9dddd9dd9ddd9d9dd9ddd9dd9dd00000000000000000000000000000000
11c1cc11ddd99dddddddd9ddddddd9dddd9dd9dddd9ddddddd9dddddddddd9dddd9dd9dddd9dd9ddd9d9dd9ddd9dd9dd00000000000000000000000000000000
11c11c11ddd99ddddd9999ddddd999dddd9999dddd9999dddd9999ddddddd9dddd9999dddd9999ddd9d9dd9ddd9dd9dd00000000000000000000000000000000
c1cccc1cddd99ddddd9dddddddddd9ddddddd9ddddddd9dddd9dd9ddddddd9dddd9dd9ddddddd9ddd9d9dd9ddd9dd9dd00000000000000000000000000000000
cc1111ccddd99ddddd9999dddd9999ddddddd9dddd9999dddd9999ddddddd9dddd9999dddd9999ddd9d9999ddd9999dd00000000000000000000000000000000
ccc11cccdddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd00000000000000000000000000000000
00000000000000000000000000000000000000000000000000666600000000000000000000000000000000000066660000666600000000000066660000666600
000000000000000000000000000000000000000000000000006666000000000000dddd0000000000000000000066660000666600000000000066660000666600
0000000000000000000000000000000000000000666666d0006666000d6666660066660000666666666666006666660000666666666666666666660066666666
0000000000000000000000000000000000000000666666d0006666000d6666660066660000666666666666006666660000666666666666666666660066666666
0000000000000000000000000000000000000000666666d0006666000d6666660066660000666666666666006666660000666666666666666666660066666666
0000000000000000000000000000000000000000666666d0006666000d6666660066660000666666666666006666660000666666666666666666660066666666
00000000000000000000000000000000000000000000000000dddd00000000000066660000666600006666000000000000000000006666000066660000000000
00000000000000000000000000000000000000000000000000000000000000000066660000666600006666000000000000000000006666000066660000000000
00666600000000000066660000666600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00666600000000000066660000666600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00666666666666660066660066666666000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00666666666666660066660066666666000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00666666666666660066660066666666000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00666666666666660066660066666666000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00666600000000000066660000666600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00666600000000000066660000666600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
