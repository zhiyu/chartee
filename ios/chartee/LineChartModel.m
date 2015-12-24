//
//  LineChartModel.m
//  chartee
//
//  Created by zzy on 5/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LineChartModel.h"

@implementation LineChartModel

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

	float R   = [[color componentsSeparatedByString:@","][0] floatValue]/255;
	float G   = [[color componentsSeparatedByString:@","][1] floatValue]/255;
	float B   = [[color componentsSeparatedByString:@","][2] floatValue]/255;

	Section *sec = chart.sections[section];

    if(chart.selectedIndex!=-1 && chart.selectedIndex < data.count && data[chart.selectedIndex] !=nil){
        float value = [[data[chart.selectedIndex] objectAtIndex:0] floatValue];
        CGContextSetShouldAntialias(context, NO);
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

    CGContextSetShouldAntialias(context, YES);
    for(int i=chart.rangeFrom;i<chart.rangeTo;i++){
        if(i == data.count-1){
            break;
        }
        if(data[i] == nil){
            continue;
        }
        if (i<chart.rangeTo-1 && data[i + 1] != nil) {
            float value = [[data[i] objectAtIndex:0] floatValue];
            float ix  = sec.frame.origin.x+sec.paddingLeft+(i-chart.rangeFrom)*chart.plotWidth;
            float iNx  = sec.frame.origin.x+sec.paddingLeft+(i+1-chart.rangeFrom)*chart.plotWidth;
            float iy = [chart getLocalY:value withSection:section withAxis:yAxis];
            CGContextSetStrokeColorWithColor(context, [[UIColor alloc] initWithRed:R green:G blue:B alpha:1.0].CGColor);
            CGContextMoveToPoint(context, ix+chart.plotWidth/2, iy);

            float y = [chart getLocalY:([[data[i + 1] objectAtIndex:0] floatValue]) withSection:section withAxis:yAxis];
            if(!isnan(y)){
                CGContextAddLineToPoint(context, iNx+chart.plotWidth/2, y);
            }

            CGContextStrokePath(context);
        }
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
	NSString       *type          = serie[@"type"];
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
