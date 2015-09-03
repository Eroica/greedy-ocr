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








function compare_image_region(image, sub_image)
    assert(image:getWidth() == sub_image:getWidth())
    assert(image:getHeight() == sub_image:getHeight())

    local nom = 0
    local denom = 0

    for i=1, sub_image:getHeight() do
        for j=1, sub_image:getWidth() do
            local pixel = rgb2grey(image:getPixel(i, j))
            local sub_pixel = rgb2grey(sub_image:getPixel(i, j))

            nom = nom + bit.band(pixel, sub_pixel)
            denom = denom + bit.bor(pixel, sub_pixel)

            -- nom = nom + bit.band(image[{1, i, j}], sub_image[{1, i, j}])
            -- denom = denom + bit.bor(image[{1, i, j}], sub_image[{1, i, j}])
        end
    end

    local ratio = nom/denom

    return ratio
end

-- function overlay_images(image, prototype_image)
--     local ratios = torch.Tensor(image:size(2) - prototype_image:size(2) + 1,
--                                 image:size(3) - prototype_image:size(3) + 1)

--     local max_y = image:getHeight() - prototype_image:getHeight() + 1
--     local max_x = image:getWidth() - prototype_image:getWidth() + 1
--     local ratios = {}

--     for i=0, max_y do
--         for j=0, max_x do
--             local cropped_image = love.image.newImageData(prototype_image:getWidth(), prototype_image:getHeight())
--             cropped_image:paste(image, 0, 0, i, j, prototype_image:getWidth(), prototype_image:getHeight())



--     for i=1, ratios:size(1) do
--         for j=1, ratios:size(2) do
--             local cropped_image = component_image:narrow(2, i, prototype_bw:size(2))
--                                                  :narrow(3, j, prototype_bw:size(3))

--             ratios[{i, j}] = compare_image_region(cropped_image, prototype_bw)
--         end
--     end

--     -- return ratios
--     for i=1, ratios:size(1) do
--         for j=1, ratios:size(2) do
--             if ratios[i][j] == ratios:max() then
--                 return i, j, ratios:max()
--             end
--         end
--     end
-- end
