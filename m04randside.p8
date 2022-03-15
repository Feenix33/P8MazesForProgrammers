pico-8 cartridge // http://www.pico-8.com
version 34
__lua__
--[[
]]--
--
-- 01 Try out drawing the maze sprits
-- 02 Binary Tree
-- 03 Sidewinder
-- 04 Random Sidewider
--
-- 0=black  1=dk blue  2=purple   3=dk green
-- 4=brown  5=dk grey  6=lgrey    7=white
-- 8=red    9=orange   10=yellow  11=lgreen
-- 12=lblue 13=mgrey   14=pink    15=peach
--
-- sprites
--  0-15
-- 16-31 maze n1 e2 s4 w8 if true then draw wall
-- 32-47 maze n1 e2 s4 w8 if true then draw thin wall
-- 48-63 numbers 0-15
-- 64-79 maze n1 e2 s4 w8 if true then draw space
-- 80-95 color blocks
--
--  +- -+- -+  > v   06 14 12 08 01
--  |- -+- -|  < ^   07 15 13 02 04
--  +_ _+_ _+  - |   03 11 09 10 05
-- 
-- ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== =====

dn=1
de=2
ds=4
dw=8
nrow=8
ncol=nrow
sbase=16 -- maze
-- sbase=48 -- numbers
-- sbase=80 -- colors
grid={}
gridlines=false
runprint=true

-- ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== =====
function get_1x(mx) return flr(rnd(mx))+1 end
function binomial()
  n=0
  while rnd() > 0.5 do n+=1 end
  return n
end

function algo04() --random number sidewider
  function process(c, r, cnt)
    --printh("c="..c.." r="..r.." cnt="..cnt)
    for n=1,cnt-1 do
      add_east(c+n-1,r)
    end
    for n=1,cnt-1 do
      add_west(c+n,r)
    end
    off = get_1x(cnt)
    x = c-1 + off
    --if cnt!=off then printh("cnt="..cnt.." off="..off.." x="..x) end
    add_north(x,r)
    add_south(x,r-1)
  end
  ncol = #grid[1]
  for r=#grid,2,-1 do
    c=1
    while c <= ncol do
      count=get_1x(4)
      --printh("c="..c.." count="..count.." "..ncol)
      if c+count > ncol then count = ncol-c+1 end
      process(c,r,count)
      c+=count
    end
  end
  for c=1,#grid[1]-1 do
    add_east(c,1)
    add_west(c+1,1)
  end
end

-- ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== =====
function algo03() -- sidewinder
  function carve_east(c,r,count)
    add_east(c,r)
    if count>0 then
      add_west(c,r)
    end
  end
  function end_run(c,r,count)
    if count==0 then
      add_north(c,r)
      add_south(c,r-1)
    else
      add_west(c,r)
      local dc = flr(rnd(count+1))
      local newc = c-dc
      printh(c.."  "..newc.."  "..dc.."  "..count)
      add_north(newc,r)
      add_south(newc,r-1)
      --printh(c..", "..r.."   "..count)
    end
  end
  for r=#grid,2,-1 do
    count=0
    for c=1,#grid[r]-1 do
      if heads() then
        carve_east(c,r,count)
        count+=1
      else
        end_run(c,r,count)
        count=0
      end
    end
    end_run(#grid[r],r,count)
  end
  for c=1,#grid[1]-1 do
    add_east(c,1)
    add_west(c+1,1)
  end
end

-- ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== =====
function add_north(c,r)
    if r<=1 then return false end
    grid[c][r] += 1
    --printh("+n "..c.." "..r)
    return true
end
function add_east(c,r)
    if c>=#grid then return false end
    grid[c][r] += 2
    --printh("+e "..c.." "..r)
    return true
end
function add_south(c,r)
    if r>=#grid then return false end
    grid[c][r] += 4
    --printh("+s "..c.." "..r)
    return true
end
function add_west(c,r)
    if c<=1 then return false end
    grid[c][r] += 8
    --printh("+w "..c.." "..r)
    return true
end

-- ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== =====
function algo02() -- binary tree
  for c=1,#grid do
    for r=1,#grid[c] do
      x=flr(rnd(2)) 
      if x==1 then
        if add_north(c,r) then 
          add_south(c,r-1) 
        elseif add_east(c,r) then 
          add_west(c+1,r)
        end
      else
        if add_east(c,r) then
          add_west(c+1,r)
        elseif add_north(c,r) then
          add_south(c,r-1)
        end
      end
    end
  end
end

-- ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== =====
function heads() -- head or tails
    return flr(rnd(2))==1
end

function grid_to_map()
  for c=1,#grid do
    for r=1,#grid[c] do
      mset(c-1,r-1,grid[c][r]+sbase)
    end
  end
end

function clear_map()
  grid={}
  for c=1,ncol do
    grid[c] = {}
    for r=1,nrow do
      grid[c][r] = 0
    end
  end
end

-- ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== =====
function _init()
  -- print a runtime note
  if runprint then
    local div,m m=stat(94) if m < 10 then div=":0" else div=":" end
    printh (stat(93)..div..stat(94).." ---------------------------------------- ")
  end

  generate = algo04

  -- init the map
  clear_map()
  generate()
  grid_to_map()
end

function _update()

  if btnp(0) then
    printh("Btn 0 left")
    mx=0
    mn=10
    for j=1,1000 do
      x = flr(rnd(10))+1
      if x > mx then mx=x end
      if x < mn then mn=x end
    end
    printh ("max="..mx.."  min="..mn)



  elseif btnp(1) then
    printh("Btn 1 right")
    mx = 0
    a = {0, 0, 0}
    a[0] = 0
    for j=1,1000 do 
      x = binomial()
      if x <= 3 then a[x] += 1 end
      if x > mx then mx = x end
    end
    for j=0,3 do
      printh("a["..j.."]="..a[j])
    end
    printh("mx="..mx)

  elseif btnp(2) then 
    --printh("Btn 2 up")
    printh("random distribution check")
    cnt = {0, 0, 0}
    for j=1,1000 do
      n = get_1x(2)
      cnt[n] += 1
    end
    for j=1,3 do
      printh("cnt["..j.."]="..cnt[j])
    end

  elseif btnp(3) then
    printh("Btn 3 down")

  elseif btnp(4) then
    --printh("Btn 4 = cv")
    clear_map()
    generate()
    grid_to_map()

  elseif btnp(5) then
    --printh("Btn 5 = nm")
    gridlines=not gridlines
  end
end

function _draw()
  cls()
  mapdraw(0, 0, 0, 0, ncol, ncol)
  if gridlines then
    fillp(0b1010010110100101.1)
    for c=1,ncol+1 do
      for r=1,nrow+1 do
        line(0,(r-1)*8,(ncol)*8-1,(r-1)*8,6)
      end
      line((c-1)*8,0,(c-1)*8,nrow*8,6)
    end
    fillp()
  end
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
00999900000099000099990000999900009000000099990000999900009999000099990000999900090999900099099009099990090999900909000009099990
00900900000009000000090000000900009009000090000000900000009009000090090000900900090900900009009009000090090000900909009009090000
00900900000009000000090000000900009009000090000000900000000009000090090000900900090900900009009009000090090000900909009009090000
00900900000009000099990000099900009999000099990000999900000009000099990000999900090900900009009009099990090099900909999009099990
00900900000009000090000000000900000009000000090000900900000009000090090000000900090900900009009009090000090000900900009009000090
00999900000009000099990000999900000009000099990000999900000009000099990000999900090999900009009009099990090999900900009009099990
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000dddddddddd0000dddddddddddd0000dddddddddddd0000dddddddddddd000000dddddddddd0000dddddddddddd0000dddddddddddd0000dd00000000
00000000dddddddddd0000dddddddddddd0000dddddddddddd0000dddddddddddd000000dddddddddd0000dddddddddddd0000dddddddddddd0000dd00000000
0000000000000000000000dd000000dd0000000000000000000000dd000000dddd000000dd000000dd0000dddd0000dddd000000dd000000dd0000dd00000000
0000000000000000000000dd000000dd0000000000000000000000dd000000dddd000000dd000000dd0000dddd0000dddd000000dd000000dd0000dd00000000
0000000000000000000000dd000000dd0000000000000000000000dd000000dddd000000dd000000dd0000dddd0000dddd000000dd000000dd0000dd00000000
0000000000000000000000dd000000dd0000000000000000000000dd000000dddd000000dd000000dd0000dddd0000dddd000000dd000000dd0000dd00000000
00000000dd0000dddd0000dddd0000dddddddddddddddddddddddddddddddddddd000000dd000000dd0000dddd0000dddddddddddddddddddddddddd00000000
00000000dd0000dddd0000dddd0000dddddddddddddddddddddddddddddddddddd000000dd000000dd0000dddd0000dddddddddddddddddddddddddd00000000
00000000111111112222222233333333444444445555555566666666777777778888888899999999aaaaaaaabbbbbbbbccccccccddddddddeeeeeeeeffffffff
00000000111111112222222233333333444444445555555566666666777777778888888899999999aaaaaaaabbbbbbbbccccccccddddddddeeeeeeeeffffffff
00000000111111112222222233333333444444445555555566666666777777778888888899999999aaaaaaaabbbbbbbbccccccccddddddddeeeeeeeeffffffff
00000000111111112222222233333333444444445555555566666666777777778888888899999999aaaaaaaabbbbbbbbccccccccddddddddeeeeeeeeffffffff
00000000111111112222222233333333444444445555555566666666777777778888888899999999aaaaaaaabbbbbbbbccccccccddddddddeeeeeeeeffffffff
00000000111111112222222233333333444444445555555566666666777777778888888899999999aaaaaaaabbbbbbbbccccccccddddddddeeeeeeeeffffffff
00000000111111112222222233333333444444445555555566666666777777778888888899999999aaaaaaaabbbbbbbbccccccccddddddddeeeeeeeeffffffff
00000000111111112222222233333333444444445555555566666666777777778888888899999999aaaaaaaabbbbbbbbccccccccddddddddeeeeeeeeffffffff