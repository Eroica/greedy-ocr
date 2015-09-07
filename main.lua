require "lib/lovetoys/lovetoys"
lovebird = require "lib/lovebird"
inspect = require "lib/inspect"
lurker = require "lib/lurker"


entities = require "entities"
LanguageModel = require "LanguageModel"
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

    lexicon = LanguageModel.Lexicon("share/lexicon.txt")
    bigram_words = LanguageModel.Ngram("share/mercurius.txt")
    bigram_letters = LanguageModel.Ngram("share/mercurius.txt", true)

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

    local x, y = love.mouse.getPosition() -- get the position of the mouse



    for _, seg in pairs(engine:getEntitiesWithComponent("isSegment")) do
        local pos = seg:get("Position")
        local size = seg:get("Size")
        if x >= pos.l and x < pos.l + size.width and y >= pos.t and y < pos.t + size.height then

            love.graphics.print(x - pos.l, 100, 400) -- draw the custom mouse image
            love.graphics.print(y - pos.t, 200, 400)
        end
    end


    for _, seg in pairs(engine:getEntitiesWithComponent("isPrototype")) do
        love.graphics.draw(seg:get("Image").image_bw, valign, xalign)
    end

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