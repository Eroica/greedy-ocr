#import <Foundation/Foundation.h>
#include "points.h"

@interface Chain : NSObject {

}

@property (nonatomic, assign) int p;
@property (nonatomic, assign) int q;
@property (nonatomic, assign) float dist;
@property (nonatomic, assign) bool merged;
@property (nonatomic, assign) Point2dFloat direction;
@property (nonatomic, assign) NSMutableArray *components;

@end