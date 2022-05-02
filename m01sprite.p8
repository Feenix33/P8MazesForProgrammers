pico-8 cartridge // http://www.pico-8.com
version 34
__lua__
--[[
]]--
--
-- 01 Try out drawing the maze sprits
--
-- 0=black  1=dk blue  2=purple   3=dk green
-- 4=brown  5=dk grey  6=lgrey    7=white
-- 8=red    9=orange   10=yellow  11=lgreen
-- 12=lblue 13=mgrey   14=pink    15=peach
--
-- sprites
--  0-15
-- 16-31 maze n1 e2 s4 w8 if true then draw wall
-- 32-63 maze n1 e2 s4 w8 if true then draw thin wall
-- 64-79 maze n1 e2 s4 w8 if true then draw space
--
--  +- -+- -+  > v   06 14 12 08 01
--  |- -+- -|  < ^   07 15 13 02 04
--  +_ _+_ _+  - |   03 11 09 10 05
-- 
-- ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== =====

nrow=2
ncol=16
sbase = 16


-- ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== =====
function _init()
  -- print a runtime note
  if true then
    local div,m m=stat(94) if m < 10 then div=":0" else div=":" end
    printh (stat(93)..div..stat(94).." ---------------------------------------- ")
  end

  -- init the map
  --[[for c=0,ncol-1 do
    for r=0,nrow-1 do
      s=flr(rnd(16)) + sbase
      mset(c,r,s)
    end
  end
  ]]
  --  +- -+- -+  > v   06 14 12 08 01
  --  |- -+- -|  < ^   07 15 13 02 04
  --  +_ _+_ _+  - |   03 11 09 10 05
  ray = {
    { 0, 1, 2, 3, 4, 5, 6, 7, 8, 9,10,11,12,13,14,15},
    { 0, 0, 6,10,14,10,12, 0, 0, 0, 0, 0, 4, 0, 0, 0},
    { 0, 0, 5, 0, 5, 0, 5, 0, 0, 0, 0, 0, 5, 0, 0, 0},
    { 0, 0, 7,10,15,10,13, 0, 0, 0, 2,10,15,10, 8, 0},
    { 0, 0, 5, 0, 5, 0, 5, 0, 0, 0, 0, 0, 5, 0, 0, 0},
    { 0, 0, 5, 0, 5, 0, 5, 0, 0, 0, 0, 0, 5, 0, 0, 0},
    { 0, 0, 3,10,11,10, 9, 0, 0, 0, 0, 0, 1, 0, 0, 0},
  }
  printh("ray #="..#ray[1])
  for x=1,#ray do
    for y=1,#ray[x] do
      s = ray[x][y] + sbase
      mset(y-1, x-1, s)
    end
  end
  nrow=#ray
  ncol=#ray[1]
end

function _update()

  if btnp(0) then
    printh("Btn 0 left")

  elseif btnp(1) then
    printh("Btn 1 right")

  elseif btnp(2) then 
    printh("Btn 2 up")

  elseif btnp(3) then
    printh("Btn 3 down")

  elseif btnp(4) then
    printh("Btn 4 = cv")

  elseif btnp(5) then
    printh("Btn 5 = nm")
  end
end

function _draw()
  cls()
  --[[ fillp(0x33cc.8)
  rect(0, 0, 127, 126, 10)
  fillp() ]]--
  mapdraw(0, 0, 0, 0, ncol, ncol)
end

-->8
-- tab1
function one()
end

function oneb()
end

__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
33333333330000333333333333000033333333333300003333333333330000333333333333000033333333333300003333333333330000333333333333000033
33333333330000333333333333000033333333333300003333333333330000333333333333000033333333333300003333333333330000333333333333000033
33333333330000333300000033000000330000333300003333000000330000000000003300000033000000000000000000000033000000330000000000000000
33333333330000333300000033000000330000333300003333000000330000000000003300000033000000000000000000000033000000330000000000000000
33333333330000333300000033000000330000333300003333000000330000000000003300000033000000000000000000000033000000330000000000000000
33333333330000333300000033000000330000333300003333000000330000000000003300000033000000000000000000000033000000330000000000000000
33333333333333333333333333333333330000333300003333000033330000333333333333333333333333333333333333000033330000333300003333000033
33333333333333333333333333333333330000333300003333000033330000333333333333333333333333333333333333000033330000333300003333000033
44444444400000044444444440000004444444444000000444444444400000004444444400000004444444440000000044444444000000044444444400000000
44444444400000044000000040000000400000044000000440000000400000000000000400000004000000000000000000000004000000040000000000000000
44444444400000044000000040000000400000044000000440000000400000000000000400000004000000000000000000000004000000040000000000000000
44444444400000044000000040000000400000044000000440000000400000000000000400000004000000000000000000000004000000040000000000000000
44444444400000044000000040000000400000044000000440000000400000000000000400000004000000000000000000000004000000040000000000000000
44444444400000044000000040000000400000044000000440000000400000000000000400000004000000000000000000000004000000040000000000000000
44444444400000044000000040000000400000044000000440000000400000000000000400000004000000000000000000000004000000040000000000000000
44444444444444444444444444444444400000044000000440000000400000004444444444444444444444444444444400000004000000040000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000dddddddddd0000dddddddddddd0000dddddddddddd0000dddddddddddd000000dddddddddd0000dddddddddddd0000dddddddddddd0000dd00000000
00000000dddddddddd0000dddddddddddd0000dddddddddddd0000dddddddddddd000000dddddddddd0000dddddddddddd0000dddddddddddd0000dd00000000
0000000000000000000000dd000000dd0000000000000000000000dd000000dddd000000dd000000dd0000dddd0000dddd000000dd000000dd0000dd00000000
0000000000000000000000dd000000dd0000000000000000000000dd000000dddd000000dd000000dd0000dddd0000dddd000000dd000000dd0000dd00000000
0000000000000000000000dd000000dd0000000000000000000000dd000000dddd000000dd000000dd0000dddd0000dddd000000dd000000dd0000dd00000000
0000000000000000000000dd000000dd0000000000000000000000dd000000dddd000000dd000000dd0000dddd0000dddd000000dd000000dd0000dd00000000
00000000dd0000dddd0000dddd0000dddddddddddddddddddddddddddddddddddd000000dd000000dd0000dddd0000dddddddddddddddddddddddddd00000000
00000000dd0000dddd0000dddd0000dddddddddddddddddddddddddddddddddddd000000dd000000dd0000dddd0000dddddddddddddddddddddddddd00000000