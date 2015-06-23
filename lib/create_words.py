import os
import numpy as np
import cv2
import prototypes
import config
from random import choice

# assert all(folder in os.listdir('.') for folder in FOLDERS)
# assert LEXICON in os.listdir('.')

lexicon = [line.rstrip('\n') for line in open(config.LEXICON)]

folders = os.listdir(config.IMAGES_PATH)
letters = dict((l, []) for l in filter(lambda x: x in folders, config.ALPHABET))
letter_images = {}

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

# Randomly select 100 words for a test page
test_words = []
while len(test_words) < 100:
    word = choice(lexicon)
    if all(char in Alphabet.keys() for char in word):
        test_words.append(word)



def chunks(l, n):
    """Yield successive n-sized chunks from l."""
    for i in xrange(0, len(l), n):
        yield l[i:i+n]


lines = [line for line in chunks(test_words, 5)]
lines = map(' '.join, lines)
text = "\n".join(line for line in lines)

text_prototype = Alphabet.create_word(text)


# a = prototypes.Prototype.from_image_file("a", "../share/letters/a/93.jpg")
# b = prototypes.Prototype.from_image_file("b", "../share/letters/b/155.jpg")
# e = prototypes.Prototype.from_image_file("c", "../share/letters/e/41.jpg")
# ab = a + b
# abe = a + b + e

# cv2.imshow('a', a.image)
# cv2.imshow('b', b.image)
# cv2.imshow('e', e.image)
# cv2.imshow('ab', ab.image)
# cv2.imshow('abe', abe.image)
# cv2.waitKey(0)

# if text:
#     cv2.imshow('', text.image)
#     cv2.waitKey(0)