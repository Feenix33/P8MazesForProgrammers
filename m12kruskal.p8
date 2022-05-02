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
_in,_ie,_is,_iw=1,2,3,4
_nrow,_ncol=16,16
sbase=16 -- 16=maze
-- sbase=48 -- numbers
-- sbase=80 -- colors

-- control
_ctrl = {
  free_run=false,
  time=0,
  bump=5,--10,
  grid=false,
  start_msg=true,
}

_rnd_dir = { -- get random dir vector
  dirs={{1,2,3,4},{1,2,4,3},{1,3,2,4},{1,3,4,2},{1,4,2,3},{1,4,3,2},
        {2,1,3,4},{2,1,4,3},{2,3,1,4},{2,3,4,1},{2,4,1,3},{2,4,3,1},
        {3,1,2,4},{3,1,4,2},{3,2,1,4},{3,2,4,1},{3,4,1,2},{3,4,2,1},
        {4,1,2,3},{4,1,3,2},{4,2,1,3},{4,2,3,1},{4,3,1,2},{4,3,2,1}},
  get=function(self) return _rnd_dir.dirs[irand(24)] end,
}

-- ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== =====
--xxxaayyzz xyxy abab
--kkkkkkkkkkk
--_in,_ie,_is,_iw=1,2,3,4
_ka={ -- Kruskal's algo
  edges={},
  state=nil,
  init=function(self)
    local x,y,n
    n=0
    for y=0,_nrow-1 do
      for x=0,_ncol-1 do
        if y>0 then add(self.edges,{x,y,_in}) end
        if x>0 then add(self.edges,{x,y,_iw}) end
        self:sgrp(x,y,n)
        n+=1
      end
    end
    --for x=1,#self.edges do
      --printh(x.." "..#self.edges[x])
      --printh(x.." "..#self.edges[x].." "..tblstr(self.edges[x]))
    --end
    shuffle(self.edges)
    self.state=self.st_step
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
  dx={0,1,0,-1}, -- dx by dir
  dy={-1,0,1,0}, -- dy by dir
  opp={3,4,1,2}, -- opposite direction
  i2d={_dn,_de,_ds,_dw},
  grp={},
  ggrp=function(self,x,y) -- get the group value
    return self.grp[x+(y*_ncol)+1]
  end,
  sgrp=function(self,x,y,v) -- set the group value
    --printh('set grp xyv='..x..','..y..','..v)
    self.grp[x+(y*_ncol)+1]=v
  end,
  is_con=function(self,x1,y1, x2,y2) -- are the pts connected
    return self:ggrp(x1,y1) == self:ggrp(x2,y2)
  end,
  setall=function(self,og,ng) -- set all orig grp to new grp
    --printh("setting "..og.." to "..ng)
    local n
    for n=1,#self.grp do
      if self.grp[n] == og then self.grp[n] = ng end
    end
  end,

  st_step=function(self) -- do one step of the algo
    local x,y,d
    --pop a candidate off the stack
    x,y,d = unpack(self.edges[#self.edges])
    self.edges[#self.edges] = nil
    --printh('step xyd= '..x..","..y..","..d..','..#self.edges)
    if #self.edges==0 then self.state=self.st_fini end

    -- connect
    local nx,ny,nd,ng,g
    nx=x+self.dx[d]
    ny=y+self.dy[d]
    g=self:ggrp(x,y)
    ng=self:ggrp(nx,ny)
    --printh('step g='..g.." ng="..ng)
    if g != ng then -- groups don't match, make the connection
      --printh("step making connection")
      mset(x,y,mget(x,y)+self.i2d[d])
      nd=self.opp[d]
      mset(nx,ny,mget(nx,ny)+self.i2d[nd])
      if g< ng then self:setall(ng,g) else self:setall(g,ng) end
    end
  end,

  st_fini=function(self) -- done
    self.grp={}
    printh("fini")
  end,
  done=function(self) return self.state==self.st_fini end,
}

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
    else out=out..tostring(v) end
  end
  out=out.."}"
  printh(out)
end
-- ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== =====
function irand(n) return ceil(rnd(n)) end -- rand in [1..n]
function irand0(n) return ceil(rnd(n))-1 end
function tblstr(_t)
  out="" for j=1,#_t-1 do out=out.._t[j].."," end return out.._t[#_t]
end
function shuffle(t)
  for i=#t,1,-1 do
    local j=flr(rnd(i))+1
    t[i],t[j] = t[j],t[i]
  end
end
-- ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== =====
function init_maze()
  on={0, 0}
  for y=0,_nrow-1 do
    for x=0,_ncol-1 do
      mset(x,y,0+sbase)
    end
  end
  _ka:init()
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
    _ka:state()

  elseif btnp(1) then
    --printh("Btn 1 right")
    _ctrl.free_run=not _ctrl.free_run

  elseif btnp(2) then 
    --printh("Btn 2 up")
    if _ka:done() then init_maze() end
    while not _ka:done() do _ka:state() end

  elseif btnp(3) then
    --printh("Btn 3 down")
    init_maze()

  elseif btnp(4) then
    --printh("Btn 4 = cv")
    _ka:full_debug()

  elseif btnp(5) then
    --printh("Btn 5 = nm")
    _ctrl.grid = not _ctrl.grid
  end

  if _ctrl.free_run then
    _ctrl.time += 1
    if _ctrl.time > _ctrl.bump then 
      _ctrl.time = 0
      if not _ka:done() then _ka:state() end
    end
  end
end

function _draw() --dddddd
  cls()
  mapdraw(0, 0, 0, 0, _ncol, _nrow)
  if _ctrl.grid then
    fillp(0b1010010110100101.1)
    for y=1,_nrow+1 do
      for x=1,_ncol+1 do
        line((x-1)*8,0 ,(x-1)*8,_nrow*8,6)
      end
      line(0,(y-1)*8,(_ncol)*8-1,(y-1)*8,6)
    end
    fillp()
  end
  --_rb:draw()
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
