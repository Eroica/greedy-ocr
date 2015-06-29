import os
import numpy as np
import cv2
import components

IMG_FILE = '../share/ausschnitt.png'
LEXICON = '../share/lexikon.txt'
PROTOTYPE_FILES = ['../share/e.png', '../share/n.png']

WORDS_BB = [
    ((14, 2), (199, 64)),
    ((220, 5), (421, 51)),
    ((432, 5), (550, 55)),
    ((562, 2), (677, 56)),
    ((695, 5), (797, 49)),
    ((820, 5), (905, 53))
]


e = components.Prototype.from_image_file('e', '../share/e.png')
ch = components.Prototype.from_image_file('ch', '../share/ch.png')
img = cv2.imread('../share/ausschnitt.png', 0)
indessen = components.Word(img, ((14, 2), (199, 64)))
etliche = components.Word(img, ((432, 5), (550, 55)))

# def threshold_image(image):
#     """
#     """

#     (thresh, im_bw) = cv2.threshold(image, 128, 255, cv2.THRESH_BINARY)
#     return im_bw

# def compare_image_region(image, sub_image):
#     """
#     """

#     assert image.shape == sub_image.shape

#     nom = 0
#     denom = 0

#     image_bw = threshold_image(image)
#     sub_image_bw = threshold_image(sub_image)

#     for i in range(sub_image_bw.shape[0]):
#         for j in range(sub_image_bw.shape[1]):
#             nom += image_bw[i, j] and sub_image_bw[i, j]
#             denom += image_bw[i, j] or sub_image_bw[i, j]

#     ratio = nom/float(denom)

#     return ratio

# def overlay_images(image, sub_image):
#     """
#     """

#     assert image.shape >= sub_image.shape

#     if image.shape == sub_image.shape:
#         return compare_image_region(image, sub_image)

#     # ratios = [[] for _ in range(image.shape[0])]
#     ratio_shape = (image.shape[0] - sub_image.shape[0] + 1,
#                    image.shape[1] - sub_image.shape[1] + 1)
#     ratios = np.zeros(ratio_shape)

#     for i in range(image.shape[0] - sub_image.shape[0] + 1):
#         for j in range(image.shape[1] - sub_image.shape[1] + 1):
#             cropped_image = image[i:i + sub_image.shape[0], j:j + sub_image.shape[1]]
#             # ratios[i].append(compare_image_region(cropped_image, sub_image))
#             ratios[i, j] = compare_image_region(cropped_image, sub_image)

#     return ratios

#     # return max(max(ratios))


# img = cv2.imread(IMG_FILE, 0)
# e = cv2.imread(PROTOTYPE_FILES[0], 0)
# n = cv2.imread(PROTOTYPE_FILES[1], 0)
# c = cv2.imread('../share/c.png', 0)
# e_2 = cv2.imread('../share/e_2.png', 0)
# e_3 = cv2.imread('../share/e_3.png', 0)
# ch = cv2.imread('../share/ch.png', 0)
# etliche = cv2.imread('../share/etliche.png', 0)