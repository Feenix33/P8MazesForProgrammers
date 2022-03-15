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
-- 09 Recursive backtrack + try as an object
-- 10 Recursive backtrack with braiding
-- 11 Recursive backtrack with braiding w/state mgmt
-- 12 Kruskal's algo
-- 13 Prim's Algorith w/o weights; changed maze basics on free cells
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
--_in,_ie,_is,_iw=1,2,3,4
--_sbase=16 -- 16=maze
_sbase=32 -- 16=maze
-- _sbase=48 -- numbers
-- _sbase=80 -- colors

-- control
_ctrl = {
  nrow=16,
  ncol=16,
  frun=false,
  time=0,
  bump=5,--10,
  grid=false,
  start_msg=false,
}

_rnd_dir = { -- get random dir vector
  dirs={{1,2,3,4},{1,2,4,3},{1,3,2,4},{1,3,4,2},{1,4,2,3},{1,4,3,2},
        {2,1,3,4},{2,1,4,3},{2,3,1,4},{2,3,4,1},{2,4,1,3},{2,4,3,1},
        {3,1,2,4},{3,1,4,2},{3,2,1,4},{3,2,4,1},{3,4,1,2},{3,4,2,1},
        {4,1,2,3},{4,1,3,2},{4,2,1,3},{4,2,3,1},{4,3,1,2},{4,3,2,1}},
  get=function(self) return _rnd_dir.dirs[irand(24)] end,
}

-- ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== =====
_algo={ -- 
  state=nil,
  dx={0,1,0,-1}, -- dx by dir
  dy={-1,0,1,0}, -- dy by dir
  rdir={_dn,_de,_ds,_dw},
  odir={_ds,_dw,_dn,_de},
  i2d={_dn,_de,_ds,_dw},
  frt={}, -- frontier
  --atx=0, -- on x,y
  --aty=0, -- on x,y

  inbnd=function(self,x,y) -- check if in bounds
    return x>=0 and y>=0 and x<_ctrl.ncol and y<_ctrl.nrow
  end,

  -- converstion from xy to single entry 
  fwd=function(self, _x,_y) return _x+(_y*_ctrl.ncol) end,
  rev=function(self, _v) return _v%_ctrl.ncol, flr(_v/_ctrl.ncol) end,

  add_frt=function(self, _x,_y) -- add valid x,y to frontier
    local n
    if self:inbnd(_x,_y) then
      local nv = self:fwd(_x,_y)
      for k,v in pairs(self.frt) do -- check if we have the value already
        if v == nv then return end
      end
      add(self.frt, nv)
    end
  end,

  del_frt=function(self,_x,_y) -- remove a value from the fronteir
    local v=self:fwd(_x,_y)
    local r 
    repeat r= del(self.frt,v) until r == nil
  end,

  init=function(self)
    self.frt={} -- reset frontier
    -- start the maze
    local x, y
    x= irand0(_ctrl.ncol)
    y= irand0(_ctrl.nrow)
    mset(x,y,_sbase)

    -- add the frt
    for j=1,4 do self:add_frt(x+self.dx[j], y+self.dy[j]) end

    -- change the state
    self.state=self.st_step 
  end,

  st_step=function(self) -- do one step of the algo
    -- get a frontier space
    local n = irand(#self.frt)
    local x,y -- the frt x,y
    x,y=self:rev(self.frt[n]) -- convert from single to xy

    -- find a maze from the frontier
    local rnay=_rnd_dir.get() -- rand dir to find maze
    local mx,my -- maze x,y to carve to
    local dr -- dir that we went
    for v in all(rnay) do
      mx=x+ self.dx[v]
      my=y+ self.dy[v]
      if not free(mx,my) then
        dr=v
        break
      end
    end
    if dr==nil then stop('no maze') end

    -- carve to the frontier
    self:carve_to(dr,x,y)
    self:carve_from(dr,mx,my)

    -- remove from frontier
    self:del_frt(x,y)

    -- add new neighbors to frontier
    local nx,ny -- new neighbors
    for j=1,4 do
      nx=x+self.dx[j]
      ny=y+self.dy[j]
      if free(nx,ny) then self:add_frt( nx, ny) end
    end

    -- check if done
    if #self.frt==0 then self.state=self.st_fini end
  end,

  carve_to=function(self,_d,_x,_y)
    local mval=mget(_x,_y)
    local base = 0
    if mval < _sbase then base=_sbase end
    mset(_x,_y,mget(_x,_y)+self.rdir[_d]+base)
  end,
  carve_from=function(self,_d,_x,_y)
    local mval=mget(_x,_y)
    local base = 0
    if mval < _sbase then base=_sbase end
    mset(_x,_y,mget(_x,_y)+self.odir[_d]+base)
  end,

  st_fini=function(self) -- done
    --printh('fini')
  end,

  -- check if done w/maze gen
  done=function(self) return self.state==self.st_fini end,

  draw=function(self) -- additional drawing
    local j,n,x,y
    for j=1,#self.frt do
      n=self.frt[j] -- get a frt cell
      x,y=self:rev(n) -- convert to xy
      hilite(x,y,15)
    end
    if self.state==self.st_fini then -- draw a box when done
      rect(0,0, _ctrl.ncol*8-1, _ctrl.nrow*8-1, 14)
    end
  end,

  full_debug=function (self)
    printh("full debug -----------------------------------")
    for k,v in pairs(self) do
      if type(v)!="function" then
        printh("k="..k.." - "..tostring(v))
        if type(v)=="table" then prt_table(v) end
      end
    end
  end,
}

-- ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== =====

function prt_table(t,_nlc)
  -- nlc = number entries before cr
  if type(t)!="table" then return end
  local out="{"
  local nl=0
  local k,v
  local nlc=_nlc or 5
  for k,v in pairs(t) do
    if type(v) == "table" then
      if type(v[1]) == "table" then
        prt_table(v)
        nl=0
      else
        out=out..'('..tblstr(v)..') '
        nl+=1
        if (nl>=nlc) then out=out..'\n' nl=0 end
      end
    else out=out..tostring(v)..' ' end
  end
  out=out.."}"
  printh(out)
end
-- ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== =====
function irand(n) return ceil(rnd(n)) end -- rand in [1..n]
function irand0(n) return ceil(rnd(n))-1 end -- rand in [0..n)
function free(_x,_y) return mget(_x,_y)==0 end
function tblstr(_t)
  out="" for j=1,#_t-1 do out=out.._t[j].."," end return out.._t[#_t]
end
function shuffle(t)
  for i=#t,1,-1 do
    local j=flr(rnd(i))+1
    t[i],t[j] = t[j],t[i]
  end
end
function hilite(x,y,c) -- highlight x,y map location w/rect of color c
  local x8=x*8 local y8=y*8 rect(x8+1, y8+1, x8+7,y8+7,c)
end
function hifill(x,y,c) -- highlight x,y map location w/rect of color c
  local x8=x*8 local y8=y*8
  --fillp(0x33cc.8)
  fillp(0x5a5a.8)
  rectfill(x8+1, y8+1, x8+7,y8+7,c)
  fillp()
end
-- ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== =====
function init_maze()
  on={0, 0}
  for y=0,_ctrl.nrow-1 do
    for x=0,_ctrl.ncol-1 do
      mset(x,y,0)
    end
  end
  _algo:init()
end

-- ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== =====
function _init() --iiiiiii
  -- print a runtime note
  if _ctrl.start_msg then
    local div,m m=stat(94) if m < 10 then div=":0" else div=":" end
    local siv,s s=stat(95) if s < 10 then siv=":0" else siv=":" end
    printh (stat(93)..div..m..siv..s.." ---------------------------------------- ")
  end
  -- init the map
  init_maze()
end

function _update() --uuuuuuuu

  if btnp(0) then
    --printh("Btn 0 left")
    _algo:state()

  elseif btnp(1) then
    --printh("Btn 1 right")
    _ctrl.frun=not _ctrl.frun

  elseif btnp(2) then 
    --printh("Btn 2 up")
    if _algo:done() then init_maze() end
    while not _algo:done() do _algo:state() end

  elseif btnp(3) then
    --printh("Btn 3 down")
    init_maze()

  elseif btnp(4) then
    --printh("Btn 4 = cv")
    _algo:full_debug()

  elseif btnp(5) then
    --printh("Btn 5 = nm")
    _ctrl.grid = not _ctrl.grid
  end

  if _ctrl.frun then
    _ctrl.time += 1
    if _ctrl.time > _ctrl.bump then 
      _ctrl.time = 0
      if not _algo:done() then _algo:state() end
    end
  end
end

function _draw() --dddddd
  cls()
  mapdraw(0, 0, 0, 0, _ctrl.ncol, _ctrl.nrow)
  if _ctrl.grid then
    fillp(0b1010010110100101.1)
    for y=1,_ctrl.nrow+1 do
      for x=1,_ctrl.ncol+1 do
        line((x-1)*8,0 ,(x-1)*8,_ctrl.nrow*8,6)
      end
      line(0,(y-1)*8,(_ctrl.ncol)*8-1,(y-1)*8,6)
    end
    fillp()
  end
  
  _algo:draw()
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
44444444400000044444444440000000444444444000000444444444400000004444444400000004444444440000000044444444000000044444444400000000
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
