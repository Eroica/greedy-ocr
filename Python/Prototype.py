import cv2

class Prototype(str):
    """

    """

    _default_image = None

    def __new__(cls, characters, image=_default_image):
        """
        """

        return super(Prototype, cls).__new__(cls, str(characters))

    def __init__(self, characters, image=_default_image):
        """
        """

        self._image = image

    @classmethod
    def from_image_file(cls, characters, image_file):
        """
        """

        assert isinstance(image_file, str)
        image = cv2.imread(image_file, 0)

        return cls(characters, image)

    def height(self):
        return self._image.shape[0]

    def width(self):
        return self._image.shape[1]

    def copy_and_resize(self, width, height):
        """
        """

        return cv2.resize(self.image, (width, height))

