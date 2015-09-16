local binser = require "lib/binser"
local LanguageModel = require "LanguageModel"


-- `allwords', `allletters' functions:
-- These are 2 helper functions that are used to iterate over a text
-- file, and return every pair of successive words/letters.
local function allwords (corpus_file)
    local line = corpus_file:read()
    local pos = 1
    return function ()
        while line do
            local s, e = string.find(line, "%S+", pos)
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



local corpus_file = io.open("share/mercurius.txt")
local w1, w2 = "", ""

model = {}

local iterator = allwords
-- swap the file iterator to check for letters instead of words
if check_letters then iterator = allletters end

for w in iterator(corpus_file) do
    w1 = w2; w2 = w;

    if model[w1] == nil then
        model[w1] = LanguageModel.Bag()
        model[w1]:insert(w2)
    else
        model[w1]:insert(w2)
    end
end

corpus_file:close()