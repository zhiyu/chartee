//
//  CandleChartModel.m
//  chartee
//
//  Created by zzy on 5/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CandleChartModel.h"

@implementation CandleChartModel

-(void)drawSerie:(Chart *)chart serie:(NSMutableDictionary *)serie{
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
    
    Section *sec = [chart.sections objectAtIndex:section];
    for(int i=chart.rangeFrom;i<chart.rangeTo;i++){
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
        
        float ix  = sec.frame.origin.x+sec.paddingLeft+(i-chart.rangeFrom)*chart.plotWidth;
        float iNx = sec.frame.origin.x+sec.paddingLeft+(i+1-chart.rangeFrom)*chart.plotWidth;
        float iyo = [chart getLocalY:open withSection:section withAxis:yAxis];
        float iyc = [chart getLocalY:close withSection:section withAxis:yAxis];
        float iyh = [chart getLocalY:high withSection:section withAxis:yAxis];
        float iyl = [chart getLocalY:low withSection:section withAxis:yAxis];
        
        if(i == chart.selectedIndex && chart.selectedIndex < data.count && [data objectAtIndex:chart.selectedIndex]!=nil){
            CGContextSetStrokeColorWithColor(context, [[UIColor alloc] initWithRed:0.2 green:0.2 blue:0.2 alpha:1.0].CGColor);
            CGContextMoveToPoint(context, ix+chart.plotWidth/2, sec.frame.origin.y+sec.paddingTop);
            CGContextAddLineToPoint(context,ix+chart.plotWidth/2,sec.frame.size.height+sec.frame.origin.y);
            CGContextStrokePath(context);
        }
        
        if(close == open){
            if(i == chart.selectedIndex){
                CGContextSetStrokeColorWithColor(context, [[UIColor alloc] initWithRed:SR green:SG blue:SB alpha:1.0].CGColor);
            }else{
                CGContextSetStrokeColorWithColor(context, [[UIColor alloc] initWithRed:R green:G blue:B alpha:1.0].CGColor);
            }
        }else{
            if(close < open){
                if(i == chart.selectedIndex){
                    CGContextSetStrokeColorWithColor(context, [[UIColor alloc] initWithRed:NSR green:NSG blue:NSB alpha:1.0].CGColor);
                    CGContextSetRGBFillColor(context, NSR, NSG, NSB, 1.0); 
                }else{
                    CGContextSetStrokeColorWithColor(context, [[UIColor alloc] initWithRed:NR green:NG blue:NB alpha:1.0].CGColor);
                    CGContextSetRGBFillColor(context, NR, NG, NB, 1.0); 
                }
            }else{
                if(i == chart.selectedIndex){
                    CGContextSetStrokeColorWithColor(context, [[UIColor alloc] initWithRed:SR green:SG blue:SB alpha:1.0].CGColor);
                    CGContextSetRGBFillColor(context, SR, SG, SB, 1.0); 
                }else{
                    CGContextSetStrokeColorWithColor(context, [[UIColor alloc] initWithRed:R green:G blue:B alpha:1.0].CGColor);
                    CGContextSetRGBFillColor(context, R, G, B, 1.0); 
                } 
            }
        }
        
        if(close == open){
            CGContextMoveToPoint(context, ix+chart.plotPadding, iyo);
            CGContextAddLineToPoint(context, iNx-chart.plotPadding,iyo);
            CGContextStrokePath(context);
            
        }else{
            if(close < open){
                CGContextFillRect (context, CGRectMake (ix+chart.plotPadding, iyo, chart.plotWidth-2*chart.plotPadding,iyc-iyo)); 
            }else{
                CGContextFillRect (context, CGRectMake (ix+chart.plotPadding, iyc, chart.plotWidth-2*chart.plotPadding, iyo-iyc)); 
            }
        }
        
        CGContextMoveToPoint(context, ix+chart.plotWidth/2, iyh);
        CGContextAddLineToPoint(context,ix+chart.plotWidth/2,iyl);
        CGContextStrokePath(context);
    }
}

-(void)setValuesForYAxis:(Chart *)chart serie:(NSDictionary *)serie{
    if([[serie objectForKey:@"data"] count] == 0){
		return;
	}
	
	NSMutableArray *data    = [serie objectForKey:@"data"];
	NSString       *yAxis   = [serie objectForKey:@"yAxis"];
	NSString       *section = [serie objectForKey:@"section"];
	
	YAxis *yaxis = [[[chart.sections objectAtIndex:[section intValue]] yAxises] objectAtIndex:[yAxis intValue]];
	
	
    float high = [[[data objectAtIndex:chart.rangeFrom] objectAtIndex:2] floatValue];
    float low = [[[data objectAtIndex:chart.rangeFrom] objectAtIndex:3] floatValue];
    
    if(!yaxis.isUsed){
        [yaxis setMax:high];
        [yaxis setMin:low];
        yaxis.isUsed = YES;
    }
    
    for(int i=chart.rangeFrom;i<chart.rangeTo;i++){
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

-(void)setLabel:(Chart *)chart label:(NSMutableArray *)label forSerie:(NSMutableDictionary *) serie{

}

@end
