//
//  Chartios
//  Mailto: zhengzhiyu@yeah.net
//  Created by zhengzhiyu on 7/9/11.
//  Copyright 2011  All rights reserved.
//

#import <UIKit/UIKit.h>

@class ChartiosViewController;

@interface ChartiosAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    ChartiosViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet ChartiosViewController *viewController;

@end

