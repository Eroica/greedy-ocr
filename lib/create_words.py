import os
import numpy as np
import cv2
import prototypes
import config

# assert all(folder in os.listdir('.') for folder in FOLDERS)
# assert LEXICON in os.listdir('.')

folders = os.listdir(config.IMAGES_PATH)
letters = dict((l, []) for l in filter(lambda x: x in folders, config.ALPHABET))
letter_images = {}

test_phrase = "eine neue"
test_text = """eine neue
der die das
ein einer"""

for letter in letters:
    letter_images[letter] = []

    for file in os.listdir(config.IMAGES_PATH + '/' + letter):
        if file.endswith(config.EXTENSIONS):
            letter_images[letter].append(file)

    # DEBUG
    letter_images[letter] = letter_images[letter][0]

for letter in letter_images:
    img = cv2.imread(config.IMAGES_PATH + '/' + letter + '/' + letter_images[letter])
    letters[letter] = img

Alphabet = prototypes.PrototypeFactory(letters)

a = Alphabet.create_word("""des bibers
freude ist das
nagen""")
if a:
    cv2.imshow('', a.image)
    cv2.waitKey(0)