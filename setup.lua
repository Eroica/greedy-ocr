local PROTOTYPE_DIR = config.prototypes_directory
local PAGES_DIR = config.pages_directory

function load_prototypes ()
    local function create_prototype (filename)
        if  love.filesystem.isFile(PROTOTYPE_DIR .. "/" .. filename)
        and filename:sub(1, 1) ~= "."
        and filename:sub(1, 1) ~= "_" then
            local image = love.graphics.newImage(PROTOTYPE_DIR .. "/" .. filename)

            -- Get the part before the `.'
            local literal = explode(".", filename)[1]

            Entities.Prototype(literal, image)
        end
    end

    love.filesystem.getDirectoryItems(PROTOTYPE_DIR, create_prototype)
end

function load_image()
    local line_image = love.graphics.newImage(config.line[1])
    local page = Entities.Page(line_image, config.line.boxes)
    return page
end