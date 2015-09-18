--[[
    greedy-ocr
    Original Work Copyright (c) 2015 Sebastian Spaar
------------------------------------------------------------------------
    _config.lua

]]

local config = {}

config.DEBUG = true

config.lexicon_filename = "_share/lexicon.txt"

config.prototypes_directory = "_prototypes"

config.BACKGROUND_COLOR = {127, 127, 127}

config.line = {
    "_pages/992793.jpg",
    boxes = {
        {155, 17, 159, 58},
        {333, 29, 103, 48},
        {447, 38, 73, 52},
        {535, 21, 122, 69},
        {669, 25, 55, 58},
        {736, 45, 48, 38},
        {847, 30, 97, 66},
        {947, 38, 148, 67},
        {20, 82, 324, 76},
        {384, 93, 149, 62},
        {537, 97, 83, 53},
        {633, 111, 75, 40},
        {711, 94, 132, 71},
        {843, 108, 89, 52},
        {934, 102, 162, 73},
        {19, 155, 112, 59},
        {144, 155, 200, 57},
        {357, 159, 167, 55},
        {577, 166, 168, 55},
        {749, 168, 89, 54},
        {842, 169, 256, 66},
        {18, 217, 213, 68},
        {243, 221, 112, 63},
        {365, 219, 150, 68},
        {527, 228, 241, 61},
        {823, 228, 107, 66},
        {941, 238, 154, 64},
        {14, 284, 222, 70},
        {248, 283, 214, 64},
        {476, 292, 165, 60},
        {646, 297, 111, 61},
        {761, 299, 155, 65},
        {925, 301, 170, 65},
        {14, 352, 122, 66},
        {145, 352, 141, 66},
        {297, 354, 331, 62},
        {641, 370, 93, 49},
        {773, 366, 55, 65},
        {834, 374, 84, 54},
        {920, 372, 174, 64},
        {12, 417, 162, 64},
        {175, 423, 222, 55},
        {416, 421, 139, 69},
        {565, 428, 252, 63},
        {845, 430, 134, 62},
        {981, 437, 110, 67},
        {14, 481, 293, 71},
        {316, 485, 67, 70},
        {399, 488, 55, 66},
        {463, 491, 109, 60},
        {575, 495, 252, 56},
        {886, 498, 113, 61},
        {1006, 512, 83, 51},
        {14, 554, 79, 61},
        {113, 546, 149, 69},
        {276, 552, 52, 64},
        {340, 558, 93, 52},
        {452, 553, 269, 72},
        {746, 559, 220, 66},
        {973, 569, 112, 64},
        {11, 614, 273, 66},
        {295, 621, 217, 62},
        {615, 625, 106, 56},
        {731, 630, 83, 52},
        {816, 630, 168, 61},
        {991, 641, 92, 53},
        {13, 678, 194, 71},
        {220, 685, 108, 64},
        {333, 685, 125, 65},
        {470, 697, 54, 51},
        {533, 689, 174, 67},
        {761, 700, 88, 53},
        {857, 697, 90, 62},
        {956, 700, 66, 58},
        {1028, 700, 54, 60},
        {9, 746, 168, 70},
        {186, 748, 123, 70},
        {331, 751, 182, 65},
        {519, 751, 183, 70},
        {725, 760, 84, 56},
        {820, 770, 53, 52},
        {885, 758, 198, 67},
        {10, 825, 101, 48},
        {169, 810, 107, 62},
        {278, 815, 58, 55},
        {341, 816, 141, 66},
        {493, 821, 54, 65},
        {551, 832, 95, 48},
        {658, 827, 109, 60},
        {778, 825, 304, 69},
        {7, 877, 185, 69},
        {272, 879, 145, 71},
        {423, 894, 106, 51},
        {545, 884, 290, 72},
        {843, 898, 106, 60},
        {952, 897, 131, 63},
        {7, 943, 262, 70},
        {349, 951, 114, 62},
        {474, 965, 79, 55},
        {560, 956, 133, 63},
        {701, 958, 77, 58},
        {783, 956, 100, 64},
        {888, 964, 82, 56},
        {976, 959, 103, 72},
        {7, 1011, 182, 66},
        {220, 1016, 106, 57},
        {357, 1016, 145, 66},
        {522, 1024, 72, 56},
        {625, 1022, 161, 68},
        {800, 1019, 278, 78},
        {10, 1072, 227, 74},
        {248, 1079, 194, 67},
        {454, 1087, 185, 59}
    }
}

return config