#ifndef EXTRACT_LETTERS_H
#define EXTRACT_LETTERS_H

#include <stdbool.h>
#include <opencv/cv.h>

#ifdef __cplusplus
extern "C" {
#endif

void
extract_letters(IplImage *input_image,
                bool dark_on_light);

#ifdef __cplusplus
}
#endif

#endif // EXTRACT_LETTERS_H