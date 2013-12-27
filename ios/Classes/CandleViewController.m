//  https://github.com/zhiyu/chartee/
//
//  Created by zhiyu on 7/11/11.
//  Copyright 2011 zhiyu. All rights reserved.
//

#import "CandleViewController.h"
#import "ASIHTTPRequest.h"
#import "ResourceHelper.h"
#import "JSONKit.h"

@implementation CandleViewController

@synthesize candleChart;
@synthesize autoCompleteView;
@synthesize toolBar;
@synthesize candleChartFreqView;
@synthesize autoCompleteDelegate;
@synthesize timer;
@synthesize chartMode;
@synthesize tradeStatus;
@synthesize lastTime;
@synthesize status;
@synthesize req_freq;
@synthesize req_type;
@synthesize req_url;
@synthesize req_security_id;

- (void)viewDidLoad {
    [super viewDidLoad];
	
	//add notification observer
	NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
	[center addObserver:self selector:@selector(doNotification:) name:UIApplicationWillEnterForegroundNotification object:nil];
	
	//init vars
	self.chartMode  = 1; //1,candleChart
	self.tradeStatus= 1;
	self.req_freq   = @"d";
	self.req_type   = @"H";
	self.req_url    = @"http://ichart.yahoo.com/table.csv?s=%@&g=%@";
	
	[self.view setFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.height, [[UIScreen mainScreen] bounds].size.width)];

    
	//candleChart
	self.candleChart = [[Chart alloc] initWithFrame:CGRectMake(0, 40, self.view.frame.size.width, self.view.frame.size.height-40)];
	[self.view addSubview:candleChart];
    
    //toolbar
	self.toolBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 40)];
	[self.toolBar release];
    
    [self.view addSubview:toolBar];
	//status bar
	self.status = [[UILabel alloc] initWithFrame:CGRectMake(220, 0, 200, 40)];
	[self.status release];
	self.status.font = [UIFont systemFontOfSize:14];
	self.status.backgroundColor = [UIColor clearColor];
    self.status.textColor = [UIColor whiteColor];
	[self.toolBar addSubview:status];
	
    
	UIImage *btnImg = [[ResourceHelper loadImage:@"candle_chart"] retain];
	UIImage *btnImgBg = [[ResourceHelper loadImage:[@"candle_chart" stringByAppendingFormat:@"_%@",@"selected"]] retain];
	UIButton *btn = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
	btn.tag = 2;
	[btn setFrame:CGRectMake(0,0, 80, 40)];
	[btn setImage:btnImg forState:UIControlStateNormal];
	[btn setImage:btnImgBg forState:UIControlStateSelected];
	[btn addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
	[self.toolBar addSubview:btn];
	[btn release];
	[btnImg release];
    
    UILabel *link = [[UILabel alloc] initWithFrame:CGRectMake(self.toolBar.frame.size.width/2-130, 0, 260, 40)];
	link.font     = [UIFont systemFontOfSize:14];
    link.backgroundColor = [UIColor clearColor];
    link.textColor = [UIColor grayColor];
    link.text     = @"©2011 https://github.com/zhiyu/chartee";
	[self.toolBar addSubview:link];
	
    
	//search bar
	UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(self.toolBar.frame.size.width-250, 0, 250, 40)];
	[searchBar setBackgroundColor:[[UIColor alloc] initWithRed:0 green:0 blue:0 alpha:0]];
	searchBar.delegate = self;
    
    if ([searchBar respondsToSelector:@selector(barTintColor)]) {
        [searchBar setBarTintColor:[UIColor clearColor]];
    }
    
	searchBar.barStyle = UIBarStyleBlackTranslucent;
	searchBar.placeholder = @"enter security";
	searchBar.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
	searchBar.autocapitalizationType = NO;
	[self.toolBar addSubview:searchBar];

    
    //candleChart freqView
	self.candleChartFreqView = [[UIView alloc] initWithFrame:CGRectMake(80, -160, 120, 120)];
	[self.candleChartFreqView setBackgroundColor:[[UIColor alloc] initWithRed:0/255.f green:0/255.f blue:255/255.f alpha:1]];
	[self.candleChartFreqView release];

    btnImg = [[ResourceHelper loadImage:@"k1d"] retain];
    btnImgBg = [[ResourceHelper loadImage:[@"k1d" stringByAppendingFormat:@"_%@",@"selected"]] retain];
    btn = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
	btn.tag = 26;
	[btn setFrame:CGRectMake(0,0, 120, 40)];
	[btn setImage:btnImg forState:UIControlStateNormal];
	[btn setImage:btnImgBg forState:UIControlStateSelected];
	[btn addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
	[candleChartFreqView addSubview:btn];
	[btn release];
	[btnImg release];
	[btnImgBg release];
	
	btnImg = [[ResourceHelper loadImage:@"k1w"] retain];
	btnImgBg = [[ResourceHelper loadImage:[@"k1w" stringByAppendingFormat:@"_%@",@"selected"]] retain];
	btn = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
	btn.tag = 27;
	[btn setFrame:CGRectMake(0,40, 120, 40)];
	[btn setImage:btnImg forState:UIControlStateNormal];
	[btn setImage:btnImgBg forState:UIControlStateSelected];
	[btn addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
	[candleChartFreqView addSubview:btn];
	[btn release];
	[btnImg release];
	[btnImgBg release];
	
	btnImg = [[ResourceHelper loadImage:@"k1m"] retain];
	btnImgBg = [[ResourceHelper loadImage:[@"k1m" stringByAppendingFormat:@"_%@",@"selected"]] retain];
	btn = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
	btn.tag = 28;
	[btn setFrame:CGRectMake(0,80, 120, 40)];
	[btn setImage:btnImg forState:UIControlStateNormal];
	[btn setImage:btnImgBg forState:UIControlStateSelected];
	[btn addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
	[candleChartFreqView addSubview:btn];
	[btn release];
	[btnImg release];
	[btnImgBg release];
	
	[self.view addSubview:candleChartFreqView];
	
    
    //init chart
    [self initChart];
    
    //load securities
	self.autoCompleteDelegate = [[AutoCompleteDelegate alloc] initWithBar:searchBar];
	[self.autoCompleteDelegate release];
	self.autoCompleteView = [[UITableView alloc]initWithFrame:CGRectMake(self.view.frame.size.width-240, 40,240, 0)];
	self.autoCompleteView.separatorStyle=UITableViewCellSeparatorStyleNone;
	self.autoCompleteView.showsVerticalScrollIndicator = YES;
	self.autoCompleteView.delegate = autoCompleteDelegate;
    self.autoCompleteView.dataSource = autoCompleteDelegate;
	self.autoCompleteView.hidden = YES;
	[self.view addSubview:autoCompleteView];
	[ResourceHelper setUserDefaults:nil forKey:@"autocompTime"];
	[self getAutoCompleteData];
    
    //load default security data
    searchBar.text = @"深证成指（399001.SZ）";
	[self searchBarSearchButtonClicked:searchBar];
	
	
}

-(void)initChart{
	NSMutableArray *padding = [NSMutableArray arrayWithObjects:@"20",@"20",@"20",@"20",nil];
	[self.candleChart setPadding:padding];
	NSMutableArray *secs = [[NSMutableArray alloc] init];
	[secs addObject:@"4"];
	[secs addObject:@"1"];
	[secs addObject:@"1"];
	[self.candleChart addSections:3 withRatios:secs];
	[self.candleChart getSection:2].hidden = YES;
	[[[self.candleChart sections] objectAtIndex:0] addYAxis:0];
	[[[self.candleChart sections] objectAtIndex:1] addYAxis:0];
	[[[self.candleChart sections] objectAtIndex:2] addYAxis:0];
	
	[self.candleChart getYAxis:2 withIndex:0].baseValueSticky = NO;
	[self.candleChart getYAxis:2 withIndex:0].symmetrical = NO;
	[self.candleChart getYAxis:0 withIndex:0].ext = 0.05;
	NSMutableArray *series = [[NSMutableArray alloc] init];
	NSMutableArray *secOne = [[NSMutableArray alloc] init];
	NSMutableArray *secTwo = [[NSMutableArray alloc] init];
	NSMutableArray *secThree = [[NSMutableArray alloc] init];
	
	//price
	NSMutableDictionary *serie = [[NSMutableDictionary alloc] init]; 
	NSMutableArray *data = [[NSMutableArray alloc] init];
	[serie setObject:@"price" forKey:@"name"];
	[serie setObject:@"Price" forKey:@"label"];
	[serie setObject:data forKey:@"data"];
	[serie setObject:@"candle" forKey:@"type"];
	[serie setObject:@"0" forKey:@"yAxis"];
	[serie setObject:@"0" forKey:@"section"];
	[serie setObject:@"249,222,170" forKey:@"color"];
	[serie setObject:@"249,222,170" forKey:@"negativeColor"];
	[serie setObject:@"249,222,170" forKey:@"selectedColor"];
	[serie setObject:@"249,222,170" forKey:@"negativeSelectedColor"];
	[serie setObject:@"176,52,52" forKey:@"labelColor"];
	[serie setObject:@"77,143,42" forKey:@"labelNegativeColor"];
	[series addObject:serie];
	[secOne addObject:serie];
	[data release];
	[serie release];
	
	//MA10
	serie = [[NSMutableDictionary alloc] init]; 
	data = [[NSMutableArray alloc] init];
	[serie setObject:@"ma10" forKey:@"name"];
	[serie setObject:@"MA10" forKey:@"label"];
	[serie setObject:data forKey:@"data"];
	[serie setObject:@"line" forKey:@"type"];
	[serie setObject:@"0" forKey:@"yAxis"];
	[serie setObject:@"0" forKey:@"section"];
	[serie setObject:@"255,255,255" forKey:@"color"];
	[serie setObject:@"255,255,255" forKey:@"negativeColor"];
	[serie setObject:@"255,255,255" forKey:@"selectedColor"];
	[serie setObject:@"255,255,255" forKey:@"negativeSelectedColor"];
	[series addObject:serie];
	[secOne addObject:serie];
	[data release];
	[serie release];
    
	//MA30
	serie = [[NSMutableDictionary alloc] init]; 
	data = [[NSMutableArray alloc] init];
	[serie setObject:@"ma30" forKey:@"name"];
	[serie setObject:@"MA30" forKey:@"label"];
	[serie setObject:data forKey:@"data"];
	[serie setObject:@"line" forKey:@"type"];
	[serie setObject:@"0" forKey:@"yAxis"];
	[serie setObject:@"0" forKey:@"section"];
	[serie setObject:@"250,232,115" forKey:@"color"];
	[serie setObject:@"250,232,115" forKey:@"negativeColor"];
	[serie setObject:@"250,232,115" forKey:@"selectedColor"];
	[serie setObject:@"250,232,115" forKey:@"negativeSelectedColor"];
	[series addObject:serie];
	[secOne addObject:serie];
	[data release];
	[serie release];
	
	//MA60
	serie = [[NSMutableDictionary alloc] init]; 
	data = [[NSMutableArray alloc] init];
	[serie setObject:@"ma60" forKey:@"name"];
	[serie setObject:@"MA60" forKey:@"label"];
	[serie setObject:data forKey:@"data"];
	[serie setObject:@"line" forKey:@"type"];
	[serie setObject:@"0" forKey:@"yAxis"];
	[serie setObject:@"0" forKey:@"section"];
	[serie setObject:@"232,115,250" forKey:@"color"];
	[serie setObject:@"232,115,250" forKey:@"negativeColor"];
	[serie setObject:@"232,115,250" forKey:@"selectedColor"];
	[serie setObject:@"232,115,250" forKey:@"negativeSelectedColor"];
	[series addObject:serie];
	[secOne addObject:serie];
	[data release];
	[serie release];
	
	
	//VOL
	serie = [[NSMutableDictionary alloc] init]; 
	data = [[NSMutableArray alloc] init];
	[serie setObject:@"vol" forKey:@"name"];
	[serie setObject:@"VOL" forKey:@"label"];
	[serie setObject:data forKey:@"data"];
	[serie setObject:@"column" forKey:@"type"];
	[serie setObject:@"0" forKey:@"yAxis"];
	[serie setObject:@"1" forKey:@"section"];
	[serie setObject:@"0" forKey:@"decimal"];
	[serie setObject:@"176,52,52" forKey:@"color"];
	[serie setObject:@"77,143,42" forKey:@"negativeColor"];
	[serie setObject:@"176,52,52" forKey:@"selectedColor"];
	[serie setObject:@"77,143,42" forKey:@"negativeSelectedColor"];
	[series addObject:serie];
	[secTwo addObject:serie];
	[data release];
	[serie release];
	
	//candleChart init
    [self.candleChart setSeries:series];
	[series release];
	
	[[[self.candleChart sections] objectAtIndex:0] setSeries:secOne];
	[secOne release];
	[[[self.candleChart sections] objectAtIndex:1] setSeries:secTwo];
	[secTwo release];
	[[[self.candleChart sections] objectAtIndex:2] setSeries:secThree];
	[[[self.candleChart sections] objectAtIndex:2] setPaging:YES];
	[secThree release];
	
	
	NSString *indicatorsString =[NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"indicators" ofType:@"json"] encoding:NSUTF8StringEncoding error:nil];
    
	if(indicatorsString != nil){
		NSArray *indicators = [indicatorsString objectFromJSONString];
		for(NSObject *indicator in indicators){
			if([indicator isKindOfClass:[NSArray class]]){
				NSMutableArray *arr = [[NSMutableArray alloc] init];
				for(NSDictionary *indic in indicator){
					NSMutableDictionary *serie = [[NSMutableDictionary alloc] init]; 
					[self setOptions:indic ForSerie:serie];
					[arr addObject:serie];
					[serie release];
				}
			    [self.candleChart addSerie:arr];
				[arr release];
			}else{
				NSDictionary *indic = (NSDictionary *)indicator;
				NSMutableDictionary *serie = [[NSMutableDictionary alloc] init]; 
				[self setOptions:indic ForSerie:serie];
				[self.candleChart addSerie:serie];
				[serie release];
			}
		}
	}
    
    CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    pathAnimation.duration = 10.0;
    pathAnimation.fromValue = [NSNumber numberWithFloat:0.0f];
    pathAnimation.toValue = [NSNumber numberWithFloat:1.0f];
    [self.candleChart addAnimation:pathAnimation forKey:@"strokeEndAnimation"];
    
}

-(void)setOptions:(NSDictionary *)options ForSerie:(NSMutableDictionary *)serie;{
	[serie setObject:[options objectForKey:@"name"] forKey:@"name"];
	[serie setObject:[options objectForKey:@"label"] forKey:@"label"];
	[serie setObject:[options objectForKey:@"type"] forKey:@"type"];
	[serie setObject:[options objectForKey:@"yAxis"] forKey:@"yAxis"];
	[serie setObject:[options objectForKey:@"section"] forKey:@"section"];
	[serie setObject:[options objectForKey:@"color"] forKey:@"color"];
	[serie setObject:[options objectForKey:@"negativeColor"] forKey:@"negativeColor"];
	[serie setObject:[options objectForKey:@"selectedColor"] forKey:@"selectedColor"];
	[serie setObject:[options objectForKey:@"negativeSelectedColor"] forKey:@"negativeSelectedColor"];
}

-(void)buttonPressed:(id)sender{
    UIButton *btn = (UIButton *)sender;
	int index = btn.tag;
	
	if(index !=2){
		CGContextRef context = UIGraphicsGetCurrentContext();
		[UIView beginAnimations:nil context:context];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
		[UIView setAnimationDuration:0.3];
		CGRect rect = [self.candleChartFreqView frame];
		rect.origin.y =  - 160;
		[self.candleChartFreqView setFrame:rect];
		[UIView commitAnimations];
	}
	
	if(index>=21 && index<=28){
		for (UIView *subview in self.candleChartFreqView.subviews){
			UIButton *btn = (UIButton *)subview;
			btn.selected = NO;
		}
	}
	btn.selected = YES;
	
    switch (index) {
		case 1:{
			UIButton *sel = (UIButton *)[self.toolBar viewWithTag:2];
			sel.selected = NO;
			self.chartMode  = 0;
			self.req_freq   = @"1m";
			self.req_type   = @"T";
			[self getData];
			break;
	    }
        case 2:{
			UIButton *sel = (UIButton *)[self.toolBar viewWithTag:1];
			sel.selected = NO;
			CGContextRef context = UIGraphicsGetCurrentContext();
			[UIView beginAnimations:nil context:context];
			[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
			[UIView setAnimationDuration:0.3];
			CGRect rect = [self.candleChartFreqView frame];
			if(rect.origin.y == 0){
				rect.origin.y = - 160;
				[self.candleChartFreqView setFrame:rect];
			}else{
				rect.origin.y =  0;
				[self.candleChartFreqView setFrame:rect];
                btn.selected = NO;
                sel.selected = NO;
			}
			[UIView commitAnimations];
			break;
		}
        case 26:{
			UIButton *sel = (UIButton *)[self.toolBar viewWithTag:2];
			sel.selected = NO;
			self.chartMode  = 1;
			self.req_freq   = @"d";
			self.req_type   = @"H";
			[self getData];
			break;
			break;
	    }
		case 27:{
			UIButton *sel = (UIButton *)[self.toolBar viewWithTag:2];
			sel.selected = NO;
			self.chartMode  = 1;
			self.req_freq   = @"w";
			self.req_type   = @"H";
			[self getData];
			break;
			
	    }
		case 28:{
			UIButton *sel = (UIButton *)[self.toolBar viewWithTag:2];
			sel.selected = NO;
			self.chartMode  = 1;
			self.req_freq   = @"m";
			self.req_type   = @"H";
			[self getData];
			break;
			
	    }
		case 50:{
			UIGraphicsBeginImageContext(self.candleChart.bounds.size);    
			[self.candleChart.layer renderInContext:UIGraphicsGetCurrentContext()];    
			UIImage *anImage = UIGraphicsGetImageFromCurrentImageContext();    
			UIGraphicsEndImageContext();
			UIImageWriteToSavedPhotosAlbum(anImage,nil,nil,nil);
			break;
	    }
		default:
			break;
    }

}

- (void)doNotification:(NSNotification *)notification{
	UIButton *sel = (UIButton *)[self.toolBar viewWithTag:1];
	[self buttonPressed:sel];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
	NSMutableArray *data = [self.autoCompleteDelegate.items mutableCopy];
    self.autoCompleteDelegate.selectedItems = data;
	[data release];
    self.autoCompleteView.hidden = NO;
	
	if([self isCodesExpired]){
	    [self getAutoCompleteData];
	}
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	[UIView beginAnimations:nil context:context];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDuration:0.2];
	CGRect rect = [self.autoCompleteView frame];
	rect.size.height = 300;
	[self.autoCompleteView setFrame:rect];
	[UIView commitAnimations];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
	[self.autoCompleteDelegate.selectedItems removeAllObjects];
    for(NSArray *item in self.autoCompleteDelegate.items){
	    if([[item objectAtIndex:0] hasPrefix:searchText]){
			[self.autoCompleteDelegate.selectedItems addObject:item];
		}
	}
	[self.autoCompleteView reloadData];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar{
	CGRect rect = [self.autoCompleteView frame];
	rect.size.height = 0;
	[self.autoCompleteView setFrame:rect];
	self.autoCompleteView.hidden = YES;
    if(![searchBar.text isEqualToString:@""]){
        self.req_security_id = [[[[[searchBar text] componentsSeparatedByString:@"（"] objectAtIndex:1] componentsSeparatedByString:@"）"] objectAtIndex:0];
        [self getData];
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar{
    NSLog(@"CancelButtonClicked");
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
	[searchBar resignFirstResponder];
    self.req_security_id = [[[[[searchBar text] componentsSeparatedByString:@"（"] objectAtIndex:1] componentsSeparatedByString:@"）"] objectAtIndex:0];
	[self getData];
}

-(BOOL)isCodesExpired{
	NSDate *date = [NSDate date];
	double now = [date timeIntervalSince1970];
	double last = now;
	NSString *autocompTime = (NSString *)[ResourceHelper  getUserDefaults:@"autocompTime"];
	if(autocompTime!=nil){
		last = [autocompTime doubleValue];
		if(now - last >3600*8){
		    return YES;
		}else{
		    return NO;
		}
    }else{
	    return YES;
	}
}

-(void)getAutoCompleteData{	
    NSString *securities =[NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"securities" ofType:@"json"] encoding:NSUTF8StringEncoding error:nil];
    NSMutableArray *data = [securities mutableObjectFromJSONString];
    self.autoCompleteDelegate.items = data;
}

-(void)getData{
	self.status.text = @"Loading...";
	if(chartMode == 0){
		[self.candleChart getSection:2].hidden = YES;
	}else{
	    [self.candleChart getSection:2].hidden = NO;
	}
    NSString *reqURL = [[NSString alloc] initWithFormat:self.req_url,self.req_security_id,self.req_freq];
	NSLog(@"url:%@",reqURL);

    NSURL *url = [NSURL URLWithString:[reqURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
	[reqURL release];
	
	ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
	[request setTimeOutSeconds:5];
	[request setDelegate:self];
	[request startAsynchronous];
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
	self.status.text = @"";
    NSMutableArray *data =[[NSMutableArray alloc] init];
	NSMutableArray *category =[[NSMutableArray alloc] init];

    NSString *content = [request responseString];
    NSArray *lines = [content componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    NSInteger idx;    
    for (idx = lines.count-1; idx > 0; idx--) {
        NSString *line = [lines objectAtIndex:idx];
        if([line isEqualToString:@""]){
            continue;
        }
        NSArray   *arr = [line componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@","]];
        [category addObject:[arr objectAtIndex:0]];

        NSMutableArray *item =[[NSMutableArray alloc] init];
        [item addObject:[arr objectAtIndex:1]];
        [item addObject:[arr objectAtIndex:4]];
        [item addObject:[arr objectAtIndex:2]];
        [item addObject:[arr objectAtIndex:3]];
        [item addObject:[arr objectAtIndex:5]];
        [data addObject:item];
        [item release];
    }
    
	if(data.count==0){
		self.status.text = @"Error!";
	    return;
	}

	if (chartMode == 0) {
		if([self.req_type isEqualToString:@"T"]){
			if(self.timer != nil)
				[self.timer invalidate];
			
			[self.candleChart reset];
			[self.candleChart clearData];
			[self.candleChart clearCategory];
			
			if([self.req_freq hasSuffix:@"m"]){
				self.req_type = @"L";
				self.timer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(getData) userInfo:nil repeats:YES];
			}
		}else{
		    NSString *time = [category objectAtIndex:0];
			if([time isEqualToString:self.lastTime]){
				if([time hasSuffix:@"1500"]){
					if(self.timer != nil)
						[self.timer invalidate];
				}
				return;
			}
			if ([time hasSuffix:@"1130"] || [time hasSuffix:@"1500"]) {
				if(self.tradeStatus == 1){
					self.tradeStatus = 0;
				}
			}else{
				self.tradeStatus = 1;
			}
		}
	}else{
		if(self.timer != nil)
			[self.timer invalidate];
		[self.candleChart reset];
		[self.candleChart clearData];
		[self.candleChart clearCategory];
	}
	
	self.lastTime = [category lastObject];
	
	NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
	[self generateData:dic From:data];
	[self setData:dic];
	[dic release];
	
	if(chartMode == 0){
		[self setCategory:category];
	}else{
		NSMutableArray *cate = [[NSMutableArray alloc] init];
		for(int i=60;i<category.count;i++){
			[cate addObject:[category objectAtIndex:i]];
		}
	    [self setCategory:cate];
		[cate release];
	}
	
	[self.candleChart setNeedsDisplay];
}

-(void)generateData:(NSMutableDictionary *)dic From:(NSArray *)data{
	if(self.chartMode == 1){
		//price 
		NSMutableArray *price = [[NSMutableArray alloc] init];
	    for(int i = 60;i < data.count;i++){
			[price addObject: [data objectAtIndex:i]];
		}
		[dic setObject:price forKey:@"price"];
		[price release];
		
		//VOL
		NSMutableArray *vol = [[NSMutableArray alloc] init];
	    for(int i = 60;i < data.count;i++){
			NSMutableArray *item = [[NSMutableArray alloc] init];
			[item addObject:[@"" stringByAppendingFormat:@"%f",[[[data objectAtIndex:i] objectAtIndex:4] floatValue]/100]];
			[vol addObject:item];
			[item release];
		}
		[dic setObject:vol forKey:@"vol"];
		[vol release];
		
		//MA 10
		NSMutableArray *ma10 = [[NSMutableArray alloc] init];
	    for(int i = 60;i < data.count;i++){
			float val = 0;
		    for(int j=i;j>i-10;j--){
			    val += [[[data objectAtIndex:j] objectAtIndex:1] floatValue];
			}
			val = val/10;
			NSMutableArray *item = [[NSMutableArray alloc] init];
			[item addObject:[@"" stringByAppendingFormat:@"%f",val]];
			[ma10 addObject:item];
			[item release];
		}
		[dic setObject:ma10 forKey:@"ma10"];
		[ma10 release];
		
		//MA 30
		NSMutableArray *ma30 = [[NSMutableArray alloc] init];
	    for(int i = 60;i < data.count;i++){
			float val = 0;
		    for(int j=i;j>i-30;j--){
			    val += [[[data objectAtIndex:j] objectAtIndex:1] floatValue];
			}
			val = val/30;
			NSMutableArray *item = [[NSMutableArray alloc] init];
			[item addObject:[@"" stringByAppendingFormat:@"%f",val]];
			[ma30 addObject:item];
			[item release];
		}
		[dic setObject:ma30 forKey:@"ma30"];
		[ma30 release];
		
		//MA 60
		NSMutableArray *ma60 = [[NSMutableArray alloc] init];
	    for(int i = 60;i < data.count;i++){
			float val = 0;
		    for(int j=i;j>i-60;j--){
			    val += [[[data objectAtIndex:j] objectAtIndex:1] floatValue];
			}
			val = val/60;
			NSMutableArray *item = [[NSMutableArray alloc] init];
			[item addObject:[@"" stringByAppendingFormat:@"%f",val]];
			[ma60 addObject:item];
			[item release];
		}
		[dic setObject:ma60 forKey:@"ma60"];
		[ma60 release];

		//RSI6
		NSMutableArray *rsi6 = [[NSMutableArray alloc] init];
	    for(int i = 60;i < data.count;i++){
			float incVal  = 0;
			float decVal = 0;
			float rs = 0;
		    for(int j=i;j>i-6;j--){
				float interval = [[[data objectAtIndex:j] objectAtIndex:1] floatValue]-[[[data objectAtIndex:j] objectAtIndex:0] floatValue];
				if(interval >= 0){
				    incVal += interval;
				}else{
				    decVal -= interval;
				}
			}
			
			rs = incVal/decVal;
			float rsi =100-100/(1+rs);
			
			NSMutableArray *item = [[NSMutableArray alloc] init];
			[item addObject:[@"" stringByAppendingFormat:@"%f",rsi]];
			[rsi6 addObject:item];
			[item release];
			
		}
		[dic setObject:rsi6 forKey:@"rsi6"];
		[rsi6 release];
		
		//RSI12
		NSMutableArray *rsi12 = [[NSMutableArray alloc] init];
	    for(int i = 60;i < data.count;i++){
			float incVal  = 0;
			float decVal = 0;
			float rs = 0;
		    for(int j=i;j>i-12;j--){
				float interval = [[[data objectAtIndex:j] objectAtIndex:1] floatValue]-[[[data objectAtIndex:j] objectAtIndex:0] floatValue];
				if(interval >= 0){
				    incVal += interval;
				}else{
				    decVal -= interval;
				}
			}
			
			rs = incVal/decVal;
			float rsi =100-100/(1+rs);
			
			NSMutableArray *item = [[NSMutableArray alloc] init];
			[item addObject:[@"" stringByAppendingFormat:@"%f",rsi]];
			[rsi12 addObject:item];
			[item release];
		}
		[dic setObject:rsi12 forKey:@"rsi12"];
		[rsi12 release];
		
		//WR
		NSMutableArray *wr = [[NSMutableArray alloc] init];
	    for(int i = 60;i < data.count;i++){
			float h  = [[[data objectAtIndex:i] objectAtIndex:2] floatValue];
			float l = [[[data objectAtIndex:i] objectAtIndex:3] floatValue];
			float c = [[[data objectAtIndex:i] objectAtIndex:1] floatValue];
		    for(int j=i;j>i-10;j--){
				if([[[data objectAtIndex:j] objectAtIndex:2] floatValue] > h){
				    h = [[[data objectAtIndex:j] objectAtIndex:2] floatValue];
				}
						 
				if([[[data objectAtIndex:j] objectAtIndex:3] floatValue] < l){
					l = [[[data objectAtIndex:j] objectAtIndex:3] floatValue];
				}
			}
			
			float val = (h-c)/(h-l)*100;
			NSMutableArray *item = [[NSMutableArray alloc] init];
			[item addObject:[@"" stringByAppendingFormat:@"%f",val]];
			[wr addObject:item];
			[item release];
		}
		[dic setObject:wr forKey:@"wr"];
		[wr release];
		
		//KDJ
		NSMutableArray *kdj_k = [[NSMutableArray alloc] init];
		NSMutableArray *kdj_d = [[NSMutableArray alloc] init];
		NSMutableArray *kdj_j = [[NSMutableArray alloc] init];
		float prev_k = 50;
		float prev_d = 50;
        float rsv = 0;
	    for(int i = 60;i < data.count;i++){
			float h  = [[[data objectAtIndex:i] objectAtIndex:2] floatValue];
			float l = [[[data objectAtIndex:i] objectAtIndex:3] floatValue];
			float c = [[[data objectAtIndex:i] objectAtIndex:1] floatValue];
		    for(int j=i;j>i-10;j--){
				if([[[data objectAtIndex:j] objectAtIndex:2] floatValue] > h){
				    h = [[[data objectAtIndex:j] objectAtIndex:2] floatValue];
				}
				
				if([[[data objectAtIndex:j] objectAtIndex:3] floatValue] < l){
					l = [[[data objectAtIndex:j] objectAtIndex:3] floatValue];
				}
			}
            
            if(h!=l)
			  rsv = (c-l)/(h-l)*100;
            float k = 2*prev_k/3+1*rsv/3;
			float d = 2*prev_d/3+1*k/3;
			float j = d+2*(d-k);
			
			prev_k = k;
			prev_d = d;
			
			NSMutableArray *itemK = [[NSMutableArray alloc] init];
			[itemK addObject:[@"" stringByAppendingFormat:@"%f",k]];
			[kdj_k addObject:itemK];
			[itemK release];
			NSMutableArray *itemD = [[NSMutableArray alloc] init];
			[itemD addObject:[@"" stringByAppendingFormat:@"%f",d]];
			[kdj_d addObject:itemD];
			[itemD release];
			NSMutableArray *itemJ = [[NSMutableArray alloc] init];
			[itemJ addObject:[@"" stringByAppendingFormat:@"%f",j]];
			[kdj_j addObject:itemJ];
			[itemJ release];
		}
		[dic setObject:kdj_k forKey:@"kdj_k"];
		[dic setObject:kdj_d forKey:@"kdj_d"];
		[dic setObject:kdj_j forKey:@"kdj_j"];
		[kdj_k release];
		[kdj_d release];
		[kdj_j release];
		
		//VR
		NSMutableArray *vr = [[NSMutableArray alloc] init];
	    for(int i = 60;i < data.count;i++){
			float inc = 0;
			float dec = 0;
			float eq  = 0;
		    for(int j=i;j>i-24;j--){
				float o = [[[data objectAtIndex:j] objectAtIndex:0] floatValue];
				float c = [[[data objectAtIndex:j] objectAtIndex:1] floatValue];

				if(c > o){
				    inc += [[[data objectAtIndex:j] objectAtIndex:4] intValue];
				}else if(c < o){
				    dec += [[[data objectAtIndex:j] objectAtIndex:4] intValue];
				}else{
				    eq  += [[[data objectAtIndex:j] objectAtIndex:4] intValue];
				}
			}
			
			float val = (inc+1*eq/2)/(dec+1*eq/2);
			NSMutableArray *item = [[NSMutableArray alloc] init];
			[item addObject:[@"" stringByAppendingFormat:@"%f",val]];
			[vr addObject:item];
			[item release];
		}
		[dic setObject:vr forKey:@"vr"];
		[vr release];

	}else{
		//price 
		NSMutableArray *price = [[NSMutableArray alloc] init];
	    for(int i = 0;i < data.count;i++){
			[price addObject: [data objectAtIndex:i]];
		}
		[dic setObject:price forKey:@"price"];
		[price release];
		
		//VOL
		NSMutableArray *vol = [[NSMutableArray alloc] init];
	    for(int i = 0;i < data.count;i++){
			NSMutableArray *item = [[NSMutableArray alloc] init];
			[item addObject:[@"" stringByAppendingFormat:@"%f",[[[data objectAtIndex:i] objectAtIndex:4] floatValue]/100]];
			[vol addObject:item];
			[item release];
		}
		[dic setObject:vol forKey:@"vol"];
		[vol release];
		
	}
}

-(void)setData:(NSDictionary *)dic{
	[self.candleChart appendToData:[dic objectForKey:@"price"] forName:@"price"];
	[self.candleChart appendToData:[dic objectForKey:@"vol"] forName:@"vol"];
	
	[self.candleChart appendToData:[dic objectForKey:@"ma10"] forName:@"ma10"];
	[self.candleChart appendToData:[dic objectForKey:@"ma30"] forName:@"ma30"];
	[self.candleChart appendToData:[dic objectForKey:@"ma60"] forName:@"ma60"];
	
	[self.candleChart appendToData:[dic objectForKey:@"rsi6"] forName:@"rsi6"];
	[self.candleChart appendToData:[dic objectForKey:@"rsi12"] forName:@"rsi12"];
	
	[self.candleChart appendToData:[dic objectForKey:@"wr"] forName:@"wr"];
	[self.candleChart appendToData:[dic objectForKey:@"vr"] forName:@"vr"];
	
	[self.candleChart appendToData:[dic objectForKey:@"kdj_k"] forName:@"kdj_k"];
	[self.candleChart appendToData:[dic objectForKey:@"kdj_d"] forName:@"kdj_d"];
	[self.candleChart appendToData:[dic objectForKey:@"kdj_j"] forName:@"kdj_j"];
	
	NSMutableDictionary *serie = [self.candleChart getSerie:@"price"];
	if(serie == nil)
		return;
	if(self.chartMode == 1){
		[serie setObject:@"candle" forKey:@"type"];
	}else{
		[serie setObject:@"line" forKey:@"type"];
	}
}

-(void)setCategory:(NSArray *)category{
	[self.candleChart appendToCategory:category forName:@"price"];
	[self.candleChart appendToCategory:category forName:@"line"];
	
}

- (void)requestFailed:(ASIHTTPRequest *)request{
	self.status.text = @"Error!";
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return (interfaceOrientation == UIInterfaceOrientationLandscapeRight || interfaceOrientation == UIInterfaceOrientationLandscapeLeft);
}

- (void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration{
	
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillDisappear:(BOOL)animated{
	[self.timer invalidate];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (void)dealloc {
    [super dealloc];
	[candleChart release];
	[autoCompleteView release];
	[toolBar release];
	[candleChartFreqView release];
	[autoCompleteDelegate release];
	[req_security_id release];
	[timer release];
	[lastTime release];
	[status release];
	[req_freq release];
	[req_type release];
	[req_url release];
	[req_security_id release];
}

@end
