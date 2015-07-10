import os
import numpy as np
import cv2
import components
import re

IMG_FILE = '../share/ausschnitt.png'
LEXICON_FILE = '../share/lexicon.txt'
PROTOTYPE_FILES = ['../share/e.png', '../share/n.png']

WORDS_BB = [
    ((14, 2), (199, 64)),
    ((220, 5), (421, 51)),
    ((432, 5), (550, 55)),
    ((562, 2), (677, 56)),
    ((695, 5), (797, 49)),
    ((820, 5), (905, 53))
]



def lexicon_query(word):
    """
    """

    search_term = '^' + word + '$'

    return [word.group(0) for word in (re.search(search_term, l) for l in lexicon) if word]




e = components.Prototype.from_image_file('e', '../share/e.png')
c = components.Prototype.from_image_file('c', '../share/c.png')
ch = components.Prototype.from_image_file('ch', '../share/ch.png')
img = cv2.imread('../share/ausschnitt.png', 0)
indessen = components.Word(img, ((14, 2), (199, 64)))
etliche = components.Word(img, ((432, 5), (550, 55)))

lexicon = set([line.rstrip('\n') for line in open(LEXICON_FILE)])

# img = cv2.imread(IMG_FILE, 0)
# e = cv2.imread(PROTOTYPE_FILES[0], 0)
# n = cv2.imread(PROTOTYPE_FILES[1], 0)
# c = cv2.imread('../share/c.png', 0)
# e_2 = cv2.imread('../share/e_2.png', 0)
# e_3 = cv2.imread('../share/e_3.png', 0)
# ch = cv2.imread('../share/ch.png', 0)
# etliche = cv2.imread('../share/etliche.png', 0)