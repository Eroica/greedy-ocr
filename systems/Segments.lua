--[[
    greedy-ocr
    Original Work Copyright (c) 2015 Sebastian Spaar
------------------------------------------------------------------------
    systems.lua

]]

local Segments = {}

Segments.DrawString = tiny.processingSystem({isDrawSystem = true})
function Segments.DrawString:process (entity, dt)
    CAMERA:draw(function(l, t, w, h)
        love.graphics.setColor(213, 78, 83, 127)
        love.graphics.rectangle("fill", entity.position.l, entity.position.t, entity.size.width, 16)
        love.graphics.setColor(0, 0, 0)
        love.graphics.printf(tostring(entity), entity.position.l + 1, entity.position.t, entity.size.width, "center")
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

    love.graphics.setColor(unpack(config.SEGMENT_COLOR))
    CAMERA:draw(function(l, t, w, h)
        love.graphics.rectangle("line", position.l, position.t, size.width, size.height)
    end)
    love.graphics.setColor(255, 255, 255)
end

function Segments.DrawBoundingBox:filter (entity)
    return entity.isSegment ~= nil
end


Segments.Lookup = tiny.processingSystem({isUpdateSystem = true, active = false, interval=30})
function Segments.Lookup:process (entity, dt)
    local match = LEXICON:lookup(tostring(entity))

    if #match == 1 then
        if config.DEBUG then
            print(tostring(entity), "succesfully recognized as:", match[1])
        end

        local match_copy = match[1]

        local component
        for j=1, #entity.components do
            component = entity.components[j]
            if j == #entity.components or (component.string == ".+" and entity.components[j+1].string == ".+") then
                entity.string = match
                goto recognition_end
            end
        end

        do
            local letter_count = 0
            for j=1, #entity.components do
                component = entity.components[j]

                if component.string == "." then
                    component.string = match_copy:sub(j, j)
                    Entities.Prototype(component.string, component.image)
                end

                if component.string == ".+" then
                    if not config.UNKNOWN_COMPONENTS[entity.components[j+1].string]
                        or entity.components[j+1].string == "." then
                        component.string = match_copy:sub(letter_count + 1, j+1)
                        Entities.Prototype(component.string, component.image)
                    end
                end

                letter_count = letter_count + #tostring(component)
            end
        end

        ::recognition_end::

        entity.isNotRecognized = nil
        -- Refresh this entity's components
        self.world:addEntity(entity)
    end
end

function Segments.Lookup:filter (entity)
    return (entity.isNotRecognized ~= nil and #tostring(entity) ~= ".+")
end


return Segments