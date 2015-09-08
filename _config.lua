--[[
    greedy-ocr
    Original Work Copyright (c) 2015 Sebastian Spaar
------------------------------------------------------------------------
    _config.lua

]]

local config = {}

config.DEBUG = true

config.prototypes = {
    {"ch", "share/ch.png"},
    {"c", "share/c.png"},
    {"e", "share/e.png"}
}

config.BACKGROUND_COLOR = {127, 127, 127}

config.line = {
    "pages/line.png",
    boxes = {
        {{2, 14}, {136, 64}},
        {{157, 11}, {229, 51}},
        {{261, 2}, {543, 58}},
        {{563, 1}, {858, 61}},
    }
}

return config