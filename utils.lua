

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
