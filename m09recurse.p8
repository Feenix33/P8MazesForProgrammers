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
_nrow,_ncol=15,15
sbase=16 -- 16=maze
-- sbase=48 -- numbers
-- sbase=80 -- colors

-- control
_ctrl = {
  run=false,
  time=0,
  bump=10,
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
--xxxaayyzz xyxy abab
_rb = { --recursive backlog
  cx=-1,
  cy=-1,
  off={{0,-1},{1,0},{0,1},{-1,0}}, -- neighbor offsets
  opp={{0, 1},{-1,0},{0,-1},{ 1,0}}, -- opposite offsets
  trk={}, -- the track queue
  back=false,
  fini=false,
  init=function(self)
    self.cx=irand0(_ncol)
    self.cy=irand0(_nrow)
    self.trk={{cx,cy}}
    self.back=false
    self.fini=false
  end,
  carve=function(self)
    local rnay=_rnd_dir.get()
    local done=false
    for n in all(rnay) do
      if not done then
        newx=self.cx+self.off[n][1]
        newy=self.cy+self.off[n][2]
        if valid(newx,newy) and free(newx,newy) then
          add(self.trk, {newx, newy})
          carve_to(n,self.cx,self.cy)
          self.cx=newx
          self.cy=newy
          carve_from(n,self.cx,self.cy)
          done=true
        end
      end
    end
    if not done then -- didn't find a step
      --printh("switch to back")
      self.back=true
    end
  end,
  backup=function(self)
    -- here xxxxyyyxzzzzz
    while self.back do
      --pop off stack
      local newx,newy
      local pt= self.trk[#self.trk]
      pt= self.trk[#self.trk]
      self.trk[#self.trk]=nil
      local rnay=_rnd_dir.get()
      for n in all(rnay) do
        newx=pt[1]+self.off[n][1]
        newy=pt[2]+self.off[n][2]
        if valid(newx,newy) and free(newx,newy) then
          self.cx=pt[1]
          self.cy=pt[2]
          carve_to(n,self.cx,self.cy)
          self.cx=newx
          self.cy=newy
          carve_from(n,self.cx,self.cy)
          self.back=false
        end
        if #self.trk == 1 then
          --printh("We are done")
          self.back = false
          self.fini=true
        end
      end
    end
  end,
  step=function(self)
    if self.fini then
      return
    else
      if self.back==true then
        _rb:backup()
      else
        _rb:carve()
      end
    end
  end,
  dbg=function(self)
    printh("dbg rb")
    printh("at ("..self.cx..","..self.cy..")")
    for k,v in pairs(self.trk) do
      printh("   "..j.." ("..v[1]..","..v[2]..")")
    end
  end,
  draw=function(self)
    if valid(self.cx,self.cy) and not self.fini then
      rect(self.cx*8, self.cy*8, self.cx*8+6,self.cy*8+6,6)
    end
  end,
}

function prt_table(t, lvl)
  if type(t)!="table" then return end
  local out=lvl.."{"
  for k,v in pairs(t) do
    if type(v) == "table" then
      if #v == 2 then
        out=out.."{"..v[1]..","..v[2].."}"
      else
        prt_table(v, lvl)
      end
    else
      out=out..tostring(v)
    end
  end
  out=out.."}"
  printh(out)
end

function _rb:full_debug(self)
  printh("rb full debug -----------------------------------")
  --printh("at ".._rb.cx)
  for k,v in pairs(_rb) do
    printh("k="..k.." - "..tostring(v))
    if type(v)=="table" then
      prt_table(v,"+-")
    end
  end
  printh("-------------------------------------------------")
end

-- ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== =====
function irand(n) return ceil(rnd(n)) end -- rand in [1..n]
function irand0(n) return ceil(rnd(n))-1 end
function free(_x,_y) return mget(_x,_y)==sbase end
function valid(_x,_y) return (0 <= _x) and (_x < _ncol) and (0 <= _y) and (_y<_nrow) end
function carve_to(_d,_x,_y)
  local dir={_dn,_de,_ds,_dw}
  mset(_x,_y,mget(_x,_y)+dir[_d])
end
function carve_from(_d,_x,_y)
  local odr={_ds,_dw,_dn,_de}
  mset(_x,_y,mget(_x,_y)+odr[_d])
end

-- ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== =====


-- ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== =====
function init_maze()
  on={0, 0}
  for y=0,_nrow-1 do
    for x=0,_ncol-1 do
      mset(x,y,0+sbase)
    end
  end
  _rb:init()
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
    _rb:step()

  elseif btnp(1) then
    --printh("Btn 1 right")
    init_maze()

  elseif btnp(2) then 
    --printh("Btn 2 up")
    if _rb.fini then init_maze() end
    while not _rb.fini do
      _rb:step()
    end

  elseif btnp(3) then
    --printh("Btn 3 down")
    _ctrl.run= not _ctrl.run

  elseif btnp(4) then
    --printh("Btn 4 = cv")
    --_rb:dbg()
    _rb:full_debug()

  elseif btnp(5) then
    --printh("Btn 5 = nm")
    _ctrl.grid = not _ctrl.grid
  end

  if _ctrl.run then
    _ctrl.time += 1
    if _ctrl.time > _ctrl.bump then 
      _ctrl.time = 0
      if not _rb.fini then _rb:step() end
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
  _rb:draw()
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
