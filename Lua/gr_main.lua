require "torch"
require "image"

Prototype = require "Prototype"
Word = require "Word"
Component = require "Component"
-- Lexicon = require "Lexicon"
Lexicon = require "Lexicon"

SPLIT_THRESHOLD = 0.65
START = '^'
END = '$'
UNKNOWN_COMPONENT = '.*'
--local STANDARD_COLOR = (0, 0, 0)
MINIMUM_COMPONENT_WIDTH = 4
LEXICON_FILENAME = "share/lexicon.txt"
DEBUG = true

ch = Prototype:new_from_image_file("share/ch.png", "ch")
c = Prototype:new_from_image_file('share/c.png', "c")
e = Prototype:new_from_image_file('share/e.png', "e")
page = image.load("share/page.png", 1)
ausschnitt = image.load("share/ausschnitt.png", 1)
indessen = Word:new(ausschnitt, {17, 5, 200, 65})
etliche = Word:new(ausschnitt, {433, 5, 551, 55})
lexicon = Lexicon.new(LEXICON_FILENAME)



-- function threshold(x)
--     if x >= 0.5 then return 1.0 else return 0 end
-- end

function threshold (mean)
    local mean = mean or 0.5

    return function (x)
        if x >= mean then return 0 else return 1.0 end
    end
end


function find_lines(img)
    local image_bw = img:clone():apply(threshold)
    local lines = {}
    local find_white = true

    for i=1, image_bw:size(2) do
        if find_white then
            if image_bw[{1, i, {}}]:eq(1):all() then
                goto continue
            else
                lines[#lines + 1] = i
                find_white = false
            end
        else
            if image_bw[{1, i, {}}]:eq(0):any() then
                goto continue
            else
                lines[#lines + 1] = i
                find_white = true
            end
        end
        ::continue::
    end
    return lines
end






function compare_image_region(image, sub_image)
    assert(image:size()[2] == sub_image:size(2))
    assert(image:size()[3] == sub_image:size(3))

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
    local ratios = torch.Tensor(image:size(2) - prototype_image:size(2) + 1,
                                image:size(3) - prototype_image:size(3) + 1)

    local component_image = image:clone():apply(threshold)
    local prototype_bw = prototype_image:clone():apply(threshold)

    for i=1, ratios:size(1) do
        for j=1, ratios:size(2) do
            local cropped_image = component_image:narrow(2, i, prototype_bw:size(2))
                                                 :narrow(3, j, prototype_bw:size(3))

            ratios[{i, j}] = compare_image_region(cropped_image, prototype_bw)
        end
    end

    -- return ratios
    for i=1, ratios:size(1) do
        for j=1, ratios:size(2) do
            if ratios[i][j] == ratios:max() then
                return i, j, ratios:max()
            end
        end
    end
end