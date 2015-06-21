import cv2
import numpy as np
from collections import OrderedDict, Sequence
from random import randint, choice

MINMAX = min
DEBUG = True
BASELINE_HEIGHT = 10

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


class Prototype(str):
    """

    """

    ALIGN_COMPONENTS_HEIGHTS = True
    _default_image = None
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
    def _from_components(cls, *components):
        """
        """

        assert len(components) > 0

        composition = ''.join(letter for letter in components)
        images = [x.image for x in components]

        width = reduce(lambda x, y: x + y, (x.shape[1] for x in images))
        height = reduce(max, (x.shape[0] for x in images))

        composition_img = np.zeros((height, width, 3), np.uint8)
        expanded_width = 0

        if Prototype.ALIGN_COMPONENTS_HEIGHTS:
            for i, component in enumerate(components):
                y_offset = (height - component.image.shape[0])/2

                composition_img[
                    y_offset:component.image.shape[0] + y_offset,
                    expanded_width:component.image.shape[1] + expanded_width] \
                = component.image[:]

                expanded_width += component.image.shape[1]

        comp_prototype = cls(composition, composition_img)

        for comp in components:
            comp_prototype.components.append(comp)

        return comp_prototype

    @classmethod
    def from_image_file(cls, letter, image_file):
        """
        """

        assert isinstance(image_file, str)
        image = cv2.imread(image_file)

        return cls(letter, image)

    def __new__(cls, letter, image=_default_image):
        """
        """

        return super(Prototype, cls).__new__(cls, str(letter))

    def __init__(self, letter, image=_default_image):
        """
        """

        self.image = image
        self.components = []

    def __add__(self, right_component):
        """
        """

        return Prototype._from_components(self, right_component)


    def write_box_file(self, path=None):
        """
        """

        def expand_components(prot):
            """
            """

            if len(prot.components) == 0:
                return [prot]
            else:
                l = []
                for comp in prot.components:
                    # l.extend(expand_components(comp))
                    l += expand_components(comp)
                return l

        box_file_path = path or (str(self) + '.box')
        components = expand_components(self)
        x_offset = 0

        if DEBUG:
            for prototype in components:
                y_offset = (self.image.shape[0] - prototype.image.shape[0])/2

                print '{0} {1} {2} {3} {4}'.format(prototype,
                                                   x_offset,
                                                   y_offset,
                                                   x_offset + prototype.image.shape[1],
                                                   y_offset + prototype.image.shape[0])
                x_offset += prototype.image.shape[1]
            return

        with open(box_file_path, 'w') as box_file:
            for prototype in components:
                y_offset = (self.image.shape[0] - prototype.image.shape[0])/2

                box_file.write('{0} {1} {2} {3} {4}'
                               .format(prototype,
                                       x_offset,
                                       y_offset,
                                       x_offset + prototype.image.shape[1],
                                       y_offset + prototype.image.shape[0]))
                x_offset += prototype.image.shape[1]


class PrototypeFactory(OrderedDict):
    """

    """

    def __init__(self, alphabet):
        """
        """

        super(PrototypeFactory, self).__init__()

        for letter in alphabet:
            self[letter] = Prototype(letter, alphabet[letter])

        # DEBUG

        # Create a blank space character.
        width = reduce(lambda x, y: x + y, (x.image.shape[1] for x in self.values()))
        width /= len(self.values())
        height = reduce(lambda x, y: x + y, (x.image.shape[0] for x in self.values()))
        height /= len(self.values())
        max_height = reduce(max, (x.image.shape[0] for x in self.values()))

        self[' '] = Prototype(' ', np.zeros((width, height, 3), np.uint8))
        self['\n'] = Prototype('\n', np.zeros((max_height + BASELINE_HEIGHT, 0, 3), np.uint8))

    def create_word(self, word):
        """
        """

        if not all(l in self for l in word):
            print "Some letters not found!"
            return

        components = [self[letter] for letter in word]

        return Prototype._from_components(*components)



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


a = Prototype.from_image_file("a", "../share/a.png")
b = Prototype.from_image_file("b", "../share/b.png")
c = Prototype.from_image_file("c", "../share/c.png")
ab = a + b
aba = a + b + a