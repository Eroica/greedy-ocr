local entities = {}

function entities.newLine(image)
    local line = ecs.Entity()
    line.segments = {}
    line:add(isLine)
          :add(Image, image)

    STATE_MANAGER:current():addEntity(line)

    return line
end

function entities.newSegment(l, t, width, height)
    local segment = ecs.Entity()
        :add(isSegment)
        :add(Position, l, t)
        :add(Size, width, height)

    segment.components = {}
    local component = entities.newComponent(0, width - 1)
    table.insert(segment.components, component)

    STATE_MANAGER:current():addEntity(segment)

    return segment
end

function entities.newPrototype(literal, image)
    local prototype = ecs.Entity()
        :add(isPrototype)
        :add(String, literal)
        :add(Image, image)

    create_prototype_system(prototype)

    STATE_MANAGER:current():addEntity(prototype)

    return prototype
end

function entities.newComponent(s, e)
    local component = ecs.Entity()
        :add(isComponent)
        :add(Range, s, e)
        :add(String)

    STATE_MANAGER:current():addEntity(component)

    return component
end

function create_prototype_system(prototype)
    local x = ecs.System(isComponent)
        :addEventListener("update", function(entity)
            print("checking for prototype " .. prototype:get(String).string)
        end)

    STATE_MANAGER:current():addSystem(x)
end

return entities