local Components = {}


Components.sharedComponents = tiny.system({isUpdateSystem = true})
function Components.sharedComponents:filter (entity)
    return entity.isComponent ~= nil
end

function Components.sharedComponents:splitComponents ()

end

function Components.sharedComponents:onAdd (entity)
    entity.image_bw = threshold_image(entity.image)
    self.world:addEntity(entity)

    if entity.string ~= ".*" then
        local components = entity.parent.components
        local index = invert_table(entity.parent.components)[entity]

        if index == #components then return end

        if components[index+1].string == ".*" then
            components[index+1].letter_frequencies = {}
            local recognized_letter = entity.string
            local sum_frequency = BIGRAM[recognized_letter]._count

            for letter, frequency in pairs(BIGRAM[recognized_letter]) do
                if letter ~= "_count" and letter ~= "class" then
                    components[index+1].letter_frequencies[letter] = frequency/sum_frequency
                end
            end
        end
    end
end

-- Segments.UpdatePossibleLetters = tiny.processingSystem({isUpdateSystem = true})
-- function Segments.UpdatePossibleLetters:process (entity, dt)
--     for i=1, #entity.components do
--         if  entity.components[i].string ~= ".*"
--         and entity.components[i+1].string == ".*"
--         and i ~= #entity.components then
--             entity.components[i+1].letter_frequencies = {}
--             local recognized_letter = entity.components[i].string
--             local sum_frequency = BIGRAM[recognized_letter]._count


--             for letter, frequency in pairs(BIGRAM[recognized_letter]) do
--                 if letter ~= "_count" and letter ~= "class" then
--                     entity.components[i+1].letter_frequencies[letter] = frequency/sum_frequency
--                 end
--             end

--             --     local l = BIGRAM[recognized_letter][letter]

--             -- end
--         end
--     end

-- end

-- function Segments.UpdatePossibleLetters:filter (entity)
--     return entity.isSegment ~= nil
-- end



Components.DrawLines = tiny.processingSystem({isDrawSystem = true})
function Components.DrawLines:process (entity, dt)
    local position = entity.parent.position
    local size     = entity.parent.size

    love.graphics.setColor(0, 255, 0)

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


Components.Splitting = tiny.processingSystem({isUpdateSystem = true,
                                                      active = false})
function Components.Splitting:process (entity, dt)
end

function Components.Splitting:activate ()
    local prototype = PROTOTYPES.entities[4]

    for _, comp in pairs(self.entities) do
        if  prototype.image:getWidth()  <= comp.image:getWidth()
        and prototype.image:getHeight() <= comp.image:getHeight() then
            comp:overlay(prototype)
        end
    end
end

function Components.Splitting:filter (entity)
    return     entity.isComponent ~= nil
           and entity.string      == ".*"
end


return Components