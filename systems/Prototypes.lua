local Prototypes = {}

-- This system provides a wrapper for all existing prototypes by sorting
-- them according to their size (larger prototypes come before smaller
-- ones).
Prototypes.sharedPrototypes = tiny.sortedSystem({isUpdateSystem = true})
function Prototypes.sharedPrototypes:onAddToWorld (world)
    -- self.prototype_images = {}
end

function Prototypes.sharedPrototypes:update (dt)
    -- local prototype_images = {}
    -- for i=1, #self.entities do
    --     prototype_images[#prototype_images + 1] = self.entities[i].image_bw
    -- end

    -- self.prototype_images = prototype_images
end

function Prototypes.sharedPrototypes:compare (e1, e2)
    local area_1 = e1.image:getWidth() * e1.image:getHeight()
    local area_2 = e2.image:getWidth() * e2.image:getHeight()

    if area_1 > area_2 then
        return true
    else
        return false
    end
end

function Prototypes.sharedPrototypes:filter (entity)
    return entity.isPrototype ~= nil
end



Prototypes.OverlayPrototypes = tiny.system({isDrawSystem = true, active = false})
function Prototypes.OverlayPrototypes:update (dt)
    local width, height = love.graphics.getDimensions()
    local padding = 4
    local next_x = padding
    local next_y = padding

    love.graphics.setColor(0, 0, 0, 191)
    love.graphics.rectangle("fill", 0, 0, width, height)
    love.graphics.setColor(255, 255, 255)

    for i=1, #PROTOTYPES.entities do
        local image = PROTOTYPES.entities[i].image

        love.graphics.draw(image, next_x, next_y)
        next_x = next_x + image:getWidth() + padding

        if  i ~= #PROTOTYPES.entities
        and next_x + padding + PROTOTYPES.entities[i+1].image:getWidth() > width then
            next_x = padding
            next_y = next_y + padding + 100
        end
    end
end

-- function Prototypes.OverlayPrototypes:filter (entity)
--     return entity.isPrototype ~= nil
-- end


return Prototypes