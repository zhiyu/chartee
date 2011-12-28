//
//  CandleChart.m
//  https://github.com/zhiyu/chartee/
//
//  Created by zhiyu on 7/11/11.
//  Copyright 2011 zhiyu. All rights reserved.
//

#import "CandleChart.h"

#define MIN_INTERVAL  3

@implementation CandleChart

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
		self.backgroundColor = [[UIColor alloc] initWithRed:20/255.f green:20/255.f blue:20/255.f alpha:1];
    }
    return self;
}

- (void)initChart{
	[super initChart];
}

-(void)drawSideBar{
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSetLineWidth(context, 1.0f);
	CGContextSetShouldAntialias(context, YES);
	for(int i=0;i<5;i++){
		NSMutableString *l = [[NSMutableString alloc] init];
		[l appendFormat:@"%@%d:%.3f ",@"买",i,(float)i/3];
		[l drawAtPoint:CGPointMake(self.frame.size.width-self.paddingRight+20,15*i+self.paddingTop) withFont:[UIFont systemFontOfSize: 12]];
		[l release];
	}
	
	for(int i=5;i<10;i++){
		NSMutableString *l = [[NSMutableString alloc] init];
		[l appendFormat:@"%@%d:%.3f ",@"卖",i,(float)i/3];
		[l drawAtPoint:CGPointMake(self.frame.size.width-self.paddingRight+20,15*i+self.paddingTop) withFont:[UIFont systemFontOfSize: 12]];
		[l release];
	}
}

-(void)setValuesForYAxis:(NSDictionary *)serie{
	[super setValuesForYAxis:serie];
	
	if([[serie objectForKey:@"data"] count] == 0){
		return;
	}
	
	NSMutableArray *data    = [serie objectForKey:@"data"];
	NSString       *type    = [serie objectForKey:@"type"];
	NSString       *yAxis   = [serie objectForKey:@"yAxis"];
	NSString       *section = [serie objectForKey:@"section"];
	
	YAxis *yaxis = [[[self.sections objectAtIndex:[section intValue]] yAxises] objectAtIndex:[yAxis intValue]];
	
	if([type isEqualToString:@"candle"]){
		float high = [[[data objectAtIndex:self.rangeFrom] objectAtIndex:2] floatValue];
		float low = [[[data objectAtIndex:self.rangeFrom] objectAtIndex:3] floatValue];
		
		if(!yaxis.isUsed){
			[yaxis setMax:high];
			[yaxis setMin:low];
			yaxis.isUsed = YES;
		}
		
		for(int i=self.rangeFrom;i<self.rangeTo;i++){
			if(i == data.count){
				break;
			}
			if([data objectAtIndex:i] == nil){
			    continue;
			}
			
			float high = [[[data objectAtIndex:i] objectAtIndex:2] floatValue];
			float low = [[[data objectAtIndex:i] objectAtIndex:3] floatValue];
			if(high > [yaxis max])
				[yaxis setMax:high];
			if(low < [yaxis min])
				[yaxis setMin:low];
		}
	}	
}

-(void)setLabel:(NSMutableArray *)label WithSerie:(NSMutableDictionary *) serie{
    [super setLabel:label WithSerie:serie];
	
	if([serie objectForKey:@"data"] == nil || [[serie objectForKey:@"data"] count] == 0){
	    return;
	}
	
	NSMutableArray *data          = [serie objectForKey:@"data"];
	NSString       *type          = [serie objectForKey:@"type"];
	NSString       *name          = [serie objectForKey:@"name"];
	int            yAxis          = [[serie objectForKey:@"yAxis"] intValue];
	int            section        = [[serie objectForKey:@"section"] intValue];
	NSString       *color         = [serie objectForKey:@"color"];
	NSString       *negativeColor = [serie objectForKey:@"negativeColor"];
	
	YAxis *yaxis = [[[self.sections objectAtIndex:section] yAxises] objectAtIndex:yAxis];
	NSString *format=[@"%." stringByAppendingFormat:@"%df",yaxis.decimal];
	
	float R   = [[[color componentsSeparatedByString:@","] objectAtIndex:0] floatValue]/255;
	float G   = [[[color componentsSeparatedByString:@","] objectAtIndex:1] floatValue]/255;
	float B   = [[[color componentsSeparatedByString:@","] objectAtIndex:2] floatValue]/255;
	float NR  = [[[negativeColor componentsSeparatedByString:@","] objectAtIndex:0] floatValue]/255;
	float NG  = [[[negativeColor componentsSeparatedByString:@","] objectAtIndex:1] floatValue]/255;
	float NB  = [[[negativeColor componentsSeparatedByString:@","] objectAtIndex:2] floatValue]/255;
	
	float ZR  = 1;
	float ZG  = 1;
	float ZB  = 1;
	
	if([type isEqualToString:@"candle"]){
			if(self.selectedIndex!=-1 && self.selectedIndex < data.count && [data objectAtIndex:self.selectedIndex]!=nil){
				float high  = [[[data objectAtIndex:self.selectedIndex] objectAtIndex:2] floatValue];
				float low   = [[[data objectAtIndex:self.selectedIndex] objectAtIndex:3] floatValue];
				float open  = [[[data objectAtIndex:self.selectedIndex] objectAtIndex:0] floatValue];
				float close = [[[data objectAtIndex:self.selectedIndex] objectAtIndex:1] floatValue];
				float inc   =  (close-open)*100/open;
				
				NSMutableDictionary *tmp = [[NSMutableDictionary alloc] init];
				NSMutableString *l = [[NSMutableString alloc] init];
				[l appendFormat:@"开:%.2f",open];
				[tmp setObject:l forKey:@"text"];
				[l release];
				NSMutableString *clr = [[NSMutableString alloc] init];
				[clr appendFormat:@"%f,",ZR];
				[clr appendFormat:@"%f,",ZG];
				[clr appendFormat:@"%f",ZB];
				[tmp setObject:clr forKey:@"color"];
				[clr release];
				[label addObject:tmp];
				[tmp release];
				
				tmp = [[NSMutableDictionary alloc] init];
				l = [[NSMutableString alloc] init];
				[l appendFormat:@"收:%.2f",close];
				[tmp setObject:l forKey:@"text"];
				[l release];
				 clr = [[NSMutableString alloc] init];
				if(close>open){
					[clr appendFormat:@"%f,",R];
					[clr appendFormat:@"%f,",G];
					[clr appendFormat:@"%f",B];
				}else if (close < open) {
					[clr appendFormat:@"%f,",NR];
					[clr appendFormat:@"%f,",NG];
					[clr appendFormat:@"%f",NB];
				}else{
					[clr appendFormat:@"%f,",ZR];
					[clr appendFormat:@"%f,",ZG];
					[clr appendFormat:@"%f",ZB];
				}
				[tmp setObject:clr forKey:@"color"];
				[clr release];
				[label addObject:tmp];
				[tmp release];
				
				tmp = [[NSMutableDictionary alloc] init];
				l = [[NSMutableString alloc] init];
				[l appendFormat:@"高:%.2f",high];
				[tmp setObject:l forKey:@"text"];
				[l release];
				 clr = [[NSMutableString alloc] init];
				if(high>open){
					[clr appendFormat:@"%f,",R];
					[clr appendFormat:@"%f,",G];
					[clr appendFormat:@"%f",B];
				}else{
					[clr appendFormat:@"%f,",ZR];
					[clr appendFormat:@"%f,",ZG];
					[clr appendFormat:@"%f",ZB];
				}
				[tmp setObject:clr forKey:@"color"];
				[clr release];
				[label addObject:tmp];
				[tmp release];

				tmp = [[NSMutableDictionary alloc] init];
				l = [[NSMutableString alloc] init];
				[l appendFormat:@"低:%.2f ",low];
				[tmp setObject:l forKey:@"text"];
				[l release];
				 clr = [[NSMutableString alloc] init];
				if(low>open){
					[clr appendFormat:@"%f,",R];
					[clr appendFormat:@"%f,",G];
					[clr appendFormat:@"%f",B];
				}else if(low<open){
					[clr appendFormat:@"%f,",NR];
					[clr appendFormat:@"%f,",NG];
					[clr appendFormat:@"%f",NB];
				}else{
					[clr appendFormat:@"%f,",ZR];
					[clr appendFormat:@"%f,",ZG];
					[clr appendFormat:@"%f",ZB];
				}
				
				[tmp setObject:clr forKey:@"color"];
				[clr release];
				[label addObject:tmp];
				[tmp release];

				
				tmp = [[NSMutableDictionary alloc] init];
				l = [[NSMutableString alloc] init];
				[l appendFormat:@"涨幅:%.2f%@  ",inc,@"%"];
				[tmp setObject:l forKey:@"text"];
				[l release];
				 clr = [[NSMutableString alloc] init];
				if(inc > 0){
					[clr appendFormat:@"%f,",R];
					[clr appendFormat:@"%f,",G];
					[clr appendFormat:@"%f",B];
				}else if(inc < 0){
					[clr appendFormat:@"%f,",NR];
					[clr appendFormat:@"%f,",NG];
					[clr appendFormat:@"%f",NB];
				}else{
					[clr appendFormat:@"%f,",ZR];
					[clr appendFormat:@"%f,",ZG];
					[clr appendFormat:@"%f",ZB];
				}
				
				[tmp setObject:clr forKey:@"color"];
				[clr release];
				[label addObject:tmp];
				[tmp release];
				
			}
	}	
	
	if([name isEqualToString:@"price"] && [type isEqualToString:@"line"]){
		NSString       *labelColor = [serie objectForKey:@"labelColor"];
	    NSString       *labelNegativeColor = [serie objectForKey:@"labelNegativeColor"];
		float LR   = [[[labelColor componentsSeparatedByString:@","] objectAtIndex:0] floatValue]/255;
		float LG   = [[[labelColor componentsSeparatedByString:@","] objectAtIndex:1] floatValue]/255;
		float LB   = [[[labelColor componentsSeparatedByString:@","] objectAtIndex:2] floatValue]/255;
		float LNR  = [[[labelNegativeColor componentsSeparatedByString:@","] objectAtIndex:0] floatValue]/255;
		float LNG  = [[[labelNegativeColor componentsSeparatedByString:@","] objectAtIndex:1] floatValue]/255;
		float LNB  = [[[labelNegativeColor componentsSeparatedByString:@","] objectAtIndex:2] floatValue]/255;
		
		if(self.selectedIndex!=-1 && self.selectedIndex < data.count && [data objectAtIndex:self.selectedIndex]!=nil){
			for(int i=0;i<label.count;i++){
			    NSMutableDictionary *tmp = [label objectAtIndex:i];
				if([[tmp objectForKey:@"text"] hasPrefix:@"价格"]){
				    [label removeObjectAtIndex:i];
					break;
				}
			}
			NSString *fmt = [@"%@:" stringByAppendingFormat:@"%@",format];
			
			float open  = [[[data objectAtIndex:0] objectAtIndex:0] floatValue];
			float value = [[[data objectAtIndex:self.selectedIndex] objectAtIndex:0] floatValue];
			float inc   = (value-open)*100/open;
			
			NSMutableDictionary *tmp = [[NSMutableDictionary alloc] init];
			NSMutableString *l = [[NSMutableString alloc] init];
			[l appendFormat:fmt,@"价格",value];
			[tmp setObject:l forKey:@"text"];
			[l release];
			NSMutableString *clr = [[NSMutableString alloc] init];
			[clr appendFormat:@"%f,",ZR];
			[clr appendFormat:@"%f,",ZG];
			[clr appendFormat:@"%f",ZB];
			[tmp setObject:clr forKey:@"color"];
			[clr release];
			[label addObject:tmp];
			[tmp release];
			
			tmp = [[NSMutableDictionary alloc] init];
			l = [[NSMutableString alloc] init];
			[l appendFormat:@"涨幅:%.2f%@  ",inc,@"%"];
			[tmp setObject:l forKey:@"text"];
			[l release];
			clr = [[NSMutableString alloc] init];
			if(inc > 0){
				[clr appendFormat:@"%f,",LR];
				[clr appendFormat:@"%f,",LG];
				[clr appendFormat:@"%f",LB];
			}else if(inc < 0){
				[clr appendFormat:@"%f,",LNR];
				[clr appendFormat:@"%f,",LNG];
				[clr appendFormat:@"%f",LNB];
			}else{
				[clr appendFormat:@"%f,",ZR];
				[clr appendFormat:@"%f,",ZG];
				[clr appendFormat:@"%f",ZB];
			}
			[tmp setObject:clr forKey:@"color"];
			[clr release];
			[label addObject:tmp];
			[tmp release];
		}
	}
}

-(void)drawSerie:(NSMutableDictionary *)serie{
	NSString *type  = [serie objectForKey:@"type"];
	NSString *name  = [serie objectForKey:@"name"];

	if ([name isEqualToString:@"price"]) {
		if([type isEqualToString:@"candle"]){
		    [serie setObject:@"176,52,52" forKey:@"color"];
		    [serie setObject:@"77,143,42" forKey:@"negativeColor"];
		    [serie setObject:@"176,52,52" forKey:@"selectedColor"];
	     	[serie setObject:@"77,143,42" forKey:@"negativeSelectedColor"];
	    }else{
	    	[serie setObject:@"249,222,170" forKey:@"color"];
	    	[serie setObject:@"249,222,170" forKey:@"negativeColor"];
	     	[serie setObject:@"249,222,170" forKey:@"selectedColor"];
	    	[serie setObject:@"249,222,170" forKey:@"negativeSelectedColor"];	
	    }
	}
	
	[super drawSerie:serie];
	
	
	if([type isEqualToString:@"candle"]){
		CGContextRef context = UIGraphicsGetCurrentContext();
		CGContextSetShouldAntialias(context, NO);
		CGContextSetLineWidth(context, 1.0f);
		
		NSMutableArray *data          = [serie objectForKey:@"data"];
		int            yAxis          = [[serie objectForKey:@"yAxis"] intValue];
		int            section        = [[serie objectForKey:@"section"] intValue];
		NSString       *color         = [serie objectForKey:@"color"];
		NSString       *negativeColor = [serie objectForKey:@"negativeColor"];
		NSString       *selectedColor = [serie objectForKey:@"selectedColor"];
		NSString       *negativeSelectedColor = [serie objectForKey:@"negativeSelectedColor"];
		
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
		for(int i=self.rangeFrom;i<self.rangeTo;i++){
			if(i == data.count){
				break;
			}
			if([data objectAtIndex:i] == nil){
			    continue;
			}
			
			float high  = [[[data objectAtIndex:i] objectAtIndex:2] floatValue];
			float low   = [[[data objectAtIndex:i] objectAtIndex:3] floatValue];
			float open  = [[[data objectAtIndex:i] objectAtIndex:0] floatValue];
			float close = [[[data objectAtIndex:i] objectAtIndex:1] floatValue];
			float ix  = sec.frame.origin.x+sec.paddingLeft+(i-self.rangeFrom)*plotWidth;
			float iNx = sec.frame.origin.x+sec.paddingLeft+(i+1-self.rangeFrom)*plotWidth;
			float iyo = [self getLocalY:open withSection:section withAxis:yAxis];
			float iyc = [self getLocalY:close withSection:section withAxis:yAxis];
			float iyh = [self getLocalY:high withSection:section withAxis:yAxis];
			float iyl = [self getLocalY:low withSection:section withAxis:yAxis];
			
			if(i == self.selectedIndex && self.selectedIndex < data.count && [data objectAtIndex:self.selectedIndex]!=nil){
				CGContextSetStrokeColorWithColor(context, [[UIColor alloc] initWithRed:0.2 green:0.2 blue:0.2 alpha:1.0].CGColor);
				CGContextMoveToPoint(context, ix+plotWidth/2, sec.frame.origin.y+sec.paddingTop);
				CGContextAddLineToPoint(context,ix+plotWidth/2,sec.frame.size.height+sec.frame.origin.y);
				CGContextStrokePath(context);
			}
			
			if(close == open){
				if(i == self.selectedIndex){
					CGContextSetStrokeColorWithColor(context, [[UIColor alloc] initWithRed:SR green:SG blue:SB alpha:1.0].CGColor);
				}else{
					CGContextSetStrokeColorWithColor(context, [[UIColor alloc] initWithRed:R green:G blue:B alpha:1.0].CGColor);
				}
			}else{
				if(close < open){
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
			}
			
			if(close == open){
				CGContextMoveToPoint(context, ix+plotPadding, iyo);
				CGContextAddLineToPoint(context, iNx-plotPadding,iyo);
				CGContextStrokePath(context);
				
			}else{
				if(close < open){
					CGContextFillRect (context, CGRectMake (ix+plotPadding, iyo, plotWidth-2*plotPadding,iyc-iyo)); 
				}else{
					CGContextFillRect (context, CGRectMake (ix+plotPadding, iyc, plotWidth-2*plotPadding, iyo-iyc)); 
				}
			}
			
			CGContextMoveToPoint(context, ix+plotWidth/2, iyh);
			CGContextAddLineToPoint(context,ix+plotWidth/2,iyl);
			CGContextStrokePath(context);
		}
	}	
}

-(void)drawTips:(NSMutableDictionary *)serie{
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSetShouldAntialias(context, NO);
	CGContextSetLineWidth(context, 1.0f);
	
	NSMutableArray *data          = [serie objectForKey:@"data"];
	NSString       *type          = [serie objectForKey:@"type"];
	NSString       *name          = [serie objectForKey:@"name"];
	int            section        = [[serie objectForKey:@"section"] intValue];
	NSMutableArray *category      = [serie objectForKey:@"category"];
	Section *sec = [self.sections objectAtIndex:section];
	
	if([type isEqualToString:@"candle"]){
		for(int i=self.rangeFrom;i<self.rangeTo;i++){
			if(i == data.count){
				break;
			}
			if([data objectAtIndex:i] == nil){
			    continue;
			}
			
			float ix  = sec.frame.origin.x+sec.paddingLeft+(i-self.rangeFrom)*plotWidth;
			
			if(i == self.selectedIndex && self.selectedIndex < data.count && [data objectAtIndex:self.selectedIndex]!=nil){
				
				CGContextSetShouldAntialias(context, YES);
				CGContextSetRGBFillColor(context, 0.2, 0.2, 0.2, 0.8); 
				CGSize size = [[category objectAtIndex:self.selectedIndex] sizeWithFont:[UIFont fontWithName:@"Helvetica" size:12.0]];
				
				int x = ix+plotWidth/2;
				int y = sec.frame.origin.y+sec.paddingTop;
				if(x+size.width > sec.frame.size.width+sec.frame.origin.x){
					x= x-(size.width+4);
				}
				CGContextFillRect (context, CGRectMake (x, y, size.width+4,size.height+2)); 
				CGContextSetRGBFillColor(context, 0.8, 0.8, 0.8, 1.0); 
				[[category objectAtIndex:self.selectedIndex] drawAtPoint:CGPointMake(x+2,y+1) withFont:[UIFont fontWithName:@"Helvetica" size:12.0]];
				CGContextSetShouldAntialias(context, NO);	
			}
		}
	}
	
	if([type isEqualToString:@"line"] && [name isEqualToString:@"price"]){
		for(int i=self.rangeFrom;i<self.rangeTo;i++){
			if(i == data.count){
				break;
			}
			if([data objectAtIndex:i] == nil){
			    continue;
			}
			
			float ix  = sec.frame.origin.x+sec.paddingLeft+(i-self.rangeFrom)*plotWidth;
			
			if(i == self.selectedIndex && self.selectedIndex < data.count && [data objectAtIndex:self.selectedIndex]!=nil){
				
				CGContextSetShouldAntialias(context, YES);
				CGContextSetRGBFillColor(context, 0.2, 0.2, 0.2, 0.8); 
				CGSize size = [[category objectAtIndex:self.selectedIndex] sizeWithFont:[UIFont fontWithName:@"Helvetica" size:12.0]];
				
				int x = ix+plotWidth/2;
				int y = sec.frame.origin.y+sec.paddingTop;
				if(x+size.width > sec.frame.size.width+sec.frame.origin.x){
					x = x-(size.width+4);
				}
				CGContextFillRect (context, CGRectMake (x, y, size.width+4,size.height+2)); 
				CGContextSetRGBFillColor(context, 0.8, 0.8, 0.8, 1.0); 
				[[category objectAtIndex:self.selectedIndex] drawAtPoint:CGPointMake(x+2,y+1) withFont:[UIFont fontWithName:@"Helvetica" size:12.0]];
				CGContextSetShouldAntialias(context, NO);	
			}
		}
	}
	
}

-(void)drawChart{
	[super drawChart];
	[self drawSideBar];
}

- (void)dealloc {
    [super dealloc];
}

@end
