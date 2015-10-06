//
//  ColumnChartModel.m
//  chartee
//
//  Created by zzy on 5/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ColumnChartModel.h"

@implementation ColumnChartModel

-(void)drawSerie:(Chart *)chart serie:(NSMutableDictionary *)serie{
    if(serie[@"data"] == nil || [serie[@"data"] count] == 0){
	    return;
	}

	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSetShouldAntialias(context, YES);
	CGContextSetLineWidth(context, 1.0f);

	NSMutableArray *data          = serie[@"data"];
	int            yAxis          = [serie[@"yAxis"] intValue];
	int            section        = [serie[@"section"] intValue];
	NSString       *color         = serie[@"color"];
	NSString       *negativeColor = serie[@"negativeColor"];
	NSString       *selectedColor = serie[@"selectedColor"];
	NSString       *negativeSelectedColor = serie[@"negativeSelectedColor"];

	YAxis *yaxis = [[chart.sections objectAtIndex:section] yAxises][yAxis];

	float R   = [[color componentsSeparatedByString:@","][0] floatValue]/255;
	float G   = [[color componentsSeparatedByString:@","][1] floatValue]/255;
	float B   = [[color componentsSeparatedByString:@","][2] floatValue]/255;
	float NR  = [[negativeColor componentsSeparatedByString:@","][0] floatValue]/255;
	float NG  = [[negativeColor componentsSeparatedByString:@","][1] floatValue]/255;
	float NB  = [[negativeColor componentsSeparatedByString:@","][2] floatValue]/255;
	float SR  = [[selectedColor componentsSeparatedByString:@","][0] floatValue]/255;
	float SG  = [[selectedColor componentsSeparatedByString:@","][1] floatValue]/255;
	float SB  = [[selectedColor componentsSeparatedByString:@","][2] floatValue]/255;
	float NSR = [[negativeSelectedColor componentsSeparatedByString:@","][0] floatValue]/255;
	float NSG = [[negativeSelectedColor componentsSeparatedByString:@","][1] floatValue]/255;
	float NSB = [[negativeSelectedColor componentsSeparatedByString:@","][2] floatValue]/255;

	Section *sec = chart.sections[section];

    if(chart.selectedIndex!=-1 && chart.selectedIndex < data.count && data[chart.selectedIndex] !=nil){
        float value = [[data[chart.selectedIndex] objectAtIndex:0] floatValue];
        CGContextSetStrokeColorWithColor(context, [[UIColor alloc] initWithRed:0.2 green:0.2 blue:0.2 alpha:1.0].CGColor);
        CGContextMoveToPoint(context, sec.frame.origin.x+sec.paddingLeft+(chart.selectedIndex-chart.rangeFrom)*chart.plotWidth+chart.plotWidth/2, sec.frame.origin.y+sec.paddingTop);
        CGContextAddLineToPoint(context,sec.frame.origin.x+sec.paddingLeft+(chart.selectedIndex-chart.rangeFrom)*chart.plotWidth+chart.plotWidth/2,sec.frame.size.height+sec.frame.origin.y);
        CGContextStrokePath(context);

        CGContextSetShouldAntialias(context, YES);
        CGContextBeginPath(context);
        CGContextSetRGBFillColor(context, R, G, B, 1.0);
        if(!isnan([chart getLocalY:value withSection:section withAxis:yAxis])){
            CGContextAddArc(context, sec.frame.origin.x+sec.paddingLeft+(chart.selectedIndex-chart.rangeFrom)*chart.plotWidth+chart.plotWidth/2, [chart getLocalY:value withSection:section withAxis:yAxis], 3, 0, 2*M_PI, 1);
        }
        CGContextFillPath(context);
    }

    CGContextSetShouldAntialias(context, NO);
    for(int i=chart.rangeFrom;i<chart.rangeTo;i++){
        if(i == data.count){
            break;
        }
        if(data[i] == nil){
            continue;
        }

        float value = [[data[i] objectAtIndex:0] floatValue];
        float ix  = sec.frame.origin.x+sec.paddingLeft+(i-chart.rangeFrom)*chart.plotWidth;
        float iy = [chart getLocalY:value withSection:section withAxis:yAxis];

        if(value < yaxis.baseValue){
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


        CGContextFillRect (context, CGRectMake (ix+chart.plotPadding, iy, chart.plotWidth-2*chart.plotPadding,[chart getLocalY:yaxis.baseValue withSection:section withAxis:yAxis]-iy));
    }

}

-(void)setValuesForYAxis:(Chart *)chart serie:(NSDictionary *)serie{
    if([serie[@"data"] count] == 0){
		return;
	}

	NSMutableArray *data    = serie[@"data"];
	NSString       *yAxis   = serie[@"yAxis"];
	NSString       *section = serie[@"section"];

	YAxis *yaxis = [[chart.sections objectAtIndex:[section intValue]] yAxises][[yAxis intValue]];
	if(serie[@"decimal"] != nil){
		yaxis.decimal = [serie[@"decimal"] intValue];
	}

	float value = [[data[chart.rangeFrom] objectAtIndex:0] floatValue];
	if(!yaxis.isUsed){
        [yaxis setMax:value];
        [yaxis setMin:value];
        yaxis.isUsed = YES;
    }
    for(int i=chart.rangeFrom;i<chart.rangeTo;i++){
        if(i == data.count){
            break;
        }
        if(data[i] == nil){
            continue;
        }

        float value = [[data[i] objectAtIndex:0] floatValue];
        if(value > [yaxis max])
            [yaxis setMax:value];
        if(value < [yaxis min])
            [yaxis setMin:value];
    }

}

-(void)setLabel:(Chart *)chart label:(NSMutableArray *)label forSerie:(NSMutableDictionary *) serie{
    if(serie[@"data"] == nil || [serie[@"data"] count] == 0){
	    return;
	}

	NSMutableArray *data          = serie[@"data"];
	NSString       *lbl           = serie[@"label"];
	int            yAxis          = [serie[@"yAxis"] intValue];
	int            section        = [serie[@"section"] intValue];
	NSString       *color         = serie[@"color"];

	YAxis *yaxis = [[chart.sections objectAtIndex:section] yAxises][yAxis];
	NSString *format=[@"%." stringByAppendingFormat:@"%df",yaxis.decimal];

	float R   = [[color componentsSeparatedByString:@","][0] floatValue]/255;
	float G   = [[color componentsSeparatedByString:@","][1] floatValue]/255;
	float B   = [[color componentsSeparatedByString:@","][2] floatValue]/255;

    if(chart.selectedIndex!=-1 && chart.selectedIndex < data.count && data[chart.selectedIndex] !=nil){
        float value = [[data[chart.selectedIndex] objectAtIndex:0] floatValue];
        NSMutableDictionary *tmp = [[NSMutableDictionary alloc] init];
        NSMutableString *l = [[NSMutableString alloc] init];
        NSString *fmt = [@"%@:" stringByAppendingFormat:@"%@",format];
        [l appendFormat:fmt,lbl,value];
        tmp[@"text"] = l;

        NSMutableString *clr = [[NSMutableString alloc] init];
        [clr appendFormat:@"%f,",R];
        [clr appendFormat:@"%f,",G];
        [clr appendFormat:@"%f",B];
        tmp[@"color"] = clr;

        [label addObject:tmp];
    }
}

@end
