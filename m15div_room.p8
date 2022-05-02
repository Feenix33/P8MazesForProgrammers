pico-8 cartridge // http://www.pico-8.com
version 34
__lua__
--[[
-- maze 15 recursive division
--
]]--
-- ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== =====
_dn,_de,_ds,_dw=1,2,4,8
_sbase=16 -- 16-31 maze n1 e2 s4 w8 if true then draw wall
-- _sbase=32 -- 32-47 maze n1 e2 s4 w8 if true then draw thin wall
-- _sbase=48 -- 48-63 numbers 0-15
-- _sbase=64 -- 64-79 maze n1 e2 s4 w8 if true then draw space
-- _sbase=80 -- 80-95 color blocks

-- ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== =====
_ctrl={ --  recursive division
-- control
  nrow=16,
  ncol=16,
  auto_run=false,
  time=0,
  auto_bump=5,--10,
  grid=false,
  start_msg=false,
  state=nil,
  srnd=false,
}

_algo={ --  recursive division
  -- generic helper variables
  dx={0,1,0,-1}, -- dx by dir
  dy={-1,0,1,0}, -- dy by dir
  rdir={_dn,_de,_ds,_dw},
  odir={_ds,_dw,_dn,_de},
  i2d={_dn,_de,_ds,_dw},
}


--counter = 0 -- hack to stop algo for debug
--counter_trip = 2

function recursive_division(_w, _h)

  function divide(x, y, w, h, o, l)
    --if w < 2 then return end
    --if h < 2 then return end
    if w < 2 or h < 2 then return end
    if w < 5 and h < 5 and irand(4) == 1 then printh("abandon") return end


    local lvl = l or -1 -- log level
    local cx,cy -- cut location
    local ax,xy -- at location
    local px,py -- passage
    local ind =''
    local v -- value of pixel while setting wall
    local len -- wall length
    local nx,ny,nw,nh,no -- new dim for sub rect
    local vert=(o==1)
    local mask1, mask1 -- for setting the walls 


    -- set log level
    for n=1,lvl do ind=ind..'  .' end
    --counter += 1
    --if counter >  counter_trip  then return end
    --log(1, "\n----- ----- counter="..counter, ind)
    --log(1, "divide vert x="..x..' y='..y..' w='..w..' h='..h..' o='..o..' l='..lvl..' vert='..tostr(vert), ind)

    -- cut the rect
    -- vert cut
    if vert then
      cx = irand(w-1)-1
      --cx = 1
      cy = y
      dx = 0
      dy = 1
      ax,ay=x+cx,y
      len = h
      px = ax
      py = ay+irand0(len)
      mask1,mask2 = 0b1111111111111101,0b1111111111110111
    else -- horizontal cut
      cx = x
      cy = irand(h-1)-1
      --cy = ceil(h/2)-1
      --cy = h-2
      dx = 1
      dy = 0
      ax,ay=x,y+cy
      len = w
      px = ax+irand0(len)
      py = ay
      mask1,mask2 = 0b1111111111111011, 0b1111111111111110
    end
    log(3, "cut at cx="..cx..' cy='..cy, ind)
    log(3, 'pas at px='..px..' py='..py, ind)

    --mmmmmmmmm
    while len > 0 do
      if vert then
        if (ax!=px) or (ay!=py) then
          v = band(mget(ax,ay), mask1)
          mset(ax, ay, v)
          v = mget(ax,ay-1) - _ds
          v = band(mget(ax+1,ay),mask2)
          mset(ax+1, ay, v)
        end
      else
        if (ax!=px) or (ay!=py) then
          v = band(mget(ax,ay),mask1)
          mset(ax, ay, v)
          v = mget(ax-1,ay) - _ds
          v = band(mget(ax,ay+1), mask2)
          mset(ax, ay+1, v)
        end
      end

      ax += dx
      ay += dy
      len -= 1
    end

    -- cut left/top
    if vert then
      nx,ny = x,y
      nw,nh = cx+1,h
    else
      nx,ny = x,y
      nw,nh = w, cy+1
    end
    no = orient(nw,nh)
    log(3,'left/top rect x='..nx..' y='..ny..' w='..nw..' h='..nh, ind)
    divide(nx, ny, nw, nh, no, lvl+1)
    

    -- cut right/bottom
    --[[
    ]]--
    if vert then
      nx,ny = x+cx+1, y
      nw,nh = w-cx-1, h
    else
      nx,ny = x, y+cy+1
      nw,nh = w, h-cy-1
    end
    no = orient(nw,nh)
    log(3,'right/bot rect x='..nx..' y='..ny..' w='..nw..' h='..nh, ind)
    divide(nx, ny, nw, nh, no, lvl+1)
  end

  function orient(w,h)
    if w < h then return 0 end
    if w > h then return 1 end
    return irand0(2)
  end

  function init_recursive(_x,_y,_w,_h)
    log (1, 'init recursive', '----===---')
    for y=_y+1,_y+_h-2 do
      for x=_x+1,_x+_w-2 do
        mset(x,y,15)
      end
    end
    for y=_y,_y+_h-1 do mset(_x,y, 7) mset(_x+_w-1,y, 13) end
    for x=_x,_x+_w-1 do mset(x,_y, 14) mset(x,_y+_h-1, 11) end
    mset(_x,_y, 6)
    mset(_x,_y+_h-1, 3)
    mset(_x+_w-1,_y, 12)
    mset(_x+_w-1,_y+_h-1, 9)
  end
  function add_sbase()
    log(1, 'adding sbase')
    for y=0, _ctrl.nrow-1 do
      for x=0, _ctrl.ncol-1 do
        mset(x,y,mget(x,y)+_sbase)
      end
    end
  end

  ------ algo main -----
  -- xxxx yyyy zzzz
  if _ctrl.srnd then srand(1) end
  --counter = 0
  log (1, "recursive division w=".._w..' h='.._h)
  init_recursive(0,0,_w,_h) -- clear the base
  divide(0, 0, _w, _h, irand0(2), 0) 
  add_sbase()
end

function print_map(w,h)
  local out
  local v
  printh('==================================================')
  for y=0,h-1 do
    out=''
    for x=0,w-1 do
      v = mget(x,y) - _sbase
      if v < 10 then out = out..' ' end
      out = out..v..' '
    end
    printh(out)
  end
  printh('==================================================')
end

-- ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== =====
-- collection of support functions
-- ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== =====
function log(_lvl, _msg, _ind) local ind=_ind or '' if _lvl < 1 then printh(ind.._msg) end end
function irand(n) return ceil(rnd(n)) end -- rand in [1..n]
function irand0(n) if (n==0) then return 0 else return ceil(rnd(n))-1 end end -- rand in [0..n)
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
  for y=0,_ctrl.nrow-1 do
    for x=0,_ctrl.ncol-1 do
      mset(x,y,0)
    end
  end
end

-- ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== =====
function _init() --iiiiiii
  -- print a runtime note
  if _ctrl.start_msg then
    local div,m m=stat(94) if m < 10 then div=":0" else div=":" end
    local siv,s s=stat(95) if s < 10 then siv=":0" else siv=":" end
    printh ('\n\n-------------------- '..stat(93)..div..m..siv..s..' --------------------')
  end
  -- init the map
  init_maze()

  --for x=0, _ctrl.ncol-1 do mset(x, _ctrl.nrow, 48+x) end
end

function _update() --uuuuuuuu

  if btnp(0) then
    --printh("Btn 0 left")
    --_ctrl:state()
    --counter_trip -= 1
    --if counter_trip < 1 then counter_trip = 1 end
    --log('counter_trip = '..counter_trip, 3)

  elseif btnp(1) then
    --printh("Btn 1 right")
    --_ctrl.auto_run=not _ctrl.auto_run
    --counter_trip += 1
    --log('counter_trip = '..counter_trip, 3)

  elseif btnp(2) then 
    --printh("Btn 2 up")
    recursive_division(_ctrl.ncol, _ctrl.nrow)

  elseif btnp(3) then
    --printh("Btn 3 down")
    init_maze()
    _ctrl.srnd = not _ctrl.srnd
    log (1, 'srand ctrl='..tostr(_ctrl.srnd), '########')

  elseif btnp(4) then
    --printh("Btn 4 = cv")
  print_map(_ctrl.ncol, _ctrl.nrow)

  elseif btnp(5) then
    --printh("Btn 5 = nm")
    _ctrl.grid = not _ctrl.grid
  end

  --[[
  if _ctrl.auto_run then
    _ctrl.time += 1
    if _ctrl.time > _ctrl.auto_bump then 
      _ctrl.time = 0
      if not _ctrl:done() then _ctrl:state() end
    end
  end
  ]]--
end

function _draw() --dddddd
  cls()
  --mapdraw(0, 0, 0, 0, _ctrl.ncol, _ctrl.nrow)
  mapdraw(0, 0, 0, 0, _ctrl.ncol+1, _ctrl.nrow+1)
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
  
  --_algo:draw()
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
