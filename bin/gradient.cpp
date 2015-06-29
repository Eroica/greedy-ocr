#include <iostream>
#include <opencv2/core/core.hpp>
#include <opencv2/highgui/highgui.hpp>
#include <opencv2/imgproc/imgproc.hpp>

#define OUTPUT_FOLDER_PATH      string("")

using namespace cv;

void
extract_components(Mat &image, Rect &rect)
{
    static unsigned int count = 0;

    Mat img2 = image(rect);
    imwrite(OUTPUT_FOLDER_PATH + string("comp") + std::to_string(count) + string(".jpg"), img2);

    count++;
}

int
main(int argc, char* argv[])
{
    if(argc != 2) {
        std::cout << "Usage: " << argv[0] << " imagefile" << std::endl;
        return -1;
    }

    Mat large = imread(argv[1]);
    Mat rgb;

    pyrDown(large, rgb);

    Mat small;
    cvtColor(rgb, small, CV_BGR2GRAY);

    // morphological gradient
    Mat grad;
    Mat morphKernel = getStructuringElement(MORPH_ELLIPSE, Size(3, 3));
    morphologyEx(small, grad, MORPH_GRADIENT, morphKernel);

    // binarize
    Mat bw;
    threshold(grad, bw, 0.0, 255.0, THRESH_BINARY | THRESH_OTSU);

    // connect horizontally oriented regions
    Mat connected;
    morphKernel = getStructuringElement(MORPH_RECT, Size(9, 1));
    morphologyEx(bw, connected, MORPH_CLOSE, morphKernel);

    // find contours
    Mat mask = Mat::zeros(bw.size(), CV_8UC1);
    vector<vector<Point>> contours;
    vector<Vec4i> hierarchy;
    findContours(connected, contours, hierarchy, CV_RETR_CCOMP, CV_CHAIN_APPROX_SIMPLE, Point(0, 0));

    // filter contours
    int count = 0;
    for(int idx = 0; idx >= 0; idx = hierarchy[idx][0])
    {
        Rect rect = boundingRect(contours[idx]);
        Mat maskROI(mask, rect);
        maskROI = Scalar(0, 0, 0);
        // fill the contour
        drawContours(mask, contours, idx, Scalar(255, 255, 255), CV_FILLED);
        // ratio of non-zero pixels in the filled region
        double r = (double)countNonZero(maskROI)/(rect.width*rect.height);

        if (r > .45 && (rect.height > 8 && rect.width > 8)) {
            // assume at least 45% of the area is filled if it contains text
            // constraints on region size
            // these two conditions alone are not very robust. better to use something
            // like the number of significant peaks in a horizontal projection as a third condition
            rectangle(rgb, rect, Scalar(0, 255, 0), 2);

            extract_components(small, rect);
        }
    }
    imwrite(OUTPUT_FOLDER_PATH + string("components.jpg"), rgb);

    return 0;
}