//
//  HqViewController.h
//  tzz
//
//  Created by zzy on 7/4/11.
//  Copyright 2011 RegalFinance. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CandleChart.h"
#import <QuartzCore/QuartzCore.h>

@interface CharteeViewController : UIViewController<UISearchBarDelegate> {
	CandleChart *kline;
    UIView *toolBar;
   	int chartMode;
	NSString *req_security_id;
}

@property (nonatomic,retain) CandleChart *kline;
@property (nonatomic,retain) UIView *toolBar;
@property (nonatomic) int chartMode;
@property (nonatomic,retain) NSString *req_security_id;

-(void)getData;
-(void)generateData:(NSMutableDictionary *)dic From:(NSArray *)data;
-(void)setData:(NSDictionary *)dic;
-(void)setCategory:(NSArray *)category;
-(void)setOptions:(NSDictionary *)options ForSerie:(NSMutableDictionary *)serie;

@end
