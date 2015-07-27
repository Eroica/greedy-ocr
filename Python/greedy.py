import os
import numpy as np
import cv2
import re

import gr_config as CONFIG
from Component import Component
from Prototype import Prototype
from Word import Word
from LanguageModel import Lexicon

def threshold(image):
    """
    """

    (thresh, image_bw) = cv2.threshold(image, 127, 255, cv2.THRESH_BINARY)

    return image_bw


WORDS_BB = [
    ((14, 2), (199, 64)),
    ((220, 5), (421, 51)),
    ((432, 5), (550, 55)),
    ((562, 2), (677, 56)),
    ((695, 5), (797, 49)),
    ((820, 5), (905, 53))
]

e = Prototype.from_image_file('e', '../share/e.png')
c = Prototype.from_image_file('c', '../share/c.png')
ch = Prototype.from_image_file('ch', '../share/ch.png')
img = cv2.imread('../share/ausschnitt.png', 0)
indessen = Word(img, ((14, 2), (199, 64)))
etliche = Word(img, ((432, 5), (550, 55)))

ausschnitt = []
for pair in WORDS_BB:
    ausschnitt.append(Word(img, pair))

etliche._split_at(10, 100)
etliche._split_at(5, 112)

lexicon = Lexicon(CONFIG.LEXICON_FILE)
