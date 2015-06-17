import cv2
import numpy as np

MINMAX = min
ALIGN_LETTERS_HEIGHT = False

def catImage(img_left, img_right):
    """
    """

    width = img_left.shape[1] + img_right.shape[1]
    height = max(img_left.shape[0], img_right.shape[0])

    cat_img = np.zeros((height, width, 3), np.uint8)

    if ALIGN_LETTERS_HEIGHT:
        if img_left.shape[0] > img_right.shape[0]:
            y_offset = (img_left.shape[0] - img_right.shape[0])/2
            smaller_height = y_offset + img_right.shape[0]

            cat_img[0:img_left.shape[0], 0:img_left.shape[1]] = img_left[:]
            cat_img[y_offset:smaller_height, img_left.shape[1]:] = img_right[:]
        else:
            y_offset = (img_right.shape[0] - img_left.shape[0])/2
            smaller_height = y_offset + img_left.shape[0]

            cat_img[y_offset:smaller_height, 0:img_left.shape[1]] = img_left[:]
            cat_img[0:img_right.shape[0], img_left.shape[1]:] = img_right[:]

    else:
        cat_img[0:img_left.shape[0], 0:img_left.shape[1]] = img_left[:]
        cat_img[0:img_right.shape[0], img_left.shape[1]:] = img_right[:]

    return cat_img


class Word(str):
    _default_image = None

    def __init__(self, string, image=_default_image):
        self.image = image

    def __new__(cls, string, image=_default_image):
        return super(Word, cls).__new__(cls, str(string))

    def __add__(self, letter_right):
        width = self.image.shape[1] + letter_right.image.shape[1]
        height = max(self.image.shape[0], letter_right.image.shape[0])

        word_img = np.zeros((height, width, 3), np.uint8)

        if ALIGN_LETTERS_HEIGHT:
            if self.image.shape[0] > letter_right.image.shape[0]:
                y_offset = (self.image.shape[0] - letter_right.image.shape[0])/2
                smaller_height = y_offset + letter_right.image.shape[0]

                word_img[0:self.image.shape[0], 0:self.image.shape[1]] = self.image[:]
                word_img[y_offset:smaller_height, self.image.shape[1]:] = letter_right.image[:]
            else:
                y_offset = (letter_right.image.shape[0] - self.image.shape[0])/2
                smaller_height = y_offset + self.image.shape[0]

                word_img[y_offset:smaller_height, 0:self.image.shape[1]] = self.image[:]
                word_img[0:letter_right.image.shape[0], self.image.shape[1]:] = letter_right.image[:]

        else:
            word_img[0:self.image.shape[0], 0:self.image.shape[1]] = self.image[:]
            word_img[0:letter_right.image.shape[0], self.image.shape[1]:] = letter_right.image[:]

        return Word(str(self) + str(letter_right), word_img)



class Letter(str):
    _default_image = None

    def __init__(self, letter, image=_default_image):
        self.image = cv2.imread(image)

    def __new__(cls, letter, image=_default_image):
        return super(Letter, cls).__new__(cls, str(letter)[0])

    def __add__(self, letter_right):
        width = self.image.shape[1] + letter_right.image.shape[1]
        height = max(self.image.shape[0], letter_right.image.shape[0])

        word_img = np.zeros((height, width, 3), np.uint8)

        if ALIGN_LETTERS_HEIGHT:
            if self.image.shape[0] > letter_right.image.shape[0]:
                y_offset = (self.image.shape[0] - letter_right.image.shape[0])/2
                smaller_height = y_offset + letter_right.image.shape[0]

                word_img[0:self.image.shape[0], 0:self.image.shape[1]] = self.image[:]
                word_img[y_offset:smaller_height, self.image.shape[1]:] = letter_right.image[:]
            else:
                y_offset = (letter_right.image.shape[0] - self.image.shape[0])/2
                smaller_height = y_offset + self.image.shape[0]

                word_img[y_offset:smaller_height, 0:self.image.shape[1]] = self.image[:]
                word_img[0:letter_right.image.shape[0], self.image.shape[1]:] = letter_right.image[:]

        else:
            word_img[0:self.image.shape[0], 0:self.image.shape[1]] = self.image[:]
            word_img[0:letter_right.image.shape[0], self.image.shape[1]:] = letter_right.image[:]

        return Word(str(self) + str(letter_right), word_img)


a = Letter("aaaa", "../share/a.png")
b = Letter("bbb", "../share/b.png")
c = Letter("ccc", "../share/c.png")