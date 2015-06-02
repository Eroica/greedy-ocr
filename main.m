#import <Foundation/Foundation.h>

#include <assert.h>
#include "opencv/cv.h"
#include "opencv/highgui.h"
#include "opencv/cvwimage.h"
#include "TextDetection.h"

void
convertToFloatImage(IplImage *byteImage, IplImage *floatImage)
{
    cvConvertScale(byteImage, floatImage, 1/255., 0);
}


IplImage *
loadByteImage(const char *name)
{
    IplImage *image = cvLoadImage(name, CV_LOAD_IMAGE_COLOR);

    if(!image)
        return 0;

    cvCvtColor(image, image, CV_BGR2RGB);

    return image;
}

IplImage *
loadFloatImage(const char *name)
{
    IplImage *image = cvLoadImage(name, CV_LOAD_IMAGE_COLOR);

    if (!image)
        return 0;

    cvCvtColor(image, image, CV_BGR2RGB);

    IplImage *floatingImage = cvCreateImage(cvGetSize(image),
                                            IPL_DEPTH_32F,
                                            3);

    cvConvertScale(image, floatingImage, 1/255., 0);
    cvReleaseImage(&image);

    return floatingImage;
}

int
mainTextDetection(int argc, char **argv)
{
    IplImage *byteQueryImage = cvLoadImage(argv[1], CV_LOAD_IMAGE_COLOR);
    if(!byteQueryImage) {
        printf("couldn't load query image\n");
        return -1;
    }

    // Detect text in the image
    IplImage *output = textDetection(byteQueryImage, atoi(argv[3]));
    cvReleaseImage(&byteQueryImage);
    cvSaveImage(argv[2], output, 0);
    cvReleaseImage(&output);

    return 0;
}

int main(int argc, char **argv)
{
    if(argc != 4)
    {
        printf("usage: %s imagefile resultImage darkText\n", argv[0]);
        return -1;
    }

    return mainTextDetection(argc, argv);
}
