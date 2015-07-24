require "torch"
require "image"

Prototype = require "Prototype"
Word = require "Word"
Component = require "Component"

ch = Prototype:new_from_image_file("share/ch.png", "ch")
c = Prototype:new_from_image_file('share/c.png', "c")
e = Prototype:new_from_image_file('share/e.png', "e")
ausschnitt = image.load("share/ausschnitt.png", 1)
indessen = Word:new(ausschnitt, {17, 5, 200, 65})
etliche = Word:new(ausschnitt, {433, 5, 551, 55})

local SPLIT_THRESHOLD = 0.65
local START = '^'
local END = '$'
local UNKNOWN_COMPONENT = '.*'
--local STANDARD_COLOR = (0, 0, 0)
--local MINIMUM_COMPONENT_WIDTH = 4


function threshold(x)
    if x >= 0.5 then return 1.0 else return 0 end
end

function compare_image_region(image, sub_image)
    assert(image:size()[2] == sub_image:size()[2])
    assert(image:size()[3] == sub_image:size()[3])


    -- image_bw = image:clone():apply(threshold)
    -- sub_image_bw = sub_image:clone():apply(threshold)

    local nom = 0
    local denom = 0

    for i=1, sub_image:size()[2] do
        for j=1, sub_image:size()[3] do
            nom = nom + bit.band(image[{1, i, j}], sub_image[{1, i, j}])
            denom = denom + bit.bor(image[{1, i, j}], sub_image[{1, i, j}])
        end
    end

    local ratio = nom/denom

    return ratio
end

function overlay_images(image, prototype_image)
    local ratios = torch.Tensor(image:size()[2] - prototype_image:size()[2] + 1,
                          image:size()[3] - prototype_image:size()[3] + 1)

    local component_image = image:clone():apply(threshold)
    local prototype_bw = prototype_image:clone():apply(threshold)

    for i=1, ratios:size()[1] do
        for j=1, ratios:size(2) do
            local cropped_image = component_image:narrow(2, i, prototype_bw:size()[2])
                                                 :narrow(3, j, prototype_bw:size()[3])

            ratios[{i, j}] = compare_image_region(cropped_image, prototype_bw)
        end
    end

    -- return ratios
    for i=1, ratios:size()[1] do
        for j=1, ratios:size()[2] do
            if ratios[i][j] == ratios:max() then
                return i, j, ratios:max()
            end
        end
    end
end


-- Greedy = {}

-- local function threshold(x)
--     if x >= 0.5 then return 1.0 else return 0 end
-- end

-- function Greedy.compare_image_region(image, sub_image)
--     assert(image:size()[2] == sub_image:size()[2])
--     assert(image:size()[3] == sub_image:size()[3])

--     local nom = 0
--     local denom = 0

--     image_bw = image:clone():apply(threshold)
--     sub_image_bw = sub_image:clone():apply(threshold)

--     for i=1, sub_image_bw:size()[2] do
--         for j=1, sub_image_bw:size()[3] do
--             nom = nom + (image_bw[{1, i, j}] and sub_image_bw[{1, i, j}])
--             denom = denom + (image_bw[{1, i, j}] or sub_image_bw[{1, i, j}])
--         end
--     end

--     ratio = nom/(denom) + 0.0

--     return ratio
-- end

