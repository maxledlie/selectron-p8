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

    rect(x, y, x + width, y + height)
end
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
