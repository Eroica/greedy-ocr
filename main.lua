--[[
    greedy-ocr
    Original Work Copyright (c) 2015 Sebastian Spaar
------------------------------------------------------------------------
    main.lua

]]

class    = require "lib/30log"
tiny     = require "lib/tiny"
lovebird = require "lib/lovebird"
inspect  = require "lib/inspect"
-- lurker   = require "lib/lurker"
-- lurker.postswap = function (f) print("File " .. f .. " was swapped") end

local gamera = require "lib/gamera"

Systems = {
    Segments   = require "systems/Segments",
    Prototypes = require "systems/Prototypes",
    Components = require "systems/Components",
    Page       = require "systems/Page"
}

require "utils"
require "setup"
config        = require "_config"
LanguageModel = require "LanguageModel"
Entities      = require "Entities"


local draw_prototypes_system = Systems.Prototypes.OverlayPrototypes

function love.load()
    love.graphics.setDefaultFilter("nearest", "nearest")

    WORLD  = tiny.world()
    PAGE   = load_image()
    BIGRAM = load_bigram()
    -- BIGRAM_REVERSE = load_bigram(true)
    load_prototypes()

    CAMERA = gamera.new(0, 0, PAGE.image:getWidth(),
                              PAGE.image:getHeight() + 128)
    CAMERA:setPosition(0, 0)

    WORLD:addSystem(Systems.Page.DrawPage)
    WORLD:addSystem(Systems.Segments.DrawBoundingBox)
    WORLD:addSystem(Systems.Components.DrawLines)
    WORLD:addSystem(Systems.Segments.DrawString)
    -- WORLD:addSystem(Systems.Segments.Recognize)
    -- WORLD:addSystem(Systems.Components.DrawRange)
    WORLD:addSystem(Systems.Page.DrawHUD)
    WORLD:addSystem(Systems.Page.DrawButtons)
    WORLD:addSystem(draw_prototypes_system)

    LOOKUP = WORLD:addSystem(Systems.Segments.Lookup)
    PROTOTYPES = WORLD:addSystem(Systems.Prototypes.sharedPrototypes)
    COMPONENTS = WORLD:addSystem(Systems.Components.sharedComponents)

    LEXICON = LanguageModel.Lexicon(config.lexicon_filename)

    love.graphics.setBackgroundColor(unpack(config.BACKGROUND_COLOR))
end

comp_images = {}

function love.update(dt)
    lovebird.update()
    WORLD:update(dt, tiny.requireAll("isUpdateSystem"))
end

function love.draw()
    WORLD:update(love.timer.getDelta(), tiny.requireAll("isDrawSystem"))

    for _, comp in pairs(comp_images) do
        love.graphics.setColor(0, 0, 255)
        love.graphics.rectangle("fill", 50, 50, 100, 100)
        love.graphics.setColor(255, 255, 255)
        love.graphics.draw(comp.image, 50, 50)
    end

end

function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
    end

    -- if key == "." then
    --     lurker.scan()
    -- end

    if key == "p" then
        draw_prototypes_system.active = not draw_prototypes_system.active
    end

    if key == "x" then
        PAGE.image, PAGE.image_bw = PAGE.image_bw, PAGE.image
    end

    if key == "y" then
        for i=1, #PROTOTYPES.entities do
              PROTOTYPES.entities[i].image, PROTOTYPES.entities[i].image_bw
            = PROTOTYPES.entities[i].image_bw, PROTOTYPES.entities[i].image
        end
    end
end

function love.keyreleased(key)
end

function love.mousepressed(x, y, button)
    if button == "l" then
        WORLD:addSystem(Systems.Page.CreateRectangles)
        WORLD:addSystem(Systems.Page.CameraPosition)
    end
end

function love.mousereleased(x, y, button)
    if button == "l" then
        WORLD:removeSystem(Systems.Page.CreateRectangles)
        WORLD:removeSystem(Systems.Page.CameraPosition)
    end

    if button == "r" then
        local width, height = love.graphics.getDimensions()
        local x, y = CAMERA:toWorld(love.mouse.getPosition())

        for _, e in pairs(PAGE.segments) do
            local pos  = e.position
            local l, t = pos.l, pos.t
            local size = e.size
            if  x >= l and x < l + size.width
            and y >= t and y < t + size.height then
                e:recognize()
            end
        end
    end
end