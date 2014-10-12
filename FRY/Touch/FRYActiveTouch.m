//
//  TouchInteraction.m
//  FRY
//
//  Created by Brian King on 10/3/14.
//  Copyright (c) 2014 Raizlabs. All rights reserved.
//

#import "FRYActiveTouch.h"
#import "FRYPointInTime.h"
#import "FRYSimulatedTouch.h"
#import "UITouch+FRY.h"

static CGFloat FRYDistanceBetweenPoints(CGPoint p1, CGPoint p2) {
    CGFloat xDist = (p2.x - p1.x);
    CGFloat yDist = (p2.y - p1.y);
    CGFloat distance = sqrt((xDist * xDist) + (yDist * yDist));
    return distance;
}
static NSUInteger const kFRYTouchPhaseUndefined = -1;

@interface FRYActiveTouch()

@property (strong, nonatomic) FRYSimulatedTouch *touchDefinition;
@property (strong, nonatomic) UIView *view;
@property (assign, nonatomic) NSTimeInterval startTime;

@property (assign, nonatomic) CGPoint lastPointInWindow;
@property (strong, nonatomic) UITouch *currentTouch;

@end

@implementation FRYActiveTouch

- (id)initWithSimulatedTouch:(FRYSimulatedTouch *)touch inView:(UIView *)view startTime:(NSTimeInterval)startTime;
{
    self = [super init];
    if ( self ) {
        _touchDefinition = touch;
        _view = view;
        _startTime = startTime;
    }
    return self;
}

- (UITouchPhase)currentTouchPhase
{
    return self.currentTouch ? self.currentTouch.phase : kFRYTouchPhaseUndefined;
}


- (UITouch *)touchAtTime:(NSTimeInterval)currentTime
{
    if ( currentTime - self.startTime < self.touchDefinition.startingOffset ) {
        return nil;
    }
    NSTimeInterval relativeTime = currentTime - self.startTime;
    CGPoint windowPoint = [self.touchDefinition pointAtRelativeTime:relativeTime];

    if ( self.currentTouch == nil ) {
        self.currentTouch = [[UITouch alloc] initAtPoint:windowPoint inWindow:self.view.window];
    }
    else {
        [self.currentTouch setLocationInWindow:windowPoint];
        if ( relativeTime < [self.touchDefinition duration] ) {
            if ( FRYDistanceBetweenPoints(windowPoint, self.lastPointInWindow) > 1.0f ) {
                if ( CGRectContainsPoint(self.view.window.frame, windowPoint) ) {
                    [self.currentTouch setPhaseAndUpdateTimestamp:UITouchPhaseMoved];
                }
                else {
                    [self.currentTouch setPhaseAndUpdateTimestamp:UITouchPhaseCancelled];
                }
            }
            else {
                [self.currentTouch setPhaseAndUpdateTimestamp:UITouchPhaseStationary];
            }
        }
        else {
            [self.currentTouch setPhaseAndUpdateTimestamp:UITouchPhaseEnded];
        }
    }

    self.lastPointInWindow = windowPoint;
    return self.currentTouch;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@:%p touchDefinition=%@, startTime=%f view=%@ currentTouch=%@", self.class, self, self.touchDefinition, self.startTime, self.view, self.currentTouch];
}

@end
