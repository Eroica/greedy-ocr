#
#   greedy-ocr
#   Original Work Copyright (c) 2015 Sebastian Spaar
#-----------------------------------------------------------------------
#   gr_lexicon.sh
#
#   tbd

#!/usr/bin/bash
cat mercurius_1st_half.txt | tr -cs "[:alpha:]" "\n" | sort | uniq > raw_lexicon.txt
LC_ALL="de" sort -fd lexicon.txt | uniq > new_lex.txt