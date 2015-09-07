require "lib/lovetoys/lovetoys"
lovebird = require "lib/lovebird"
inspect = require "lib/inspect"
lurker = require "lib/lurker"


entities = require "entities"
LanguageModel = require "LanguageModel"
config = require "_config"
require "components"
--require "engines"
require "systems"
require "utils"


lurker.postswap = function(f) print("File " .. f .. " was swapped") end


function load_prototypes()
    prototypes = {}
    new_prototypes = {}

    for _, prototype in pairs(config.prototypes) do
        local image = love.graphics.newImage(prototype[2])
        local prototype = entities.Prototype(prototype[1], image)
        table.insert(prototypes, prototype)
    end
end

function load_image()
    local line_image = love.graphics.newImage(config.line[1])
    line = entities.Line(line_image, config.line.boxes)
    segments = line._segments
end

function love.load()
    engine = Engine()

    lexicon = LanguageModel.Lexicon("share/dummy_lexicon.txt")
    -- bigram_words = LanguageModel.Ngram("share/mercurius.txt")
    -- bigram_letters = LanguageModel.Ngram("share/mercurius.txt", true)

    load_image()
    load_prototypes()

    engine:addSystem(LineDrawSystem())
    engine:addSystem(SegmentDrawSystem())
    engine:addSystem(ComponentsDrawSystem())
    engine:addSystem(SegmentStringDrawSystem())
    engine:addSystem(HUDDrawSystem())
    engine:addSystem(SegmentRecognitionSystem())

    love.graphics.setBackgroundColor(127, 127, 127)

    -- segments[1]:split_at(50, 60)
end

function love.update(dt)
    lovebird.update()
    engine:update(dt)
end

function love.draw()
    local valign = 100
    local xalign = 200

    for _, seg in pairs(engine:getEntitiesWithComponent("isPrototype")) do
        love.graphics.draw(seg:get("Image").image_bw, xalign, valign)
        xalign = xalign + 50
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