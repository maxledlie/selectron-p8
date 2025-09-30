pico-8 cartridge // http://www.pico-8.com

version 42

__lua__

LEFT = 0
RIGHT = 1
UP = 2
DOWN = 3
Z = 4
X = 5

-- GAMEPLAY CONSTANTS
MIN_SIZE = 2
SPEED = 4

-- GLOBAL STATE
x = 50
y = 50
width = 1
height = 1


-- SEMANTICS
--
-- DEFAULT  : arrows move top left
-- HOLDING Z: arrows move bottom right
--
-- x, y refer to the top left

function _draw()
    cls(5)

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

    -- Work out "boxlet" bounds
    -- Depending on our position there can be up to four smaller "boxlets" if we wrap around
    -- the x and/or y boundaries.

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

    -- Draw the four boxlets. Any with negative dimensions should be omitted.
    tl_color = btn(Z) and 6 or 8
    br_color = btn(Z) and 12 or 6
    for i, box in ipairs({ a, b, c, d }) do
        local x1 = box.x + box.width - 1
        local y1 = box.y + box.height - 1
        if box.width > 0 and box.height > 0 then
            if box.y ~= 0 then
                line(box.x, box.y, x1, box.y, tl_color)
            else
                dashed_line_horizontal(box.x, x1, box.y, tl_color)
            end

            if box.x ~= 0 then
                line(box.x, box.y, box.x, y1, btn(Z) and 6 or 8)
            else
                dashed_line_vertical(box.y, y1, box.x, tl_color)
            end

            if x1 ~= 127 then
                line(x1, box.y, x1, y1, btn(Z) and 12 or 6)
            else
                dashed_line_vertical(box.y, y1, x1, tl_color)
            end

            if y1 ~= 127 then
                line(box.x, y1, x1, y1, br_color)
            else
                dashed_line_horizontal(box.x, x1, y1, br_color)
            end
        end
    end

    -- Debug info
    color(7)
    print(x, 0, 0)
    print(y, 0, 8)
    print(width, 0, 16)
    print(height, 0, 24)
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

__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000