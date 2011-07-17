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
    return fra.size.height - (fra.size.height-yaxis.paddingTop) * (val-min)/(max-min)+fra.origin.y;
}

- (void)initChart{
	if(!self.isInitialized){
		self.plotPadding = 2.0f;
		self.rangeTo = [[[[self series] objectAtIndex:0] objectForKey:@"data"] count];
		self.plotCount = self.rangeTo;

		if(rangeTo-range >= 0){
			self.rangeFrom = rangeTo-range;
		}
		if(self.padding != nil){
			self.paddingTop    = [[self.padding objectAtIndex:0] floatValue];
			self.paddingRight  = [[self.padding objectAtIndex:1] floatValue];
			self.paddingBottom = [[self.padding objectAtIndex:2] floatValue];
			self.paddingLeft   = [[self.padding objectAtIndex:3] floatValue];
		}
		self.isInitialized = YES;
	}
}

- (void)initXAxis{

}

- (void)initYAxis{
	for(int secIndex=0;secIndex<[self.sections count];secIndex++){
		Section *sec = [self.sections objectAtIndex:secIndex];
		
		for(int sIndex=0;sIndex<[sec.series count];sIndex++){
			NSObject *serie = [[sec series] objectAtIndex:sIndex];
			if(sec.paging){
				if(sec.selectedIndex == sIndex){
					if([serie isKindOfClass:[NSArray class]]){
						for(int i=0;i<[serie count];i++){
							[self initYAxisWithSerie:[serie objectAtIndex:i]];
						}
					}else {
						[self initYAxisWithSerie:serie];
					}
				}
			}else{
		        [self initYAxisWithSerie:serie];
			}
		}
	}
}

-(void)initYAxisWithSerie:(NSDictionary *)serie{
	NSMutableArray *data    = [serie objectForKey:@"data"];
	NSString       *type    = [serie objectForKey:@"type"];
	NSString       *yAxis   = [serie objectForKey:@"yAxis"];
	NSString       *section = [serie objectForKey:@"section"];
	
	YAxis *yaxis = [[[self.sections objectAtIndex:[section intValue]] yAxises] objectAtIndex:[yAxis intValue]];
	
	if([type isEqual:@"column"]){
		if(![yaxis isInitialized]){
			float value = [[[data objectAtIndex:0] objectAtIndex:0] floatValue];
		    [yaxis setMax:value];
			[yaxis setMin:value];
			[yaxis setIsInitialized:YES];
		}
		for(int i=self.rangeFrom;i<self.rangeTo;i++){
			float value = [[[data objectAtIndex:i] objectAtIndex:0] floatValue];
			if(value > [yaxis max])
				[yaxis setMax:value];
			if(value < [yaxis min])
				[yaxis setMin:value];
		}
	}else if([type isEqual:@"line"]){
		if(![yaxis isInitialized]){
			float value = [[[data objectAtIndex:0] objectAtIndex:0] floatValue];
		    [yaxis setMax:value];
			[yaxis setMin:value];
			[yaxis setIsInitialized:YES];
		}
		for(int i=self.rangeFrom;i<self.rangeTo;i++){
			float value = [[[data objectAtIndex:i] objectAtIndex:0] floatValue];
			if(value > [yaxis max])
				[yaxis setMax:value];
			if(value < [yaxis min])
				[yaxis setMin:value];
		}
	}else if([type isEqual:@"area"]){
		if(![yaxis isInitialized]){
			float value = [[[data objectAtIndex:0] objectAtIndex:0] floatValue];
		    [yaxis setMax:value];
			[yaxis setMin:value];
			[yaxis setIsInitialized:YES];
		}
		for(int i=self.rangeFrom;i<self.rangeTo;i++){
			float value = [[[data objectAtIndex:i] objectAtIndex:0] floatValue];
			if(value > [yaxis max])
				[yaxis setMax:value];
			if(value < [yaxis min])
				[yaxis setMin:value];
		}
	}
	
}

-(void)drawChart{
	
	
	NSMutableArray  *labels = [[NSMutableArray alloc] init];
	for(int secIndex=0;secIndex<self.sections.count;secIndex++){
		NSMutableArray *label  = [[NSMutableArray alloc] init];
		[labels addObject:label];
		[label release];
		
		Section *sec = [self.sections objectAtIndex:secIndex];
		plotWidth = (sec.frame.size.width-sec.paddingLeft)/(self.rangeTo-self.rangeFrom);
		
		for(int sIndex=0;sIndex<sec.series.count;sIndex++){
			NSObject *serie = [sec.series objectAtIndex:sIndex];
			if(sec.paging){
				if (sec.selectedIndex == sIndex) {
					if([serie isKindOfClass:[NSArray class]]){
						for(int i=0;i<[serie count];i++){
							[self drawSerie:[serie objectAtIndex:i] withLabels:labels];
						}
					}else{
						[self drawSerie:serie withLabels:labels];
					}
					break;
				}
			}else{
				if([serie isKindOfClass:[NSArray class]]){
					for(int i=0;i<[serie count];i++){
						[self drawSerie:[serie objectAtIndex:i] withLabels:labels];
					}
				}else{
					[self drawSerie:serie withLabels:labels];
				}
			}			
		}
	}	
	
	for(int i=0;i<labels.count;i++){
		Section *sec = [self.sections objectAtIndex:i];
		NSMutableArray *label = [labels objectAtIndex:i];
		float w = 0;
		for(int j=0;j<label.count;j++){
			NSMutableDictionary *lbl = [label objectAtIndex:j];
			NSString *text  = [lbl objectForKey:@"text"];
			NSString *color = [lbl objectForKey:@"color"];
			NSArray *colors = [color componentsSeparatedByString:@","];
			CGContextRef context = UIGraphicsGetCurrentContext();
			CGContextSetRGBFillColor(context, [[colors objectAtIndex:0] floatValue], [[colors objectAtIndex:1] floatValue], [[colors objectAtIndex:2] floatValue], 1.0);
			[text drawAtPoint:CGPointMake(sec.paddingLeft+2+w,sec.frame.origin.y) withFont:[UIFont systemFontOfSize: 12]];
			w+=[text sizeWithFont:[UIFont systemFontOfSize:12]].width;
		}
	}
	[labels release];
}

-(void)drawSerie:(NSMutableDictionary *)serie withLabels:(NSMutableArray *)labels{
	CGContextRef context = UIGraphicsGetCurrentContext();
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
	
	if([type isEqual:@"column"]){
		for(int i=self.rangeFrom;i<self.rangeTo;i++){
			float value = [[[data objectAtIndex:i] objectAtIndex:0] floatValue];
			
			float ix  = sec.paddingLeft+(i-self.rangeFrom)*plotWidth;
			float iy = [self getLocalY:value withSection:section withAxis:yAxis];
			
			if(value < 0){
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
			CGContextFillRect (context, CGRectMake (ix, iy, plotWidth,[self getLocalY:0 withSection:section withAxis:yAxis]-iy)); 
		}
		
		if(self.selectedIndex!=-1){
			float value = [[[data objectAtIndex:self.selectedIndex] objectAtIndex:0] floatValue];
			NSMutableDictionary *lbl = [[NSMutableDictionary alloc] init];
			NSMutableString *l = [[NSMutableString alloc] init];
			[l appendFormat:@"%@:%.2f ",label,value];
			[lbl setObject:l forKey:@"text"];
			[l release];
			
			NSMutableString *clr = [[NSMutableString alloc] init];
			[clr appendFormat:@"%f,",R];
			[clr appendFormat:@"%f,",G];
			[clr appendFormat:@"%f",B];
			[lbl setObject:clr forKey:@"color"];
			[clr release];

			[[labels objectAtIndex:section] addObject:lbl];
			[lbl release];
		}
		
	}else if([type isEqual:@"line"]){
		for(int i=self.rangeFrom;i<self.rangeTo;i++){
			float value = [[[data objectAtIndex:i] objectAtIndex:0] floatValue];
			float ix  = sec.paddingLeft+(i-self.rangeFrom)*plotWidth;
			float iNx  = sec.paddingLeft+(i+1-self.rangeFrom)*plotWidth;
			float iy = [self getLocalY:value withSection:section withAxis:yAxis];
			
			if ((i-self.rangeFrom)<(self.rangeTo-self.rangeFrom)-1) {
				CGContextSetStrokeColorWithColor(context, [[UIColor alloc] initWithRed:R green:G blue:B alpha:1.0].CGColor);
				CGContextMoveToPoint(context, ix+plotWidth/2, iy);
				CGContextAddLineToPoint(context, iNx+plotWidth/2,[self getLocalY:([[[data objectAtIndex:(i+1)] objectAtIndex:0] floatValue]) withSection:section withAxis:yAxis]);
				CGContextStrokePath(context);
			}	
		}
		
		if(self.selectedIndex!=-1){
			float value = [[[data objectAtIndex:self.selectedIndex] objectAtIndex:0] floatValue];
			NSMutableDictionary *lbl = [[NSMutableDictionary alloc] init];
			NSMutableString *l = [[NSMutableString alloc] init];
			[l appendFormat:@"%@:%.2f ",label,value];
			[lbl setObject:l forKey:@"text"];
			[l release];
			
			NSMutableString *clr = [[NSMutableString alloc] init];
			[clr appendFormat:@"%f,",R];
			[clr appendFormat:@"%f,",G];
			[clr appendFormat:@"%f",B];
			[lbl setObject:clr forKey:@"color"];
			[clr release];
			
			[[labels objectAtIndex:section] addObject:lbl];
			[lbl release];
			
			CGContextBeginPath(context); 
			CGContextSetRGBFillColor(context, R, G, B, 1.0);
			CGContextAddArc(context, sec.paddingLeft+(self.selectedIndex-self.rangeFrom)*plotWidth+plotWidth/2, [self getLocalY:value withSection:section withAxis:yAxis], 2, 0, 2*M_PI, 1);
			CGContextFillPath(context); 
		}
	}else if([type isEqual:@"spline"]){
		
	}else if([type isEqual:@"area"]){
		for(int i=self.rangeFrom;i<self.rangeTo;i++){
			float value = [[[data objectAtIndex:i] objectAtIndex:0] floatValue];
			
			float ix  = sec.paddingLeft+(i-self.rangeFrom)*plotWidth;
			float iNx = sec.paddingLeft+(i+1-self.rangeFrom)*plotWidth;
			
			
			
			if (i < self.rangeTo-1) {
				float nextValue = [[[data objectAtIndex:(i+1)] objectAtIndex:0] floatValue];
				float baseValue = 0; 
				
				if([[yAxises objectAtIndex:yAxis] min] >= 0  && [[yAxises objectAtIndex:yAxis] max] >= 0){
					baseValue = [[yAxises objectAtIndex:yAxis] min];
				}else if([[yAxises objectAtIndex:yAxis] min] <= 0  && [[yAxises objectAtIndex:yAxis] max] <= 0){
					baseValue = [[yAxises objectAtIndex:yAxis] max]; 
				}else{
					baseValue = 0; 
				}
				
				float iy = [self getLocalY:value withSection:section withAxis:yAxis];
				float iNy = [self getLocalY:nextValue withSection:section withAxis:yAxis];
				float iBy = [self getLocalY:baseValue withSection:section withAxis:yAxis];
				
				if(value <= 0 && nextValue <= 0){
					CGContextBeginPath(context);
					CGContextSetRGBFillColor(context, NR, NG, NB, 1.0);
					CGContextMoveToPoint(context, ix+plotWidth/2, iy);
					CGContextAddLineToPoint(context, iNx+plotWidth/2,iNy);
					CGContextAddLineToPoint(context, iNx+plotWidth/2,iBy);
					CGContextAddLineToPoint(context, ix+plotWidth/2,iBy);
					CGContextAddLineToPoint(context, ix+plotWidth/2,iy);
					CGContextFillPath(context);
				}else if(value >= 0 && nextValue >= 0){
					CGContextBeginPath(context);
					CGContextSetRGBFillColor(context, R, G, B, 1.0);
					CGContextMoveToPoint(context, ix+plotWidth/2, iy);
					CGContextAddLineToPoint(context, iNx+plotWidth/2,iNy);
					CGContextAddLineToPoint(context, iNx+plotWidth/2,iBy);
					CGContextAddLineToPoint(context, ix+plotWidth/2,iBy);
					CGContextAddLineToPoint(context, ix+plotWidth/2,iy);
					CGContextFillPath(context);
				}else{
					float zeroX = abs(value)*plotWidth/abs(nextValue-value)+(sec.paddingLeft+(i-self.rangeFrom)*plotWidth+plotWidth/2);
					float izy = [self getLocalY:0 withSection:section withAxis:yAxis];
					if(value>0){
						CGContextSetRGBFillColor(context, R, G, B, 1.0);
					}else{ 
						CGContextSetRGBFillColor(context, NR, NG, NB, 1.0);
					}
					CGContextBeginPath(context);
					CGContextMoveToPoint(context, ix+plotWidth/2, iy);
					CGContextAddLineToPoint(context, zeroX,iBy);
					CGContextAddLineToPoint(context, ix+plotWidth/2,iBy);
					CGContextAddLineToPoint(context, ix+plotWidth/2,iy);
					CGContextFillPath(context);
					
					if(nextValue>0){
						CGContextSetRGBFillColor(context, R, G, B, 1.0);
					}else{ 
						CGContextSetRGBFillColor(context, NR, NG, NB, 1.0);
					}
					CGContextBeginPath(context);
					CGContextMoveToPoint(context, zeroX, izy);
					CGContextAddLineToPoint(context, iNx+plotWidth/2,iNy);
					CGContextAddLineToPoint(context, iNx+plotWidth/2,izy);
					CGContextAddLineToPoint(context, zeroX,izy);
					CGContextFillPath(context);
				}
			}
		}
		
		if(self.selectedIndex!=-1){
			float value = [[[data objectAtIndex:self.selectedIndex] objectAtIndex:0] floatValue];
			NSMutableDictionary *lbl = [[NSMutableDictionary alloc] init];
			NSMutableString *l = [[NSMutableString alloc] init];
			[l appendFormat:@"%@:%.2f ",label,value];
			[lbl setObject:l forKey:@"text"];
			[l release];
			
			NSMutableString *clr = [[NSMutableString alloc] init];
			[clr appendFormat:@"%f,",R];
			[clr appendFormat:@"%f,",G];
			[clr appendFormat:@"%f",B];
			[lbl setObject:clr forKey:@"color"];
			[clr release];
			
			[[labels objectAtIndex:section] addObject:lbl];
			[lbl release];
			
			if(value>=0){
				CGContextSetRGBFillColor(context, R, G, B, 1.0);
			}else{ 
				CGContextSetRGBFillColor(context, NR, NG, NB, 1.0);
			}
			
			CGContextBeginPath(context);
			CGContextAddArc(context, sec.paddingLeft+(self.selectedIndex-self.rangeFrom)*plotWidth+plotWidth/2, [self getLocalY:value withSection:section withAxis:yAxis], 2, 0, 2*M_PI, 1);
			CGContextFillPath(context);
		}
	}			
}

-(void)drawYAxis{
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSetLineWidth(context, 1.0f);
	CGContextSetStrokeColorWithColor(context, [[UIColor alloc] initWithRed:0.3 green:0.3 blue:0.3 alpha:1.0].CGColor);
	CGContextSetRGBFillColor(context, 0.1, 0.1, 0.1, 1.0);
	
	for(int secIndex=0;secIndex<[self.sections count];secIndex++){
		Section *sec = [self.sections objectAtIndex:secIndex];
		CGContextFillRect (context, CGRectMake(0, sec.frame.origin.y, sec.paddingLeft, sec.frame.size.height)); 
		CGContextMoveToPoint(context,sec.paddingLeft,sec.frame.origin.y);
		CGContextAddLineToPoint(context, sec.paddingLeft,sec.frame.size.height+sec.frame.origin.y);
		CGContextStrokePath(context);
	}
	
	CGContextSetRGBFillColor(context, 0.5, 0.5, 0.5, 1.0);
	for(int secIndex=0;secIndex<self.sections.count;secIndex++){
		Section *sec = [self.sections objectAtIndex:secIndex];
		for(int aIndex=0;aIndex<sec.yAxises.count;aIndex++){
			YAxis *yaxis = [sec.yAxises objectAtIndex:aIndex];
			float step = (float)(yaxis.max-yaxis.min)/yaxis.tickInterval;
			for(int i=0; i<yaxis.tickInterval+1;i++){
				float iy = [self getLocalY:(yaxis.min+i*step) withSection:secIndex withAxis:aIndex];
				CGContextMoveToPoint(context,sec.paddingLeft,iy);
				CGContextAddLineToPoint(context, sec.paddingLeft-3,iy);
				CGContextStrokePath(context);
				[[@"" stringByAppendingFormat:@"%.2f",yaxis.min+i*step] drawAtPoint:CGPointMake(0,iy-6) withFont:[UIFont systemFontOfSize: 12]];
			}
		}
	}	
}

-(void)drawXAxis{
    CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSetLineWidth(context, 1.0f);
	CGContextSetStrokeColorWithColor(context, [[UIColor alloc] initWithRed:0.3 green:0.3 blue:0.3 alpha:1.0].CGColor);
	CGContextSetRGBFillColor(context, 0.1, 0.1, 0.1, 1.0);

	for(int secIndex=0;secIndex<self.sections.count;secIndex++){
		Section *sec = [self.sections objectAtIndex:secIndex];
		CGContextMoveToPoint(context,0,sec.frame.size.height+sec.frame.origin.y);
		CGContextAddLineToPoint(context, sec.frame.size.width,sec.frame.size.height+sec.frame.origin.y);
	}
	CGContextStrokePath(context);
}

-(void) setSelectedIndexByPoint:(CGPoint) point{
	for(int i=self.rangeFrom;i<self.rangeTo;i++){
		if((plotWidth*(i-self.rangeFrom))<=(point.x-45) && (point.x-45)<plotWidth*((i-self.rangeFrom)+1)){
			if (self.selectedIndex != i) {
				self.selectedIndex=i;
				[self setNeedsDisplay];
			}
			return;
		}
	}
}

-(int)getSectionIndexByPoint:(CGPoint) point{
    for(int i=0;i<self.sections.count;i++){
	    Section *sec = [self.sections objectAtIndex:i];
		if (CGRectContainsPoint(sec.frame, point)){
		    return i;
		}
	}
	return -1;
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
	if(!self.isSectionInitialized){
		int total = 0;
		for (int i=0; i< self.ratios.count; i++) {
			int ratio = [[self.ratios objectAtIndex:i] intValue];
			total+=ratio;
		}
		for (int i=0; i< self.sections.count; i++) {
			int ratio = [[self.ratios objectAtIndex:i] intValue];
			Section *sec = [self.sections objectAtIndex:i];
			int height = self.frame.size.height*ratio/total;
			
			if(i==0){
				[sec setFrame:CGRectMake(0, 0, self.frame.size.width,height)];
			}else{
				Section *preSec = [self.sections objectAtIndex:i-1];
				if(i==([self.sections count]-1)){
					[sec setFrame:CGRectMake(0, preSec.frame.origin.y+preSec.frame.size.height, self.frame.size.width,self.frame.size.height-(preSec.frame.origin.y+preSec.frame.size.height))];
				}else {
					[sec setFrame:CGRectMake(0, preSec.frame.origin.y+preSec.frame.size.height, self.frame.size.width,height)];
				}
			}
		}
		self.isSectionInitialized = YES;
	}
}


/* 
 * UIView Methods
 */
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
	
	self.backgroundColor    = [[UIColor alloc] initWithRed:0.15 green:0.15 blue:0.15 alpha:1.0];
	
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
		self.range           = 30;
		self.touchFlag       = 0;
		
		NSMutableArray *rats = [[NSMutableArray alloc] init];
		self.ratios        = rats; 
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
	[self drawChart];
	[self drawXAxis];
	[self drawYAxis];
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
			}
			
		}
	}
	self.touchFlag = 0;
}

@end
