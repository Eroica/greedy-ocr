#include <stdlib.h>
#include <stdio.h>
#include "opencv/cv.h"
#include "opencv/highgui.h"
#include "opencv/cvwimage.h"

/// Global variables.
int edgeThresh = 1;
int lowThreshold;
int const max_lowThreshold = 100;
int ratio = 3;
int kernel_size = 3;
char* window_name = "Edge Map";

CvMat *src, *src_gray = NULL;
CvMat *dst, *detected_edges = NULL;

void
CannyThreshold(int position) {
    detected_edges = cvCreateMat(src->rows, src->cols, CV_8U);

    cvSmooth(src_gray, detected_edges, CV_GAUSSIAN, 3, 0, 0, 0);

    cvCanny(detected_edges, detected_edges, lowThreshold, lowThreshold*ratio, kernel_size);

    // cvCopy(src, dst, detected_edges);

    cvShowImage(window_name, detected_edges);
}

/** @function main */
int
main(int argc, char *argv[]) {
	if(argv[1] == NULL)
		return -1;

	printf("Loading %s\n", argv[1]);

    if((src = cvLoadImageM(argv[1], 1)) == 0)
        return -1;

	printf("%i\n", src->rows);

	dst = cvCreateMat(src->rows, src->cols, CV_8U);
    src_gray = cvCreateMat(src->rows, src->cols, CV_8U);
	cvCvtColor(src, src_gray, CV_RGB2GRAY);

	cvNamedWindow(window_name, CV_WINDOW_AUTOSIZE);

    void (*callbackFunction) (int position);
    callbackFunction = CannyThreshold;

    cvCreateTrackbar("Min Threshold:", window_name, &lowThreshold, max_lowThreshold, callbackFunction);

    CannyThreshold(0);

	cvWaitKey(0);

    cvReleaseMat(&src);
    cvReleaseMat(&dst);
    cvReleaseMat(&src_gray);
    cvReleaseMat(&detected_edges);

	return 0;
}
