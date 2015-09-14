--[[
    greedy-ocr
    Original Work Copyright (c) 2015 Sebastian Spaar
------------------------------------------------------------------------
    _config.lua

]]

local config = {}

config.DEBUG = true

config.prototypes = {
    {"ch", "prototypes/ch.png"},
    {"c", "prototypes/c.png"},
    {"e", "prototypes/e.png"}
}

config.BACKGROUND_COLOR = {127, 127, 127}

config.line = {
    "pages/992793.jpg",
    boxes = {
        {{2, 14}, {136, 64}},
        {{157, 11}, {229, 51}},
        {{261, 2}, {543, 58}},
        {{563, 1}, {858, 61}},
    }
}

return config