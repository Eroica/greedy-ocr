local config = require "_config"

local PROTOTYPE_DIR = config.prototypes_directory
local PAGES_DIR = config.pages_directory
local BIGRAM_FILE = config.corpus_filename

-- load_prototypes:
-- Checks the Prototypes directory (specified in `_config.lua') and
-- creates a Prototype for each image found.
-- IMPORTANT: Files that start with a `.' or an `_' are ignored. This
-- is to ignore hidden files, e.g. `.DS_Store', and to enable the user
-- to put images inside Prototypes directory that get loaded at another
-- place.
--
-- @params:
-- @returns:
function load_prototypes ()
    local content = love.filesystem.getDirectoryItems(PROTOTYPE_DIR)
    local prototypes = {}
    for _, directory in pairs(content) do
        if love.filesystem.isDirectory(PROTOTYPE_DIR .. "/" .. directory)
        and directory:sub(1, 1) ~= "."
        and directory:sub(1, 1) ~= "_" then
            table.insert(prototypes, directory)
        end

        if directory == "_capitals" then
            local capitals = love.filesystem.getDirectoryItems(PROTOTYPE_DIR .. "/_capitals")
            for _, prototype in pairs(capitals) do
                if prototype:sub(1, 1) ~= "." and prototype:sub(1, 1) ~= "_" then
                    print(prototype)
                    local prot_image = love.graphics.newImage(PROTOTYPE_DIR .. "/_capitals/" .. prototype)
                    local literal = explode(".", prototype)[1]
                    Entities.Prototype(literal, prot_image)
                end
            end
        end
    end

    local images = {}
    for _, prototype in pairs(prototypes) do
        images = love.filesystem.getDirectoryItems(PROTOTYPE_DIR .. "/" .. prototype)
         for _, image in pairs(images) do
            if image:sub(1, 1) ~= "." and image:sub(1, 1) ~= "_" then
                local prot_image = love.graphics.newImage(PROTOTYPE_DIR .. "/" .. prototype .. "/" .. image)
                Entities.Prototype(prototype, prot_image)
            end
        end
    end

    for _, prototype in pairs(config.additional_prototypes) do
        Entities.Prototype(prototype[1], love.graphics.newImage(prototype[2]))
    end
end


-- load_image:
-- Goes inside the Pages directory (specified in `_config.lua') and
-- looks for a pair of an image and a Lua file with the same name.
-- This Lua file should contain the bounding boxes of the words found
-- in the image, and will be read using `dofile()'.
--
-- @params:
-- @returns:
function load_image ()
    local pages = love.filesystem.getDirectoryItems(PAGES_DIR)

    for _, filename in pairs(pages) do
        if  filename:sub(1, 1) ~= "."
        and filename:sub(1, 1) ~= "_" then
            local file = explode(".", filename)
            local name = file[1]
            local suffix = file[2]

            if suffix ~= "lua" then
                local image_filename = PAGES_DIR .. "/" .. name .. "." .. suffix
                local image = love.graphics.newImage(image_filename)
                local lua_filename = PAGES_DIR .. "/" .. name .. "." .. "lua"
                return Entities.Page(image, dofile(lua_filename))
            end
        end
    end
end


-- load_bigram:
-- Takes the corpus specified in `_config.lua' and creates a bigram
-- model over the letters.
--
-- @params:
-- @returns: MODEL: The bigram
--                  @type: table
function load_bigram (reverse)
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
        if reverse then
            w2 = w1; w1 = w;
        else
            w1 = w2; w2 = w;
        end

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