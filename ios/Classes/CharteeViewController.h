//
//  CharteeViewController.h
//  Chartee
//
//  Created by zzy on 7/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CandleChart.h"
@interface CharteeViewController : UIViewController {
    CandleChart *candle;
}

@property (nonatomic,retain) CandleChart *candle;

@end

