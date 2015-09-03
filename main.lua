--ecs = require "lib/ecs"
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



-- function load_prototypes()
--     for _, prototype in pairs(config.prototypes) do
--         local image = love.graphics.newImage(prototype[2])
--         entities.newPrototype(prototype[1], image)
--     end
-- end

function load_image()
    local line_image = love.graphics.newImage(config.line[1])
    line = entities.Line(line_image, config.line.boxes)
end

function love.load()
    engine = Engine()

    load_image()
    --load_prototypes()

    engine:addSystem(LineDrawSystem())
    engine:addSystem(SegmentDrawSystem())
    engine:addSystem(ComponentsDrawSystem())

    love.graphics.setBackgroundColor(127, 127, 127)

end

function love.update(dt)
    lovebird.update()
    engine:update(dt)

end

function love.draw()
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