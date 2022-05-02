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
-- 08 Hunt and kill
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
_dn,_de,_ds,_dw=1,2,4,8
nrow,ncol=16,16
sbase=16 -- 16=maze
-- sbase=48 -- numbers
-- sbase=80 -- colors
_gridlines=true
_runprint=true
_freerun=false
_free_t=0
_free_frm=8--10
_hk={}

-- ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== =====
function irand(n) return ceil(rnd(n)) end -- rand in [1..n]
function irand0(n) return ceil(rnd(n))-1 end
function free(_x,_y) return mget(_x,_y)==sbase end
function valid(_x,_y) return (0 <= _x) and (_x < ncol) and (0 <= _y) and (_y<nrow) end
-- ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== =====

function hunt_kill()
  _hk.st[_hk.m]()
end

function hk_init() -- mode=1
  _hk.x,_hk.y=irand(ncol)-1,irand(nrow)-1
  _hk.m=2 -- next mode
end

-- need to rewrite these to chose a random dir then compute the new position
-- so we can add the dir and the opp dir

function hk_neighs(x,y) -- get the open neighbors from passed
  -- returns 1,2,3,4 for each dir if valid and free
  local j,nx,ny,nay
  nay={} -- no neighbors
  for j,off in pairs(_hk.off) do
    nx,ny=x+off[1],y+off[2]
    if valid(nx,ny) then
      if free(nx,ny) then
        add(nay,j)
      end
    end
  end
  return nay
end
function hk_taken(x,y) -- get the list of taken neighbors
  -- returns 1,2,3,4 for each dir if valid and used
  local j,nx,ny,nay
  nay={} -- no takens
  for j,off in pairs(_hk.off) do
    nx,ny=x+off[1],y+off[2]
    if valid(nx,ny) then
      if not free(nx,ny) then
        add(nay,j)
      end
    end
  end
  return nay
end

function hk_choose(x,y) -- return dir of an open neighbor or nil
  local nay,choice
  nay=hk_neighs(x,y)
  if #nay==0 then
    return nil
  else
    return nay[irand(#nay)] -- random across the return vector
  end
end

function hk_walk() -- mode=2
  local nx,ny,nay
  nay=hk_choose(_hk.x,_hk.y)
  if not nay then
    _hk.m=3 -- mode is hunt
  else
    --printh("dir="..nay)
    mset(_hk.x, _hk.y, mget(_hk.x, _hk.y)+_hk.mv[nay])
    _hk.x+=_hk.off[nay][1]
    _hk.y+=_hk.off[nay][2]
    mset(_hk.x, _hk.y, mget(_hk.x, _hk.y)+_hk.mvo[nay])
  end
end

function hk_hunt() -- mode=3
  --start at top corner, look for a cell w/a visited neighbor
  local fnd=0
  local x,y, atx,aty
  local nay,choice,srch
  y=0
  srch=true -- search

  while y<nrow and srch do --and not fnd do
    x=0
    while x<nrow and srch do --and not fnd do

      -- if empty, get neighbors
      if free(x,y) then
        nay= hk_taken(x,y) -- get the list of taken neighbors
        if #nay >0 then -- we have a taken neighbor
          atx,aty=x,y
          fnd=nay[irand(#nay)] -- random across the return vector
          srch=false -- found a neighbor
        end
      end

      x+=1
    end
    y+=1
  end
  if fnd==0 then
    _hk.m=4 -- all done
    hk_chill() -- mode=4 all done
    return
  end -- maze gen done
  -- connect at cell to maze and go on rand walk
  _hk.x,_hk.y=atx,aty
  mset(_hk.x, _hk.y, mget(_hk.x, _hk.y)+_hk.mv[fnd])
  _hk.x+=_hk.off[fnd][1]
  _hk.y+=_hk.off[fnd][2]
  mset(_hk.x, _hk.y, mget(_hk.x, _hk.y)+_hk.mvo[fnd])
  _hk.x,_hk.y=atx,aty
  _hk.m=2 -- back to walk mode
end

function hk_chill() -- mode=4 all done
  --printh("fini")
  -- switch off drawing of current cell
  _hk.x,_hk.y=-1,-1
end

function init_hunt_kill()
  _hk={}
  _hk["m"]=1 -- mode 1=init 2=walk 3=hunt 4=chill
  _hk["st"] = {hk_init, hk_walk, hk_hunt, hk_chill}
  _hk["x"]=-1
  _hk["y"]=-1
  _hk["off"]={{0,-1},{1,0},{0,1},{-1,0}} -- neighbor offsets
  _hk["opp"]={{0, 1},{-1,0},{0,-1},{ 1,0}} -- opposite offsets
  _hk["mv"] ={_dn,_de,_ds,_dw}
  _hk["mvo"]={_ds,_dw,_dn,_de}
end

function hk_draw()
  if valid(_hk.x,_hk.y) then
    rect(_hk.x*8+1, _hk.y*8+1,_hk.x*8+6, _hk.y*8+6,6)
  end
end

function dbg_hunt_kill()
  printh("mode=".._hk.m)
  --[[
  printh("irand() test")
  local j,k,out
  for j=1,10 do
    out=""
    for k=1,10 do
      out=out..irand(9)
    end
    printh(out)
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
  init_hunt_kill()
end

-- ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== =====
function test()
  printh("test pairs")
  for k,v in pairs(_hk.off) do
    printh("k="..k.." v=("..v[1]..","..v[2]..")")
  end
  a = {nil, {1,2}, nil, nil, false}
  printh("len="..(#a))
  for k,v in pairs(a) do
    if v then printh(k.."is true") else printh(k.."is f") end
  end
end
-- ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== =====
function _init()
  -- print a runtime note
  if _runprint then
    local div,m m=stat(94) if m < 10 then div=":0" else div=":" end
    printh (stat(93)..div..stat(94).." ---------------------------------------- ")
  end

  -- init the map
  init_maze()
end

function _update()

  if btnp(0) then
    --printh("Btn 0 left")
    hunt_kill()

  elseif btnp(1) then
    --printh("Btn 1 right")
    init_maze()

  elseif btnp(2) then 
    --printh("Btn 2 up")
    while _hk.m!=4 do
      hunt_kill()
    end

  elseif btnp(3) then
    --printh("Btn 3 down")
    _freerun=not _freerun
    _free_t=0

  elseif btnp(4) then
    --printh("Btn 4 = cv")
    dbg_hunt_kill()

  elseif btnp(5) then
    --printh("Btn 5 = nm")
    _gridlines=not _gridlines
  end

  if _freerun then
    _free_t += 1
    if _free_t > _free_frm then
      _free_t = 0
      hunt_kill()
    end
  end
end

function _draw()
  cls()
  mapdraw(0, 0, 0, 0, ncol, nrow)
  if _gridlines then
    fillp(0b1010010110100101.1)
    for y=1,nrow+1 do
      for x=1,ncol+1 do
        line((x-1)*8,0 ,(x-1)*8,nrow*8,6)
      end
      line(0,(y-1)*8,(ncol)*8-1,(y-1)*8,6)
    end
    fillp()
  end
  hk_draw()
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
