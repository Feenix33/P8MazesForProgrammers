pico-8 cartridge // http://www.pico-8.com
version 34
__lua__
--[[
-- 14 Elles' Algo
--
-- 0=black 1=dblue   2=purple  3=dgreen  4=brown  5=dgrey  6=lgrey  7=white
-- 8=red   9=orange 10=yellow 11=lgreen 12=lblue 13=mgrey 14=pink  15=peach
--
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
]]--
-- ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== =====
_dn,_de,_ds,_dw=1,2,4,8
_sbase=16 -- green maze
--_sbase=32 -- brown maze
-- _sbase=48 -- numbers
-- _sbase=80 -- colors

-- control
_ctrl = {
  nrow=16,
  ncol=16,
  auto_run=false,
  time=0,
  auto_bump=5,--10,
  grid=false,
  start_msg=false,
}


-- ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== =====
_algo={ --  eller's Algo
  state=nil,
  dx={0,1,0,-1}, -- dx by dir
  dy={-1,0,1,0}, -- dy by dir
  rdir={_dn,_de,_ds,_dw},
  odir={_ds,_dw,_dn,_de},
  i2d={_dn,_de,_ds,_dw},
  prob_horz=0.50, -- probability of carving horizontally
  prob_vert=0.50, -- probability of carving vertically



  inbnd=function(self,x,y) -- check if in bounds
    return x>=0 and y>=0 and x<_ctrl.ncol and y<_ctrl.nrow
  end,

  -- frontier management
  -- converstion from xy to single entry 
  --[[
  fwd=function(self, _x,_y) return _x+(_y*_ctrl.ncol) end,
  rev=function(self, _v) return _v%_ctrl.ncol, flr(_v/_ctrl.ncol) end,

  del_frt=function(self,_x,_y) -- remove a value from the fronteir
    local v=self:fwd(_x,_y)
    local r 
    repeat r= del(self.frt,v) until r == nil
  end,
  ]]--

  --- main part of the algo
  grpcur={}, -- grp for current row
  grpnxt={}, -- grp for next row 
  grpn=1, -- grp number
  sets={}, -- 2d of sets in v fmt
  ony=1, -- what row are we on

  init=function(self)
    --printh("init")
    -- change the state
    self.state=self.st_step 
    self.ony=1 -- what row are we on
    self.grpn=1 
    for x=1,_ctrl.ncol do
      self.grpcur[x] = self.grpn -- first row everyone in a different row
      self.grpn += 1 -- next group
    end
  end,

  carve_east=function(self,_x,_y) -- carves x,y and x+1,y
    local atv, ntv -- values for at and next
    local base -- base value
    local x = _x-1 -- offset for map
    local y = _y-1 -- offset for map
    atv = mget(x,y)
    if atv < _sbase then base=_sbase else base=0 end
    mset(x,y,atv+self.rdir[2]+base)

    ntv = mget(x+1,y)
    if ntv < _sbase then base=_sbase else base=0 end
    mset(x+1,y,ntv+self.rdir[4]+base)
  end,

  has_carve=function(self,_x,_y,_d) -- check if the cell had the dir
    local x = _x-1 -- offset for map
    local y = _y-1 -- offset for map
    local atv = mget(x,y) - _sbase
    local rtn=false
    if atv>0 then rtn=band(atv,_d) end
    --printh("has-carve ".._x..",".._y.." = "..atv..' = '..rtn)
    return rtn>0
  end,

  carve_south=function(self,_x,_y)
    local atv, ntv -- values for at and next
    local base -- base value
    local x = _x-1 -- offset for map
    local y = _y-1 -- offset for map
    atv = mget(x,y)
    if atv < _sbase then base=_sbase else base=0 end
    mset(x,y,atv+self.rdir[3]+base)

    ntv = mget(x,y+1)
    if ntv < _sbase then base=_sbase else base=0 end
    mset(x,y+1,ntv+self.rdir[1]+base)
  end,

  combine=function(self,_a,_b) -- combine a&b into b
    for k,v in pairs(self.grpcur) do
      if v == _a then self.grpcur[k] = _b end
    end
  end,

  st_step=function(self) -- one step of algo
    -- init
    for x=1,_ctrl.ncol do self.grpnxt[x] = 0 end

    --printh("------ step on row "..self.ony)
    --print_table(self.grpcur)
    --printh('cur group = ['..tblstr(self.grpcur)..']')
    for x=1,_ctrl.ncol-1 do -- these are 1..n for tracking
      if self.grpcur[x] != self.grpcur[x+1] and rnd() > self.prob_horz then -- carve east
        --printh('carving east x='..x)
        self:carve_east(x, self.ony)
        --self.grpcur[x+1] = self.grpcur[x] -- reset the group
        self:combine(self.grpcur[x+1], self.grpcur[x]) -- reset the group
      end
    end
    --printh('cur group = ['..tblstr(self.grpcur)..']')

    --[[
    ]]--
    --printh("\nhoriz done go to vert-----------")
    -- for each group add one vertical
    --print_table(self.grpcur)
    --printh('cur group = ['..tblstr(self.grpcur)..']')
    local cvr={} -- stack for covered groups
    -- count the groups
    for k,v in pairs(self.grpcur) do
      if not contains(cvr, v) then -- if we haven't covered this value
        -- add to the addressed groups
        --printh("carving south for group "..v)
        cvr[#cvr+1]=v
        -- count how many
        local count=0
        local crvat -- which place to carve south
        for n in all(self.grpcur) do if n==v then count+=1 end end
        --printh('there are '..count..' members')
        crvat=irand(count)
        --printh('south at instance '..crvat)
        -- find this instance and carve south
        --- this part isn't working correctly
        for kk,vv in pairs(self.grpcur) do
          if vv==v then 
            --printh('match of '..v..' to '..vv..' at pos '..kk)
            crvat-=1
            if crvat==0 then -- at the instance
              --printh('at '..kk)
              self:carve_south(kk, self.ony)
              self.grpnxt[kk] = self.grpcur[kk] -- copy the group number
            end
          end
        end
      end
    end
    --print_table(cvr)
    --printh('cvr       = ['..tblstr(cvr)..']')

    -- carve the verticals
    --[[
    ]]--
    --printh('\nmandatory vert done do optional')
    --print_table(self.grpcur)
    --printh('cur group = ['..tblstr(self.grpcur)..']')
    for x=1,_ctrl.ncol do -- for each box check if vertical
      -- check if south already
      if not self:has_carve(x, self.ony, _ds) then
        --printh("potential south carve on "..x)
        if rnd() > self.prob_vert then -- carve south
          --printh("positive carve south at x="..x)
          self:carve_south(x, self.ony)
          self.grpnxt[x] = self.grpcur[x] -- copy the group number
          add(self.grps, self.grpnxt[x]) -- took care of a vert w/this group
        end
      end
    end

      
    -- go to next row
    self.ony +=1
    --print_table(self.grpcur) 

    -- move next row to cur row
    for x=1,_ctrl.ncol do 
      if self.grpnxt[x] == 0 then
        self.grpcur[x] = self.grpn
        self.grpn += 1 -- next group
      else
        self.grpcur[x] = self.grpnxt[x]
      end
    end
    --printh("table replication")
    --printh('cur group = ['..tblstr(self.grpcur)..']')
    --printh('nxt group = ['..tblstr(self.grpnxt)..']')
    --print_table(self.grpcur)
    --print_table(self.grpnxt)

    -- check if at the end
    if self.ony == _ctrl.nrow then 
      self.state=self.st_step_end
    end
  end,

  st_step_end=function(self) -- one step of algo; ellers: first step 
    --printh("----------step end----------")
    --printh('cur group = ['..tblstr(self.grpcur)..']')
    for x=1,_ctrl.ncol-1 do -- these are 1..n for tracking
      if self.grpcur[x] != self.grpcur[x+1]  then -- carve east
        --printh('carving east x='..x..' ['..self.grpcur[x]..' != '..self.grpcur[x+1]..']')
        self:carve_east(x, self.ony)
        --self.grpcur[x+1] = self.grpcur[x] -- reset the group
        self:combine(self.grpcur[x+1], self.grpcur[x]) -- reset the group
      end
    end
    --print_table(self.grpcur)
    self.state=self.st_fini
  end,

  st_fini=function(self) -- done
    printh('fini')
  end,

  -- check if done w/maze gen
  done=function(self) return self.state==self.st_fini end,

  draw=function(self) -- additional drawing
  end,

  full_debug=function (self)
    printh("full debug -----------------------------------")
    for k,v in pairs(self) do
      if type(v)!="function" then
        printh("k="..k.." - "..tostring(v))
        if type(v)=="table" then print_table(v) end
      end
    end
  end,
}

-- ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== =====

function print_table(t,_nlc)
  -- nlc = number entries before cr
  if type(t)!="table" then return end
  local out="{"
  local nl=0
  local k,v
  local nlc=_nlc or 5
  for k,v in pairs(t) do
    if type(v) == "table" then
      if type(v[1]) == "table" then
        print_table(v)
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
function xy2v(_x,_y) return _x+(_y*_ctrl.ncol) end
function v2xy(_v) return _v%_ctrl.ncol, flr(_v/_ctrl.ncol) end
function free(_x,_y) return mget(_x,_y)==0 end
function tblstr(_t) out="" for j=1,#_t-1 do out=out.._t[j].."," end return out.._t[#_t] end
function shuffle(t) for i=#t,1,-1 do local j=flr(rnd(i))+1 t[i],t[j] = t[j],t[i] end end
function contains(_tbl,_el) for _ in all(_tbl) do if _==_el then return true end end return false end

-- highlight x,y map location w/rect of color c
function hilite(x,y,c) local x8=x*8 local y8=y*8 rect(x8+1, y8+1, x8+7,y8+7,c) end
function hifill(x,y,c) -- highlight x,y map location w/rect of color c
  local x8=x*8 local y8=y*8
  --fillp(0x33cc.8)
  fillp(0x5a5a.8) rectfill(x8+1, y8+1, x8+7,y8+7,c) fillp()
end
_rnd_dir = { -- get random dir vector
  dirs={{1,2,3,4},{1,2,4,3},{1,3,2,4},{1,3,4,2},{1,4,2,3},{1,4,3,2},
        {2,1,3,4},{2,1,4,3},{2,3,1,4},{2,3,4,1},{2,4,1,3},{2,4,3,1},
        {3,1,2,4},{3,1,4,2},{3,2,1,4},{3,2,4,1},{3,4,1,2},{3,4,2,1},
        {4,1,2,3},{4,1,3,2},{4,2,1,3},{4,2,3,1},{4,3,1,2},{4,3,2,1}},
  get=function(self) return _rnd_dir.dirs[irand(24)] end,
}
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
    _ctrl.auto_run=not _ctrl.auto_run

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

  if _ctrl.auto_run then
    _ctrl.time += 1
    if _ctrl.time > _ctrl.auto_bump then 
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
