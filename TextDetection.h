#ifndef TEXTDETECTION_H
#define TEXTDETECTION_H

#include "opencv/cv.h"

// Point2d struct.
struct _Point2d {
    int x;
    int y;
    float SWT;
};
typedef struct _Point2d Point2d;

@interface NSValue (Point2d)
+ (id)valueWithPoint2d:(Point2d)point2d;
- (Point2d)point2dValue;
@end

@implementation NSValue (Point2d)
+ (id)valueWithPoint2d:(Point2d)point2d
{
    return [NSValue value:&point2d withObjCType:@encode(Point2d)];
}

- (Point2d)point2dValue
{
    Point2d point2d;
    [self getValue:&point2d];
    return point2d;
}
@end

// Point2dFloat struct.
struct _Point2dFloat {
    float x;
    float y;
};
typedef struct _Point2dFloat Point2dFloat;

@interface NSValue (Point2dFloat)
+ (id)valueWithPoint2dFloat:(Point2dFloat)point2dFloat;
- (Point2dFloat)point2dFloatValue;
@end

@implementation NSValue (Point2dFloat)
+ (id)valueWithPoint2dFloat:(Point2dFloat)point2dFloat
{
    return [NSValue value:&point2dFloat withObjCType:@encode(Point2dFloat)];
}

- (Point2dFloat)point2dFloatValue
{
    Point2dFloat point2dFloat;
    [self getValue:&point2dFloat];
    return point2dFloat;
}
@end

// Point3dFloat struct.
struct _Point3dFloat {
    float x;
    float y;
    float z;
};
typedef struct _Point3dFloat Point3dFloat;

@interface NSValue (Point3dFloat)
+ (id)valueWithPoint3dFloat:(Point3dFloat)point3dFloat;
- (Point3dFloat)point3dFloatValue;
@end

@implementation NSValue (Point3dFloat)
+ (id)valueWithPoint3dFloat:(Point3dFloat)point3dFloat
{
    return [NSValue value:&point3dFloat withObjCType:@encode(Point3dFloat)];
}

- (Point3dFloat)point3dFloatValue
{
    Point3dFloat point3dFloat;
    [self getValue:&point3dFloat];
    return point3dFloat;
}
@end

// Others.
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