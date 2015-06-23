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



def chunks(l, n):
    """Yield successive n-sized chunks from l."""
    for i in xrange(0, len(l), n):
        yield l[i:i+n]


def filter_lexicon_words(lexicon, length=100):
    """
    """

    # Randomly select 100 words for a test page
    test_words = []
    while len(test_words) < length:
        word = choice(lexicon)
        if all(char in Alphabet.keys() for char in word):
            test_words.append(word)

    return test_words

def generate_letter_images(letters):
    """
    """

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


generate_letter_images(letters)
Alphabet = prototypes.PrototypeFactory(letters)


def generate_text_lines(test_words):
    """
    """

    lines = [line for line in chunks(test_words, 5)]
    lines = map(' '.join, lines)
    # text = "\n".join(line for line in lines)

    return lines

# text_prototype = Alphabet.create_word(text)


if __name__ == '__main__':
    exps = []
    for i in range(0, 64):
        words = filter_lexicon_words(lexicon)
        line = generate_text_lines(words)[0]
        line_prototype = Alphabet.create_word(line)
        exps.append(line_prototype)

        cv2.imwrite(config.LANGUAGE_MODEL + '.' + config.LANGUAGE_NAME + '.' + 'exp' + str(i) + '.tif', line_prototype.image)
        line_prototype.write_box_file(config.LANGUAGE_MODEL + '.' + config.LANGUAGE_NAME + '.' + 'exp' + str(i) + '.box')

