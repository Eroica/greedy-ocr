#ifndef TEXTDETECTION_HPP
#define TEXTDETECTION_HPP

#include <opencv/cv.h>

struct Point2d {
    int x;
    int y;
    float SWT;
};

struct Point2dFloat {
    float x;
    float y;
};

struct Ray {
        Point2d p;
        Point2d q;
        std::vector<Point2d> points;
};

struct Point3dFloat {
    float x;
    float y;
    float z;
};

struct Chain {
    int p;
    int q;
    float dist;
    bool merged;
    Point2dFloat direction;
    std::vector<int> components;
};


bool
Point2dSort(Point2d const &lhs,
            Point2d const &rhs);

IplImage *
textDetection(IplImage *float_input,
              bool dark_on_light);

void
strokeWidthTransform(IplImage *edgeImage,
                     IplImage *gradientX,
                     IplImage *gradientY,
                     bool dark_on_light,
                     IplImage *SWTImage,
                     std::vector<Ray> &rays);

void
SWTMedianFilter(IplImage *SWTImage,
                std::vector<Ray> &rays);

std::vector<std::vector<Point2d>>
findLegallyConnectedComponents(IplImage *SWTImage,
                              std::vector<Ray> &rays);

std::vector< std::vector<Point2d>>
findLegallyConnectedComponentsRAY(IplImage *SWTImage,
                                  std::vector<Ray> &rays);

void
componentStats(IplImage *SWTImage,
               const std::vector<Point2d> &component,
               float &mean, float &variance, float &median,
               int &minx, int &miny, int &maxx, int &maxy);

void
filterComponents(IplImage *SWTImage,
                 std::vector<std::vector<Point2d>> &components,
                 std::vector<std::vector<Point2d>> &validComponents,
                 std::vector<Point2dFloat> &compCenters,
                 std::vector<float> &compMedians,
                 std::vector<Point2d> &compDimensions,
                 std::vector<std::pair<Point2d, Point2d>> &compBB);

void
extractComponents(IplImage *input,
                  std::vector<std::pair<Point2d, Point2d>> &compBB);

std::vector<Chain>
makeChains(IplImage *colorImage,
           std::vector<std::vector<Point2d>> &components,
           std::vector<Point2dFloat> &compCenters,
           std::vector<float> &compMedians,
           std::vector<Point2d> &compDimensions,
           std::vector<std::pair<Point2d, Point2d>> &compBB);

#endif // TEXTDETECTION_HPP