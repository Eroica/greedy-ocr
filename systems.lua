function OverlayPrototypesSystem()
end

function DrawLineSystem()
    return ecs.System(isLine)
        :addEventListener("draw", function(entity)
            love.graphics.draw(entity:get(Image).image, 0, 0)
        end)
end

function DrawSegmentsSystem()
    return ecs.System(isSegment, Position, Size)
        :addEventListener("draw", function(entity)
            local position = entity:get(Position)
            local size = entity:get(Size)
            --local bounding_box = love.graphics.rectangle("line", position.l, position.t, size.width, size.height)

            love.graphics.setColor(255, 0, 255)
            love.graphics.rectangle("line", position.l, position.t, size.width, size.height)
            love.graphics.setColor(255, 255, 255)
        end)
end

function PrintSystem()
    return ecs.System(isSegment)
        :addEventListener("state", function(entity)
            for _, component in ipairs(entity.components) do
                io.write(component:get(String).string)
                print("")
            end
        end)
end

function OverlayPrototypesSystem()
    -- local prototypes = engine:getEntities(isPrototype)

    -- return ecs.System(isComponent)
    --     :addEventListener("draw", function(entity)
    --         for _, prot in ipairs(prototypes) do
    --             love.graphics.draw(prot:get(Image).image, 100, 100)
    --         end
    --     end)
end

function DrawComponentsSystem()
    return ecs.System(isSegment)
        :addEventListener("draw", function(entity)
            local size = entity:get(Size)
            local position = entity:get(Position)

            love.graphics.setColor(255, 0, 0)
            love.graphics.push() -- stores the default coordinate system
            love.graphics.translate(position.l, position.t) -- move the camera position

            for _, component in ipairs(entity.components) do
                local s, e = component:get(Range).s, component:get(Range).e
                love.graphics.line(s, 0, s, size.height)
                love.graphics.line(e, 0, e, size.height)
            end

            love.graphics.pop()
            love.graphics.setColor(255, 255, 255)
        end)
end