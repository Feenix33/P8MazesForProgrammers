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
-- 05 Dijkstra's Algorithm (fixed maze)
-- 06 Aldous-Broder
-- 07 Wilson's
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
--  +- -+- -+  > v   06 14 12 08 01       dn=1
--  |- -+- -|  < ^   07 15 13 02 04   dw=8  +  de=2
--  +_ _+_ _+  - |   03 11 09 10 05       ds=4
-- 
-- ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== =====

_dn=1
_de=2
_ds=4
_dw=8
nrow=16
ncol=16--nrow
nrowcol1=(nrow*ncol)-1
sbase=16 -- maze
-- sbase=48 -- numbers
-- sbase=80 -- colors
gridlines=true
runprint=true
gcursor=true
gsteps=true
--
wilson={}

clr_bgn=11 -- color of begining cell
clr_pth=14 -- color of path

-- ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== =====
function irand(n) return ceil(rnd(n)) end
function irand0(n) return ceil(rnd(n))-1 end
function free(_x,_y) return mget(_x,_y)==sbase end
function valid(_x,_y) return (0 <= _x) and (_x < ncol) and (0 <= _y) and (_y<nrow) end

function pp_wilson()
  printh("wilson") --xxxx
  if wilson.init then 
    printh(" initialized") 
  end
  if #wilson.bgn>0 then 
    printh(" bgn {"..wilson.bgn[1]..","..wilson.bgn[2].."}")
  end
  printh(" n="..wilson.n)
  printh("path="..count(wilson.path))
  for pt in all(wilson.path) do
    printh(pt[1]..","..pt[2])
  end
  printh("visit="..count(wilson.visit))
  for k,v in pairs(wilson.visit) do
    printh(k.."="..v)
  end
  print_map()
end

  --print the map
function print_map()
  local out, x, y,v
  printh("map ==")
  for y=0,nrow-1 do
    out=""
    for x=0,ncol-1 do
      v=mget(x,y)-sbase
      if v<10 then out=out.." " end
      out=out..tostr(v)
    end
    printh(out)
  end
end

-- ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== =====
function wilson_algo()
  function wilson_start() 
    mset(irand0(ncol),irand0(nrow),sbase+15)
    wilson["n"]=nrow*ncol-1
    wilson.init=true
  end
  ------
  function get_bgn()
    local x,y
    repeat
      x,y=irand0(ncol),irand0(nrow)
    until free(x,y)
    wilson.bgn={x,y}
    wilson.init=true
    wilson.walk=false
    wilson.cx=x
    wilson.cy=y
    wilson.path={{x,y}}
  end
  ------
  function add_walk()
    local cx,cy,dex,dir,pre
    cx,cy=wilson.bgn[1],wilson.bgn[2]
    pre=nil
    while free(cx,cy) do
      dex=cy*ncol+cx
      dir=wilson.visit[dex]
      mset(cx,cy,mget(cx,cy)+dir)
      if pre then
        mset(cx,cy,mget(cx,cy)+pre)
        --printh("cx="..cx.." cy="..cy.." dex="..dex.." dir="..dir.." pre="..pre)
      --else
       -- printh("cx="..cx.." cy="..cy.." dex="..dex.." dir="..dir.." pre=")
      end
      cx+=wilson.dx[dir]
      cy+=wilson.dy[dir]
      pre=wilson.opp[dir]
      --mset(cx,cy,mget(cx,cy)+wilson.opp[dir])
      wilson.n -=1
    end
    if mget(cx,cy)==(sbase+15) then mset(cx,cy,sbase) end
    mset(cx,cy,mget(cx,cy)+pre)
  end
  ------
  function step()
    if wilson.n==0 then return end
    if not wilson.walk then
      get_bgn()
      wilson.walk=true
      wilson.visit={}
      wilson.path={}
      return
    end
    local dir, nx,ny
    repeat
      dir=wilson.dir[irand(4)]
      nx=wilson.cx+wilson.dx[dir]
      ny=wilson.cy+wilson.dy[dir]
    until valid(nx,ny)
    if free(nx,ny) then
      --wilson.visit[ny*ncol+nx]=dir
      wilson.visit[wilson.cy*ncol+wilson.cx]=dir
      wilson.cx,wilson.cy=nx,ny
      add(wilson.path,{nx,ny})
    else
      wilson.visit[wilson.cy*ncol+wilson.cx]=dir
      wilson.walk=false
      --[[
      printh("--------------- end of path -------------")
      pp_wilson()
      printh("compute")
      printh(" bgn {"..wilson.bgn[1]..","..wilson.bgn[2].."}")
      local dex=wilson.bgn[2]*ncol+wilson.bgn[1]
      --local dex=wilson.bgn[1]*ncol+wilson.bgn[2]
      printh("dex="..dex)
      printh("visit["..dex.."]="..wilson.visit[dex])
      ]]--
      add_walk()
    end
  end
  ------
  if not wilson.init then wilson_start() end
  while wilson.n > 0 do
    step()
  end

  --[[
  if not wilson.init then wilson_start() return true end
  while wilson.n > 0 do
    step()
  end
  ]]--
end

-- ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== =====
function init_maze()
  on={0, 0}
  for y=0,nrow-1 do
    for x=0,ncol-1 do
      mset(x,y,0+sbase)
    end
  end
end
function init_wilson()
  -- wilson init
  wilson={}
  wilson.init=false
  wilson.bgn={}
  wilson["n"]=0
  wilson["cx"]=-1
  wilson["cy"]=-1
  wilson.dir={_dn, _de, _ds, _dw}
  wilson.opp={}
  wilson.opp[_dn]=_ds
  wilson.opp[_ds]=_dn
  wilson.opp[_dw]=_de
  wilson.opp[_de]=_dw
  wilson.dx={}
  wilson.dy={}
  wilson.dx={0,1,nil,0,nil,nil,nil,-1}
  wilson.dy={-1,0,nil,1,nil,nil,nil,0}
  wilson.visit={}
  wilson.path={}
end

function restart()
  init_maze()
  init_wilson()
end
-- ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== =====
function _init()
  -- print a runtime note
  if runprint then
    local div,m m=stat(94) if m < 10 then div=":0" else div=":" end
    printh (stat(93)..div..stat(94).." ---------------------------------------- ")
  end

  -- init the map
  restart()
end

function _update()

  if btnp(0) then
    --printh("Btn 0 left")
    wilson_algo()

  elseif btnp(1) then
    --printh("Btn 1 right")
    --printh("reset--------------------")
    restart()

  elseif btnp(2) then 
    --printh("Btn 2 up")
    gsteps = not gsteps

  elseif btnp(3) then
    --printh("Btn 3 down")
    pp_wilson()

  elseif btnp(4) then
    --printh("Btn 4 = cv")
    restart()
    wilson_algo()

  elseif btnp(5) then
    --printh("Btn 5 = nm")
    gridlines=not gridlines
  end
end

function _draw()
  cls()
  mapdraw(0, 0, 0, 0, ncol, nrow)
  if gridlines then
    fillp(0b1010010110100101.1)
    for y=1,nrow+1 do
      for x=1,ncol+1 do
        line((x-1)*8,0 ,(x-1)*8,nrow*8,6)
      end
      line(0,(y-1)*8,(ncol)*8-1,(y-1)*8,6)
    end
    fillp()
  end

  --if gcursor then
  --  rect (on[1]*8+1, on[2]*8+1, on[1]*8+6, on[2]*8+6, 10)
  --end
  if gsteps and #wilson.bgn>0 then
    rect (wilson.bgn[1]*8+1, wilson.bgn[2]*8+1, wilson.bgn[1]*8+7, wilson.bgn[2]*8+7, clr_bgn)
  end
  if gsteps and #wilson.path>0 then
    for pt in all(wilson.path) do
      rect (pt[1]*8+2, pt[2]*8+2, pt[1]*8+6, pt[2]*8+6, clr_pth)
    end
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
