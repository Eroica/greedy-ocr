--[[
    greedy-ocr
    Original Work Copyright (c) 2015 Sebastian Spaar
------------------------------------------------------------------------
    utils.lua

]]

function count_pixel_color (image, count_white)
    local pixel_color = 0
    if count_white then pixel_color = 255 end

    local count = 0
    for i=0, image:getWidth() - 1 do
        for j=0, image:getHeight() - 1 do
            local r, g, b = image:getData():getPixel(i, j)
            if rgb2grey(r, g, b) == pixel_color then
                count = count + 1
            end
        end
    end

    return count
end


-- rgb2grey:
-- Takes an RGB color value and converts it to a greyscale value
-- (from 0 to 255). Based on the article at
-- http://www.johndcook.com/blog/2009/08/24/algorithms-convert-color-grayscale/
-- (Date retrieved: September 1st, 2015)
--
-- @params:  r, g, b: R, G, B values
--                    @type: number
-- @returns: A number from 0 to 255.
--           @type: number
function rgb2grey (r, g, b)
    return math.ceil(0.21*r + 0.72*g + 0.07*b)
end

-- threshold:
-- Used by `:mapPixel' to convert an image to a binary image.
-- A color value over `value' will get converted to white (255).
-- `value' can be specified when calling `threshold'. This creates a
-- closure!
--
-- @params:  value: The threshold value
--                  @type: number
-- @returns: A threshold function
--           @type: function
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

-- threshold_image:
-- Takes an image and creates a binary image out of it.
--
-- @params: image: The image to be thresholded
--                 @type: Image (love2d's image format)
-- @returns: @type: Image (love2d's image format)
function threshold_image (image)
    local width, height = image:getWidth(), image:getHeight()
    local image_data    = love.image.newImageData(width, height)
    image_data:paste(image:getData(), 0, 0, 0, 0, width, height)
    image_data:mapPixel(threshold())
    return love.graphics.newImage(image_data)
end

-- trim_image:
-- Cuts away white pixels that make up an image's border.
--
-- @params:  image: An image
--                  @type: Image
-- @returns: @type: Image
function trim_image (image)
    local function all_white (t)
        for i=1, #t do
            if t[i] ~= 255 then return false end
        end --inner for

        return true
    end

    local image_bw = threshold_image(image)
    local width    = image_bw:getWidth()
    local height   = image_bw:getHeight()

    local white_columns = {}
    local white_rows    = {}

    for i=0, height - 1 do
        local row = {}

        for j=0, width - 1 do
            local r, g, b = image_bw:getData():getPixel(j, i)
            row[#row + 1] = rgb2grey(r, g, b)
        end --inner for

        if all_white(row) then
            white_rows[#white_rows + 1] = i
        end --inner if
    end --for

    for i=0, width - 1 do
        local column = {}

        for j=0, height - 1 do
            local r, g, b = image_bw:getData():getPixel(i, j)
            column[#column + 1] = rgb2grey(r, g, b)
        end --inner for

        if all_white(column) then
            white_columns[#white_columns + 1] = i
        end --inner if
    end --for

    -- Keep a buffer of n white pixels
    local BUFFER = 0

    local white_pixels_left = 0
    if #white_columns ~= 0 then
        white_pixels_left = find_successor(white_columns, 1) - BUFFER
    end

    local white_pixels_right = 0
    if white_columns[#white_columns] == width - 1 then
        white_pixels_right =   #white_columns
                             - find_antecessor(white_columns, #white_columns)
                             + 1
    end

    local white_pixels_top = 0
    if #white_rows ~= 0 then
        local white_pixels_top = find_successor(white_rows, 1) - BUFFER
    end

    local white_pixels_bottom = 0
    if white_rows[#white_rows] == height - 1 then
        white_pixels_bottom =   #white_rows
                              - find_antecessor(white_rows, #white_rows)
                              + 1
    end

    local trimmed_width      = width  - white_pixels_left - white_pixels_right
    local trimmed_height     = height - white_pixels_top  - white_pixels_bottom
    local trimmed_image_data = love.image.newImageData(trimmed_width,
                                                       trimmed_height)

    trimmed_image_data:paste(image:getData(),
                             0, 0,
                             white_pixels_left, white_pixels_top,
                             width  - white_pixels_right,
                             height - white_pixels_bottom)

    return love.graphics.newImage(trimmed_image_data)
end

-- find_successor:
-- In a sequence (a table that consists of number values), checks until
-- which index the sequence is without holes. For example:
-- {0, 1, 2, 4, 5} --> 3
--
-- @params:  t @type: table
--           i: The index from which to start counting. Defaults to 1.
--              @type: number
-- @returns: @type: number
function find_successor (t, i)
    local i = i or 1

    if t[i + 1] ~= t[i] + 1 then
        return i
    else
        return find_successor(t, i + 1)
    end
end

-- find_antecessor:
-- In a sequence (a table that consists of number values), checks until
-- which index the sequence is without holes FROM THE BACK. For example:
-- {0, 1, 2, 4, 5} --> 4
--
-- @params:  t @type: table
--           i: The index from which to start counting. Defaults to #t.
--              @type: number
-- @returns: @type: number
function find_antecessor (t, i)
    local i = i or #t

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
--
-- @params: t @type: table
-- @returns:
--     key @type: number
--     max @type: number
function max_pair (t)
    local key, max = 1, t[1]

    for k, v in ipairs(t) do
        if t[k] > max then
            key, max = k, v
        end --inner if
    end

    return key, max
end


-- invert_table:
-- Creates a new table from a given table, swapping every key-value
-- pair.
-- @params: t @type: table
-- @returns: @type: table
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
-- @params: div, str
--     div: The dividing string.
--          @type: string
--     str: The string to be divided.
--          @type: string
-- @returns: : table
function explode (div, str)
    if (div == "") then return false end
    local pos, arr = 0, {}
    for st, sp in function () return string.find(str, div, pos, true) end do
        table.insert(arr, string.sub(str, pos, st - 1))
        pos = sp + 1
    end
    table.insert(arr, string.sub(str, pos))
    return arr
end