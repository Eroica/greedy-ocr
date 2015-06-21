import cv2
import numpy as np
from collections import OrderedDict
from random import randint, choice

MINMAX = min
# ALIGN_COMPONENTS_HEIGHT = False
# RANDOM = True

def hash(img):
    """Algorithm description: http://www.hackerfactor.com/blog/index.php?/archives/432-Looks-Like-It.html
    """

    img_gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
    img_8x8 = cv2.resize(img_gray, (8, 8))

    sum_pixel = reduce(lambda x, y: x+y,
                       (img_8x8.item(p) for p in range(0, 64)))
    average = sum_pixel/64

    bits = [1 if img_8x8.item(x) > average else 0 for x in range(0, 64)]

    return hex(int(''.join(str(b) for b in bits), 2))

def catImage(img_left, img_right):
    """
    """

    width = img_left.shape[1] + img_right.shape[1]
    height = max(img_left.shape[0], img_right.shape[0])

    cat_img = np.zeros((height, width, 3), np.uint8)

    if ALIGN_COMPONENTS_HEIGHT:
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


class Prototype(str):
    """

    """

    ALIGN_COMPONENTS_HEIGHTS = False

    # @property
    # def image(self):
    #     return choice(self._image)
    # @image.setter
    # def image(self, img):
    #     # self._image.append(img)
    #     pass

    # @property
    # def components(self):
    #     return self._components
    # @components.setter
    # def components(self, component):
    #     self._components.append(component)

    @classmethod
    def _from_components(cls, composition, *components):
        """
        """

        left_image = components[0].random_image()
        right_image = components[1].random_image()

        width = left_image.shape[1] + right_image.shape[1]
        height = max(left_image.shape[0], right_image.shape[0])

        composition_img = np.zeros((height, width, 3), np.uint8)

        if Prototype.ALIGN_COMPONENTS_HEIGHTS:
            if left_image.shape[0] > right_image.shape[0]:
                y_offset = (left_image.shape[0] - right_image.shape[0])/2
                smaller_height = y_offset + right_image.shape[0]

                composition_img[0:left_image.shape[0], 0:left_image.shape[1]] = left_image[:]
                composition_img[y_offset:smaller_height, left_image.shape[1]:] = right_image[:]
            else:
                y_offset = (right_image.shape[0] - left_image.shape[0])/2
                smaller_height = y_offset + left_image.shape[0]

                composition_img[y_offset:smaller_height, 0:left_image.shape[1]] = left_image[:]
                composition_img[0:right_image.shape[0], left_image.shape[1]:] = right_image[:]
        else:
            composition_img[0:left_image.shape[0], 0:left_image.shape[1]] = left_image[:]
            composition_img[0:right_image.shape[0], left_image.shape[1]:] = right_image[:]

        comp_prototype = cls(composition, composition_img)

        comp_prototype.components.append(left_image.shape[:2])
        comp_prototype.components.append(right_image.shape[:2])

        return comp_prototype

    def __new__(cls, letter, *letter_images):
        """
        """

        # assert len(letter) == len(letter_images)

        return super(Prototype, cls).__new__(cls, str(letter))

    def __init__(self, letter, *letter_images):
        """
        """

        self.image = []
        self.components = []

        # if len(letter) == 1:
        #     self.components.append(self)
        # self.components = [self]

        for img in letter_images:
            if isinstance(img, str):
                self.image.append(cv2.imread(img))

            if isinstance(img, np.ndarray):
                self.image.append(img)

    def __add__(self, right_component):
        """
        """

        return Prototype._from_components(str(self) + str(right_component), self, right_component)

    def random_image(self):
        """
        """

        return choice(self.image)

    # # def __getitem__(self, index):
    # #     if RANDOM:
    # #         return self.image[randint(0, len(self.image))]
    # #     else:
    # #         return self.image[index]

    # #     if isinstance( index, slice ) :

    def write_box_file(self, path=None):
        """
        """

        box_file_path = path or (self + '.box')
        return box_file_path

        # with open(box_file_path, 'w') as box_file:
        #     for char in self:
        #         box_file.write(char + ' ' + '0 0 {0} {1}'
        #                        .format(prototype.image.shape[1],
        #                                prototype.image.shape[0]))


a = Prototype("aaaa", "../share/a.png")
b = Prototype("bbb", "../share/b.png")
c = Prototype("ccc", "../share/c.png")
ab = a + b