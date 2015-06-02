#ifndef TEXTDETECTION_H
#define TEXTDETECTION_H

#include "opencv/cv.h"


typedef struct {
    int x;
    int y;
    float SWT;
} Point2d;

typedef struct {
    float x;
    float y;
} Point2dFloat;

typedef struct {
    float x;
    float y;
    float z;
} Point3dFloat;


@interface Ray : NSObject {

}

@property (nonatomic, assign) Point2d p;
@property (nonatomic, assign) Point2d q;
@property (nonatomic, assign) NSMutableArray *points;

@end

@interface Chain : NSObject {

}

@property (nonatomic, assign) int p;
@property (nonatomic, assign) int q;
@property (nonatomic, assign) float dist;
@property (nonatomic, assign) bool merged;
@property (nonatomic, assign) Point2dFloat direction;
@property (nonatomic, assign) NSMutableArray *components;

@end

bool
Point2dSort(const Point2d *lhs,
            const Point2d *rhs);

IplImage *
textDetection(IplImage *float_input,
              bool dark_on_light);

void
strokeWidthTransform(IplImage *edgeImage,
                     IplImage *gradientX,
                     IplImage *gradientY,
                     bool dark_on_light,
                     IplImage *SWTImage,
                     NSMutableArray *rays);

void
SWTMedianFilter(IplImage *SWTImage,
                NSMutableArray *rays);

NSMutableArray *
findLegallyConnectedComponents(IplImage *SWTImage,
                               NSMutableArray *rays);

NSMutableArray *
findLegallyConnectedComponentsRAY(IplImage *SWTImage,
                                  NSMutableArray *rays);

void
componentStats(IplImage *SWTImage,
               const NSMutableArray *component,
               float *mean, float *variance, float *median,
               int *minx, int *miny, int *maxx, int *maxy);

void
filterComponents(IplImage *SWTImage,
                 NSMutableArray *components,
                 NSMutableArray *validComponents,
                 NSMutableArray *compCenters,
                 NSMutableArray *compMedians,
                 NSMutableArray *compDimensions,
                 NSMutableArray *compBB );

NSMutableArray *
makeChains(IplImage *colorImage,
           NSMutableArray *components,
           NSMutableArray *compCenters,
           NSMutableArray *compMedians,
           NSMutableArray *compDimensions,
           NSMutableArray *compBB);


#endif // TEXTDETECTION_H