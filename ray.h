#import <Foundation/Foundation.h>
#import "points.h"

@interface Ray : NSObject {

}

@property (nonatomic, retain) Point2D *p;
@property (nonatomic, retain) Point2D *q;
@property (nonatomic, retain) NSMutableArray *points;

@end
