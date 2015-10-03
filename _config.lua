--[[
    greedy-ocr
    Original Work Copyright (c) 2015 Sebastian Spaar
------------------------------------------------------------------------
    _config.lua

]]

local config = {}

config.DEBUG = true

config.lexicon_filename = "_share/lexicon_until_april.txt"
config.corpus_filename  = "_share/mercurius_until_april.txt"

config.prototypes_directory = "_prototypes"
config.pages_directory      = "_pages"

config.BACKGROUND_COLOR = {127, 127, 127}

config.automatically_split_segments = false
config.MINIMUM_COMPONENT_WIDTH = 10
config.SPLIT_THRESHOLD = 0.75

config.prototype_ranking = {
    "u", "m", "n", "l", "i", "t"
}

config.additional_prototypes = {
    {"M", "_prototypes/_m_c.png"},
    {"J", "_prototypes/_j_c.png"},
    {"P", "_prototypes/_p_c.png"},
    {"ß", "_prototypes/_sz.png"},
    {"T", "_prototypes/_t_c.png"},
    {"N", "_prototypes/_n_c.png"},
    {"B", "_prototypes/_b_c.png"},
    {"i", "_prototypes/_i_2.png"},
    {"S", "_prototypes/_s_c.png"},
    {"F", "_prototypes/_f_c.png"},
    {"V", "_prototypes/_v_c.png"},
    {"C", "_prototypes/_c_c.png"},
    {"R", "_prototypes/_r_c.png"},
    {"D", "_prototypes/_d_c.png"},
}

config.UNKNOWN_COMPONENTS = {[".*"] = true, [".?"] = true}

return config