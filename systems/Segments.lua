--[[
    greedy-ocr
    Original Work Copyright (c) 2015 Sebastian Spaar
------------------------------------------------------------------------
    systems.lua

]]

local Segments = {}


Segments.DrawString = tiny.processingSystem({isDrawSystem = true})
function Segments.DrawString:process (entity, dt)
    love.graphics.setColor(0, 0, 0)
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

    love.graphics.setColor(255, 137, 115)
    CAMERA:draw(function(l, t, w, h)
        love.graphics.rectangle("line", position.l, position.t, size.width, size.height)
    end)
    love.graphics.setColor(255, 255, 255)
end

function Segments.DrawBoundingBox:filter (entity)
    return entity.isSegment ~= nil
end


Segments.Recognition = tiny.processingSystem({isUpdateSystem = true, active = false})
function Segments.Recognition:process (entity, dt)
    local match = LEXICON:lookup(tostring(entity))

    -- As a precaution: From the list of matches, remove those who have
    -- less letters than the number of Components.
    for i=#match, 1, -1 do
        if #match[i] < #entity.components then
            table.remove(match, i)
        end
    end

    if #match == 1 then
        if config.DEBUG then
            print(tostring(entity), "succesfully recognized as:", match[1])
        end

        local match_copy = match[1]

        local recognized_components = {}
        for j, component in pairs(entity.components) do
            if  component.string ~= ".*"
            and component.string ~= ".?" then
                table.insert(recognized_components, component.string)
            end
        end

        table.sort(recognized_components, function (a, b) return #a > #b end)

        for j=1, #recognized_components do
            match_copy = string.gsub(match_copy, recognized_components[j], "#", 1)
        end

        local match_substring = explode("#", match_copy)
        print(inspect(match_substring))
        local match_table = {}
        for j=1, #match_substring do
            if match_substring[j] ~= "" then
                table.insert(match_table, match_substring[j])
            end
        end

        local match_components = {}
        for j=1, #entity.components do
            if entity.components[j].string == ".*" or entity.components[j].string == ".?" then
                table.insert(match_components, entity.components[j])
            end
        end

        -- assert(#match_table == #match_components)

        for j=1, #match_table do
            match_components[j].string = match_table[j]
        end

        for j=1, #match_components do
            local component = match_components[j]
            Entities.Prototype(component.string, component.image)
        end

        entity.isNotRecognized = nil
        -- Refresh this entity's components
        self.world:addEntity(entity)
    end
end

function Segments.Recognition:filter (entity)
    return entity.isNotRecognized ~= nil
end


return Segments