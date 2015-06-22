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

text = Alphabet.create_word("""abc
def
gh i l m
m y y y""")

a = prototypes.Prototype.from_image_file("a", "../share/letters/a/93.jpg")
b = prototypes.Prototype.from_image_file("b", "../share/letters/b/155.jpg")
e = prototypes.Prototype.from_image_file("c", "../share/letters/e/41.jpg")
ab = a + b
abe = a + b + e

cv2.imshow('a', a.image)
cv2.imshow('b', b.image)
cv2.imshow('e', e.image)
cv2.imshow('ab', ab.image)
cv2.imshow('abe', abe.image)
cv2.waitKey(0)

if text:
    cv2.imshow('', text.image)
    cv2.waitKey(0)