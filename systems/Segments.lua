--[[
    greedy-ocr
    Original Work Copyright (c) 2015 Sebastian Spaar
------------------------------------------------------------------------
    systems.lua

]]

local Segments = {}


Segments.DrawString = tiny.processingSystem({isDrawSystem = true})
function Segments.DrawString:process (entity, dt)
    love.graphics.setColor(255, 0, 255)
    CAMERA:draw(function(l, t, w, h)
        love.graphics.print(tostring(entity), entity.position.l, math.floor(entity.position.t + entity.size.height))
    end)
    love.graphics.setColor(255, 255, 255)
end

function Segments.DrawString:filter (entity)
    return entity.isSegment ~= nil
end


Segments.DrawBoundingBox = tiny.processingSystem({isDrawSystem = true})
function Segments.DrawBoundingBox:process (entity, dt)
    local position = entity.position
    local size = entity.size

    love.graphics.setColor(255, 0, 255)
    CAMERA:draw(function(l, t, w, h)
        love.graphics.rectangle("line", position.l, position.t, size.width, size.height)
    end)
    love.graphics.setColor(255, 255, 255)
end

function Segments.DrawBoundingBox:filter (entity)
    return entity.isSegment ~= nil
end


Segments.Recognition = tiny.processingSystem({isUpdateSystem = true, interval = 30})
function Segments.Recognition:process (entity, dt)
    local match = LEXICON:lookup(tostring(entity))

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
        -- Refresh this entity's components
        self.world:addEntity(entity)
    end
end

function Segments.Recognition:filter (entity)
    return entity.isNotRecognized ~= nil
end



Segments.DrawComponents = tiny.processingSystem({isDrawSystem = true})
function Segments.DrawComponents:process (entity, dt)
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

function Segments.DrawComponents:filter (entity)
    return entity.isSegment ~= nil
end






return Segments


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


