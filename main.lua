--[[
    greedy-ocr
    Original Work Copyright (c) 2015 Sebastian Spaar
------------------------------------------------------------------------
    main.lua

]]

require "lib/lovetoys/lovetoys"
lovetoyDebug = true
lovebird = require "lib/lovebird"
inspect = require "lib/inspect"
lurker = require "lib/lurker"


require "components"
require "engines"
require "systems"
require "utils"
require "setup"
entities = require "entities"
LanguageModel = require "LanguageModel"
config = require "_config"


lurker.postswap = function(f) print("File " .. f .. " was swapped") end


function love.load()
    engine = GreedyEngine()
    listener = EventManager()

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
    engine:addSystem(ButtonDrawSystem())
    engine:addSystem(PrototypeDrawSystem())
    engine:stopSystem("PrototypeDrawSystem")
    engine:addSystem(SegmentRecognitionSystem())


    love.graphics.setBackgroundColor(unpack(config.BACKGROUND_COLOR))
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

    if key == "p" then
        engine:toggleSystem("PrototypeDrawSystem")
    end
end