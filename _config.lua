--[[
    greedy-ocr
    Original Work Copyright (c) 2015 Sebastian Spaar
------------------------------------------------------------------------
    _config.lua

]]

local config = {}

config.DEBUG = true

config.use_lexicon = true
config.use_bigram = true

config.lexicon_filename = "_share/lexicon_until_april.txt"
config.corpus_filename  = "_share/mercurius_until_april.txt"

config.prototypes_directory = "_prototypes"
config.pages_directory      = "_pages"

config.automatically_split_segments = true
config.MINIMUM_COMPONENT_WIDTH = 10
config.SPLIT_THRESHOLD = 0.80
config.HIGH_SPLIT_THRESHOLD = 0.85

config.prototype_ranking = {
    "b", "d", "u", "m", "n", "r", "o", "l", "i", "t"
}

config.high_confidence = {
     l = true, i = true, u = true, r = true, t = true, m = true, d = true, o = true
}

config.separate_clusters = {s = true, i = true}

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

config.punctuation = {["."] = true, ["-"] = true, ["/"] = true}

config.UNKNOWN_COMPONENTS = {[".*"] = true, [".+"] = true, ["."] = true, [".?"] = true}

-- Colors.
config.BACKGROUND_COLOR = {127, 127, 127}
config.FONT_COLOR = {150, 152, 150}
config.HUD_COLOR = {66, 66, 66}
config.HUD_LINE_COLOR = {42, 42, 42}
config.SEGMENT_COLOR = {213, 78, 83}
config.COMPONENT_COLOR = {122, 166, 218}

return config