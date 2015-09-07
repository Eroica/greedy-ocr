function load_prototypes()
    prototypes = {}
    new_prototypes = {}

    for _, prototype in pairs(config.prototypes) do
        local image = love.graphics.newImage(prototype[2])
        local prototype = entities.Prototype(prototype[1], image)
        table.insert(prototypes, prototype)
    end
end

function load_image()
    local line_image = love.graphics.newImage(config.line[1])
    line = entities.Line(line_image, config.line.boxes)
    segments = line._segments
end