--[[
    greedy-ocr
    Original Work Copyright (c) 2015 Sebastian Spaar
------------------------------------------------------------------------
    main.lua

]]

class = require "lib/30log"
tiny = require "lib/tiny"

--require "lib/lovetoys/lovetoys"
--lovetoyDebug = true
lovebird = require "lib/lovebird"
inspect = require "lib/inspect"
lurker = require "lib/lurker"


--require "components"
--require "engines"
local Systems = require "systems"
--require "utils"
require "setup"
Entities = require "Entities"
--LanguageModel = require "LanguageModel"
config = require "_config"


lurker.postswap = function(f) print("File " .. f .. " was swapped") end


function love.load()
    WORLD = tiny.world()
    WORLD:addEntity(joe)
    load_image()
    load_prototypes()

    WORLD:addSystem(Systems.PageDrawSystem)
    WORLD:addSystem(Systems.SegmentDrawSystem)
    WORLD:addSystem(Systems.ComponentDrawSystem)
    WORLD:addSystem(Systems.SegmentStringDrawSystem)
    -- lexicon = LanguageModel.Lexicon("share/dummy_lexicon.txt")
    -- -- bigram_words = LanguageModel.Ngram("share/mercurius.txt")
    -- -- bigram_letters = LanguageModel.Ngram("share/mercurius.txt", true)


    -- engine:addSystem(LineDrawSystem())
    -- engine:addSystem(SegmentDrawSystem())
    -- engine:addSystem(ComponentsDrawSystem())
    -- engine:addSystem(SegmentStringDrawSystem())
    -- engine:addSystem(HUDDrawSystem())
    -- engine:addSystem(ButtonDrawSystem())
    -- engine:addSystem(PrototypeDrawSystem())
    -- engine:stopSystem("PrototypeDrawSystem")
    -- engine:addSystem(SegmentRecognitionSystem())


    love.graphics.setBackgroundColor(unpack(config.BACKGROUND_COLOR))
end

function love.update(dt)
    lovebird.update()
    WORLD:update(dt, tiny.requireAll("isUpdateSystem"))
end

function love.draw()
    WORLD:update(dt, tiny.requireAll("isDrawSystem"))
end

function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
    end

    if key == "." then
        lurker.scan()
    end

    -- if key == "p" then
    --     engine:toggleSystem("PrototypeDrawSystem")
    -- end
end