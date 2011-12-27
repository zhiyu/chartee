//
//  YAxis.m
//  https://github.com/zhiyu/chartee/
//
//  Created by zhiyu on 7/11/11.
//  Copyright 2011 zhiyu. All rights reserved.
//

#import "YAxis.h"

@implementation YAxis

@synthesize isUsed;
@synthesize frame;
@synthesize max;
@synthesize min;
@synthesize ext;
@synthesize baseValue;
@synthesize baseValueSticky;
@synthesize symmetrical;
@synthesize paddingTop;
@synthesize tickInterval;
@synthesize pos;
@synthesize decimal;

- (id)init{
	self = [super init];
    if (self) {
		[self reset];
    }
	return self;
}

-(void)reset{
	self.isUsed = NO;
	self.min = MAXFLOAT;
	self.max = MAXFLOAT;
	self.ext = 0;
	self.baseValue = 0;
	self.symmetrical = NO;
	self.baseValueSticky = NO;
	self.paddingTop=15;
	self.tickInterval = 6;
	self.pos = 0;
	self.decimal = 2;
}

@end
