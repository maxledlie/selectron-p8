pico-8 cartridge // http://www.pico-8.com
version 42
__lua__

function _init()
    cartdata("rcjam_selectron_0_0_0")
end

LEFT = 0
RIGHT = 1
UP = 2
DOWN = 3
Z = 4
X = 5

DT = 1. / 30.

-- GAMEPLAY CONSTANTS
MIN_SIZE = 2
SPEED = 4
TIME_LIMIT = 60
LAMBDA = 0.7

-- GLOBAL STATE
x = 50
y = 50
width = 1
height = 1

state = { }

-- grid size is 16x16
-- virtual grid. dots plotted here. 
-- at dot generation time, consult this grid.
GRID_SIZE = 8
TILE_SIZE = 16

function state_reset()
    state = {
        good_dots = {},
        bad_dots = {},
        score = 0,
        game_time = 0,
        next_spawn_time = 0,
        game_over = false
    }
end

state_reset()

-- TYPES
function box_new(x, y, width, height)
    return  {
        x = x,
        y = y,
        width = width,
        height = height
    }
end


-- SEMANTICS
--
-- DEFAULT  : arrows move top left
-- HOLDING Z: arrows move bottom right
--
-- x, y refer to the top left

function compute_boxlets(full_box)
    -- Given current full box, returns x and y coordinates and dimensions of the
    -- boxlets. There may be up to four.
    local a = {
        width = min(width, 128 - x),
        height = min(height, 128 - y),
        x = x,
        y = y,
    }

    local b = {
        width = width - a.width,
        height = a.height,
        x = 0,
        y = y,
    }

    local c = {
        width = a.width,
        height = height - a.height,
        x = a.x,
        y = 0,
    }

    local d = {
        width = width - a.width,
        height = height - a.height,
        x = 0,
        y = 0,
    }

    ret = {}
    for i, boxlet in ipairs({a, b, c, d}) do
        if boxlet.width > 0 and boxlet.height > 0 then
            add(ret, boxlet)
        end
    end
    return ret
end

function is_selected(x, y, boxlets)
    -- Returns true if a given pixel is contained in the selection box
    
    for i, box in ipairs(boxlets) do 
        if x > box.x and x < box.x + box.width and
           y > box.y and y < box.y + box.height then
            return true
        end
    end
    
    return false
end

-- given the tile number (row major), return the pixel coords
function tile_coords(tile_index)
    local y_ = flr(tile_index / GRID_SIZE)
    local x_ = tile_index % GRID_SIZE
    return (x_ + 0.5) * TILE_SIZE, (y_ + 0.5) * TILE_SIZE
end

function calculate_score(boxlets)
    num_good_selected = 0
    num_bad_selected = 0
    for i, _ in pairs(state.good_dots) do 
        dot_x, dot_y = tile_coords(i)
        if (is_selected(dot_x, dot_y, boxlets)) then
            num_good_selected += 1
            state.good_dots[i] = nil
        end
    end
    for i, _ in pairs(state.bad_dots) do 
        dot_x, dot_y = tile_coords(i)
        if (is_selected(dot_x, dot_y, boxlets)) then
            num_bad_selected += 1
            state.bad_dots[i] = nil
        end
    end

    local score_change = num_good_selected*num_good_selected - 2*num_bad_selected*num_bad_selected
    state.score += score_change

    if score_change > 0 then
        sfx(0)
    else
        sfx(1)
    end
end

function ln(n)
    if (n <= 0) return nil
    local f, t = 0, 0
    while n < 0.5 do
    n *= 2.71828
    t -= 1
    end
    while n > 1.5 do
    n /= 2.71828
    t += 1
    end

    n -= 1
    for i = 9, 1, -1 do
    f = n*(1/i - f)
    end
    t += f
    -- to change base, change the
    -- divisor below to ln(base)
    return t
end

function get_next_spawn_time()
    -- sample from the exponential distribution with parameter LAMBDA
    
    -- first sample from uniform(0, 1)
    p = rnd(1)
    -- transform into exponential dist.
    res = -ln(p)/LAMBDA
    return res
end

function spawn_dot()
    -- Rejection sample until we find a tile index not occupied by a good or bad dot
    index = nil
    for attempt = 1, 1000 do
        i = flr(rnd(GRID_SIZE * GRID_SIZE + 1))
        if not (state.good_dots[i] or state.bad_dots[i]) then
            index = i
            break
        end
    end

    if index == nil then
        return
    end

    r = flr(rnd(4))
    if r == 1 then
        state.bad_dots[index] = true
    else
        state.good_dots[index] = true
    end

    state.next_spawn_time = state.game_time + get_next_spawn_time()
end

function _draw()
    if state.game_over then
        cls(0)
        print("game over!", 40, 40)
        print("score: "..state.score, 40, 50)
        print("high: "..dget(0), 40, 60)
        return
    end

    state.game_time += DT
    if state.game_time >= TIME_LIMIT then
        state.game_over = true
        if state.score > dget(0) then
            dset(0, state.score)
        end
    end

    if state.game_time >= state.next_spawn_time then
        spawn_dot()
    end

    if not btn(Z) then
        if (btn(LEFT)) x = x - SPEED
        if (btn(RIGHT) and width > MIN_SIZE) x = x + SPEED
        if (btn(UP)) y = y - SPEED
        if (btn(DOWN) and height > MIN_SIZE) y = y + SPEED
        x = x % 128
        y = y % 128
    end

    if btn(Z) then
        if btn(LEFT) then
            width = max(width - SPEED, MIN_SIZE)
        end

        if btn(RIGHT) then
            width = width + SPEED
        end
        if btn(UP) then
            height = max(height - SPEED, MIN_SIZE)
        end
        if btn(DOWN) then
            height = height + SPEED
        end
    else
        if btn(LEFT) then
            width = width + SPEED
        end
        if btn(RIGHT) then
            width = max(width - SPEED, MIN_SIZE)
        end
        if btn(UP) then
            height = height + SPEED
        end
        if btn(DOWN) then
            height = max(height - SPEED, MIN_SIZE)
        end
    end

    width = min(width, 127)
    height = min(height, 127)

    full_box = box_new(x, y, width, height)

    -- Work out "boxlet" bounds
    -- Depending on our position there can be up to four smaller "boxlets" if we wrap around
    -- the x and/or y boundaries.
    boxlets = compute_boxlets(full_box)

    -- DRAW
    cls(5)

    draw_dots()

    -- Draw the four boxlets. Any with negative dimensions should be omitted.
    tl_color = btn(Z) and 6 or 9
    br_color = btn(Z) and 12 or 6
    for i, box in ipairs(boxlets) do
        local x1 = box.x + box.width - 1
        local y1 = box.y + box.height - 1
        if box.y ~= 0 then
            line(box.x, box.y, x1, box.y, tl_color)
        else
            dashed_line_horizontal(box.x, x1, box.y, tl_color)
        end

        if box.x ~= 0 then
            line(box.x, box.y, box.x, y1, tl_color)
        else
            dashed_line_vertical(box.y, y1, box.x, tl_color)
        end

        if x1 ~= 127 then
            line(x1, box.y, x1, y1, br_color)
        else
            dashed_line_vertical(box.y, y1, x1, tl_color)
        end

        if y1 ~= 127 then
            line(box.x, y1, x1, y1, br_color)
        else
            dashed_line_horizontal(box.x, x1, y1, br_color)
        end
    end

    -- score calculation stuff
    if btnp(X) then
        calculate_score(boxlets)
    end

    -- Debug info
    color(7)
    -- print(x, 0, 8)
    -- print(y, 0, 16)
    -- print(width, 0, 24)
    -- print(height, 0, 32)
    print("score: "..state.score, 1, 1)
    print("high: "..dget(0), 40, 1)
    local display_time = max(0, flr(TIME_LIMIT - state.game_time))
    print("time: "..display_time, 90, 1)
end

function draw_dots()
    for i, _ in pairs(state.good_dots) do
        dot_x, dot_y = tile_coords(i)
        if is_selected(dot_x, dot_y, boxlets) then
            circ(dot_x, dot_y, 6, 10)
        end
        circfill(dot_x, dot_y, 5, 3)
    end
    for i, _ in pairs(state.bad_dots) do
        dot_x, dot_y = tile_coords(i)
        if is_selected(dot_x, dot_y, boxlets) then
            circ(dot_x, dot_y, 6, 10)
        end
        circfill(dot_x, dot_y, 5, 8)
    end
end

function dashed_line_horizontal(x0, x1, y, color)
    local DASH_SIZE = 5
    local GAP_SIZE = 4

    local pair_size = DASH_SIZE + GAP_SIZE
    local num_pairs = flr((x1 - x0) / pair_size)
    for i = 1, num_pairs do
        local pair_start = x0 + (i - 1) * pair_size
        line(pair_start, y, pair_start + DASH_SIZE - 1, y, color)
    end

    local r = (x1 - x0) % pair_size
    line(x1 - r, y, min(x1 - r + DASH_SIZE, x1), y, color)
end

function dashed_line_vertical(y0, y1, x, color)
    local DASH_SIZE = 5
    local GAP_SIZE = 4

    local pair_size = DASH_SIZE + GAP_SIZE
    local num_pairs = flr((y1 - y0) / pair_size)
    for i = 1, num_pairs do
        local pair_start = y0 + (i - 1) * pair_size
        line(x, pair_start, x, pair_start + DASH_SIZE - 1, color)
    end

    local r = (y1 - y0) % pair_size
    line(x, y1 - r, x, min(y1 - r + DASH_SIZE, y1), color)
end

function dump(o)
   if type(o) == 'table' then
      local s = '{ '
      for k,v in pairs(o) do
         if type(k) ~= 'number' then k = '"'..k..'"' end
         s = s .. '['..k..'] = ' .. dump(v) .. ','
      end
      return s .. '} '
   else
      return tostring(o)
   end
end

__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
00010000000000056002560035700457006570085700a5700b5700d570105701357016570185701b5701e5702257026570295702c5702e5703257035570375503855038550385503855000000000000000000000
00020000000003555036550325502c550295502d5502e5502a550225501e5502155023550225501b550115500e550105500e55008550025500055000000000000000000000000000000000000000000000000000
