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
  nrow=5,
  ncol=6,
  auto_run=false,
  time=0,
  auto_bump=5,--10,
  grid=false,
  start_msg=true,
  state=nil,
  srnd=true,
}

_algo={ --  recursive division
  -- generic helper variables
  dx={0,1,0,-1}, -- dx by dir
  dy={-1,0,1,0}, -- dy by dir
  rdir={_dn,_de,_ds,_dw},
  odir={_ds,_dw,_dn,_de},
  i2d={_dn,_de,_ds,_dw},
}


counter = 0
counter_trip = 2

function recursive_division(_w, _h)

  function divide(x, y, w, h, o, l)
    if w < 2 then return end
    if h < 2 then return end


    local lvl = l or -1
    local cx,cy -- cut location
    local ax,xy -- at location
    local px,py -- passage
    local ind =''
    local v -- value of pixel while setting wall
    local len -- wall length
    local nx,ny,nw,nh,no -- new dim for sub rect
    local vert=(o==1)



    for n=1,lvl do ind=ind..'  .' end
    counter += 1
    --if counter >  counter_trip  then return end
    log(1, "\n----- ----- counter="..counter, ind)
    log(1, "divide vert x="..x..' y='..y..' w='..w..' h='..h..' o='..o..' l='..lvl..' vert='..tostr(vert), ind)

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
    else
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
    end
    log(3, "cut at cx="..cx..' cy='..cy, ind)
    log(3, 'pas at px='..px..' py='..py, ind)
    --log(3, "       dx="..dx..' dy='..dy, ind)

    --mmmmmmmmm
    while len > 0 do
      if vert then
        if (ax!=px) or (ay!=py) then
          v = band(mget(ax,ay), 0b1111111111111101)
          mset(ax, ay, v)
          v = mget(ax,ay-1) - _ds
          v = band(mget(ax+1,ay),0b1111111111110111)
          mset(ax+1, ay, v)
        end
      else
        if (ax!=px) or (ay!=py) then
          v = band(mget(ax,ay),0b1111111111111011)
          mset(ax, ay, v)
          v = mget(ax-1,ay) - _ds
          v = band(mget(ax,ay+1), 0b1111111111111110)
          mset(ax, ay+1, v)
        end
      end

      ax += dx
      ay += dy
      len -= 1
    end

    --log (3, 'done vert cx='..cx..' cy='..cy..' ax='..ax..' ay='..ay, ind)
    -- cut finished, decide which way to cut and then cut
    -- orientation =
    --no=0
    --log(3, 'slice w='..w..' h='..h..' o='..no, ind)

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
  if _ctrl.srnd then
    srand(1)
  end
  counter = 0
  log (1, "recursive division w=".._w..' h='.._h)
  init_recursive(0,0,_w,_h) -- clear the base
  divide(0, 0, _w, _h, irand0(2), 0) -- todo: convert last entry to rand
  --divide(0, 0, _w, _h, 1, 0) -- todo: convert last entry to rand
  add_sbase()
end


function recursive_division_try01(_w, _h)

  --function divide_vert(x, y, w, h, o)
  function divide(x, y, w, h, o, l)

    local lvl = l or -1

    if h < 2 or w<2 then log(3, "rtn h="..h.." w="..w..' l='..l) return end

    local ind =''
    for n=1,lvl do ind=ind..'  .' end

    counter += 1
    --if counter >= 3 then stop() end
    --if counter >=  4 then return end
    if counter >  counter_trip  then return end
    printh ("\n----- ----- counter="..counter)

    log(2, "divide vert x="..x..' y='..y..' w='..w..' h='..h..' o='..o..' l='..lvl, ind)

    --local hz = (o==0) -- horizontal if orientation = 0
    --log(5, 'hz = '..tostr(hz))

    -- cut the rect
    local wx, wy, len, temp
    temp = irand0(w-2)
    wx = x + temp
    wy = y
    len = h

    log(3, "cut at wx="..wx..' wy='..wy..' x='..x..' w='..temp..' len='..len, ind)


    --vert wall
    local v
    local dx, dy

    dx = 0
    dy = 1
    
    -- passage
    local px, py
    px = wx
    py = irand0(len)
    log(1, 'passage at '..px..','..py, ind)

    while len > 0 do
      if (wx!=px) or (wy!=py) then
      --if wx!=px then
        --v = mget(wx,wy) - _dn
        v = band(mget(wx,wy), 0b1111111111111101)
        mset(wx, wy, v)
        --v = mget(wx,wy-1) - _ds
        v = band(mget(wx+1,wy),0b1111111111110111)
        mset(wx+1, wy, v)
        --log(3, 'setting '..wx..','..wy, ind)
      end
      wx += dx
      wy += dy
      len -= 1
    end

    -- do a h cut
    --local nh=wy-y
    --log(1, 'nh = '..nh)
    local nw, nh
    local nx,ny

    nw = wx+1
    nh = h
    nx = x
    ny = y
    if nw > 1 then
      log(1, 'calling divide_l(x='..nx..', y='..ny..', w='..nw..', h='..nh..' l='..l..')', ind)
    end
    divide (nx, ny, nw, nh, 1, lvl+1)
    --[[
    ]]--

    nx = x + nw --need old x,y
    ny = y
    nw = w-wx-1 
    nh = h
    if nw > 1 then
      log(1, 'calling divide_r(x='..nx..', y='..ny..', w='..nw..', h='..nh..' l='..l..')', ind)
    end
    divide (nx, ny, nw, nh, 1, lvl+1)

  end
  function divide_horz(x, y, w, h, o)

    if h < 2 or w<2 then return end

    counter += 1
    --if counter >= 3 then stop() end
    --if counter >= 5 then return end
    printh ("----- ----- counter="..counter)

    log(2, "\ndivide x="..x..' y='..y..' w='..w..' h='..h..' o='..o)

    --local hz = (o==0) -- horizontal if orientation = 0
    --log(5, 'hz = '..tostr(hz))

    -- cut the rect
    local wx, wy, len
    wx = x
    --wy = y + flr(h/2)
    wy = y + irand(h-1)
    len = w

    log(3, "wx="..wx..' wy='..wy..' len='..len)


    --horz wall
    local v
    local dx, dy

    dx = 1
    dy = 0
    
    -- passage
    local px, py
    px = irand0(len)
    py = wy
    log(1, 'passage at '..px..','..py)

    while len > 0 do
      if (wx!=px) or (wy!=py) then
      --if wx!=px then
        --v = mget(wx,wy) - _dn
        v = band(mget(wx,wy), 0b1111111111111110)
        mset(wx, wy, v)
        --v = mget(wx,wy-1) - _ds
        v = band(mget(wx,wy-1),0b1111111111111011)
        mset(wx, wy-1, v)
        --log(3, 'setting '..wx..','..wy)
      end
      wx += dx
      wy += dy
      len -= 1
    end

    -- do a h cut
    --local nh=wy-y
    --log(1, 'nh = '..nh)

    log(1, 'calling divide1(x='..x..', y='..y..', w='..w..', h='..(wy-y)..')')
    divide (x, y, w, (wy-y), 1)

    log(1, 'calling divide2(x='..x..', y='..wy..', w='..w..', h='..(y+h-wy)..')')
    divide (x, wy, w, y+h-wy, 1)

  end



  function combodivide(x, y, w, h, o)

    if h<2 or w<2 then return end

    local hz = (o==0) -- horizontal if orientation = 0
    local wx, wy, len
    local v
    local dx, dy -- wall coords
    local px, py -- passage
    local wall1, wall2
    local ox, oy


    counter += 1
    --if counter >= 3 then stop() end
    --if counter >= 5 then return end
    if counter >= 9 then return end
    log (5, "----- ----- counter="..counter)

    log(2, "\ndivide x="..x..' y='..y..' w='..w..' h='..h..' o='..o)

    log(5, 'hz = '..tostr(hz))

    -- cut the rect
    if hz then
      wx = x
      wy = y + irand(h-1)
      len = w
    else
      --log(5, 'setting vert 1')
      wx = x + irand0(w-1)
      wy = y
      len = h
    end

    log(3, "wx="..wx..' wy='..wy..' len='..len)


    if hz then
      --horz wall
      dx = 1
      dy = 0
    
      -- passage
      px = irand0(len)
      py = wy
    else
      --log(5, 'setting vert 2 wall')
      --log(3, "wx="..wx..' wy='..wy..' len='..len)
      --vert wall
      dx = 0
      dy = 1
    
      -- passage
      px = wx
      py = irand0(len)
    end

    log(1, 'passage at '..px..','..py)


    if hz then
      wall1 = 0b1111111111111110
      wall2 = 0b1111111111111011
      ox=0
      oy=-1
    else
      log(5, 'setting vert 2 params')
      wall1 = 0b1111111111111101
      wall2 = 0b1111111111110111
      ox=1
      oy=0
    end

    while len > 0 do
      if (wx!=px) or (wy!=py) then
        v = band(mget(wx,wy), wall1)
        mset(wx, wy, v)
        v = band(mget(wx+ox,wy+oy),wall2)
        mset(wx+ox, wy+oy, v)
      end
      wx += dx
      wy += dy
      len -= 1
    end

    --hz = irand0(2) == 0
    --log(5, 'cut with hz = '..tostr(hz))
    if hz then
      log(1, 'calling divide1 horz(x='..x..', y='..y..', w='..w..', h='..(wy-y)..')')
      divide (x, y, w, (wy-y), 0)

      log(1, 'calling divide2 horz(x='..x..', y='..wy..', w='..w..', h='..(y+h-wy)..')')
      divide (x, wy, w, y+h-wy, 0)
    else
      if (wx-x) > 1 then
        log(1, 'calling divide1 vert(x='..x..', y='..y..', w='..(wx-x)..', h='..(h)..')')
        divide (x, y, (wx-x), (h), 1)
      end

      if (x+w-wx) > 1 then
        log(1, 'calling divide2 vert(x='..x..', y='..wy..', w='..(x+w-wx)..', h='..(h)..')')
        divide (x, wy, (x+w-wx), h, 1)
      end
    end

  end

  function add_sbase()
    log(1, 'adding sbase')
    for y=0, _ctrl.nrow-1 do
      for x=0, _ctrl.ncol-1 do
        mset(x,y,mget(x,y)+_sbase)
      end
    end
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

  ------ algo main -----
  -- xxxx yyyy zzzz
  srand(1)
  counter = 0
  log (1, "recursive division w=".._w..' h='.._h)
  init_recursive(0,0,_w,_h) -- clear the base
  divide(0, 0, _w, _h, 1, 0) -- todo: convert last entry to rand
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
function log(_lvl, _msg, _ind) local ind=_ind or '' if _lvl < 5 then printh(ind.._msg) end end
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

  for x=0, _ctrl.ncol-1 do
    mset(x, _ctrl.nrow, 48+x) 
  end
end

function _update() --uuuuuuuu

  if btnp(0) then
    --printh("Btn 0 left")
    --_ctrl:state()
    counter_trip -= 1
    if counter_trip < 1 then counter_trip = 1 end
    printh('counter_trip = '..counter_trip)

  elseif btnp(1) then
    --printh("Btn 1 right")
    --_ctrl.auto_run=not _ctrl.auto_run
    counter_trip += 1
    printh('counter_trip = '..counter_trip)

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
