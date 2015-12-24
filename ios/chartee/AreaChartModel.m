//
//  AreaChartModel.m
//  chartee
//
//  Created by zzy on 5/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AreaChartModel.h"

@implementation AreaChartModel

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

	YAxis *yaxis = [[chart.sections objectAtIndex:section] yAxises][yAxis];

	float R   = [[color componentsSeparatedByString:@","][0] floatValue]/255;
	float G   = [[color componentsSeparatedByString:@","][1] floatValue]/255;
	float B   = [[color componentsSeparatedByString:@","][2] floatValue]/255;
	float NR  = [[negativeColor componentsSeparatedByString:@","][0] floatValue]/255;
	float NG  = [[negativeColor componentsSeparatedByString:@","][1] floatValue]/255;
	float NB  = [[negativeColor componentsSeparatedByString:@","][2] floatValue]/255;

	Section *sec = chart.sections[section];


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

    float iBy = [chart getLocalY:yaxis.baseValue withSection:section withAxis:yAxis];

    if(chart.selectedIndex!=-1 && chart.selectedIndex < data.count && data[chart.selectedIndex] !=nil){
        float value = [[data[chart.selectedIndex] objectAtIndex:0] floatValue];
        if(value>=yaxis.baseValue){
            CGContextSetRGBFillColor(context, R, G, B, 1.0);
        }else{
            CGContextSetRGBFillColor(context, NR, NG, NB, 1.0);
        }

        CGContextSetShouldAntialias(context, NO);
        CGContextSetStrokeColorWithColor(context, [[UIColor alloc] initWithRed:0.2 green:0.2 blue:0.2 alpha:1.0].CGColor);
        CGContextMoveToPoint(context, sec.frame.origin.x+sec.paddingLeft+(chart.selectedIndex-chart.rangeFrom)*chart.plotWidth+chart.plotWidth/2, sec.frame.origin.y+sec.paddingTop);
        CGContextAddLineToPoint(context,sec.frame.origin.x+sec.paddingLeft+(chart.selectedIndex-chart.rangeFrom)*chart.plotWidth+chart.plotWidth/2,sec.frame.size.height+sec.frame.origin.y);
        CGContextStrokePath(context);

        CGContextSetShouldAntialias(context, YES);
        CGContextBeginPath(context);
        CGContextAddArc(context, sec.frame.origin.x+sec.paddingLeft+(chart.selectedIndex-chart.rangeFrom)*chart.plotWidth+chart.plotWidth/2, [chart getLocalY:value withSection:section withAxis:yAxis], 3, 0, 2*M_PI, 1);
        CGContextFillPath(context);
    }

    CGContextSetShouldAntialias(context, YES);
    /*
     Start:drawing positive values
     */
    CGContextBeginPath(context);
    CGContextSetRGBFillColor(context, R, G, B, 1.0);
    for(int i=chart.rangeFrom;i<chart.rangeTo;i++){
        if(i == data.count-1){
            break;
        }
        if(data[i] == nil){
            continue;
        }

        float value = [[data[i] objectAtIndex:0] floatValue];

        if(value >= yaxis.baseValue){
            ix  = sec.frame.origin.x+sec.paddingLeft+(i-chart.rangeFrom)*chart.plotWidth;
            iy = [chart getLocalY:value withSection:section withAxis:yAxis];

            if(found == 0){
                found = 1;
                if(i==chart.rangeFrom){
                    CGContextMoveToPoint(context, ix+chart.plotWidth/2, iy);
                    startPoint = CGPointMake(ix+chart.plotWidth/2, iy);
                }else if(i>chart.rangeFrom){
                    prevValue = [[data[i - 1] objectAtIndex:0] floatValue];
                    iPx = sec.frame.origin.x+sec.paddingLeft+(i-1-chart.rangeFrom)*chart.plotWidth;
                    iPy = [chart getLocalY:prevValue withSection:section withAxis:yAxis];
                    if(prevValue < yaxis.baseValue){
                        float baseX = (yaxis.baseValue-prevValue)*chart.plotWidth/(value-prevValue)+(sec.frame.origin.x+sec.paddingLeft+(i-1-chart.rangeFrom)*chart.plotWidth+chart.plotWidth/2);
                        CGContextMoveToPoint(context, baseX,iBy);
                        CGContextAddLineToPoint(context, ix+chart.plotWidth/2, iy);
                        startPoint = CGPointMake(baseX, iBy);
                        endPoint = CGPointMake(ix+chart.plotWidth/2,iy);
                    }
                }
            }else if(i>chart.rangeFrom){
                prevValue = [[data[i - 1] objectAtIndex:0] floatValue];
                iPx = sec.frame.origin.x+sec.paddingLeft+(i-1-chart.rangeFrom)*chart.plotWidth;
                iPy = [chart getLocalY:prevValue withSection:section withAxis:yAxis];
                if(prevValue < yaxis.baseValue){
                    float baseX = (yaxis.baseValue-prevValue)*chart.plotWidth/(value-prevValue)+(sec.frame.origin.x+sec.paddingLeft+(i-1-chart.rangeFrom)*chart.plotWidth+chart.plotWidth/2);
                    CGContextAddLineToPoint(context, baseX,iBy);
                    CGContextAddLineToPoint(context, ix+chart.plotWidth/2,iy);
                    endPoint = CGPointMake(ix+chart.plotWidth/2,iy);
                }
            }

            if (i < chart.rangeTo-1  && data[i + 1] != nil) {
                nextValue = [[data[i + 1] objectAtIndex:0] floatValue];
                iNx = sec.frame.origin.x+sec.paddingLeft+(i+1-chart.rangeFrom)*chart.plotWidth;
                iNy = [chart getLocalY:nextValue withSection:section withAxis:yAxis];

                if(nextValue < yaxis.baseValue){
                    float baseX = (value-yaxis.baseValue)*chart.plotWidth/(value-nextValue)+(sec.frame.origin.x+sec.paddingLeft+(i-chart.rangeFrom)*chart.plotWidth+chart.plotWidth/2);
                    CGContextAddLineToPoint(context, baseX,iBy);
                    endPoint = CGPointMake(baseX, iBy);
                }else{
                    CGContextAddLineToPoint(context, iNx+chart.plotWidth/2,iNy);
                    endPoint = CGPointMake(iNx+chart.plotWidth/2,iNy);
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
    for(int i=chart.rangeFrom;i<chart.rangeTo;i++){
        if(i == data.count-1){
            break;
        }
        if(data[i] == nil){
            continue;
        }

        float value = [[data[i] objectAtIndex:0] floatValue];
        if(value < yaxis.baseValue){
            ix  = sec.frame.origin.x+sec.paddingLeft+(i-chart.rangeFrom)*chart.plotWidth;
            iy = [chart getLocalY:value withSection:section withAxis:yAxis];

            if(found == 0){
                found = 1;
                if(i==chart.rangeFrom){
                    CGContextMoveToPoint(context, ix+chart.plotWidth/2, iy);
                    startPoint = CGPointMake(ix+chart.plotWidth/2, iy);
                }else if(i>chart.rangeFrom){
                    prevValue = [[data[i - 1] objectAtIndex:0] floatValue];
                    iPx = sec.frame.origin.x+sec.paddingLeft+(i-1-chart.rangeFrom)*chart.plotWidth;
                    iPy = [chart getLocalY:prevValue withSection:section withAxis:yAxis];
                    if(prevValue > yaxis.baseValue){
                        float baseX = (prevValue-yaxis.baseValue)*chart.plotWidth/(prevValue-value)+(sec.frame.origin.x+sec.paddingLeft+(i-1-chart.rangeFrom)*chart.plotWidth+chart.plotWidth/2);
                        CGContextMoveToPoint(context, baseX,iBy);
                        CGContextAddLineToPoint(context, ix+chart.plotWidth/2, iy);
                        startPoint = CGPointMake(baseX, iBy);
                        endPoint = CGPointMake(ix+chart.plotWidth/2,iy);
                    }
                }
            }else if(i>chart.rangeFrom){
                prevValue = [[data[i - 1] objectAtIndex:0] floatValue];
                iPx = sec.frame.origin.x+sec.paddingLeft+(i-1-chart.rangeFrom)*chart.plotWidth;
                iPy = [chart getLocalY:prevValue withSection:section withAxis:yAxis];
                if(prevValue > yaxis.baseValue){
                    float baseX = (prevValue-yaxis.baseValue)*chart.plotWidth/(prevValue-value)+(sec.frame.origin.x+sec.paddingLeft+(i-1-chart.rangeFrom)*chart.plotWidth+chart.plotWidth/2);
                    CGContextAddLineToPoint(context, baseX,iBy);
                    CGContextAddLineToPoint(context, ix+chart.plotWidth/2,iy);
                    endPoint = CGPointMake(ix+chart.plotWidth/2,iy);
                }
            }

            if (i < chart.rangeTo-1 && data[i + 1] != nil) {
                nextValue = [[data[i + 1] objectAtIndex:0] floatValue];
                iNx = sec.frame.origin.x+sec.paddingLeft+(i+1-chart.rangeFrom)*chart.plotWidth;
                iNy = [chart getLocalY:nextValue withSection:section withAxis:yAxis];
                if(nextValue > yaxis.baseValue){
                    float baseX = (yaxis.baseValue-value)*chart.plotWidth/(nextValue-value)+(sec.frame.origin.x+sec.paddingLeft+(i-chart.rangeFrom)*chart.plotWidth+chart.plotWidth/2);
                    CGContextAddLineToPoint(context, baseX,iBy);
                    endPoint = CGPointMake(baseX, iBy);
                }else{
                    CGContextAddLineToPoint(context, iNx+chart.plotWidth/2,iNy);
                    endPoint = CGPointMake(iNx+chart.plotWidth/2,iNy);
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
