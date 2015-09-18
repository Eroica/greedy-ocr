local Components = {}


Components.DrawRange = tiny.system({isDrawSystem = true})
function Components.DrawRange:update (dt)
    local x, y = CAMERA:toWorld(love.mouse.getPosition())

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

function Components.DrawRange:filter (entity)
    return entity.isSegment ~= nil
end




Components.Splitting = tiny.processingSystem({isUpdateSystem = true, active = false})
function Components.Splitting:process (entity, dt)
    local prototypes = all_prototypes.entities

    for _, prototype in pairs(prototypes) do
        print ("I wanna check " .. tostring(prototype) )
    end

end

function Components.Splitting:filter (entity)
    return entity.isComponent ~= nil
end


return Components