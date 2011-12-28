//
//  Chart.m
//  https://github.com/zhiyu/chartee/
//
//  Created by zhiyu on 7/11/11.
//  Copyright 2011 zhiyu. All rights reserved.
//

#import "Chart.h"

#define MIN_INTERVAL  3

@implementation Chart

@synthesize enableSelection; 
@synthesize isInitialized;
@synthesize isSectionInitialized;
@synthesize borderColor;
@synthesize borderWidth;
@synthesize plotWidth;
@synthesize plotPadding;
@synthesize plotCount;
@synthesize paddingLeft;
@synthesize paddingRight;
@synthesize paddingTop;
@synthesize paddingBottom;
@synthesize padding;
@synthesize selectedIndex;
@synthesize touchFlag;
@synthesize touchFlagTwo;
@synthesize rangeFrom;
@synthesize rangeTo;
@synthesize range;
@synthesize series;
@synthesize sections;
@synthesize ratios;
@synthesize title;

-(float)getLocalY:(float)val withSection:(int)sectionIndex withAxis:(int)yAxisIndex{
	Section *sec = [[self sections] objectAtIndex:sectionIndex];
	YAxis *yaxis = [sec.yAxises objectAtIndex:yAxisIndex];
	CGRect fra = sec.frame;
	float  max = yaxis.max;
	float  min = yaxis.min;
    return fra.size.height - (fra.size.height-sec.paddingTop)* (val-min)/(max-min)+fra.origin.y;
}

- (void)initChart{
	if(!self.isInitialized){
		self.plotPadding = 1.f;
		if(self.padding != nil){
			self.paddingTop    = [[self.padding objectAtIndex:0] floatValue];
			self.paddingRight  = [[self.padding objectAtIndex:1] floatValue];
			self.paddingBottom = [[self.padding objectAtIndex:2] floatValue];
			self.paddingLeft   = [[self.padding objectAtIndex:3] floatValue];
		}
		
		if(self.series!=nil){
			self.rangeTo = [[[[self series] objectAtIndex:0] objectForKey:@"data"] count];
			if(rangeTo-range >= 0){
				self.rangeFrom = rangeTo-range;
			}else{
			    self.rangeFrom = 0;
				self.rangeTo   = range;
			}
		}else{
			self.rangeTo   = 0;
			self.rangeFrom = 0;
		}
		self.selectedIndex = self.rangeTo-1;
		self.isInitialized = YES;
	}

	if(self.series!=nil){
		self.plotCount = [[[[self series] objectAtIndex:0] objectForKey:@"data"] count];
	}
	
}

-(void)reset{
	self.isInitialized = NO;
}

- (void)initXAxis{

}

- (void)initYAxis{
	for(int secIndex=0;secIndex<[self.sections count];secIndex++){
		Section *sec = [self.sections objectAtIndex:secIndex];
		for(int sIndex=0;sIndex<[sec.yAxises count];sIndex++){
			YAxis *yaxis = [sec.yAxises objectAtIndex:sIndex];
			yaxis.isUsed = NO;
		}
	}
	
	for(int secIndex=0;secIndex<[self.sections count];secIndex++){
		Section *sec = [self.sections objectAtIndex:secIndex];
		if(sec.paging){
			NSObject *serie = [[sec series] objectAtIndex:sec.selectedIndex];
			if([serie isKindOfClass:[NSArray class]]){
				for(int i=0;i<[serie count];i++){
					[self setValuesForYAxis:[serie objectAtIndex:i]];
				}
			}else {
				[self setValuesForYAxis:serie];
			}
		}else{
			for(int sIndex=0;sIndex<[sec.series count];sIndex++){
				NSObject *serie = [[sec series] objectAtIndex:sIndex];
				if([serie isKindOfClass:[NSArray class]]){
					for(int i=0;i<[serie count];i++){
						[self setValuesForYAxis:[serie objectAtIndex:i]];
					}
				}else {
					[self setValuesForYAxis:serie];
				}
			}
		}
		
		for(int i = 0;i<sec.yAxises.count;i++){
			YAxis *yaxis = [sec.yAxises objectAtIndex:i];
			yaxis.max += (yaxis.max-yaxis.min)*yaxis.ext;
			yaxis.min -= (yaxis.max-yaxis.min)*yaxis.ext;
			
			if(!yaxis.baseValueSticky){
				if(yaxis.max >= 0 && yaxis.min >= 0){
					yaxis.baseValue = yaxis.min;
				}else if(yaxis.max < 0 && yaxis.min < 0){
					yaxis.baseValue = yaxis.max;
				}else{
					yaxis.baseValue = 0;
				}
			}else{
				if(yaxis.baseValue < yaxis.min){
					yaxis.min = yaxis.baseValue;
				}
				
				if(yaxis.baseValue > yaxis.max){
					yaxis.max = yaxis.baseValue;
				}
			}
			
			if(yaxis.symmetrical == YES){
				if(yaxis.baseValue > yaxis.max){
					yaxis.max =  yaxis.baseValue + (yaxis.baseValue-yaxis.min);
				}else if(yaxis.baseValue < yaxis.min){
					yaxis.min =  yaxis.baseValue - (yaxis.max-yaxis.baseValue);
				}else {
					if((yaxis.max-yaxis.baseValue) > (yaxis.baseValue-yaxis.min)){
						yaxis.min =  yaxis.baseValue - (yaxis.max-yaxis.baseValue);
					}else{
						yaxis.max =  yaxis.baseValue + (yaxis.baseValue-yaxis.min);
					}
				}
			}	
		}
	}
}

-(void)setValuesForYAxis:(NSDictionary *)serie{
	if([[serie objectForKey:@"data"] count] == 0){
		return;
	}
	
	NSMutableArray *data    = [serie objectForKey:@"data"];
	NSString       *type    = [serie objectForKey:@"type"];
	NSString       *yAxis   = [serie objectForKey:@"yAxis"];
	NSString       *section = [serie objectForKey:@"section"];
	
	YAxis *yaxis = [[[self.sections objectAtIndex:[section intValue]] yAxises] objectAtIndex:[yAxis intValue]];
	if([serie objectForKey:@"decimal"] != nil){
		yaxis.decimal = [[serie objectForKey:@"decimal"] intValue];
	}
	
	float value = [[[data objectAtIndex:self.rangeFrom] objectAtIndex:0] floatValue];
	if([type isEqualToString:@"column"]){
		if(!yaxis.isUsed){
			[yaxis setMax:value];
			[yaxis setMin:value];
			yaxis.isUsed = YES;
		}
		for(int i=self.rangeFrom;i<self.rangeTo;i++){
			if(i == data.count){
				break;
			}
			if([data objectAtIndex:i] == nil){
			    continue;
			}
			
			float value = [[[data objectAtIndex:i] objectAtIndex:0] floatValue];
			if(value > [yaxis max])
				[yaxis setMax:value];
			if(value < [yaxis min])
				[yaxis setMin:value];
		}
	}else if([type isEqualToString:@"line"]){
		if(!yaxis.isUsed){
			[yaxis setMax:value];
			[yaxis setMin:value];
			yaxis.isUsed = YES;
		}
		
		for(int i=self.rangeFrom;i<self.rangeTo;i++){
			if(i == data.count){
				break;
			}
			if([data objectAtIndex:i] == nil){
			    continue;
			}
			
			float value = [[[data objectAtIndex:i] objectAtIndex:0] floatValue];
			if(value > [yaxis max])
				[yaxis setMax:value];
			if(value < [yaxis min])
				[yaxis setMin:value];
		}
	}else if([type isEqualToString:@"area"]){
		if(!yaxis.isUsed){
			[yaxis setMax:value];
			[yaxis setMin:value];
			yaxis.isUsed = YES;
		}
		for(int i=self.rangeFrom;i<self.rangeTo;i++){
			if(i == data.count){
				break;
			}
			if([data objectAtIndex:i] == nil){
			    continue;
			}
			
			float value = [[[data objectAtIndex:i] objectAtIndex:0] floatValue];
			if(value > [yaxis max])
				[yaxis setMax:value];
			if(value < [yaxis min])
				[yaxis setMin:value];
		}
	}
}

-(void)drawChart{
	for(int secIndex=0;secIndex<self.sections.count;secIndex++){
		Section *sec = [self.sections objectAtIndex:secIndex];
		if(sec.hidden){
		    continue;
		}
		plotWidth = (sec.frame.size.width-sec.paddingLeft)/(self.rangeTo-self.rangeFrom);
		for(int sIndex=0;sIndex<sec.series.count;sIndex++){
			NSObject *serie = [sec.series objectAtIndex:sIndex];
			
			if(sec.hidden){
				continue;
			}
			
			if(sec.paging){
				if (sec.selectedIndex == sIndex) {
					if([serie isKindOfClass:[NSArray class]]){
						for(int i=0;i<[serie count];i++){
							[self drawSerie:[serie objectAtIndex:i]];
						}
					}else{
						[self drawSerie:serie];
					}
					break;
				}
			}else{
				if([serie isKindOfClass:[NSArray class]]){
					for(int i=0;i<[serie count];i++){
						[self drawSerie:[serie objectAtIndex:i]];
					}
				}else{
					[self drawSerie:serie];
				}
			}			
		}
	}	
	[self drawLabels];
}

-(void)drawTips:(NSMutableDictionary *)serie{
}

-(void)drawLabels{
	for(int i=0;i<self.sections.count;i++){
		Section *sec = [self.sections objectAtIndex:i];
		if(sec.hidden){
		    continue;
		}
		
		float w = 0;
		for(int s=0;s<sec.series.count;s++){
			NSMutableArray *label =[[NSMutableArray alloc] init];
		    NSObject *serie = [sec.series objectAtIndex:s];
			
			if(sec.paging){
				if (sec.selectedIndex == s) {
					if([serie isKindOfClass:[NSArray class]]){
						for(int i=0;i<[serie count];i++){
							[self setLabel:label WithSerie:[serie objectAtIndex:i]];
						}
					}else{
						[self setLabel:label WithSerie:serie];
					}
				}
			}else{
				if([serie isKindOfClass:[NSArray class]]){
					for(int i=0;i<[serie count];i++){
						[self setLabel:label WithSerie:[serie objectAtIndex:i]];
					}
				}else{
					[self setLabel:label WithSerie:serie];
				}
			}	
			for(int j=0;j<label.count;j++){
				NSMutableDictionary *lbl = [label objectAtIndex:j];
				NSString *text  = [lbl objectForKey:@"text"];
				NSString *color = [lbl objectForKey:@"color"];
				NSArray *colors = [color componentsSeparatedByString:@","];
				CGContextRef context = UIGraphicsGetCurrentContext();
				CGContextSetShouldAntialias(context, YES);
				CGContextSetRGBFillColor(context, [[colors objectAtIndex:0] floatValue], [[colors objectAtIndex:1] floatValue], [[colors objectAtIndex:2] floatValue], 1.0);
				[text drawAtPoint:CGPointMake(sec.frame.origin.x+sec.paddingLeft+2+w,sec.frame.origin.y) withFont:[UIFont systemFontOfSize: 14]];
				w += [text sizeWithFont:[UIFont systemFontOfSize:14]].width;
			}
			[label release];
		}
	}
}

-(void)setLabel:(NSMutableArray *)label WithSerie:(NSMutableDictionary *) serie{
	if([serie objectForKey:@"data"] == nil || [[serie objectForKey:@"data"] count] == 0){
	    return;
	}
	
	NSMutableArray *data          = [serie objectForKey:@"data"];
	NSString       *type          = [serie objectForKey:@"type"];
	NSString       *lbl           = [serie objectForKey:@"label"];
	int            yAxis          = [[serie objectForKey:@"yAxis"] intValue];
	int            section        = [[serie objectForKey:@"section"] intValue];
	NSString       *color         = [serie objectForKey:@"color"];
	
	YAxis *yaxis = [[[self.sections objectAtIndex:section] yAxises] objectAtIndex:yAxis];
	NSString *format=[@"%." stringByAppendingFormat:@"%df",yaxis.decimal];
	
	float R   = [[[color componentsSeparatedByString:@","] objectAtIndex:0] floatValue]/255;
	float G   = [[[color componentsSeparatedByString:@","] objectAtIndex:1] floatValue]/255;
	float B   = [[[color componentsSeparatedByString:@","] objectAtIndex:2] floatValue]/255;
	
	if([type isEqualToString:@"column"]){
		if(self.selectedIndex!=-1 && self.selectedIndex < data.count && [data objectAtIndex:self.selectedIndex]!=nil){
			float value = [[[data objectAtIndex:self.selectedIndex] objectAtIndex:0] floatValue];
			NSMutableDictionary *tmp = [[NSMutableDictionary alloc] init];
			NSMutableString *l = [[NSMutableString alloc] init];
			NSString *fmt = [@"%@:" stringByAppendingFormat:@"%@",format];
			[l appendFormat:fmt,lbl,value];
			[tmp setObject:l forKey:@"text"];
			[l release];
			
			NSMutableString *clr = [[NSMutableString alloc] init];
			[clr appendFormat:@"%f,",R];
			[clr appendFormat:@"%f,",G];
			[clr appendFormat:@"%f",B];
			[tmp setObject:clr forKey:@"color"];
			[clr release];
			
			[label addObject:tmp];
			[tmp release];
		}
	}else if([type isEqualToString:@"line"]){
		if(self.selectedIndex!=-1 && self.selectedIndex < data.count && [data objectAtIndex:self.selectedIndex]!=nil){
			float value = [[[data objectAtIndex:self.selectedIndex] objectAtIndex:0] floatValue];
			NSMutableDictionary *tmp = [[NSMutableDictionary alloc] init];
			NSMutableString *l = [[NSMutableString alloc] init];
			NSString *fmt = [@"%@:" stringByAppendingFormat:@"%@",format];
			[l appendFormat:fmt,lbl,value];
			[tmp setObject:l forKey:@"text"];
			[l release];
			
			NSMutableString *clr = [[NSMutableString alloc] init];
			[clr appendFormat:@"%f,",R];
			[clr appendFormat:@"%f,",G];
			[clr appendFormat:@"%f",B];
			[tmp setObject:clr forKey:@"color"];
			[clr release];
			
			[label addObject:tmp];
			[tmp release];
	    }
	}else if([type isEqualToString:@"area"]){
		if(self.selectedIndex!=-1 && self.selectedIndex < data.count && [data objectAtIndex:self.selectedIndex]!=nil){
			float value = [[[data objectAtIndex:self.selectedIndex] objectAtIndex:0] floatValue];
			NSMutableDictionary *tmp = [[NSMutableDictionary alloc] init];
			NSMutableString *l = [[NSMutableString alloc] init];
			NSString *fmt = [@"%@:" stringByAppendingFormat:@"%@",format];
			[l appendFormat:fmt,lbl,value];
			[tmp setObject:l forKey:@"text"];
			[l release];
			
			NSMutableString *clr = [[NSMutableString alloc] init];
			[clr appendFormat:@"%f,",R];
			[clr appendFormat:@"%f,",G];
			[clr appendFormat:@"%f",B];
			[tmp setObject:clr forKey:@"color"];
			[clr release];
			
			[label addObject:tmp];
			[tmp release];
		}
	}			
}

-(void)drawSerie:(NSMutableDictionary *)serie{
	if([serie objectForKey:@"data"] == nil || [[serie objectForKey:@"data"] count] == 0){
	    return;
	}
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSetShouldAntialias(context, YES);
	CGContextSetLineWidth(context, 1.0f);
	
	NSMutableArray *data          = [serie objectForKey:@"data"];
	NSString       *type          = [serie objectForKey:@"type"];
	NSString       *label         = [serie objectForKey:@"label"];
	int            yAxis          = [[serie objectForKey:@"yAxis"] intValue];
	int            section        = [[serie objectForKey:@"section"] intValue];
	NSString       *color         = [serie objectForKey:@"color"];
	NSString       *negativeColor = [serie objectForKey:@"negativeColor"];
	NSString       *selectedColor = [serie objectForKey:@"selectedColor"];
	NSString       *negativeSelectedColor = [serie objectForKey:@"negativeSelectedColor"];

	YAxis *yaxis = [[[self.sections objectAtIndex:section] yAxises] objectAtIndex:yAxis];
	
	float R   = [[[color componentsSeparatedByString:@","] objectAtIndex:0] floatValue]/255;
	float G   = [[[color componentsSeparatedByString:@","] objectAtIndex:1] floatValue]/255;
	float B   = [[[color componentsSeparatedByString:@","] objectAtIndex:2] floatValue]/255;
	float NR  = [[[negativeColor componentsSeparatedByString:@","] objectAtIndex:0] floatValue]/255;
	float NG  = [[[negativeColor componentsSeparatedByString:@","] objectAtIndex:1] floatValue]/255;
	float NB  = [[[negativeColor componentsSeparatedByString:@","] objectAtIndex:2] floatValue]/255;
	float SR  = [[[selectedColor componentsSeparatedByString:@","] objectAtIndex:0] floatValue]/255;
	float SG  = [[[selectedColor componentsSeparatedByString:@","] objectAtIndex:1] floatValue]/255;
	float SB  = [[[selectedColor componentsSeparatedByString:@","] objectAtIndex:2] floatValue]/255;
	float NSR = [[[negativeSelectedColor componentsSeparatedByString:@","] objectAtIndex:0] floatValue]/255;
	float NSG = [[[negativeSelectedColor componentsSeparatedByString:@","] objectAtIndex:1] floatValue]/255;
	float NSB = [[[negativeSelectedColor componentsSeparatedByString:@","] objectAtIndex:2] floatValue]/255;		

	Section *sec = [self.sections objectAtIndex:section];
	
	if([type isEqualToString:@"column"]){
		if(self.selectedIndex!=-1 && self.selectedIndex < data.count && [data objectAtIndex:self.selectedIndex]!=nil){
			float value = [[[data objectAtIndex:self.selectedIndex] objectAtIndex:0] floatValue];
			CGContextSetStrokeColorWithColor(context, [[UIColor alloc] initWithRed:0.2 green:0.2 blue:0.2 alpha:1.0].CGColor);
			CGContextMoveToPoint(context, sec.frame.origin.x+sec.paddingLeft+(self.selectedIndex-self.rangeFrom)*plotWidth+plotWidth/2, sec.frame.origin.y+sec.paddingTop);
			CGContextAddLineToPoint(context,sec.frame.origin.x+sec.paddingLeft+(self.selectedIndex-self.rangeFrom)*plotWidth+plotWidth/2,sec.frame.size.height+sec.frame.origin.y);
			CGContextStrokePath(context);
			
			CGContextSetShouldAntialias(context, YES);
			CGContextBeginPath(context);
			CGContextSetRGBFillColor(context, R, G, B, 1.0);
			CGContextAddArc(context, sec.frame.origin.x+sec.paddingLeft+(self.selectedIndex-self.rangeFrom)*plotWidth+plotWidth/2, [self getLocalY:value withSection:section withAxis:yAxis], 3, 0, 2*M_PI, 1);
			CGContextFillPath(context);
		}

		CGContextSetShouldAntialias(context, NO);
		for(int i=self.rangeFrom;i<self.rangeTo;i++){
			if(i == data.count){
				break;
			}
			if([data objectAtIndex:i] == nil){
			    continue;
			}
			
			float value = [[[data objectAtIndex:i] objectAtIndex:0] floatValue];
			float ix  = sec.frame.origin.x+sec.paddingLeft+(i-self.rangeFrom)*plotWidth;
			float iy = [self getLocalY:value withSection:section withAxis:yAxis];
			
			if(value < yaxis.baseValue){
				if(i == self.selectedIndex){
					CGContextSetStrokeColorWithColor(context, [[UIColor alloc] initWithRed:NSR green:NSG blue:NSB alpha:1.0].CGColor);
					CGContextSetRGBFillColor(context, NSR, NSG, NSB, 1.0); 
				}else{
					CGContextSetStrokeColorWithColor(context, [[UIColor alloc] initWithRed:NR green:NG blue:NB alpha:1.0].CGColor);
					CGContextSetRGBFillColor(context, NR, NG, NB, 1.0); 
				}
			}else{
				if(i == self.selectedIndex){
					CGContextSetStrokeColorWithColor(context, [[UIColor alloc] initWithRed:SR green:SG blue:SB alpha:1.0].CGColor);
					CGContextSetRGBFillColor(context, SR, SG, SB, 1.0); 
				}else{
					CGContextSetStrokeColorWithColor(context, [[UIColor alloc] initWithRed:R green:G blue:B alpha:1.0].CGColor);
					CGContextSetRGBFillColor(context, R, G, B, 1.0); 
				} 
			}
			
			
		    CGContextFillRect (context, CGRectMake (ix+plotPadding, iy, plotWidth-2*plotPadding,[self getLocalY:yaxis.baseValue withSection:section withAxis:yAxis]-iy));
		}
	}else if([type isEqualToString:@"line"]){
		if(self.selectedIndex!=-1 && self.selectedIndex < data.count && [data objectAtIndex:self.selectedIndex]!=nil){
			float value = [[[data objectAtIndex:self.selectedIndex] objectAtIndex:0] floatValue];
			CGContextSetShouldAntialias(context, NO);
			CGContextSetStrokeColorWithColor(context, [[UIColor alloc] initWithRed:0.2 green:0.2 blue:0.2 alpha:1.0].CGColor);
			CGContextMoveToPoint(context, sec.frame.origin.x+sec.paddingLeft+(self.selectedIndex-self.rangeFrom)*plotWidth+plotWidth/2, sec.frame.origin.y+sec.paddingTop);
			CGContextAddLineToPoint(context,sec.frame.origin.x+sec.paddingLeft+(self.selectedIndex-self.rangeFrom)*plotWidth+plotWidth/2,sec.frame.size.height+sec.frame.origin.y);
			CGContextStrokePath(context);
			
			CGContextSetShouldAntialias(context, YES);
			CGContextBeginPath(context); 
			CGContextSetRGBFillColor(context, R, G, B, 1.0);
			CGContextAddArc(context, sec.frame.origin.x+sec.paddingLeft+(self.selectedIndex-self.rangeFrom)*plotWidth+plotWidth/2, [self getLocalY:value withSection:section withAxis:yAxis], 3, 0, 2*M_PI, 1);
			CGContextFillPath(context); 
		}
		
		CGContextSetShouldAntialias(context, YES);
		for(int i=self.rangeFrom;i<self.rangeTo;i++){
			if(i == data.count-1){
				break;
			}
			if([data objectAtIndex:i] == nil){
			    continue;
			}
			if (i<self.rangeTo-1 && [data objectAtIndex:(i+1)] != nil) {
				float value = [[[data objectAtIndex:i] objectAtIndex:0] floatValue];
				float ix  = sec.frame.origin.x+sec.paddingLeft+(i-self.rangeFrom)*plotWidth;
				float iNx  = sec.frame.origin.x+sec.paddingLeft+(i+1-self.rangeFrom)*plotWidth;
				float iy = [self getLocalY:value withSection:section withAxis:yAxis];				
				CGContextSetStrokeColorWithColor(context, [[UIColor alloc] initWithRed:R green:G blue:B alpha:1.0].CGColor);
				CGContextMoveToPoint(context, ix+plotWidth/2, iy);
				CGContextAddLineToPoint(context, iNx+plotWidth/2,[self getLocalY:([[[data objectAtIndex:(i+1)] objectAtIndex:0] floatValue]) withSection:section withAxis:yAxis]);
				CGContextStrokePath(context);
			}	
		}
		
	}else if([type isEqualToString:@"area"]){
		CGPoint startPoint,endPoint; 
		float prevValue = 0;
		float nextValue = 0;
		float ix        = 0;
		float iy        = 0;
		float iPx       = 0;
		float iPy       = 0;
		float iNx       = 0;
		float iNy       = 0;
		int   found     = 0;
		
		float iBy = [self getLocalY:yaxis.baseValue withSection:section withAxis:yAxis];
		
		if(self.selectedIndex!=-1 && self.selectedIndex < data.count && [data objectAtIndex:self.selectedIndex]!=nil){
			float value = [[[data objectAtIndex:self.selectedIndex] objectAtIndex:0] floatValue];			
			if(value>=yaxis.baseValue){
				CGContextSetRGBFillColor(context, R, G, B, 1.0);
			}else{ 
				CGContextSetRGBFillColor(context, NR, NG, NB, 1.0);
			}
			
			CGContextSetShouldAntialias(context, NO);
			CGContextSetStrokeColorWithColor(context, [[UIColor alloc] initWithRed:0.2 green:0.2 blue:0.2 alpha:1.0].CGColor);
			CGContextMoveToPoint(context, sec.frame.origin.x+sec.paddingLeft+(self.selectedIndex-self.rangeFrom)*plotWidth+plotWidth/2, sec.frame.origin.y+sec.paddingTop);
			CGContextAddLineToPoint(context,sec.frame.origin.x+sec.paddingLeft+(self.selectedIndex-self.rangeFrom)*plotWidth+plotWidth/2,sec.frame.size.height+sec.frame.origin.y);
			CGContextStrokePath(context);
			
			CGContextSetShouldAntialias(context, YES);
			CGContextBeginPath(context);
			CGContextAddArc(context, sec.frame.origin.x+sec.paddingLeft+(self.selectedIndex-self.rangeFrom)*plotWidth+plotWidth/2, [self getLocalY:value withSection:section withAxis:yAxis], 3, 0, 2*M_PI, 1);
			CGContextFillPath(context);
		}
		
		CGContextSetShouldAntialias(context, YES);
		/*
		 Start:drawing positive values
		 */
		CGContextBeginPath(context);
		CGContextSetRGBFillColor(context, R, G, B, 1.0);
		for(int i=self.rangeFrom;i<self.rangeTo;i++){
			if(i == data.count-1){
				break;
			}
			if([data objectAtIndex:i] == nil){
			    continue;
			}
			
			float value = [[[data objectAtIndex:i] objectAtIndex:0] floatValue];
			
			if(value >= yaxis.baseValue){
				ix  = sec.frame.origin.x+sec.paddingLeft+(i-self.rangeFrom)*plotWidth;
				iy = [self getLocalY:value withSection:section withAxis:yAxis];

				if(found == 0){
					found = 1;
					if(i==self.rangeFrom){
						CGContextMoveToPoint(context, ix+plotWidth/2, iy);
						startPoint = CGPointMake(ix+plotWidth/2, iy);
					}else if(i>self.rangeFrom){
						prevValue = [[[data objectAtIndex:(i-1)] objectAtIndex:0] floatValue];
						iPx = sec.frame.origin.x+sec.paddingLeft+(i-1-self.rangeFrom)*plotWidth;
						iPy = [self getLocalY:prevValue withSection:section withAxis:yAxis];
						if(prevValue < yaxis.baseValue){
							float baseX = (yaxis.baseValue-prevValue)*plotWidth/(value-prevValue)+(sec.frame.origin.x+sec.paddingLeft+(i-1-self.rangeFrom)*plotWidth+plotWidth/2);
							CGContextMoveToPoint(context, baseX,iBy);
							CGContextAddLineToPoint(context, ix+plotWidth/2, iy);
							startPoint = CGPointMake(baseX, iBy);
							endPoint = CGPointMake(ix+plotWidth/2,iy);
						}
					}
				}else if(i>self.rangeFrom){
					prevValue = [[[data objectAtIndex:(i-1)] objectAtIndex:0] floatValue];
					iPx = sec.frame.origin.x+sec.paddingLeft+(i-1-self.rangeFrom)*plotWidth;
					iPy = [self getLocalY:prevValue withSection:section withAxis:yAxis];
					if(prevValue < yaxis.baseValue){
						float baseX = (yaxis.baseValue-prevValue)*plotWidth/(value-prevValue)+(sec.frame.origin.x+sec.paddingLeft+(i-1-self.rangeFrom)*plotWidth+plotWidth/2);
						CGContextAddLineToPoint(context, baseX,iBy);
						CGContextAddLineToPoint(context, ix+plotWidth/2,iy);
						endPoint = CGPointMake(ix+plotWidth/2,iy);
					}
				}
				
				if (i < self.rangeTo-1  && [data objectAtIndex:(i+1)] != nil) {
					nextValue = [[[data objectAtIndex:(i+1)] objectAtIndex:0] floatValue];
					iNx = sec.frame.origin.x+sec.paddingLeft+(i+1-self.rangeFrom)*plotWidth;
					iNy = [self getLocalY:nextValue withSection:section withAxis:yAxis];
						
					if(nextValue < yaxis.baseValue){
						float baseX = (value-yaxis.baseValue)*plotWidth/(value-nextValue)+(sec.frame.origin.x+sec.paddingLeft+(i-self.rangeFrom)*plotWidth+plotWidth/2);
						CGContextAddLineToPoint(context, baseX,iBy);
						endPoint = CGPointMake(baseX, iBy);
					}else{
						CGContextAddLineToPoint(context, iNx+plotWidth/2,iNy);
						endPoint = CGPointMake(iNx+plotWidth/2,iNy);
					}
				}
			}
					
		}
		if(found == 1){
			CGContextAddLineToPoint(context, endPoint.x,iBy);
			CGContextAddLineToPoint(context, startPoint.x,iBy);
			CGContextFillPath(context);
		}
		/*
		 End:drawing positive values
		 */
		
		/*
		 Start:drawing negative values
		 */
		found = 0;
		CGContextBeginPath(context);
		CGContextSetRGBFillColor(context, NR, NG, NB, 1.0);
		for(int i=self.rangeFrom;i<self.rangeTo;i++){
			if(i == data.count-1){
				break;
			}
			if([data objectAtIndex:i] == nil){
			    continue;
			}
			
			float value = [[[data objectAtIndex:i] objectAtIndex:0] floatValue];
			if(value < yaxis.baseValue){
				ix  = sec.frame.origin.x+sec.paddingLeft+(i-self.rangeFrom)*plotWidth;
				iy = [self getLocalY:value withSection:section withAxis:yAxis];
				
				if(found == 0){
					found = 1;
					if(i==self.rangeFrom){
						CGContextMoveToPoint(context, ix+plotWidth/2, iy);
						startPoint = CGPointMake(ix+plotWidth/2, iy);
					}else if(i>self.rangeFrom){
						prevValue = [[[data objectAtIndex:(i-1)] objectAtIndex:0] floatValue];
						iPx = sec.frame.origin.x+sec.paddingLeft+(i-1-self.rangeFrom)*plotWidth;
						iPy = [self getLocalY:prevValue withSection:section withAxis:yAxis];
						if(prevValue > yaxis.baseValue){
							float baseX = (prevValue-yaxis.baseValue)*plotWidth/(prevValue-value)+(sec.frame.origin.x+sec.paddingLeft+(i-1-self.rangeFrom)*plotWidth+plotWidth/2);
							CGContextMoveToPoint(context, baseX,iBy);
							CGContextAddLineToPoint(context, ix+plotWidth/2, iy);
							startPoint = CGPointMake(baseX, iBy);
							endPoint = CGPointMake(ix+plotWidth/2,iy);
						}
					}
				}else if(i>self.rangeFrom){
					prevValue = [[[data objectAtIndex:(i-1)] objectAtIndex:0] floatValue];
					iPx = sec.frame.origin.x+sec.paddingLeft+(i-1-self.rangeFrom)*plotWidth;
					iPy = [self getLocalY:prevValue withSection:section withAxis:yAxis];
					if(prevValue > yaxis.baseValue){
						float baseX = (prevValue-yaxis.baseValue)*plotWidth/(prevValue-value)+(sec.frame.origin.x+sec.paddingLeft+(i-1-self.rangeFrom)*plotWidth+plotWidth/2);
						CGContextAddLineToPoint(context, baseX,iBy);
						CGContextAddLineToPoint(context, ix+plotWidth/2,iy);
						endPoint = CGPointMake(ix+plotWidth/2,iy);
					}
				}
				
				if (i < self.rangeTo-1 && [data objectAtIndex:(i+1)] != nil) {
					nextValue = [[[data objectAtIndex:(i+1)] objectAtIndex:0] floatValue];
					iNx = sec.frame.origin.x+sec.paddingLeft+(i+1-self.rangeFrom)*plotWidth;
					iNy = [self getLocalY:nextValue withSection:section withAxis:yAxis];
					if(nextValue > yaxis.baseValue){
						float baseX = (yaxis.baseValue-value)*plotWidth/(nextValue-value)+(sec.frame.origin.x+sec.paddingLeft+(i-self.rangeFrom)*plotWidth+plotWidth/2);
						CGContextAddLineToPoint(context, baseX,iBy);
						endPoint = CGPointMake(baseX, iBy);
					}else{
						CGContextAddLineToPoint(context, iNx+plotWidth/2,iNy);
						endPoint = CGPointMake(iNx+plotWidth/2,iNy);
					}
				}
			}
		}
		
		if(found == 1){
			CGContextAddLineToPoint(context, endPoint.x,iBy);
			CGContextAddLineToPoint(context, startPoint.x,iBy);
			CGContextAddLineToPoint(context, startPoint.x,startPoint.y);
			CGContextFillPath(context);
		}
		
		/*
		 End:drawing negative values
		 */
	}		
	
	[self drawTips:serie];
}

-(void)drawYAxis{
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSetShouldAntialias(context, NO );
	CGContextSetLineWidth(context, 1.0f);
	
	for(int secIndex=0;secIndex<[self.sections count];secIndex++){
		Section *sec = [self.sections objectAtIndex:secIndex];
		if(sec.hidden){
			continue;
		}
		CGContextMoveToPoint(context, sec.frame.origin.x+sec.paddingLeft,sec.frame.origin.y+sec.paddingTop);
		CGContextAddLineToPoint(context, sec.frame.origin.x+sec.paddingLeft,sec.frame.size.height+sec.frame.origin.y);
		CGContextMoveToPoint(context, sec.frame.origin.x+sec.frame.size.width,sec.frame.origin.y+sec.paddingTop);
		CGContextAddLineToPoint(context, sec.frame.origin.x+sec.frame.size.width,sec.frame.size.height+sec.frame.origin.y);
		CGContextStrokePath(context);
	}
	
	CGContextSetRGBFillColor(context, 0.5, 0.5, 0.5, 1.0);
	CGFloat dash[] = {5};
	CGContextSetLineDash (context,0,dash,1);  

	for(int secIndex=0;secIndex<self.sections.count;secIndex++){
		Section *sec = [self.sections objectAtIndex:secIndex];
		if(sec.hidden){
			continue;
		}
		for(int aIndex=0;aIndex<sec.yAxises.count;aIndex++){
			YAxis *yaxis = [sec.yAxises objectAtIndex:aIndex];
			NSString *format=[@"%." stringByAppendingFormat:@"%df",yaxis.decimal];
			
			float baseY = [self getLocalY:yaxis.baseValue withSection:secIndex withAxis:aIndex];
			CGContextSetStrokeColorWithColor(context, [[UIColor alloc] initWithRed:0.2 green:0.2 blue:0.2 alpha:1.0].CGColor);
			CGContextMoveToPoint(context,sec.frame.origin.x+sec.paddingLeft,baseY);
			CGContextAddLineToPoint(context,sec.frame.origin.x+sec.paddingLeft-2,baseY);
			CGContextStrokePath(context);
			
			[[@"" stringByAppendingFormat:format,yaxis.baseValue] drawAtPoint:CGPointMake(sec.frame.origin.x-1,baseY-7) withFont:[UIFont systemFontOfSize: 12]];
			
			CGContextSetStrokeColorWithColor(context, [[UIColor alloc] initWithRed:0.15 green:0.15 blue:0.15 alpha:1.0].CGColor);
			CGContextMoveToPoint(context,sec.frame.origin.x+sec.paddingLeft,baseY);
			CGContextAddLineToPoint(context,sec.frame.origin.x+sec.frame.size.width,baseY);
		
			if (yaxis.tickInterval%2 == 1) {
				yaxis.tickInterval +=1;
			}
			
			float step = (float)(yaxis.max-yaxis.min)/yaxis.tickInterval;
			for(int i=1; i<= yaxis.tickInterval+1;i++){
				if(yaxis.baseValue + i*step <= yaxis.max){
					float iy = [self getLocalY:(yaxis.baseValue + i*step) withSection:secIndex withAxis:aIndex];
					
					CGContextSetStrokeColorWithColor(context, [[UIColor alloc] initWithRed:0.2 green:0.2 blue:0.2 alpha:1.0].CGColor);
					CGContextMoveToPoint(context,sec.frame.origin.x+sec.paddingLeft,iy);
					CGContextAddLineToPoint(context,sec.frame.origin.x+sec.paddingLeft-2,iy);
					CGContextStrokePath(context);
					
					[[@"" stringByAppendingFormat:format,yaxis.baseValue+i*step] drawAtPoint:CGPointMake(sec.frame.origin.x-1,iy-7) withFont:[UIFont systemFontOfSize: 12]];
					
					if(yaxis.baseValue + i*step < yaxis.max){
						CGContextSetStrokeColorWithColor(context, [[UIColor alloc] initWithRed:0.15 green:0.15 blue:0.15 alpha:1.0].CGColor);
						CGContextMoveToPoint(context,sec.frame.origin.x+sec.paddingLeft,iy);
						CGContextAddLineToPoint(context,sec.frame.origin.x+sec.frame.size.width,iy);
					}
					
					CGContextStrokePath(context);
				}
			}
			for(int i=1; i <= yaxis.tickInterval+1;i++){
				if(yaxis.baseValue - i*step >= yaxis.min){
					float iy = [self getLocalY:(yaxis.baseValue - i*step) withSection:secIndex withAxis:aIndex];
					
					CGContextSetStrokeColorWithColor(context, [[UIColor alloc] initWithRed:0.2 green:0.2 blue:0.2 alpha:1.0].CGColor);
					CGContextMoveToPoint(context,sec.frame.origin.x+sec.paddingLeft,iy);
					CGContextAddLineToPoint(context,sec.frame.origin.x+sec.paddingLeft-2,iy);
					CGContextStrokePath(context);
					
					[[@"" stringByAppendingFormat:format,yaxis.baseValue-i*step] drawAtPoint:CGPointMake(sec.frame.origin.x-1,iy-7) withFont:[UIFont systemFontOfSize: 12]];
					
					if(yaxis.baseValue - i*step > yaxis.min){
						CGContextSetStrokeColorWithColor(context, [[UIColor alloc] initWithRed:0.15 green:0.15 blue:0.15 alpha:1.0].CGColor);
						CGContextMoveToPoint(context,sec.frame.origin.x+sec.paddingLeft,iy);
						CGContextAddLineToPoint(context,sec.frame.origin.x+sec.frame.size.width,iy);
					}
					
					CGContextStrokePath(context);
				}
			}
		}
	}	
	CGContextSetLineDash (context,0,NULL,0); 
}

-(void)drawXAxis{
    CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSetShouldAntialias(context, NO);
	CGContextSetLineWidth(context, 1.f);
	CGContextSetStrokeColorWithColor(context, [[UIColor alloc] initWithRed:0.2 green:0.2 blue:0.2 alpha:1.0].CGColor);
	for(int secIndex=0;secIndex<self.sections.count;secIndex++){
		Section *sec = [self.sections objectAtIndex:secIndex];
		if(sec.hidden){
			continue;
		}
		CGContextMoveToPoint(context,sec.frame.origin.x+sec.paddingLeft,sec.frame.size.height+sec.frame.origin.y);
		CGContextAddLineToPoint(context, sec.frame.origin.x+sec.frame.size.width,sec.frame.size.height+sec.frame.origin.y);
		
		CGContextMoveToPoint(context,sec.frame.origin.x+sec.paddingLeft,sec.frame.origin.y+sec.paddingTop);
		CGContextAddLineToPoint(context, sec.frame.origin.x+sec.frame.size.width,sec.frame.origin.y+sec.paddingTop);
	}
	CGContextStrokePath(context);
}

-(void) setSelectedIndexByPoint:(CGPoint) point{
	
	if([self getIndexOfSection:point] == -1){
		return;
	}
	Section *sec = [self.sections objectAtIndex:[self getIndexOfSection:point]];
	
	for(int i=self.rangeFrom;i<self.rangeTo;i++){
		if((plotWidth*(i-self.rangeFrom))<=(point.x-sec.paddingLeft-self.paddingLeft) && (point.x-sec.paddingLeft-self.paddingLeft)<plotWidth*((i-self.rangeFrom)+1)){
			if (self.selectedIndex != i) {
				self.selectedIndex=i;
				[self setNeedsDisplay];
			}
			
			return;
		}
	}
}

-(void)appendToData:(NSArray *)data forName:(NSString *)name{
    for(int i=0;i<self.series.count;i++){
		if([[[self.series objectAtIndex:i] objectForKey:@"name"] isEqualToString:name]){
			if([[self.series objectAtIndex:i] objectForKey:@"data"] == nil){
				NSMutableArray *tempData = [[NSMutableArray alloc] init];
			    [[self.series objectAtIndex:i] setObject:tempData forKey:@"data"];
				[tempData release];
			}
			
			for(int j=0;j<data.count;j++){
				[[[self.series objectAtIndex:i] objectForKey:@"data"] addObject:[data objectAtIndex:j]];
			}
	    }
	}
}

-(void)clearDataforName:(NSString *)name{
	for(int i=0;i<self.series.count;i++){
		if([[[self.series objectAtIndex:i] objectForKey:@"name"] isEqualToString:name]){
			if([[self.series objectAtIndex:i] objectForKey:@"data"] != nil){
				[[[self.series objectAtIndex:i] objectForKey:@"data"] removeAllObjects];
			}
	    }
	}
}

-(void)clearData{
	for(int i=0;i<self.series.count;i++){
		[[[self.series objectAtIndex:i] objectForKey:@"data"] removeAllObjects];
	}
}

-(void)setData:(NSMutableArray *)data forName:(NSString *)name{
	for(int i=0;i<self.series.count;i++){
		if([[[self.series objectAtIndex:i] objectForKey:@"name"] isEqualToString:name]){
		    [[self.series objectAtIndex:i] setObject:data forKey:@"data"];
		}
	}
}


-(void)appendToCategory:(NSArray *)category forName:(NSString *)name{
	for(int i=0;i<self.series.count;i++){
		if([[[self.series objectAtIndex:i] objectForKey:@"name"] isEqualToString:name]){
			if([[self.series objectAtIndex:i] objectForKey:@"category"] == nil){
				NSMutableArray *tempData = [[NSMutableArray alloc] init];
			    [[self.series objectAtIndex:i] setObject:tempData forKey:@"category"];
				[tempData release];
			}
			
			for(int j=0;j<category.count;j++){
				[[[self.series objectAtIndex:i] objectForKey:@"category"] addObject:[category objectAtIndex:j]];
			}
	    }
	}
}

-(void)clearCategoryforName:(NSString *)name{
	for(int i=0;i<self.series.count;i++){
		if([[[self.series objectAtIndex:i] objectForKey:@"name"] isEqual:name]){
			if([[self.series objectAtIndex:i] objectForKey:@"category"] != nil){
				[[[self.series objectAtIndex:i] objectForKey:@"category"] removeAllObjects];
			}
	    }
	}
}

-(void)clearCategory{
	for(int i=0;i<self.series.count;i++){
		[[[self.series objectAtIndex:i] objectForKey:@"category"] removeAllObjects];
	}
}

-(void)setCategory:(NSMutableArray *)category forName:(NSString *)name{
	for(int i=0;i<self.series.count;i++){
		if([[[self.series objectAtIndex:i] objectForKey:@"name"] isEqualToString:name]){
		    [[self.series objectAtIndex:i] setObject:category forKey:@"category"];
		}
	}
}

/*
 * Sections
 */
-(Section *)getSection:(int) index{
    return [self.sections objectAtIndex:index];
}
-(int)getIndexOfSection:(CGPoint) point{
    for(int i=0;i<self.sections.count;i++){
	    Section *sec = [self.sections objectAtIndex:i];
		if (CGRectContainsPoint(sec.frame, point)){
		    return i;
		}
	}
	return -1;
}

/*
 * series
 */
-(NSMutableDictionary *)getSerie:(NSString *)name{
	NSMutableDictionary *serie = nil;
    for(int i=0;i<self.series.count;i++){
		if([[[self.series objectAtIndex:i] objectForKey:@"name"] isEqualToString:name]){
			serie = [self.series objectAtIndex:i];
			break;
		}
	}
	return serie;
}

-(void)addSerie:(NSObject *)serie{
	if([serie isKindOfClass:[NSArray class]]){
		int section = 0;
	    for (NSDictionary *ser in serie) {
		    section = [[ser objectForKey:@"section"] intValue];
			[self.series addObject:ser];
		}
		[[[self.sections objectAtIndex:section] series] addObject:serie];
	}else{
		int section = [[serie objectForKey:@"section"] intValue];
		[self.series addObject:serie];
		[[[self.sections objectAtIndex:section] series] addObject:serie];
	}
}

/*
 *  Chart Sections
 */ 
-(void)addSection:(NSString *)ratio{
	[ratio retain];
	Section *sec = [[Section alloc] init];
    [self.sections addObject:sec];
	[sec release];
	[self.ratios addObject:ratio];
	[ratio release];
}

-(void)removeSection:(int)index{
    [self.sections removeObjectAtIndex:index];
	[self.ratios removeObjectAtIndex:index];
}

-(void)addSections:(int)num withRatios:(NSArray *)rats{
	[rats retain];
	for (int i=0; i< num; i++) {
		Section *sec = [[Section alloc] init];
		[self.sections addObject:sec];
		[sec release];	
		[self.ratios addObject:[rats objectAtIndex:i]];
	}
	[rats release];
}

-(void)removeSections{
    [self.sections removeAllObjects];
	[self.ratios removeAllObjects];
}

-(void)initSections{
		float height = self.frame.size.height-(self.paddingTop+self.paddingBottom);
		float width  = self.frame.size.width-(self.paddingLeft+self.paddingRight);
		
		int total = 0;
		for (int i=0; i< self.ratios.count; i++) {
			if([[self.sections objectAtIndex:i] hidden]){
			    continue;
			}
			int ratio = [[self.ratios objectAtIndex:i] intValue];
			total+=ratio;
		}
		
		Section*prevSec = nil;
		for (int i=0; i< self.sections.count; i++) {
			int ratio = [[self.ratios objectAtIndex:i] intValue];
			Section *sec = [self.sections objectAtIndex:i];
			if([sec hidden]){
				continue;
			}
			float h = height*ratio/total;
			float w = width;
			
			if(i==0){
				[sec setFrame:CGRectMake(0+self.paddingLeft, 0+self.paddingTop, w,h)];
			}else{
				if(i==([self.sections count]-1)){
					[sec setFrame:CGRectMake(0+self.paddingLeft, prevSec.frame.origin.y+prevSec.frame.size.height, w,self.paddingTop+height-(prevSec.frame.origin.y+prevSec.frame.size.height))];
				}else {
					[sec setFrame:CGRectMake(0+self.paddingLeft, prevSec.frame.origin.y+prevSec.frame.size.height, w,h)];
				}
			}
			prevSec = sec;
			
		}
		self.isSectionInitialized = YES;
}


-(YAxis *)getYAxis:(int) section withIndex:(int) index{
	Section *sec = [self.sections objectAtIndex:section];
	YAxis *yaxis = [sec.yAxises objectAtIndex:index];
    return yaxis;
}

/* 
 * UIView Methods
 */
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
	if (self) {
		self.enableSelection = YES;
		self.isInitialized   = NO;
		self.isSectionInitialized   = NO;
		self.selectedIndex   = -1;
		self.padding         = nil;
		self.paddingTop      = 0;
		self.paddingRight    = 0;
		self.paddingBottom   = 0;
		self.paddingLeft     = 0;
		self.rangeFrom       = 0;
		self.rangeTo         = 0;
		self.range           = 120;
		self.touchFlag       = 0;
		self.touchFlagTwo    = 0;
		NSMutableArray *rats = [[NSMutableArray alloc] init];
		self.ratios          = rats; 
		[rats release];
		
		NSMutableArray *secs = [[NSMutableArray alloc] init];
		self.sections        = secs; 
		[secs release];
		
		[self setMultipleTouchEnabled:YES];
    } 
    return self;
}

- (void)drawRect:(CGRect)rect {
	[self initChart];
	[self initSections];
	[self initXAxis];
	[self initYAxis];
	[self drawXAxis];
	[self drawYAxis];
	[self drawChart];
}

- (void)dealloc {
    [super dealloc];
	[borderColor release];	
	[padding release];
	[series release];
	[title release];
	[sections release];
	[ratios release];
}

#pragma mark -
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	NSArray *ts = [touches allObjects];
	self.touchFlag = 0;
	self.touchFlagTwo = 0;
	if([ts count]==1){
		UITouch* touch = [ts objectAtIndex:0];
		if([touch locationInView:self].x < 40){
		    self.touchFlag = [touch locationInView:self].y;
		}
	}else if ([ts count]==2) {
		self.touchFlag = [[ts objectAtIndex:0] locationInView:self].x ;
		//abs([[ts objectAtIndex:0] locationInView:self].x-[[ts objectAtIndex:1] locationInView:self].x);
		self.touchFlagTwo = [[ts objectAtIndex:1] locationInView:self].x;
	}
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
	NSArray *ts = [touches allObjects];	
	if([ts count]==1){
		UITouch* touch = [ts objectAtIndex:0];
		int i = [self getIndexOfSection:[touch locationInView:self]];
		if(i!=-1){
			Section *sec = [self.sections objectAtIndex:i];
			if([touch locationInView:self].x > sec.paddingLeft)
				[self setSelectedIndexByPoint:[touch locationInView:self]];
			int interval = 5;
			if([touch locationInView:self].x < sec.paddingLeft){
				if(abs([touch locationInView:self].y - self.touchFlag) >= MIN_INTERVAL){
					if([touch locationInView:self].y - self.touchFlag > 0){
						if(self.plotCount > (self.rangeTo-self.rangeFrom)){
							if(self.rangeFrom - interval >= 0){
								self.rangeFrom -= interval;
								self.rangeTo   -= interval;
								if(self.selectedIndex >= self.rangeTo){
									self.selectedIndex = self.rangeTo-1;
								}
							}else {
								self.rangeFrom = 0;
								self.rangeTo  -= self.rangeFrom;
								if(self.selectedIndex >= self.rangeTo){
									self.selectedIndex = self.rangeTo-1;
								}
							}
							[self setNeedsDisplay];
						}
					}else{
						if(self.plotCount > (self.rangeTo-self.rangeFrom)){
							if(self.rangeTo + interval <= self.plotCount){
								self.rangeFrom += interval;
								self.rangeTo += interval;
								if(self.selectedIndex < self.rangeFrom){
									self.selectedIndex = self.rangeFrom;
								}
							}else {
								self.rangeFrom  += self.plotCount-self.rangeTo;
								self.rangeTo     = self.plotCount;
								
								if(self.selectedIndex < self.rangeFrom){
									self.selectedIndex = self.rangeFrom;
								}
							}
							[self setNeedsDisplay];
						}
					}
					self.touchFlag = [touch locationInView:self].y;
				}
			}
		}
		
	}else if ([ts count]==2) {
		float currFlag = [[ts objectAtIndex:0] locationInView:self].x;
		float currFlagTwo = [[ts objectAtIndex:1] locationInView:self].x;
		if(self.touchFlag == 0){
		    self.touchFlag = currFlag;
			self.touchFlagTwo = currFlagTwo;
		}else{
			int interval = 5;
			
			if((currFlag - self.touchFlag) > 0 && (currFlagTwo - self.touchFlagTwo) > 0){
				if(self.plotCount > (self.rangeTo-self.rangeFrom)){
					if(self.rangeFrom - interval >= 0){
						self.rangeFrom -= interval;
						self.rangeTo   -= interval;
						if(self.selectedIndex >= self.rangeTo){
							self.selectedIndex = self.rangeTo-1;
						}
					}else {
						self.rangeFrom = 0;
						self.rangeTo  -= self.rangeFrom;
						if(self.selectedIndex >= self.rangeTo){
							self.selectedIndex = self.rangeTo-1;
						}
					}
					[self setNeedsDisplay];
				}
			}else if((currFlag - self.touchFlag) < 0 && (currFlagTwo - self.touchFlagTwo) < 0){
				if(self.plotCount > (self.rangeTo-self.rangeFrom)){
					if(self.rangeTo + interval <= self.plotCount){
						self.rangeFrom += interval;
						self.rangeTo += interval;
						if(self.selectedIndex < self.rangeFrom){
							self.selectedIndex = self.rangeFrom;
						}
					}else {
						self.rangeFrom  += self.plotCount-self.rangeTo;
						self.rangeTo     = self.plotCount;
						
						if(self.selectedIndex < self.rangeFrom){
							self.selectedIndex = self.rangeFrom;
						}
					}
					[self setNeedsDisplay];
				}
			}else {
				if(abs(abs(currFlagTwo-currFlag)-abs(self.touchFlagTwo-self.touchFlag)) >= MIN_INTERVAL){
					if(abs(currFlagTwo-currFlag)-abs(self.touchFlagTwo-self.touchFlag) > 0){
						if(self.plotCount>self.rangeTo-self.rangeFrom){
							if(self.rangeFrom + interval < self.rangeTo){
								self.rangeFrom += interval;
							}
							if(self.rangeTo - interval > self.rangeFrom){
								self.rangeTo -= interval;
							}
						}else{
							if(self.rangeTo - interval > self.rangeFrom){
								self.rangeTo -= interval;
							}
						}
						[self setNeedsDisplay];
					}else{
						
						if(self.rangeFrom - interval >= 0){
							self.rangeFrom -= interval;
						}else{
							self.rangeFrom = 0;
						}
						self.rangeTo += interval;
						[self setNeedsDisplay];
					}
				}
			}

		}
		self.touchFlag = currFlag;
		self.touchFlagTwo = currFlagTwo;
	}
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
	NSArray *ts = [touches allObjects];	
	UITouch* touch = [[event allTouches] anyObject];
	if([ts count]==1){
		int i = [self getIndexOfSection:[touch locationInView:self]];
		if(i!=-1){
			Section *sec = [self.sections objectAtIndex:i];
			if([touch locationInView:self].x > sec.paddingLeft){
				if(sec.paging){
					[sec nextPage];
					[self setNeedsDisplay];
				}else{
					[self setSelectedIndexByPoint:[touch locationInView:self]];
				}
			}
		}
	}
	self.touchFlag = 0;
}

@end
