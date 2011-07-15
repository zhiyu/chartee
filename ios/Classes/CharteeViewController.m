//
//  CharteeViewController.m
//  https://github.com/zhiyu/chartee/
//
//  Created by zhiyu on 7/11/11.
//  Copyright 2011 zhiyu. All rights reserved.
//

#import "CharteeViewController.h"

@implementation CharteeViewController

@synthesize candle;

/*
// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	self.candle = [[CandleChart alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height)];
	
	NSMutableArray *series = [[NSMutableArray alloc] init];
	
	NSMutableArray *sec1series = [[NSMutableArray alloc] init];
	NSMutableArray *sec2series = [[NSMutableArray alloc] init];
	NSMutableArray *sec3series = [[NSMutableArray alloc] init];
	
	NSMutableDictionary *serie = [[NSMutableDictionary alloc] init]; 
	NSMutableArray *data = [[NSMutableArray alloc] init];
	for(int i=0;i<4000;i++){
	    NSMutableArray *item = [[NSMutableArray alloc] init];
		[item addObject:[NSString stringWithFormat:@"%f",(float)(30+random()%10)/10]];
		[item addObject:[NSString stringWithFormat:@"%f",(float)(30+random()%10)/10]];
		[item addObject:[NSString stringWithFormat:@"%f",(float)(40+random()%10)/10]];
		[item addObject:[NSString stringWithFormat:@"%f",(float)(20+random()%10)/10]];
		[data addObject:item];
		[item release];
	}
	[serie setObject:@"candle" forKey:@"name"];
	[serie setObject:@"candle" forKey:@"label"];
	[serie setObject:data forKey:@"data"];
	[serie setObject:@"candle" forKey:@"type"];
	[serie setObject:@"0" forKey:@"yAxis"];
	[serie setObject:@"0" forKey:@"section"];
	[serie setObject:@"189,119,117" forKey:@"color"];
	[serie setObject:@"76,255,243" forKey:@"negativeColor"];
	[serie setObject:@"165,47,44" forKey:@"selectedColor"];
	[serie setObject:@"43,134,142" forKey:@"negativeSelectedColor"];
	[series addObject:serie];
	[sec1series addObject:serie];
	[data release];
	[serie release];
	
	serie = [[NSMutableDictionary alloc] init]; 
	data = [[NSMutableArray alloc] init];
	for(int i=0;i<4000;i++){
	    NSMutableArray *item = [[NSMutableArray alloc] init];
		[item addObject:[NSString stringWithFormat:@"%f",(float)(random()%40)/10]];
		[data addObject:item];
		[item release];
	}
	[serie setObject:@"MA" forKey:@"name"];
	[serie setObject:@"MA" forKey:@"label"];
	[serie setObject:data forKey:@"data"];
	[serie setObject:@"line" forKey:@"type"];
	[serie setObject:@"0" forKey:@"yAxis"];
	[serie setObject:@"2" forKey:@"section"];
	[serie setObject:@"0,0,255" forKey:@"color"];
	[serie setObject:@"76,255,243" forKey:@"negativeColor"];
	[serie setObject:@"165,47,44" forKey:@"selectedColor"];
	[serie setObject:@"43,134,142" forKey:@"negativeSelectedColor"];
	[series addObject:serie];
	[sec3series addObject:serie];
	[data release];
	[serie release];
	
	serie = [[NSMutableDictionary alloc] init]; 
	data = [[NSMutableArray alloc] init];
	for(int i=0;i<4000;i++){
	    NSMutableArray *item = [[NSMutableArray alloc] init];
		[item addObject:[NSString stringWithFormat:@"%f",(float)(random()%40)/10]];
		[data addObject:item];
		[item release];
	}
	[serie setObject:@"MA" forKey:@"name"];
	[serie setObject:@"MA" forKey:@"label"];
	[serie setObject:data forKey:@"data"];
	[serie setObject:@"line" forKey:@"type"];
	[serie setObject:@"0" forKey:@"yAxis"];
	[serie setObject:@"0" forKey:@"section"];
	[serie setObject:@"0,0,255" forKey:@"color"];
	[serie setObject:@"76,255,243" forKey:@"negativeColor"];
	[serie setObject:@"165,47,44" forKey:@"selectedColor"];
	[serie setObject:@"43,134,142" forKey:@"negativeSelectedColor"];
	[series addObject:serie];
	[sec1series addObject:serie];
	[data release];
	[serie release];
	
	
	serie = [[NSMutableDictionary alloc] init]; 
	data = [[NSMutableArray alloc] init];
	for(int i=0;i<4000;i++){
	    NSMutableArray *item = [[NSMutableArray alloc] init];
		if(i%2==0){
			[item addObject:[NSString stringWithFormat:@"%f",(float)(random()%30)]];
		}else{
			[item addObject:[NSString stringWithFormat:@"%f",-(float)(random()%30)]];
		}
		[data addObject:item];
		[item release];
	}
	[serie setObject:@"VOL" forKey:@"name"];
	[serie setObject:@"VOL" forKey:@"label"];
	[serie setObject:data forKey:@"data"];
	[serie setObject:@"column" forKey:@"type"];
	[serie setObject:@"0" forKey:@"yAxis"];
	[serie setObject:@"1" forKey:@"section"];
	[serie setObject:@"189,119,117" forKey:@"color"];
	[serie setObject:@"76,255,243" forKey:@"negativeColor"];
	[serie setObject:@"165,47,44" forKey:@"selectedColor"];
	[serie setObject:@"43,134,142" forKey:@"negativeSelectedColor"];
	[series addObject:serie];
	[sec2series addObject:serie];
	[data release];
	[serie release];
	
	serie = [[NSMutableDictionary alloc] init]; 
	data = [[NSMutableArray alloc] init];
	for(int i=0;i<4000;i++){
	    NSMutableArray *item = [[NSMutableArray alloc] init];
		[item addObject:[NSString stringWithFormat:@"%f",(float)(random()%30)]];
		[data addObject:item];
		[item release];
	}
	
	///////
	NSMutableArray *co = [[NSMutableArray alloc] init];
	[serie setObject:@"RSI" forKey:@"name"];
	[serie setObject:@"RSI" forKey:@"label"];
	[serie setObject:data forKey:@"data"];
	[serie setObject:@"line" forKey:@"type"];
	[serie setObject:@"0" forKey:@"yAxis"];
	[serie setObject:@"1" forKey:@"section"];
	[serie setObject:@"189,119,117" forKey:@"color"];
	[serie setObject:@"76,255,243" forKey:@"negativeColor"];
	[serie setObject:@"165,47,44" forKey:@"selectedColor"];
	[serie setObject:@"43,134,142" forKey:@"negativeSelectedColor"];
	[series addObject:serie];
	[co addObject:serie];
	[data release];
	[serie release];
	
	serie = [[NSMutableDictionary alloc] init]; 
	data = [[NSMutableArray alloc] init];
	for(int i=0;i<4000;i++){
	    NSMutableArray *item = [[NSMutableArray alloc] init];
		[item addObject:[NSString stringWithFormat:@"%f",(float)(random()%30)]];
		[data addObject:item];
		[item release];
	}
	[serie setObject:@"WR" forKey:@"name"];
	[serie setObject:@"WR" forKey:@"label"];
	[serie setObject:data forKey:@"data"];
	[serie setObject:@"line" forKey:@"type"];
	[serie setObject:@"0" forKey:@"yAxis"];
	[serie setObject:@"1" forKey:@"section"];
	[serie setObject:@"76,255,243" forKey:@"color"];
	[serie setObject:@"76,255,243" forKey:@"negativeColor"];
	[serie setObject:@"165,47,44" forKey:@"selectedColor"];
	[serie setObject:@"43,134,142" forKey:@"negativeSelectedColor"];
	[series addObject:serie];
	[co addObject:serie];
	[sec2series addObject:co];
	[data release];
	[serie release];
	[co release];
	
	serie = [[NSMutableDictionary alloc] init]; 
	data = [[NSMutableArray alloc] init];
	for(int i=0;i<4000;i++){
	    NSMutableArray *item = [[NSMutableArray alloc] init];
		if(i%2==0){
			[item addObject:[NSString stringWithFormat:@"%f",(float)(random()%30)]];
		}else{
			[item addObject:[NSString stringWithFormat:@"%f",-(float)(random()%30)]];
		}
		[data addObject:item];
		[item release];
	}
	[serie setObject:@"Test" forKey:@"name"];
	[serie setObject:@"Test" forKey:@"label"];
	[serie setObject:data forKey:@"data"];
	[serie setObject:@"area" forKey:@"type"];
	[serie setObject:@"0" forKey:@"yAxis"];
	[serie setObject:@"1" forKey:@"section"];
	[serie setObject:@"189,119,117" forKey:@"color"];
	[serie setObject:@"76,255,243" forKey:@"negativeColor"];
	[serie setObject:@"165,47,44" forKey:@"selectedColor"];
	[serie setObject:@"43,134,142" forKey:@"negativeSelectedColor"];
	[series addObject:serie];
	[sec2series addObject:serie];
	[data release];
	[serie release];
	
	NSMutableArray *padding = [NSMutableArray arrayWithObjects:@"0",@"0",@"0",@"0",nil];
	[candle setPadding:padding];
	[candle setSeries:series];
	[series release];
	
	NSMutableArray *secs = [[NSMutableArray alloc] init];
	[secs addObject:@"3"];
	[secs addObject:@"1"];
	[secs addObject:@"1"];
	[candle addSections:3 withRatios:secs];
	
	[[[candle sections] objectAtIndex:0] addYAxis:0];
	[[[candle sections] objectAtIndex:1] addYAxis:0];
	[[[candle sections] objectAtIndex:2] addYAxis:0];
	
	[[[candle sections] objectAtIndex:0] setSeries:sec1series];
	[[[candle sections] objectAtIndex:1] setSeries:sec2series];
	[[[candle sections] objectAtIndex:2] setSeries:sec3series];
	[[[candle sections] objectAtIndex:1] setPaging:YES];
	
	[sec1series release];
	[sec2series release];
	[sec3series release];
	[secs release];
	
	[self.view addSubview:candle];
	[candle release];	
}



/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}

@end
