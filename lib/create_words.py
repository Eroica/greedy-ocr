import os

LETTERS = 'abcdefghijklmnopqrstuvwxyz'
FOLDERS = [char for char in LETTERS] + [char + '_' for char in LETTERS]
LEXICON = 'lexicon.txt'

assert all(folder in os.listdir('.') for folder in FOLDERS)
assert LEXICON in os.listdir('.')