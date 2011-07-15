//
//  CharteeAppDelegate.h
//  https://github.com/zhiyu/chartee/
//
//  Created by zhiyu on 7/11/11.
//  Copyright 2011 zhiyu. All rights reserved.
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

