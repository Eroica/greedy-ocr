#ifndef POINTS_H
#define POINTS_H

#import <Foundation/Foundation.h>

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

+ (id)valueWithPoint2d:(Point2d)point2d {
    return [NSValue value:&point2d withObjCType:@encode(Point2d)];
}

- (Point2d)point2dValue {
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

- (Point2dFloat)point2dFloatValue {
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

+ (id)valueWithPoint3dFloat:(Point3dFloat)point3dFloat {
    return [NSValue value:&point3dFloat withObjCType:@encode(Point3dFloat)];
}

- (Point3dFloat)point3dFloatValue {
    Point3dFloat point3dFloat;
    [self getValue:&point3dFloat];
    return point3dFloat;
}
@end




struct _ray {
    Point2d p;
    Point2d q;
    NSMutableArray *points;
};
typedef struct _ray Ray;

@interface NSValue (Ray)

+ (id)valueWithRay:(Ray)ray;
- (Ray)rayValue;

@end

@implementation NSValue (Ray)

+ (id)valueWithRay:(Ray)ray {
    return [NSValue value:&ray withObjCType:@encode(Ray)];
}

- (Ray)rayValue {
    Ray ray;
    [self getValue:&ray];
    return ray;
}

@end


#endif // POINTS_H