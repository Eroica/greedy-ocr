require "lib/lovetoys/lovetoys"
lovebird = require "lib/lovebird"
inspect = require "lib/inspect"
lurker = require "lib/lurker"


entities = require "entities"
require "components"
--require "engines"
require "systems"
require "utils"
local config = require "_config"


lurker.postswap = function(f) print("File " .. f .. " was swapped") end


function load_prototypes()
    for _, prototype in pairs(config.prototypes) do
        local image = love.graphics.newImage(prototype[2])
        local prototype = entities.Prototype(prototype[1], image)
    end
end

function load_image()
    local line_image = love.graphics.newImage(config.line[1])
    line = entities.Line(line_image, config.line.boxes)
end

function love.load()
    engine = Engine()

    load_image()
    load_prototypes()

    engine:addSystem(LineDrawSystem())
    engine:addSystem(SegmentDrawSystem())
    engine:addSystem(ComponentsDrawSystem())

    love.graphics.setBackgroundColor(127, 127, 127)


    segments = line._segments
    prototypes = engine:getEntitiesWithComponent("isPrototype")

    -- segments[1]:split_at(50, 60)
end

function love.update(dt)
    lovebird.update()
    engine:update(dt)

end

function love.draw()
    local valign = 100
    local xalign = 200

    -- for _, seg in pairs(segments) do
    --     if seg._components[2] then
    --         love.graphics.draw(seg._components[2]:get("Image").image_bw, 100, 100)
    --     end
    -- end


    for _, seg in pairs(engine:getEntitiesWithComponent("isPrototype")) do
        love.graphics.draw(seg:get("Image").image_bw, valign, xalign)
    end

    -- love.graphics.draw(line:get("Image").image_bw, 100, 100)

    -- for _, child in pairs(line.children) do
    --     love.graphics.draw(child:get("Image").image, 0, valign)

    --     for _, child in pairs(child.children) do
    --         love.graphics.draw(child:get("Image").image_bw, xalign, valign)
    --     end

    --     valign = valign + 100
    -- end


    -- love.graphics.setColor(255, 0, 255)
    -- love.graphics.rectangle("line", 0, 0, 800, 600)

    engine:draw()


end

function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
    end

    if key == "." then
        lurker.scan()
    end
end