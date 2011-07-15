//
//  CharteeAppDelegate.h
//  Chartee
//
//  Created by zzy on 7/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CharteeViewController;

@interface CharteeAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    CharteeViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet CharteeViewController *viewController;

@end

