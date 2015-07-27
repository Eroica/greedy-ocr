import numpy as np
import gr_config as CONFIG



# function compare_image_region(image, sub_image)
#     assert(image:size()[2] == sub_image:size(2))
#     assert(image:size()[3] == sub_image:size(3))

#     local nom = 0
#     local denom = 0

#     for i=1, sub_image:size()[2] do
#         for j=1, sub_image:size()[3] do
#             nom = nom + bit.band(image[{1, i, j}], sub_image[{1, i, j}])
#             denom = denom + bit.bor(image[{1, i, j}], sub_image[{1, i, j}])
#         end
#     end

#     local ratio = nom/denom

#     return ratio
# end

def compare_image_region(image, sub_image):
    """
    """

    nom = 0
    denom = 0

    image_bw = threshold_image(image)
    sub_image_bw = threshold_image(sub_image)

    for i in range(sub_image_bw.shape[0]):
        for j in range(sub_image_bw.shape[1]):
            nom += image_bw[i, j] and sub_image_bw[i, j]
            denom += image_bw[i, j] or sub_image_bw[i, j]

    ratio = nom/float(denom)

    return ratio


class Component(object):
    """

    """

    def __init__(self, word, min_x, max_x):
        """
        """

        self.begin = min_x
        self.end = max_x
        self._image = word.crop_image(min_x, max_x)
        self._prototypes = []

    def height(self):
        return self._image.shape[0]

    def width(self):
        return self._image.shape[1]

    def find_prototype_region(self, prototype):
        """
        """

        if self.height() < prototype.height() or self.width() < prototype.width():
            prototype_image = threshold(prototype.copy_and_resize(self.width(), self.height()))
        else:
            prototype_image = threshold(prototype._image)

        ratios = np.zeros((self.height() - prototype_image.shape[0] + 1,
                          self.width() - prototype_image.shape[1] + 1))

        component_image = threshold(self._image)



        for i in range(ratios.shape[0]):
            for j in range(ratios.shape[1]):
                cropped_image = component_image[i:prototype_image.shape[0],
                                                j:prototype_image.shape[1]]

                ratios[i, j] = compare_image_region(cropped_image, prototype_image)


        return ratios

    def __repr__(self):
        return self.__str__()

    def __str__(self):
        """
        """

        if self._prototypes:
            return str(self._prototypes)
        else:
            return CONFIG.UNKNOWN_COMPONENT
