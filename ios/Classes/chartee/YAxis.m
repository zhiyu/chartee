//
//  YAxis.m
//  tzz
//
//  Created by zzy on 7/11/11.
//  Copyright 2011 Zhengzhiyu. All rights reserved.
//

#import "YAxis.h"

@implementation YAxis

@synthesize isInitialized;
@synthesize frame;
@synthesize max;
@synthesize min;
@synthesize paddingTop;
@synthesize tickInterval;
@synthesize position;

- (id)init{
	self = [super init];
    if (self) {
		[self reset];
    }
	return self;
}

-(void)reset{
	self.isInitialized = NO;
	self.min =0;
	self.max =0;
	self.paddingTop=15;
	self.tickInterval = 5;
	self.position = 0;
}

@end
