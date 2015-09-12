function load_prototypes()
    local prototypes = {}

    for _, prototype in pairs(config.prototypes) do
        local image = love.graphics.newImage(prototype[2])
        local prototype = Entities.Prototype(prototype[1], image)
        table.insert(prototypes, prototype)
    end

    return prototypes
end

function load_image()
    local line_image = love.graphics.newImage(config.line[1])
    local page = Entities.Page(line_image, config.line.boxes)
    return page
end