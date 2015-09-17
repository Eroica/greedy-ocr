--[[
    greedy-ocr
    Original Work Copyright (c) 2015 Sebastian Spaar
------------------------------------------------------------------------
    LanguageModel.lua

]]

local class = require "lib/30log"

local LanguageModel = {}



-- Lexicon:
-- A Lexicon object represents a lexicon. Each word is a key in the
-- table. It is used by Systems to query possible words for redacted
-- strings.
LanguageModel.Lexicon = class("Lexicon")

-- Lexicon:init
-- @params: lexicon_filename : string
-- @returns: Lexicon object
function LanguageModel.Lexicon:init (lexicon_filename)
    -- HACK: The "class" field needs to be removed, otherwise it would
    -- get treated as a word. This, unfortunately, breaks 30log's class
    -- functionalities.
    self.class = nil
    getmetatable(self).__tostring = nil

    local lexicon_file = io.open(lexicon_filename, "r")

    for line in lexicon_file:lines() do
        self[line] = true
    end
end

-- Lexicon:contains
-- @params: str : string
--     A word that might be in the lexicon.
-- @returns: true/false
function LanguageModel.Lexicon:contains (str)
    return self[str] ~= nil
end

-- Lexicon:lookup
-- @params: str : string
--     A string or string pattern in Lua's pattern language.
-- @returns: matches : table
--     A table containing all words in the lexicon that match `str'.
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


-- Bag:
-- A Bag object is used to count occurances of things. For instance,
-- the number how many times `word' appears in a corpus.
LanguageModel.Bag = class("Bag")
function LanguageModel.Bag:init ()
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


-- Ngram:
-- The Ngram object represents n-gram models of word or letter
-- distributions. It is a table of Bags for every word/letter.
LanguageModel.Ngram = class("Ngram")

-- Ngram:init
-- @params:
--     filename : string
--         The name of the corpus file.
--     check_letters : true/false
--         If true, create a bigram model of letters instead of words.
function LanguageModel.Ngram:init (filename, check_letters)
    local corpus_file = io.open(filename)
    local w1, w2 = "", ""

    local iterator = allwords
    -- swap the file iterator to check for letters instead of words
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