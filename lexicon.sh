#!/usr/bin/bash

LC_ALL="de" sort -fd lexicon.txt | uniq > new_lex.txt