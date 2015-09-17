--[[
    greedy-ocr
    Original Work Copyright (c) 2015 Sebastian Spaar
------------------------------------------------------------------------
    systems.lua

]]

local Systems = {}

Systems.AllPrototypesSystem = tiny.sortedSystem({isUpdateSystem = true})
function Systems.AllPrototypesSystem:compare (e1, e2)
    if e1.image:getWidth() > e2.image:getWidth() then
        return true
    else
        return false
    end
end

function Systems.AllPrototypesSystem:filter (entity)
    return entity.isPrototype ~= nil
end


Systems.PageDrawSystem = tiny.processingSystem({isDrawSystem = true})
function Systems.PageDrawSystem:process (entity, dt)
    CAMERA:draw(function(l, t, w, h)
        love.graphics.draw(entity.image, entity.position.l, entity.position.t)
    end)
end

function Systems.PageDrawSystem:filter (entity)
    return entity.isPage ~= nil
end


Systems.SegmentStringDrawSystem = tiny.processingSystem({isDrawSystem = true})
function Systems.SegmentStringDrawSystem:process (entity, dt)
    love.graphics.setColor(255, 0, 255)
    CAMERA:draw(function(l, t, w, h)
        love.graphics.print(tostring(entity), entity.position.l, math.floor(entity.position.t + entity.size.height))
    end)
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
    CAMERA:draw(function(l, t, w, h)
        love.graphics.rectangle("line", position.l, position.t, size.width, size.height)
    end)
    love.graphics.setColor(255, 255, 255)
end

function Systems.SegmentDrawSystem:filter (entity)
    return entity.isSegment ~= nil
end


Systems.SegmentRecognitionSystem = tiny.processingSystem({isUpdateSystem = true})
function Systems.SegmentRecognitionSystem:process (entity, dt)
    local match = lexicon:lookup(tostring(entity))

    if #match == 1 then
        if config.DEBUG then
            print("Segment `" .. tostring(entity) .. "' succesfully recognized as `" .. match[1] .."'.")
        end

        local match_copy = match[1]

        local recognized_components = {}
        for j, component in pairs(entity.components) do
            if component.string ~= ".*" then
                table.insert(recognized_components, component.string)
            end
        end

        table.sort(recognized_components, function (a, b) return #a > #b end)

        for j=1, #recognized_components do
            match_copy = string.gsub(match_copy, recognized_components[j], "#")
        end

        local match_substring = explode("#", match_copy)
        local match_table = {}
        for j=1, #match_substring do
            if match_substring[j] ~= "" then
                table.insert(match_table, match_substring[j])
            end
        end

        local match_components = {}
        for j=1, #entity.components do
            if entity.components[j].string == ".*" then
                table.insert(match_components, entity.components[j])
            end
        end

        assert(#match_table == #match_components)

        for j=1, #match_table do
            match_components[j].string = match_table[j]
        end

        for j=1, #match_components do
            local comp = match_components[j]

            local all_prototype_strings = {}
            for _, prot in pairs(prototypes) do
                all_prototype_strings[prot.string] = true
            end

            if all_prototype_strings[comp.string] == nil then
                local literal = comp.string
                local image = trim_image(comp.image)
                local prot = Entities.Prototype(comp.string, image)
            end
        end

        entity.isNotRecognized = nil
        self.world:addEntity(entity)
    end
end

function Systems.SegmentRecognitionSystem:filter (entity)
    return entity.isNotRecognized ~= nil
end


Systems.ComponentsRangeDrawSystem = tiny.system({isDrawSystem = true})
function Systems.ComponentsRangeDrawSystem:update (dt)
    local x, y = love.mouse.getPosition()

    for _, e in pairs(self.entities) do
            local pos = e.position
            local size = e.size
            if x >= pos.l and x < pos.l + size.width and y >= pos.t and y < pos.t + size.height then
                love.graphics.setColor(255, 0, 0)
                for _, comp in pairs(e.components) do
                    CAMERA:draw(function(l, t, w, h)
                        love.graphics.print(comp.range[1], pos.l + comp.range[1], pos.t)
                        love.graphics.print(comp.range[2], pos.l + comp.range[2], pos.t)
                    end)
                end
            end
        end
    love.graphics.setColor(255, 255, 255)
end

function Systems.ComponentsRangeDrawSystem:filter (entity)
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
            CAMERA:draw(function(l, t, w, h)
                love.graphics.line(range[1], 0, range[1], size.height)
                love.graphics.line(range[2], 0, range[2], size.height)
            end)
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
    --local l, t, width, height = CAMERA:getVisible()
    l, t = 0, 0
    local x, y = love.mouse.getPosition()

    love.graphics.setColor(unpack(HUD_COLOR))
    love.graphics.rectangle("fill", l, t + height - HUD_HEIGHT, width, height)
    love.graphics.setColor(unpack(HUD_LINE_COLOR))
    love.graphics.line(l, t + height - HUD_HEIGHT - 1, l + width, t + height - HUD_HEIGHT - 1)

    love.graphics.setColor(255, 255, 255)
    love.graphics.push()
        love.graphics.translate(l + HUD_PADDING, t + height - HUD_HEIGHT + HUD_PADDING)

        for _, e in pairs(self.entities) do
            local pos = e.position
            local l, t = CAMERA:toScreen(pos.l, pos.t)
            local size = e.size
            if x >= l and x < l + size.width and y >= t and y < t + size.height then
                love.graphics.print("Segment " .. tostring(_) .. " Coordinates: " .. tostring(x - l) .. "|" .. tostring(y - t), 0, 0)
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



Systems.PrototypeDrawSystem = tiny.system({isDrawSystem = true, active = false})
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




Systems.ComponentSplittingSystem = tiny.processingSystem({isUpdateSystem = true, active = false})
function Systems.ComponentSplittingSystem:process (entity, dt)
    local prototypes = all_prototypes.entities

    for _, prototype in pairs(prototypes) do
        print ("I wanna check " .. tostring(prototype) )
    end

end

function Systems.ComponentSplittingSystem:filter (entity)
    return entity.isComponent ~= nil
end





Systems.CameraPositionSystem = tiny.system({isUpdateSystem = true})
function Systems.CameraPositionSystem:onAddToWorld (world)
    self.x, self.y = love.mouse.getPosition()
    self.l, self.t = CAMERA.x, CAMERA.y
end

function Systems.CameraPositionSystem:update (dt)
    if love.keyboard.isDown(" ") then
        local current_x, current_y = love.mouse.getPosition()
        local dx, dy = current_x - self.x, current_y - self.y

        CAMERA:setPosition(self.l - dx, self.t - dy)
    end
end

-- function Systems.CameraPositionSystem:onRemoveFromWorld (world)
--     CAMERA:setCamera(self.new_x, self.new_y)
-- end

function Systems.CameraPositionSystem:filter (entity)
    -- return entity.isCamera ~=nil
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


