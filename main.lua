--[[
    greedy-ocr
    Original Work Copyright (c) 2015 Sebastian Spaar
------------------------------------------------------------------------
    main.lua

]]

class = require "lib/30log"
tiny = require "lib/tiny"
lovebird = require "lib/lovebird"
inspect = require "lib/inspect"
lurker = require "lib/lurker"
lurker.postswap = function(f) print("File " .. f .. " was swapped") end

local gamera = require "lib/gamera"

--require "engines"
local Systems = {Segments = require "systems/Segments",
                 Prototypes = require "systems/Prototypes",
                 Components = require "systems/Components",
                 Page = require "systems/Page"}

config = require "_config"
LanguageModel = require "LanguageModel"
require "utils"
require "setup"
Entities = require "Entities"


function love.load()
    WORLD = tiny.world()

    PAGE = load_image()
    load_prototypes()

    CAMERA = gamera.new(0, 0, PAGE.image:getWidth(), PAGE.image:getHeight() + 128)
    CAMERA:setPosition(0, 0)

    WORLD:addSystem(Systems.Page.DrawPage)
    WORLD:addSystem(Systems.Segments.DrawBoundingBox)
    -- WORLD:addSystem(Systems.Segments.DrawComponents)
    WORLD:addSystem(Systems.Segments.DrawString)
    WORLD:addSystem(Systems.Segments.Recognition)
    WORLD:addSystem(Systems.Components.DrawRange)
    WORLD:addSystem(Systems.Components.DrawLines)
    WORLD:addSystem(Systems.Page.DrawHUD)
    WORLD:addSystem(Systems.Page.DrawButtons)

    protdraw = WORLD:addSystem(Systems.Prototypes.OverlayPrototypes)
    PROTOTYPES = WORLD:addSystem(Systems.Prototypes.sharedPrototypes)
    split_components = WORLD:addSystem(Systems.Components.Splitting)

    LEXICON = LanguageModel.Lexicon(config.lexicon_filename)
    --bigram_words = LanguageModel.Ngram("share/mercurius.txt")
    -- bigram_letters = LanguageModel.Ngram("share/mercurius.txt", true)

    love.graphics.setBackgroundColor(unpack(config.BACKGROUND_COLOR))
end

function love.update(dt)
    lovebird.update()
    WORLD:update(dt, tiny.requireAll("isUpdateSystem"))
end

function love.draw()
    WORLD:update(love.timer.getDelta(), tiny.requireAll("isDrawSystem"))
end

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
        WORLD:addSystem(Systems.Page.CameraPosition)
    end
end

function love.mousereleased(x, y, button)
    if button == "l" then
        -- WORLD:removeSystem(Systems.CreateRectangleSystem)
        WORLD:removeSystem(Systems.Page.CameraPosition)
    end
end