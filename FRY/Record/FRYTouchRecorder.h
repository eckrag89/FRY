//
//  FRYEventMonitor.h
//  FRY
//
//  Created by Brian King on 10/7/14.
//  Copyright (c) 2014 Raizlabs. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 * This will support touch recording and some newer, cooler features.
 */
@interface FRYTouchRecorder : NSObject

+ (FRYTouchRecorder *)shared;

- (void)enable;
- (void)disable;

@end
