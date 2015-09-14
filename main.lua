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

local gamera = require "lib/gamera"


--require "components"
--require "engines"
local Systems = require "systems"
require "utils"
require "setup"
Entities = require "Entities"
LanguageModel = require "LanguageModel"
config = require "_config"


lurker.postswap = function(f) print("File " .. f .. " was swapped") end


function love.load()
    WORLD = tiny.world()

    page = load_image()
    prototypes = load_prototypes()

    CAMERA = gamera.new(0, 0, page.image:getWidth(), page.image:getHeight() + 128)
    CAMERA:setPosition(0, 0)

    WORLD:addSystem(Systems.PageDrawSystem)
    WORLD:addSystem(Systems.SegmentDrawSystem)
    WORLD:addSystem(Systems.ComponentDrawSystem)
    WORLD:addSystem(Systems.ComponentsRangeDrawSystem)
    WORLD:addSystem(Systems.SegmentStringDrawSystem)
    -- WORLD:addSystem(Systems.HUDDrawSystem)
    -- WORLD:addSystem(Systems.ButtonDrawSystem)
    WORLD:addSystem(Systems.SegmentRecognitionSystem)

    protdraw = WORLD:addSystem(Systems.PrototypeDrawSystem)
    all_prototypes = WORLD:addSystem(Systems.AllPrototypesSystem)
    split_components = WORLD:addSystem(Systems.ComponentSplittingSystem)

    lexicon = LanguageModel.Lexicon("share/dummy_lexicon.txt")
    --bigram_words = LanguageModel.Ngram("share/mercurius.txt")
    -- bigram_letters = LanguageModel.Ngram("share/mercurius.txt", true)

    love.graphics.setBackgroundColor(unpack(config.BACKGROUND_COLOR))
end

function love.update(dt)
    lovebird.update()
    WORLD:update(dt, tiny.requireAll("isUpdateSystem"))
end

function love.draw()
    CAMERA:draw(function(l, t, w, h)
        WORLD:update(love.timer.getDelta(), tiny.requireAll("isDrawSystem"))
    end)
end

mouse_down = false

function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
    end

    if key == "." then
        lurker.scan()
    end

    if key == "p" then
        protdraw.active = not protdraw.active
    end

    if key == "c" then
        split_components.active = not split_components.active
    end
end

function love.keyreleased(key)
end

function love.mousepressed(x, y, button)
    if button == "l" then
        -- local createrect = WORLD:addSystem(Systems.CreateRectangleSystem)
        -- createrect.l = x
        -- createrect.t = y
        WORLD:addSystem(Systems.CameraPositionSystem)
    end
end

function love.mousereleased(x, y, button)
    if button == "l" then
        -- WORLD:removeSystem(Systems.CreateRectangleSystem)
        WORLD:removeSystem(Systems.CameraPositionSystem)
    end
end