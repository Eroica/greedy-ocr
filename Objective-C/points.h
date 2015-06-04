#ifndef POINTS_H
#define POINTS_H

#import <Foundation/Foundation.h>


@interface Point2D : NSObject {

}

@property (nonatomic, assign) NSInteger x;
@property (nonatomic, assign) NSInteger y;
@property (nonatomic, assign) CGFloat SWT;

@end

@interface Point2DFloat : NSObject {

}

@property (nonatomic, assign) CGFloat x;
@property (nonatomic, assign) CGFloat y;

@end


@interface Point3DFloat : NSObject {

}

@property (nonatomic, assign) CGFloat x;
@property (nonatomic, assign) CGFloat y;
@property (nonatomic, assign) CGFloat z;

@end

#endif // POINTS_H