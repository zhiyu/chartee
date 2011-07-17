//
//  Chart.h
//  https://github.com/zhiyu/chartee/
//
//  Created by zhiyu on 7/11/11.
//  Copyright 2011 zhiyu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YAxis.h"
#import "Section.h"

@interface Chart : UIView {
	bool  enableSelection;
	bool  isInitialized;
	bool  isSectionInitialized;
	float borderWidth;
	float plotWidth;
	float plotPadding;
	float plotCount;
	float paddingLeft;
	float paddingRight;
	float paddingTop;
	float paddingBottom;
	int   rangeFrom;
	int   rangeTo;
	int   range;
	int   selectedIndex;
	float touchFlag;
	NSMutableArray *padding;
	NSMutableArray *series;
	NSMutableArray *yAxises;
	NSMutableArray *xAxises;
	NSMutableArray *sections;
	NSMutableArray *ratios;
	UIColor        *borderColor;
	NSString       *title;
}

@property (nonatomic)        bool  enableSelection;
@property (nonatomic)        bool  isInitialized;
@property (nonatomic)        bool  isSectionInitialized;
@property (nonatomic)        float borderWidth;
@property (nonatomic)        float plotWidth;
@property (nonatomic)        float plotPadding;
@property (nonatomic)        float plotCount;
@property (nonatomic)        float paddingLeft;
@property (nonatomic)        float paddingRight;
@property (nonatomic)        float paddingTop;
@property (nonatomic)        float paddingBottom;
@property (nonatomic)        int   rangeFrom;
@property (nonatomic)        int   rangeTo;
@property (nonatomic)        int   range;
@property (nonatomic)        int   selectedIndex;
@property (nonatomic)        float touchFlag;
@property (nonatomic,retain) NSMutableArray *padding;
@property (nonatomic,retain) NSMutableArray *series;
@property (nonatomic,retain) NSMutableArray *sections;
@property (nonatomic,retain) NSMutableArray  *ratios;
@property (nonatomic,retain) UIColor  *borderColor;
@property (nonatomic,retain) NSString *title;

-(float)getLocalY:(float)val withSection:(int)sectionIndex withAxis:(int)yAxisIndex;

-(void)initChart;
-(void)initXAxis;
-(void)initYAxis;
-(void)initYAxisWithSerie:(NSDictionary *)serie;
-(void)drawChart;
-(void)drawXAxis;
-(void)drawYAxis;
-(void)drawSerie:(NSMutableDictionary *)serie withLabels:(NSMutableArray *)labels;
-(void)setSelectedIndexByPoint:(CGPoint) point;
-(int)getSectionIndexByPoint:(CGPoint) point;
-(void)addSection:(NSString *)ratio;
-(void)removeSection:(int)index;
-(void)addSections:(int)num withRatios:(NSArray *)rats;
-(void)removeSections;
-(void)initSections;

@end
