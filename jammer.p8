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
        if (btn(LEFT)) x = x - 1
        if (btn(RIGHT) and width > MIN_SIZE) x = x + 1
        if (btn(UP)) y = y - 1
        if (btn(DOWN) and height > MIN_SIZE) y = y + 1
        x = x % 128
        y = y % 128
    end

    if btn(Z) then
        if btn(LEFT) then
            width = max(width - 1, MIN_SIZE)
        end
        if btn(RIGHT) then
            width = width + 1
        end
        if btn(UP) then
            height = max(height - 1, MIN_SIZE)
        end
        if btn(DOWN) then
            height = height + 1
        end
    else
        if btn(LEFT) then
            width = width + 1
        end
        if btn(RIGHT) then
            width = max(width - 1, MIN_SIZE)
        end
        if btn(UP) then
            height = height + 1
        end
        if btn(DOWN) then
            height = max(height - 1, MIN_SIZE)
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
    for i, box in ipairs({ a, b, c, d }) do
        if box.width > 0 and box.height > 0 then
            line(box.x, box.y, box.x + box.width, box.y, btn(Z) and 6 or 8)
            line(box.x, box.y, box.x, box.y + box.height, btn(Z) and 6 or 8)
            line(box.x + box.width, box.y, box.x + box.width, box.y + box.height, btn(Z) and 12 or 6)
            line(box.x , box.y + box.height , box.x + box.width, box.y + box.height, btn(Z) and 12 or 6)
        end
    end

    -- Debug info
    color(7)
    print(x, 0, 0)
    print(y, 0, 8)
    print(width, 0, 16)
    print(height, 0, 24)


    -- color: highlight the upper left or lower right when active. grey otherwise.
    -- line(x, y, x + width, y, btn(Z) and 6 or 8)
    -- line(x, y, x , y + height, btn(Z) and 6 or 8)
    -- line(x + width, y, x + width, y + height, btn(Z) and 12 or 6)
    -- line(x , y + height , x + width, y + height, btn(Z) and 12 or 6)
end
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
