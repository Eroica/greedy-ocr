local LanguageModel = {}

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


LanguageModel.Lexicon = class("Lexicon")
function LanguageModel.Lexicon:__init (lexicon_filename)
    local lexicon_file = io.open(lexicon_filename, "r")

    for line in lexicon_file:lines() do
        self[line] = true
    end
end

function LanguageModel.Lexicon:contains (str)
    return self[str] ~= nil
end

function LanguageModel.Lexicon:lookup (str)
    local matches = {}

    for word, value in pairs(self) do
        local s, e = word:find(str)
        if s then
            matches[#matches + 1] = word
        end
    end

    return matches
end


LanguageModel.Bag = class("Bag")
function LanguageModel.Bag:__init ()
    -- counts the number of words
    self["_count"] = 0
end

function LanguageModel.Bag:insert (element)
    self["_count"] = self["_count"] + 1
    self[element] = (self[element] or 0) + 1
end

function LanguageModel.Bag:remove (element)
    local count = self[element]
    self[element] = (count and count > 1) and count - 1 or nil
end

LanguageModel.Ngram = class("Ngram")
function LanguageModel.Ngram:__init (filename, check_letters)
    local corpus_file = io.open(filename)
    local w1, w2 = "", ""

    local iterator = allwords
    if check_letters then iterator = allletters end

    for w in iterator(corpus_file) do
        w1 = w2; w2 = w;

        if self[w1] == nil then
            self[w1] = LanguageModel.Bag()
            self[w1]:insert(w2)
        else
            self[w1]:insert(w2)
        end
    end

    corpus_file:close()
end


return LanguageModel