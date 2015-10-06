//
//  Section.m
//  https://github.com/zhiyu/chartee/
//
//  Created by zhiyu on 7/11/11.
//  Copyright 2011 zhiyu. All rights reserved.
//

#import "Section.h"

@implementation Section

@synthesize hidden;
@synthesize isInitialized;
@synthesize paging;
@synthesize selectedIndex;
@synthesize frame;
@synthesize paddingLeft;
@synthesize paddingRight;
@synthesize paddingTop;
@synthesize paddingBottom;
@synthesize padding;
@synthesize series;
@synthesize yAxises;
@synthesize xAxises;

-(void)addYAxis:(int)pos{
    YAxis *yaix = [[YAxis alloc] init];
	yaix.pos = pos;
	[self.yAxises addObject:yaix];
}

-(void)removeYAxis:(int)index{
    [self.yAxises removeObjectAtIndex:index];
}

-(void)addYAxises:(int)num at:(int)pos{

}

-(void)removeYAxises{
    [self.yAxises removeAllObjects];
}

-(void)initYAxises{
    for(int i=0;i<[self.yAxises count];i++){
	    [self.yAxises[i] setIsUsed:NO];
	}
}

-(void)nextPage{
	if(self.selectedIndex < [self.series count] - 1){
		self.selectedIndex++;
	}else{
		self.selectedIndex = 0;
	}
	[self initYAxises];
}

- (id)init{
	self = [super init];
    if (self) {
		self.hidden          = NO;
		self.isInitialized   = NO;
		self.paging          = NO;
		self.selectedIndex   = 0;
		self.paddingLeft     = 60;
		self.paddingRight    = 0;
		self.paddingTop      = 20;
		self.paddingBottom   = 0;
		self.padding         = nil;
		NSMutableArray *sers = [[NSMutableArray alloc] init];
		self.series          = sers;
		NSMutableArray *yas = [[NSMutableArray alloc] init];
		self.yAxises        = yas;
		NSMutableArray *xas = [[NSMutableArray alloc] init];
		self.xAxises        = xas;
    }
	return self;
}

@end
