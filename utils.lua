MINIMUM_COMPONENT_WIDTH = 10

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

function split_segment_at (segment, start, _end)
    local s = math.max(0, start)
    local e = math.min(segment:get(Size).width, _end)

    assert(e - s > 0)

    local affected_components = {}
    for i=1, #segment.components do
        local comp = segment.components[i]
        local comp_range = comp:get(Range)

        if comp:get(String).string ~= ".*" then
            goto continue
        end

        if ((comp_range.s >= s and comp_range.s <= e) or (comp_range.e >= s and comp_range.e <= e))
        or ((comp_range.s <= s and s <= comp_range.e) or comp_range.s <= e and e <= comp_range.e) then
            table.insert(affected_components, i)
        end

        ::continue::
    end

    local left_component = segment.components[affected_components[1]]
    local right_component = segment.components[affected_components[#affected_components]]

    for i=#affected_components, 1, -1 do
        table.remove(segment.components, affected_components[i])
    end

    local new_components = {}
    if math.abs(left_component:get(Range).s - s) >= MINIMUM_COMPONENT_WIDTH then
        table.insert(new_components, entities.newComponent(left_component:get(Range).s, s))
    end

    table.insert(new_components, entities.newComponent(s, e))

    if math.abs(right_component:get(Range).e - e) >= MINIMUM_COMPONENT_WIDTH then
        table.insert(new_components, entities.newComponent(e, right_component:get(Range).e))
    end

    for i=1, #new_components do
        table.insert(segment.components, affected_components[1] + i - 1, new_components[i])
    end
end
