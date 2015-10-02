--[[
    greedy-ocr
    Original Work Copyright (c) 2015 Sebastian Spaar
------------------------------------------------------------------------
    gr_mercurius.lua

    This script was used to parse the Mercurius XML file, and extract
    all sentences.
]]

local xml = require "xml"

MERCURIUS_FILE = "mercurius.xml"
OUTPUT_FILE = io.open(arg[1], "w")

local xml_file = assert(io.open(MERCURIUS_FILE, "r"))
local xml_file_content = xml_file:read("*all")
xml_file:close()

local xml_data = xml.load(xml_file_content)
local xml_body = xml.find(xml_data, "body")


repeat
    local s = table.remove(xml_body, 1)
    local s_terminals = xml.find(s, "terminals")
    local parsed_sentence = {}

    for i=1, #s_terminals do
        table.insert(parsed_sentence, s_terminals[i]["word"])
    end

    local sentence = table.concat(parsed_sentence, " ")

    OUTPUT_FILE:write(sentence .. "\n")
until #xml_body == 0

OUTPUT_FILE:close()