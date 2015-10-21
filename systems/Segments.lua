--[[
    greedy-ocr
    Original Work Copyright (c) 2015 Sebastian Spaar
------------------------------------------------------------------------
    systems/Segments.lua

]]

local Segments = {}


-- This system draws every Segment's string (symbolic value).
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


-- This system draws every Segment's bounding box.
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


-- This system checks whether a Segment can be recognized using the
-- lexicon.
Segments.Lookup = tiny.processingSystem({isUpdateSystem = true, active = false, interval=30})
function Segments.Lookup:process (entity, dt)
    -- TODO: Remove global `LEXICON' dependency.
    local match = LEXICON:lookup(tostring(entity))

    -- Check if `match' is unique, then proceed to "recognize" the
    -- Segment.
    if #match == 1 then
        if config.DEBUG then
            print(tostring(entity), "succesfully recognized as:", match[1])
        end

        local match_copy = match[1]

        local component
        for j=1, #entity.components do
            component = entity.components[j]

            -- This condition cancels the recognition of every,
            -- and set ups a segment.string instead. The reason behind
            -- that is if a Segment's string is, say, "Ambassa.+.+r",
            -- and the matching word is "Ambassadeur", no one can know
            -- where the first `.+' begins and ends.
            if j == #entity.components or (component.string == ".+" and entity.components[j+1].string == ".+") then
                entity.string = match
                goto recognition_end
            end
        end

        -- Create a block so we can use goto above.
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