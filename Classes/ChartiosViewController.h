//
//  Chartios
//  Mailto: zhengzhiyu@yeah.net
//  Created by zhengzhiyu on 7/9/11.
//  Copyright 2011  All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CandleChart.h"
#import <QuartzCore/QuartzCore.h>
#import "YAxis.h"

@interface ChartiosViewController : UIViewController {
    CandleChart *candle;
}

@property (nonatomic,retain) CandleChart *candle;

@end

