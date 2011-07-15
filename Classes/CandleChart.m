//
//  KLine.m
//  tzz
//
//  Created by zzy on 7/11/11.
//  Copyright 2011 Zhengzhiyu. All rights reserved.
//

#import "CandleChart.h"

#define MIN_INTERVAL  3

@implementation CandleChart

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
		self.backgroundColor    = [[UIColor alloc] initWithRed:0.15 green:0.15 blue:0.15 alpha:1.0];
    }
    return self;
}

- (void)initChart{
	[super initChart];
}

-(void)drawSerie:(NSMutableDictionary *)serie withLabels:(NSMutableArray *)labels{
	[super drawSerie:serie withLabels:labels];
}

-(void)drawChart{
	[super drawChart];
}

#pragma mark -
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	NSArray *ts = [touches allObjects];
	self.touchFlag = 0;
	if([ts count]==1){
		UITouch* touch = [ts objectAtIndex:0];
		if([touch locationInView:self].x < 40){
		    self.touchFlag = [touch locationInView:self].y;
		}
	}else if ([ts count]==2) {
		self.touchFlag = abs([[ts objectAtIndex:0] locationInView:self].x-[[ts objectAtIndex:1] locationInView:self].x);
	}
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
	NSArray *ts = [touches allObjects];	
	if([ts count]==1){
		UITouch* touch = [ts objectAtIndex:0];
	
		if([touch locationInView:self].x > 40)
			[self setSelectedIndexByPoint:[touch locationInView:self]];
		
		if([touch locationInView:self].x < 40){
			if(abs([touch locationInView:self].y - self.touchFlag) >= MIN_INTERVAL){
				if([touch locationInView:self].y - self.touchFlag > 0){
					if(self.rangeFrom - 1 >= 0){
						self.rangeFrom -= 1;
						self.rangeTo   -= 1;
						
						if(self.selectedIndex >= self.rangeTo){
						    self.selectedIndex = self.rangeTo-1;
						}
						[self setNeedsDisplay];
					}
				}else{
					if(self.rangeTo + 1 <= self.plotCount){
						self.rangeFrom += 1;
						self.rangeTo += 1;
						
						if(self.selectedIndex < self.rangeFrom){
						    self.selectedIndex = self.rangeFrom;
						}
						[self setNeedsDisplay];
					}
				}
				self.touchFlag = [touch locationInView:self].y;
			}
		}
	}else if ([ts count]==2) {
		float currFlag = abs([[ts objectAtIndex:0] locationInView:self].x-[[ts objectAtIndex:1] locationInView:self].x);
		if(self.touchFlag == 0){
		    self.touchFlag = currFlag;
		}else{
			if(abs(currFlag-self.touchFlag) >= MIN_INTERVAL){
				if(currFlag-self.touchFlag > 0){
					if(self.rangeFrom + 1 < self.rangeTo){
						self.rangeFrom += 1;
					}
					if(self.rangeTo - 1 > self.rangeFrom){
						self.rangeTo -= 1;
					}
					[self setNeedsDisplay];
				}else{
					if(self.rangeFrom - 1 >= 0){
						self.rangeFrom -= 1;
					}
					if(self.rangeTo + 1 <= self.plotCount){
						self.rangeTo += 1;
					}
					[self setNeedsDisplay];
				}
				self.touchFlag = currFlag;				
			}
		}
		self.touchFlag = currFlag;
	}
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
	NSArray *ts = [touches allObjects];	
	UITouch* touch = [[event allTouches] anyObject];
    NSUInteger numTaps = [touch tapCount];
	
	if([ts count]==1){
		if([touch locationInView:self].x > 40){
			int i = [self getSectionIndexByPoint:[touch locationInView:self]];
			
			if(i!=-1){
				Section *sec = [self.sections objectAtIndex:i];
				if(sec.paging){
					[sec nextPage];
					[self setNeedsDisplay];
				}else{
					[self setSelectedIndexByPoint:[touch locationInView:self]];
				}
				
				if(numTaps==3){
					if(i==0){
						//[Navigator pop];
					}
				}
			}
			
		}
	}
	self.touchFlag = 0;
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{

}

- (void)dealloc {
    [super dealloc];
}

@end
