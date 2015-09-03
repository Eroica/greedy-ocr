function Setup(state)
    return ecs.Engine()
end

function CheckForPrototypes(state)
    return ecs.Engine()
        :addSystem(DrawLineSystem())
        :addSystem(DrawSegmentsSystem())
        :addSystem(DrawComponentsSystem())
        --:addSystem(OverlayPrototypesSystem())
end

function QueryDictionary(state)
end

function SplitComponents(state)
    return ecs.Engine()

end