#
#   greedy-ocr
#   Original Work Copyright (c) 2015 Sebastian Spaar
#-----------------------------------------------------------------------
#   gr_lexicon.sh
#
#   tbd

#!/usr/bin/bash

LC_ALL="de" sort -fd lexicon.txt | uniq > new_lex.txt