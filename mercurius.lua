local xml = require "xml"

MERCURIUS_FILE = "mercurius.xml"

local xml_file = io.open(MERCURIUS_FILE, "r")
local xml_file_content = xml_file:read("*all")
xml_file:close()
local xml_data = xml.load(xml_file_content)

local xml_body = xml.find(xml_data, "body")

local parsed_sentences = {}

output_file = io.open(arg[1], "w")

repeat
    local s = table.remove(xml_body, 1)
    local s_terminals = xml.find(s, "terminals")
    local parsed_sentence = {}

    for i=1, #s_terminals do
        table.insert(parsed_sentence, s_terminals[i]["word"])
    end

    local sentence = table.concat(parsed_sentence, " ")

    output_file:write(sentence .. "\n")
until #xml_body == 0

output_file:close()