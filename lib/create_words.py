import os
import numpy as np
import cv2
import prototypes

LETTERS = 'abcdefghijklmnopqrstuvwxyz'
# FOLDERS = [char for char in LETTERS] + [char + '_' for char in LETTERS]
LEXICON = 'lexicon.txt'
EXTENSIONS = ('.jpg', '.png', '.tiff')

FOLDERS = ["a_", "b_", "d_", "e_", "g_", "i_", "n_", "o_", "r_", "s_", "t_", "u_"]

# assert all(folder in os.listdir('.') for folder in FOLDERS)
# assert LEXICON in os.listdir('.')

characters = {}

for folder in FOLDERS:
    char = folder[0]
    characters[char] = []

    for file in os.listdir('../letters/' + folder):
        if file.endswith(EXTENSIONS):
            # print file
            # print '../letters/' + folder + '/' + file

            prototype = prototypes.Letter(char, '../letters/' + folder + '/' + file)
            characters[char].append(prototype)
            # print prototype.image.shape[0]
            # print prototype.image.shape[1]
            # cv2.imshow("", prototype.image)
            # cv2.waitKey(0)

            box_file_name = '../letters/' + folder + '/' + os.path.splitext(file)[0] + '.box'
            # print box_file_name

            with open(box_file_name, 'w') as box_file:
                box_file.write(char + ' ' + '0 0 {0} {1}'
                               .format(prototype.image.shape[1],
                                       prototype.image.shape[0]))