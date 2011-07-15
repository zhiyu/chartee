//
//  CharteeViewController.h
//  https://github.com/zhiyu/chartee/
//
//  Created by zhiyu on 7/11/11.
//  Copyright 2011 zhiyu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CandleChart.h"
@interface CharteeViewController : UIViewController {
    CandleChart *candle;
}

@property (nonatomic,retain) CandleChart *candle;

@end

