--[[
    greedy-ocr
    Original Work Copyright (c) 2015 Sebastian Spaar
------------------------------------------------------------------------
    utils.lua

]]

function rgb2grey(r, g, b)
    -- http://www.johndcook.com/blog/2009/08/24/algorithms-convert-color-grayscale/
    return 0.21*r + 0.72*g + 0.07*b
end

function threshold(value)
    -- this creates a clojure
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


function max_value(t)
    return math.max(unpack(t))
end

function max_pair(t)
    local key, max = 1, t[1]

    for k, v in ipairs(t) do
        if t[k] > max then
            key, max = k, v
        end
    end

    return key, max
end

function invert_table(t)
    local s = {}
    for k, v in pairs(t) do
        s[v] = k
    end

    return s
end

function get_index(t, index)
    local inverted_t = invert_table(t)
    return inverted_t[index]
end


-- Source: http://lua-users.org/wiki/MakingLuaLikePhp
-- Credit: http://richard.warburton.it/
function explode(div,str)
    if (div=='') then return false end
    local pos,arr = 0,{}
    for st,sp in function() return string.find(str,div,pos,true) end do
        table.insert(arr,string.sub(str,pos,st-1))
        pos = sp + 1
    end
    table.insert(arr,string.sub(str,pos))
    return arr
end