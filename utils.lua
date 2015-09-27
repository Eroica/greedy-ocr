--[[
    greedy-ocr
    Original Work Copyright (c) 2015 Sebastian Spaar
------------------------------------------------------------------------
    utils.lua

]]


function shallowcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in pairs(orig) do
            copy[orig_key] = orig_value
        end
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

-- rgb2grey:
-- Takes an RGB color value and converts it to a greyscale value
-- (from 0 to 255). Based on the article at
-- http://www.johndcook.com/blog/2009/08/24/algorithms-convert-color-grayscale/
-- (Date retrieved: September 1st, 2015)
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


function trim_image (image)
    local function all_white (t)
        for i=1, #t do
            if t[i] ~= 255 then return false end
        end

        return true
    end

    local image_bw = threshold_image(image)
    local width = image_bw:getWidth()
    local height = image_bw:getHeight()

    local white_columns = {}
    local white_rows = {}

    for i=0, height - 1 do
        local row = {}

        for j=0, width - 1 do
            local r, g, b = image_bw:getData():getPixel(j, i)
            row[#row + 1] = rgb2grey(r, g, b)
        end

        if all_white(row) then
            white_rows[#white_rows + 1] = i
        end

    end

    for i=0, width - 1 do
        local column = {}

        for j=0, height - 1 do
            local r, g, b = image_bw:getData():getPixel(i, j)
            column[#column + 1] = rgb2grey(r, g, b)

        end

        if all_white(column) then
            white_columns[#white_columns + 1] = i
        end
    end

    -- check up until what index the array is continuous
    local BUFFER = 0

    local max_row_left = find_successor(white_rows, 1) - BUFFER
    local max_row_right = math.abs(#white_rows - find_antecessor(white_rows, #white_rows) - BUFFER)
    local max_column_left = find_successor(white_columns, 1) - BUFFER
    local max_column_right = math.abs(#white_columns - find_antecessor(white_columns, #white_columns) - BUFFER)

    local trimmed_image_data = love.image.newImageData(width - max_column_left - max_column_right, height - max_row_left - max_row_right)
    trimmed_image_data:paste(image:getData(), 0, 0, max_column_left, max_row_left, width - max_column_right, height - max_row_right)
    return love.graphics.newImage(trimmed_image_data)
end


function find_successor (t, i)
    if t[i + 1] ~= t[i] + 1 then
        return i
    else
        return find_successor(t, i + 1)
    end
end

function find_antecessor (t, i)
    if t[i - 1] ~= t[i] - 1 then
        return i
    else
        return find_antecessor(t, i - 1)
    end
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


-- invert_table:
-- Creates a new table from a given table, swapping every key-value
-- pair.
-- @params: t : table
-- @returns: table
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
-- (Date retrieved: September 1st, 2015)
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