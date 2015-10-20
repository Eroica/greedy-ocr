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
config.SPLIT_THRESHOLD = 0.75
config.HIGH_SPLIT_THRESHOLD = 0.82
config.VERY_HIGH_SPLIT_THRESHOLD = 0.85

config.prototype_ranking = {
    "h", "b", "d", "u", "m", "n", "r", "o", "l", "i", "c", "t"
}

config.high_confidence = {
    u = true, r = true, m = true, n = true, d = true, o = true, a = true
}

config.very_high_confidence = {
    l = true, e = true, i = true, t = true, c = true
}

config.separate_clusters = {s = true, st = true, v = true}

config.additional_prototypes = {
    {"ä", "_prototypes/_a_u.png"},
    {"ä", "_prototypes/_a_u_2.png"},
    {"ö", "_prototypes/_o_u.png"},
    {"A", "_prototypes/_a_c_2.png"},
    {"B", "_prototypes/_b_c_2.png"},
    {"B", "_prototypes/_b_c_3.png"},
    {"D", "_prototypes/_d_c_2.png"},
    {"D", "_prototypes/_d_c_3.png"},
    {"F", "_prototypes/_f_c_2.png"},
    {"F", "_prototypes/_f_c_3.png"},
    {"G", "_prototypes/_g_c_2.png"},
    {"H", "_prototypes/_h_c_2.png"},
    {"H", "_prototypes/_h_c_3.png"},
    {"H", "_prototypes/_h_c_4.png"},
    {"K", "_prototypes/_k_c_2.png"},
    {"K", "_prototypes/_k_c_3.png"},
    {"L", "_prototypes/_l_c_2.png"},
    {"L", "_prototypes/_l_c_3.png"},
    {"P", "_prototypes/_p_c_2.png"},
    {"S", "_prototypes/_s_c_2.png"},
    {"T", "_prototypes/_s_c_2.png"},
    {"Sch", "_prototypes/_Sch_c.png"},
    {"Sch", "_prototypes/_Sch_c_2.png"},
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