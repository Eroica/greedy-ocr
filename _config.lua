--[[
    greedy-ocr
    Original Work Copyright (c) 2015 Sebastian Spaar
------------------------------------------------------------------------
    _config.lua

]]

local config = {}

config.DEBUG = true

config.lexicon_filename = "_share/lexicon_1st_half.txt"
config.corpus_filename  = "_share/mercurius_1st_half.txt"

config.prototypes_directory = "_prototypes"
config.pages_directory      = "_pages"

config.BACKGROUND_COLOR = {127, 127, 127}

config.MINIMUM_COMPONENT_WIDTH = 10
config.SPLIT_THRESHOLD = 0.75

config.prototype_ranking = {
    "u", "m", "n", "l", "i", "t"
}

config.additional_prototypes = {
    {"s", "_prototypes/_s_2.png"},
    {"d", "_prototypes/_d_2.png"},
    {"S", "_prototypes/_s_c.png"},
    {"T", "_prototypes/_t_c.png"},
    {"J", "_prototypes/_j_c.png"},
    {"K", "_prototypes/_k_c.png"},
    {"H", "_prototypes/_h_c.png"},
    {"G", "_prototypes/_g_c.png"},
    {"F", "_prototypes/_f_c.png"},
    {"B", "_prototypes/_b_c.png"},
    {"A", "_prototypes/_a_c.png"},
    {"l", "_prototypes/_l_2.png"},
}

config.UNKNOWN_COMPONENTS = {[".*"] = true, [".?"] = true}

return config