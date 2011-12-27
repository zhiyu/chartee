//
//  CharteeViewController.h
//  https://github.com/zhiyu/chartee/
//
//  Created by zhiyu on 7/11/11.
//  Copyright 2011 zhiyu. All rights reserved.
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
