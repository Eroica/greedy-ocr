--[[
    greedy-ocr
    Original Work Copyright (c) 2015 Sebastian Spaar
------------------------------------------------------------------------
    systems.lua

]]

local Systems = {}

Systems.PageDrawSystem = tiny.processingSystem({isDrawSystem = true})
function Systems.PageDrawSystem:process (entity, dt)
    love.graphics.draw(entity.image, entity.position.l, entity.position.t)
end

function Systems.PageDrawSystem:filter (entity)
    return entity.isPage ~= nil
end



Systems.SegmentStringDrawSystem = tiny.processingSystem({isDrawSystem = true})
function Systems.SegmentStringDrawSystem:process (entity, dt)
    love.graphics.setColor(0, 0, 0)
    love.graphics.print(tostring(entity), entity.position.l, math.floor(entity.position.t + entity.size.height))
    love.graphics.setColor(255, 255, 255)
end

function Systems.SegmentStringDrawSystem:filter (entity)
    return entity.isSegment ~= nil
end


Systems.SegmentDrawSystem = tiny.processingSystem({isDrawSystem = true})
function Systems.SegmentDrawSystem:process (entity, dt)
    local position = entity.position
    local size = entity.size

    love.graphics.setColor(255, 0, 255)
    love.graphics.rectangle("line", position.l, position.t, size.width, size.height)
    love.graphics.setColor(255, 255, 255)
end

function Systems.SegmentDrawSystem:filter (entity)
    return entity.isSegment ~= nil
end




Systems.ComponentDrawSystem = tiny.processingSystem({isDrawSystem = true})
function Systems.ComponentDrawSystem:process (entity, dt)
    local position = entity.position
    local size = entity.size

    love.graphics.setColor(0, 255, 0)

    for _, comp in pairs(entity.components) do
        local range = comp.range
        love.graphics.push()
            love.graphics.translate(position.l, position.t)
            love.graphics.line(range[1], 0, range[1], size.height)
            love.graphics.line(range[2], 0, range[2], size.height)
        love.graphics.pop()
    end

    love.graphics.setColor(255, 255, 255)
end

function Systems.ComponentDrawSystem:filter (entity)
    return entity.isSegment ~= nil
end







local HUD_HEIGHT = 44
local HUD_PADDING = 4
local HUD_COLOR = {32, 40, 63}
local HUD_LINE_COLOR = {56, 61, 81}
-- local HUD_COLOR = {73, 93, 127}
-- local HUD_LINE_COLOR = {125, 143, 165}


Systems.HUDDrawSystem = tiny.system({isDrawSystem = true})
function Systems.HUDDrawSystem:update (dt)
    local width, height = love.graphics.getDimensions()
    local x, y = love.mouse.getPosition()

    love.graphics.setColor(unpack(HUD_COLOR))
    love.graphics.rectangle("fill", 0, height - HUD_HEIGHT, width, height)
    love.graphics.setColor(unpack(HUD_LINE_COLOR))
    love.graphics.line(0, height - HUD_HEIGHT - 1, width, height - HUD_HEIGHT - 1)

    love.graphics.setColor(255, 255, 255)
    love.graphics.push()
        love.graphics.translate(HUD_PADDING, height - HUD_HEIGHT + HUD_PADDING)

        for _, e in pairs(self.entities) do
            local pos = e.position
            local size = e.size
            if x >= pos.l and x < pos.l + size.width and y >= pos.t and y < pos.t + size.height then
                love.graphics.print("Segment Coordinates: " .. tostring(x - pos.l) .. "|" .. tostring(y - pos.t), 0, 0)
            end
        end
        love.graphics.print("FPS: " .. tostring(love.timer.getFPS()), width - 55, 0)

        -- local prots = engine._prototypes
        -- local prots_strings = {}
        -- for i=1, #prots do
        --     table.insert(prots_strings, prots[i]:get("String").string)
        -- end

        -- love.graphics.print("Prototypes (" .. #engine._prototypes .. "): "
        --                     .. table.concat(prots_strings, ", "), 0, 20)
    love.graphics.pop()
end

function Systems.HUDDrawSystem:filter (entity)
    return entity.isSegment ~= nil
end


local BUTTON_HEIGHT = 24
local BUTTON_1 = {
    width = 48,
    height = BUTTON_HEIGHT,
    text = "Export"
}

local BUTTON_2 = {
    width = 148,
    height = BUTTON_HEIGHT,
    text = "Show all Prototypes"
}

Systems.ButtonDrawSystem = tiny.system({isDrawSystem = true})
function Systems.ButtonDrawSystem:update (dt)
    local width, height = love.graphics.getDimensions()

    love.graphics.push()
        love.graphics.translate(0, height - BUTTON_HEIGHT - HUD_HEIGHT - HUD_PADDING - 2)

        -- Button 1 ("Export")
        love.graphics.setColor(unpack(HUD_LINE_COLOR))
        love.graphics.rectangle("line", width - BUTTON_1.width - HUD_PADDING - 1, 0, BUTTON_1.width + 2, BUTTON_HEIGHT + 2)

        love.graphics.setColor(unpack(HUD_COLOR))
        love.graphics.rectangle("fill", width - BUTTON_1.width - HUD_PADDING, 1, BUTTON_1.width, BUTTON_HEIGHT)

        love.graphics.setColor(255, 255, 255)
        love.graphics.push()
            love.graphics.translate(width - BUTTON_1.width - HUD_PADDING, 1 + HUD_PADDING)
            love.graphics.printf(BUTTON_1.text, 0, 0, BUTTON_1.width, "center")
        love.graphics.pop()


        -- Button 2
        love.graphics.setColor(unpack(HUD_LINE_COLOR))
        love.graphics.rectangle("line", width - BUTTON_1.width - BUTTON_2.width - HUD_PADDING * 3 - 1, 0, BUTTON_2.width + 2, BUTTON_HEIGHT + 2)

        love.graphics.setColor(unpack(HUD_COLOR))
        love.graphics.rectangle("fill", width - BUTTON_1.width - BUTTON_2.width - HUD_PADDING * 3, 1, BUTTON_2.width, BUTTON_HEIGHT)

        love.graphics.setColor(255, 255, 255)
        love.graphics.push()
            love.graphics.translate(width - BUTTON_1.width - BUTTON_2.width - HUD_PADDING * 3, 1 + HUD_PADDING)
            love.graphics.printf(BUTTON_2.text, 0, 0, BUTTON_2.width, "center")
        love.graphics.pop()

    love.graphics.pop()
end

-- function ButtonDrawSystem:requires()
--     return {}
-- end



Systems.PrototypeDrawSystem = tiny.system({isDrawSystem = true})
function Systems.PrototypeDrawSystem:update (dt)
    local width, height = love.graphics.getDimensions()
    local padding = 4
    local next_x = padding
    local next_y = padding

    love.graphics.setColor(0, 0, 0, 191)
    love.graphics.rectangle("fill", 0, 0, width, height)
    love.graphics.setColor(255, 255, 255)

    for i, prototype in pairs(self.entities) do

        local image = prototype.image

        if image:getWidth() + padding > width then
            next_x = padding
            next_y = next_y + padding + 100
        end

        love.graphics.draw(image, next_x, next_y)

        next_x = next_x + image:getWidth() + padding
    end
end

function Systems.PrototypeDrawSystem:filter (entity)
    return entity.isPrototype ~= nil
end



Systems.CreateRectangleSystem = tiny.system({isDrawSystem = true, l = 0, t = 0})
function Systems.CreateRectangleSystem:update (dt)
    local x, y = love.mouse.getPosition()


    love.graphics.setColor(0, 0, 255)
    love.graphics.push()
        love.graphics.translate(self.l, self.t)
        love.graphics.rectangle("line", 0, 0, x-self.l, y-self.t)
    love.graphics.pop()
    love.graphics.setColor(255, 255, 255)
end

return Systems


-- SegmentSplittingSystem = class("SegmentSplittingSystem", System)
-- function SegmentSplittingSystem:update (dt)
--     local prototypes = engine._prototypes

--     for i, segment in pairs(self.targets) do
--         if segment:has("isNotRecognized") then
--             for j, prototype in pairs(prototypes) do
--                 for k, comp in pairs(segment._components) do
--                     local prot_image = prototype:get("Image").image
--                     local image = comp:get("Image").image

--                     -- print "current comp:"
--                     -- print(k)
--                     -- print "current prot:"
--                     -- print(prototype:get("String").string)

--                     if  prot_image:getWidth() <= image:getWidth()
--                     and prot_image:getHeight() <= image:getHeight() then
--                         -- print "comparing:"
--                         -- print(prot_image:getWidth(), image:getWidth())
--                         -- print(prot_image:getHeight(), image:getHeight())
--                         -- print("_____")

--                         comp:overlay(prototype)
--                     end

--                 end
--             end
--         end
--     end
-- end

-- function SegmentSplittingSystem:requires ()
--     return {"isNotRecognized", "isSegment"}
-- end


-- SegmentRecognitionSystem = class("SegmentRecognitionSystem", System)
-- function SegmentRecognitionSystem:update (dt)
--     for i, segment in pairs(self.targets) do
--         local match = lexicon:lookup(segment:tostring())

--         if #match == 1 then
--             if config.DEBUG then
--                 print("Segment `" .. segment:tostring() .. "' succesfully recognized as `" .. match[1] .."'.")
--             end

--             local match_copy = match[1]

--             local recognized_components = {}
--             for j, component in pairs(segment._components) do
--                 local comp_string = component:get("String").string
--                 if comp_string ~= ".*" then
--                     table.insert(recognized_components, comp_string)
--                 end
--             end

--             table.sort(recognized_components, function (a, b) return #a > #b end)

--             for j=1, #recognized_components do
--                 match_copy = string.gsub(match_copy, recognized_components[j], "#")
--             end

--             local match_substring = explode("#", match_copy)
--             local match_table = {}
--             for j=1, #match_substring do
--                 if match_substring[j] ~= "" then
--                     table.insert(match_table, match_substring[j])
--                 end
--             end

--             local match_components = {}
--             for j=1, #segment._components do
--                 if segment._components[j]:get("String").string == ".*" then
--                     table.insert(match_components, segment._components[j])
--                 end
--             end

--             assert(#match_table == #match_components)

--             for j=1, #match_table do
--                 match_components[j]:get("String").string = match_table[j]
--             end

--             for j=1, #match_components do
--                 local comp = match_components[j]
--                 if engine:checkIfPrototypeExists(comp:get("String").string) == false then
--                     local literal = comp:get("String").string
--                     local image = comp:get("Image").image
--                     local prot = entities.Prototype(literal, image)
--                 end
--             end

--             segment:remove("isNotRecognized")
--         end
--     end
-- end

-- function SegmentRecognitionSystem:requires ()
--     return {"isSegment", "isNotRecognized"}
-- end

