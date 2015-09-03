ecs = require "lib/ecs"
lovebird = require "lib/lovebird"
inspect = require "lib/inspect"
lurker = require "lib/lurker"

entities = require "entities"
require "components"
require "engines"
require "systems"
require "utils"
local config = require "_config"

lurker.postswap = function(f) print("File " .. f .. " was swapped") end

etliche = love.graphics.newImage("share/etliche.png")
etliche:getData():mapPixel(threshold())


sub_etliche = love.image.newImageData(20, 20)
sub_etliche:paste(etliche:getData(), 0, 0, 5, 5, 20, 20)
sub_image = love.graphics.newImage(sub_etliche)

x, y = 0, 0

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

function load_prototypes()
    for _, prototype in pairs(config.prototypes) do
        local image = love.graphics.newImage(prototype[2])
        entities.newPrototype(prototype[1], image)
    end
end

function load_image()
    local line_image = love.graphics.newImage(config.line[1])
    local line = entities.newLine(line_image)

    for _, segment in ipairs(config.line.boxes) do
        local width = segment[2] - segment[1] + 1
        local height = line_image:getHeight()

        local new_segment = entities.newSegment(segment[1], 0, width, height)
        table.insert(line.segments, new_segment)
        --STATE_MANAGER:current():addEntity(new_segment)
    end

    --STATE_MANAGER:current():addEntity(line)
end

function love.load()
    STATE_MANAGER = ecs.StateManager()
    STATE_MANAGER:switch(CheckForPrototypes(state))

    --engine = ecs.Engine()

    load_image()
    load_prototypes()



    local ent = STATE_MANAGER:current():getEntities()
    local sys = STATE_MANAGER:current():getSystems()

    --STATE_MANAGER:switch(CheckForPrototypes(state))
    --for _, e in ipairs(ent) do STATE_MANAGER:current():addEntity(e) end
    --for _, e in ipairs(sys) do STATE_MANAGER:current():addEntity(e) end

    love.graphics.setBackgroundColor(127, 127, 127)


    segments = STATE_MANAGER:current():getEntities(isSegment)
    first = segments[1]
end

function love.update(dt)
    lovebird.update()

    STATE_MANAGER:fireEvent("update", dt)
    -- if x >= etliche:getWidth() - sub_image:getWidth() then
    --     x = 0
    --     y = y + 10
    -- else
    --     x = x + 10
    -- end

    -- if y >= etliche:getHeight() - sub_image:getHeight() then
    --     y = 0
    -- end
end

function love.draw()
    STATE_MANAGER:fireEvent("draw")
end

function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
    end

    if key == "." then
        lurker.scan()
    end
end