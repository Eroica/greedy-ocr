local Prototypes = {}


Prototypes.sharedPrototypes = tiny.sortedSystem({isUpdateSystem = true})
function Prototypes.sharedPrototypes:compare (e1, e2)
    if e1.image:getWidth() > e2.image:getWidth() then
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

function Prototypes.OverlayPrototypes:filter (entity)
    return entity.isPrototype ~= nil
end


return Prototypes