--[[
    greedy-ocr
    Original Work Copyright (c) 2015 Sebastian Spaar
------------------------------------------------------------------------
    systems/Components.lua

]]

local Components = {}

-- This systems registers all available Components, a little bit like
-- a Singleton object.
Components.sharedComponents = tiny.system({isUpdateSystem = true})
function Components.sharedComponents:filter (entity)
    return entity.isComponent ~= nil
end

function Components.sharedComponents:onAdd (entity)
    -- Add letter frequencies to the component behind `index'

    -- First check if `entity' is a recognized component.
    if  entity.string ~= ".+"
    and entity.string ~= "."
    and #entity.string == 1 then
        local components = entity.parent.components
        local index = invert_table(entity.parent.components)[entity]

        -- Stop if `index' is the last or first component of a segment
        -- (so that there is no component after it)
        if index == #components then return end

        -- Check if the component after `entity' is not recognized
        -- AND a single character. This limit can probably be lifted
        -- some day.
        if components[index+1].string == "." then
            components[index+1].letter_frequencies = {}

            local recognized_letter = entity.string
            local sum_frequency = BIGRAM[recognized_letter]._count

            for letter, frequency in pairs(BIGRAM[recognized_letter]) do
                if letter ~= "_count" and letter ~= "class" and letter ~= " " then
                    components[index+1].letter_frequencies[letter] = frequency/sum_frequency
                end
            end
        end
    end
end

function Components.sharedComponents:onModify (dt)
    -- Check if a Segment has been recognized
    -- This currently breaks a System's autarky, and will need to be
    -- changed!
    -- TODO: Remove global `LOOKUP'
    LOOKUP:update(dt)
end


-- This system draws the Components ranges.
Components.DrawLines = tiny.processingSystem({isDrawSystem = true})
function Components.DrawLines:process (entity, dt)
    local position = entity.parent.position
    local size     = entity.parent.size

    love.graphics.setColor(unpack(config.COMPONENT_COLOR))

    do love.graphics.push()
        love.graphics.translate(position.l, position.t)
        CAMERA:draw(function(l, t, w, h)
            love.graphics.line(entity.range[1], 0, entity.range[1], size.height)
            love.graphics.line(entity.range[2], 0, entity.range[2], size.height)
        end)
    end love.graphics.pop()

    love.graphics.setColor(255, 255, 255)
end

function Components.DrawLines:filter (entity)
    return entity.isComponent ~= nil
end


-- This system (named a little bit unclear, unfortunately) draws the
-- Component's ranges in numbers.
Components.DrawRange = tiny.system({isDrawSystem = true})
function Components.DrawRange:update (dt)
    local x, y = CAMERA:toWorld(love.mouse.getPosition())

    for _, e in pairs(self.entities) do
        local pos  = e.position
        local size = e.size

        if  x >= pos.l and x < pos.l + size.width
        and y >= pos.t and y < pos.t + size.height then
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

function Components.DrawRange:filter (entity)
    return entity.isSegment ~= nil
end

return Components