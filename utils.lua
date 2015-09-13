--[[
    greedy-ocr
    Original Work Copyright (c) 2015 Sebastian Spaar
------------------------------------------------------------------------
    utils.lua

]]

-- rgb2grey:
-- Takes an RGB color value and converts it to a greyscale value
-- (from 0 to 255). Based on the article at
-- http://www.johndcook.com/blog/2009/08/24/algorithms-convert-color-grayscale/
-- (last retrieved: September 1st, 2015)
--
-- @params: r, g, b : numbers
-- @returns: A number from 0 to 255.
function rgb2grey (r, g, b)
    return math.ceil(0.21*r + 0.72*g + 0.07*b)
end

-- threshold:
-- Used by `:mapPixel' to convert an image to a binary image.
-- A color value over `value' will get converted to white (255).
-- `value' can be specified when calling `threshold'. This creates a
-- closure!
--
-- @params: value : number
function threshold (value)
    local value = value or 127

    return function (x, y, r, g, b, a)
        local color = rgb2grey(r, g, b)

        if color > value then
            return 255, 255, 255
        else
            return 0, 0, 0
        end
    end
end

function threshold_image (image)
    local width, height = image:getWidth(), image:getHeight()
    local image_data = love.image.newImageData(width, height)
    image_data:paste(image:getData(), 0, 0, 0, 0, width, height)
    image_data:mapPixel(threshold())
    return love.graphics.newImage(image_data)
end

-- max_value:
-- Deprecated.
function max_value (t)
    return math.max(unpack(t))
end

-- max_pair:
-- Traverses a table and looks for the highest value. Returns this
-- value and the corresponding index (key).
function max_pair (t)
    local key, max = 1, t[1]

    for k, v in ipairs(t) do
        if t[k] > max then
            key, max = k, v
        end
    end

    return key, max
end


function table.flatten(arr)
        local result = { }

        local function flatten(arr)
            for _, v in ipairs(arr) do
                if type(v) == "table" then
                    flatten(v)
                else
                    table.insert(result, v)
                end
            end
        end

        flatten(arr)
        return result
    end


-- invert_table:
-- Deprecated.
function invert_table (t)
    local s = {}
    for k, v in pairs(t) do
        s[v] = k
    end

    return s
end

-- get_index:
-- Deprecated.
function get_index (t, index)
    local inverted_t = invert_table(t)
    return inverted_t[index]
end

-- explode:
-- Takes a string and splits it into segments. Similar to Python's
-- `split()' method.
-- Source: http://lua-users.org/wiki/MakingLuaLikePhp
-- Credit: http://richard.warburton.it/
-- (last retrieved: September 1st, 2015)
--
-- @params: div, str : string
--     div: The dividing string.
--     str: The string to be divided.
-- @returns: : table
function explode (div, str)
    if (div == "") then return false end
    local pos, arr = 0, {}
    for st, sp in function () return string.find(str, div, pos, true) end do
        table.insert(arr, string.sub(str, pos, st-1))
        pos = sp + 1
    end
    table.insert(arr, string.sub(str, pos))
    return arr
end