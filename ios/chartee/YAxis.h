//
//  YAxis.h
//  https://github.com/zhiyu/chartee/
//
//  Created by zhiyu on 7/11/11.
//  Copyright 2011 zhiyu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface YAxis : NSObject {
	bool isUsed;
	CGRect frame;
	float max;
	float min;
	float ext;
	float baseValue;
	bool  baseValueSticky;
	bool  symmetrical;
	float paddingTop;
	int tickInterval;
	int pos;
	int decimal;
}

@property(nonatomic) bool isUsed;

@property(nonatomic) CGRect frame;
@property(nonatomic) float max;
@property(nonatomic) float min;
@property(nonatomic) float ext;
@property(nonatomic) float baseValue;
@property(nonatomic) bool  symmetrical;
@property(nonatomic) bool  baseValueSticky;
@property(nonatomic) float paddingTop;
@property(nonatomic) int tickInterval;
@property(nonatomic) int pos;
@property(nonatomic) int decimal;

-(void)reset;

@end
