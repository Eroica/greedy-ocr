local config = require "_config"

local PROTOTYPE_DIR = config.prototypes_directory
local PAGES_DIR = config.pages_directory
local BIGRAM_FILE = config.corpus_filename

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

    for _, prototype in pairs(config.additional_prototypes) do
        Entities.Prototype(prototype[1], love.graphics.newImage(prototype[2]))
    end
end

function load_image ()
    local line_image = love.graphics.newImage(config.line[1])
    local page = Entities.Page(line_image, config.line.boxes)
    return page
end

function load_bigram ()
    local function allletters (corpus_file)
        local line = corpus_file:read()
        local pos = 1
        return function ()
            while line do
                local s, e = string.find(line, "[%g%s]", pos)
                if s then
                    pos = e + 1
                    return string.sub(line, s, e)
                else
                    line = corpus_file:read()
                    pos = 1
                end
            end
            return nil
        end
    end


    local corpus_file = io.open(BIGRAM_FILE)
    local w1, w2 = "", ""
    local MODEL = {}

    for w in allletters(corpus_file) do
        w1 = w2; w2 = w;

        if MODEL[w1] == nil then
            MODEL[w1] = LanguageModel.Bag()
            MODEL[w1]:insert(w2)
        else
            MODEL[w1]:insert(w2)
        end
    end
    corpus_file:close()

    return MODEL
end