--[[
    greedy-ocr
    Original Work Copyright (c) 2015 Sebastian Spaar
------------------------------------------------------------------------
    gr_ngram.lua

    This script can be used separately to create a bigram model for a
    given corpus file (found in `_config.lua'). The model is represented
    by an "Ngram" class (a table), but no serialization is supported at
    the moment. This is why code from this script is used directly in
    `setup.lua'.
]]

#!/usr/bin/env lua

inspect = require "inspect"
local LanguageModel = require "LanguageModel"
local config = require "_config"

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


local corpus_file = io.open(config.corpus_filename)
local w1, w2 = "", ""
WORD_MODEL = {}

for w in allwords(corpus_file) do
    w1 = w2; w2 = w;

    if WORD_MODEL[w1] == nil then
        WORD_MODEL[w1] = LanguageModel.Bag()
        WORD_MODEL[w1]:insert(w2)
    else
        WORD_MODEL[w1]:insert(w2)
    end
end

corpus_file:seek("set", 0)
w1, w2 = "", ""
LETTER_MODEL = {}

for w in allletters(corpus_file) do
    w1 = w2; w2 = w;

    if LETTER_MODEL[w1] == nil then
        LETTER_MODEL[w1] = LanguageModel.Bag()
        LETTER_MODEL[w1]:insert(w2)
    else
        LETTER_MODEL[w1]:insert(w2)
    end
end

corpus_file:close()