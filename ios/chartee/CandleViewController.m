//  https://github.com/zhiyu/chartee/
//
//  Created by zhiyu on 7/11/11.
//  Copyright 2011 zhiyu. All rights reserved.
//

#import "CandleViewController.h"
#import "ASIHTTPRequest.h"
#import "ResourceHelper.h"
#import "JSONKit.h"
#import <QuartzCore/QuartzCore.h>

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

    //candleChart
    self.candleChart = [[Chart alloc] initWithFrame:CGRectMake(0, 62, self.view.frame.size.width, self.view.frame.size.height-62)];
    [self.view addSubview:candleChart];

    //toolbar
    self.toolBar = [[UIView alloc] initWithFrame:CGRectMake(0, 22, self.view.frame.size.width, 40)];

    [self.view addSubview:toolBar];
    //status bar
    self.status = [[UILabel alloc] initWithFrame:CGRectMake(220, 0, 200, 40)];
    self.status.font = [UIFont systemFontOfSize:14];
    self.status.backgroundColor = [UIColor clearColor];
    self.status.textColor = [UIColor whiteColor];
    [self.toolBar addSubview:status];


    UIImage *btnImg = [ResourceHelper loadImage:@"candle_chart"];
    UIImage *btnImgBg = [ResourceHelper loadImage:[@"candle_chart" stringByAppendingFormat:@"_%@",@"selected"]];
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.tag = 2;
    [btn setFrame:CGRectMake(0,0, 80, 40)];
    [btn setImage:btnImg forState:UIControlStateNormal];
    [btn setImage:btnImgBg forState:UIControlStateSelected];
    [btn addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.toolBar addSubview:btn];

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

    btnImg = [ResourceHelper loadImage:@"k1d"];
    btnImgBg = [ResourceHelper loadImage:[@"k1d" stringByAppendingFormat:@"_%@",@"selected"]];
    btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.tag = 26;
    [btn setFrame:CGRectMake(0,0, 120, 40)];
    [btn setImage:btnImg forState:UIControlStateNormal];
    [btn setImage:btnImgBg forState:UIControlStateSelected];
    [btn addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [candleChartFreqView addSubview:btn];

    btnImg = [ResourceHelper loadImage:@"k1w"];
    btnImgBg = [ResourceHelper loadImage:[@"k1w" stringByAppendingFormat:@"_%@",@"selected"]];
    btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.tag = 27;
    [btn setFrame:CGRectMake(0,40, 120, 40)];
    [btn setImage:btnImg forState:UIControlStateNormal];
    [btn setImage:btnImgBg forState:UIControlStateSelected];
    [btn addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [candleChartFreqView addSubview:btn];

    btnImg = [ResourceHelper loadImage:@"k1m"];
    btnImgBg = [ResourceHelper loadImage:[@"k1m" stringByAppendingFormat:@"_%@",@"selected"]];
    btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.tag = 28;
    [btn setFrame:CGRectMake(0,80, 120, 40)];
    [btn setImage:btnImg forState:UIControlStateNormal];
    [btn setImage:btnImgBg forState:UIControlStateSelected];
    [btn addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [candleChartFreqView addSubview:btn];

    [self.view addSubview:candleChartFreqView];


    //init chart
    [self initChart];

    //load securities
    self.autoCompleteDelegate = [[AutoCompleteDelegate alloc] initWithBar:searchBar];
    self.autoCompleteView = [[UITableView alloc]initWithFrame:CGRectMake(self.view.frame.size.width-240, 62, 240, 0)];
    self.autoCompleteView.separatorStyle=UITableViewCellSeparatorStyleNone;
    self.autoCompleteView.showsVerticalScrollIndicator = YES;
    self.autoCompleteView.delegate = autoCompleteDelegate;
    self.autoCompleteView.dataSource = autoCompleteDelegate;
    self.autoCompleteView.hidden = YES;
    [self.view addSubview:autoCompleteView];
    [ResourceHelper setUserDefaults:nil forKey:@"autocompTime"];
    [self getAutoCompleteData];

    //load default security data
    searchBar.text = @"宝钢股份（600019.SS）";
    [self searchBarSearchButtonClicked:searchBar];


}


-(void)viewWillAppear:(BOOL)animated{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

-(void)initChart{
    NSMutableArray *padding = [@[@"20", @"20", @"20", @"20"] mutableCopy];
    [self.candleChart setPadding:padding];
    NSMutableArray *secs = [[NSMutableArray alloc] init];
    [secs addObject:@"4"];
    [secs addObject:@"1"];
    [secs addObject:@"1"];
    [self.candleChart addSections:3 withRatios:secs];
    [self.candleChart getSection:2].hidden = YES;
    [[self.candleChart sections][0] addYAxis:0];
    [[self.candleChart sections][1] addYAxis:0];
    [[self.candleChart sections][2] addYAxis:0];

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
    serie[@"name"] = @"price";
    serie[@"label"] = @"Price";
    serie[@"data"] = data;
    serie[@"type"] = @"candle";
    serie[@"yAxis"] = @"0";
    serie[@"section"] = @"0";
    serie[@"color"] = @"249,222,170";
    serie[@"negativeColor"] = @"249,222,170";
    serie[@"selectedColor"] = @"249,222,170";
    serie[@"negativeSelectedColor"] = @"249,222,17/**/0";
    serie[@"labelColor"] = @"176,52,52";
    serie[@"labelNegativeColor"] = @"77,143,42";
    [series addObject:serie];
    [secOne addObject:serie];

    //MA10
    serie = [[NSMutableDictionary alloc] init];
    data = [[NSMutableArray alloc] init];
    serie[@"name"] = @"ma10";
    serie[@"label"] = @"MA10";
    serie[@"data"] = data;
    serie[@"type"] = @"line";
    serie[@"yAxis"] = @"0";
    serie[@"section"] = @"0";
    serie[@"color"] = @"255,255,255";
    serie[@"negativeColor"] = @"255,255,255";
    serie[@"selectedColor"] = @"255,255,255";
    serie[@"negativeSelectedColor"] = @"255,255,255";
    [series addObject:serie];
    [secOne addObject:serie];

    //MA30
    serie = [[NSMutableDictionary alloc] init];
    data = [[NSMutableArray alloc] init];
    serie[@"name"] = @"ma30";
    serie[@"label"] = @"MA30";
    serie[@"data"] = data;
    serie[@"type"] = @"line";
    serie[@"yAxis"] = @"0";
    serie[@"section"] = @"0";
    serie[@"color"] = @"250,232,115";
    serie[@"negativeColor"] = @"250,232,115";
    serie[@"selectedColor"] = @"250,232,115";
    serie[@"negativeSelectedColor"] = @"250,232,115";
    [series addObject:serie];
    [secOne addObject:serie];

    //MA60
    serie = [[NSMutableDictionary alloc] init];
    data = [[NSMutableArray alloc] init];
    serie[@"name"] = /**/@"ma60";
    serie[@"label"] = @"MA60";
    serie[@"data"] = data;
    serie[@"type"] = @"line";
    serie[@"yAxis"] = @"0";
    serie[@"section"] = @"0";
    serie[@"color"] = @"232,115,250";
    serie[@"negativeColor"] = @"232,115,250";
    serie[@"selectedColor"] = @"232,115,250";
    serie[@"negativeSelectedColor"] = @"232,115,250";
    [series addObject:serie];
    [secOne addObject:serie];


    //VOL
    serie = [[NSMutableDictionary alloc] init];
    data = [[NSMutableArray alloc] init];
    serie[@"name"] = @"vol";
    serie[@"label"] = @"VOL";
    serie[@"data"] = data;
    serie[@"type"] = @"column";
    serie[@"yAxis"] = @"0";
    serie[@"section"] = @"1";
    serie[@"decimal"] = @"0";
    serie[@"color"] = @"176,52,52";
    serie[@"negativeColor"] = @"77,143,42";
    serie[@"selectedColor"] = @"176,52,52";
    serie[@"negativeSelectedColor"] = @"77,143,42";
    [series addObject:serie];
    [secTwo addObject:serie];

    //candleChart init
    [self.candleChart setSeries:series];

    [[self.candleChart sections][0] setSeries:secOne];
    [[self.candleChart sections][1] setSeries:secTwo];
    [[self.candleChart sections][2] setSeries:secThree];
    [[self.candleChart sections][2] setPaging:YES];


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
                }
                [self.candleChart addSerie:arr];
            }else{
                NSDictionary *indic = (NSDictionary *)indicator;
                NSMutableDictionary *serie = [[NSMutableDictionary alloc] init];
                [self setOptions:indic ForSerie:serie];
                [self.candleChart addSerie:serie];
            }
        }
    }

    CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    pathAnimation.duration = 10.0/**/;
    pathAnimation.fromValue = @0.0f;
    pathAnimation.toValue = @1.0f;
    [self.candleChart.layer addAnimation:pathAnimation forKey:@"strokeEndAnimation"];

}

-(void)setOptions:(NSDictionary *)options ForSerie:(NSMutableDictionary *)serie;{
    serie[@"name"] = options[@"name"];
    serie[@"label"] = options[@"label"];
    serie[@"type"] = options[@"type"];
    serie[@"yAxis"] = options[@"yAxis"];
    serie[@"section"] = options[@"section"];
    serie[@"color"] = options[@"color"];
    serie[@"negativeColor"] = options[@"negativeColor"];
    serie[@"selectedColor"] = options[@"selectedColor"];
    serie[@"negativeSelectedColor"] = options[@"negativeSelectedColor"];
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
        if([item[0] hasPrefix:searchText]){
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
        self.req_security_id = [[[searchBar text] componentsSeparatedByString:@"（"][1] componentsSeparatedByString:@"）"][0];
        [self getData];
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar{
    NSLog(@"CancelButtonClicked");
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [searchBar resignFirstResponder];
    self.req_security_id = [[[searchBar text] componentsSeparatedByString:@"（"][1] componentsSeparatedByString:@"）"][0];
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
        NSString *line = lines[idx];
        if([line isEqualToString:@""]){
            continue;
        }
        NSArray   *arr = [line componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@","]];
        [category addObject:arr[0]];

        NSMutableArray *item =[[NSMutableArray alloc] init];
        [item addObject:arr[1]];
        [item addObject:arr[4]];
        [item addObject:arr[2]];
        [item addObject:arr[3]];
        [item addObject:arr[5]];
        [data addObject:item];
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
            NSString *time = category[0];
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

    if(chartMode == 0){
        [self setCategory:category];
    }else{
        NSMutableArray *cate = [[NSMutableArray alloc] init];
        for(int i=60;i<category.count;i++){
            [cate addObject:category[i]];
        }
        [self setCategory:cate];
    }

    [self.candleChart setNeedsDisplay];
}

-(void)generateData:(NSMutableDictionary *)dic From:(NSArray *)data{
    if(self.chartMode == 1){
        //price
        NSMutableArray *price = [[NSMutableArray alloc] init];
        for(int i = 60;i < data.count;i++){
            [price addObject:data[i]];
        }
        dic[@"price"] = price;

        //VOL
        NSMutableArray *vol = [[NSMutableArray alloc] init];
        for(int i = 60;i < data.count;i++){
            NSMutableArray *item = [[NSMutableArray alloc] init];
            [item addObject:[@"" stringByAppendingFormat:@"%f",[[data[i] objectAtIndex:4] floatValue]/100]];
            [vol addObject:item];
        }
        dic[@"vol"] = vol;

        //MA 10
        NSMutableArray *ma10 = [[NSMutableArray alloc] init];
        for(int i = 60;i < data.count;i++){
            float val = 0;
            for(int j=i;j>i-10;j--){
                val += [[data[j] objectAtIndex:1] floatValue];
            }
            val = val/10;
            NSMutableArray *item = [[NSMutableArray alloc] init];
            [item addObject:[@"" stringByAppendingFormat:@"%f",val]];
            [ma10 addObject:item];
        }
        dic[@"ma10"] = ma10;

        //MA 30
        NSMutableArray *ma30 = [[NSMutableArray alloc] init];
        for(int i = 60;i < data.count;i++){
            float val = 0;
            for(int j=i;j>i-30;j--){
                val += [[data[j] objectAtIndex:1] floatValue];
            }
            val = val/30;
            NSMutableArray *item = [[NSMutableArray alloc] init];
            [item addObject:[@"" stringByAppendingFormat:@"%f",val]];
            [ma30 addObject:item];
        }
        dic[@"ma30"] = ma30;

        //MA 60
        NSMutableArray *ma60 = [[NSMutableArray alloc] init];
        for(int i = 60;i < data.count;i++){
            float val = 0;
            for(int j=i;j>i-60;j--){
                val += [[data[j] objectAtIndex:1] floatValue];
            }
            val = val/60;
            NSMutableArray *item = [[NSMutableArray alloc] init];
            [item addObject:[@"" stringByAppendingFormat:@"%f",val]];
            [ma60 addObject:item];
        }
        dic[@"ma60"] = ma60;

        //RSI6
        NSMutableArray *rsi6 = [[NSMutableArray alloc] init];
        for(int i = 60;i < data.count;i++){
            float incVal  = 0;
            float decVal = 0;
            float rs = 0;
            for(int j=i;j>i-6;j--){
                float interval = [[data[j] objectAtIndex:1] floatValue]-[[data[j] objectAtIndex:0] floatValue];
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

        }
        dic[@"rsi6"] = rsi6;

        //RSI12
        NSMutableArray *rsi12 = [[NSMutableArray alloc] init];
        for(int i = 60;i < data.count;i++){
            float incVal  = 0;
            float decVal = 0;
            float rs = 0;
            for(int j=i;j>i-12;j--){
                float interval = [[data[j] objectAtIndex:1] floatValue]-[[data[j] objectAtIndex:0] floatValue];
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
        }
        dic[@"rsi12"] = rsi12;

        //WR
        NSMutableArray *wr = [[NSMutableArray alloc] init];
        for(int i = 60;i < data.count;i++){
            float h  = [[data[i] objectAtIndex:2] floatValue];
            float l = [[data[i] objectAtIndex:3] floatValue];
            float c = [[data[i] objectAtIndex:1] floatValue];
            for(int j=i;j>i-10;j--){
                if([[data[j] objectAtIndex:2] floatValue] > h){
                    h = [[data[j] objectAtIndex:2] floatValue];
                }

                if([[data[j] objectAtIndex:3] floatValue] < l){
                    l = [[data[j] objectAtIndex:3] floatValue];
                }
            }

            float val = (h-c)/(h-l)*100;
            NSMutableArray *item = [[NSMutableArray alloc] init];
            [item addObject:[@"" stringByAppendingFormat:@"%f",val]];
            [wr addObject:item];
        }
        dic[@"wr"] = wr;

        //KDJ
        NSMutableArray *kdj_k = [[NSMutableArray alloc] init];
        NSMutableArray *kdj_d = [[NSMutableArray alloc] init];
        NSMutableArray *kdj_j = [[NSMutableArray alloc] init];
        float prev_k = 50;
        float prev_d = 50;
        float rsv = 0;
        for(int i = 60;i < data.count;i++){
            float h  = [[data[i] objectAtIndex:2] floatValue];
            float l = [[data[i] objectAtIndex:3] floatValue];
            float c = [[data[i] objectAtIndex:1] floatValue];
            for(int j=i;j>i-10;j--){
                if([[data[j] objectAtIndex:2] floatValue] > h){
                    h = [[data[j] objectAtIndex:2] floatValue];
                }

                if([[data[j] objectAtIndex:3] floatValue] < l){
                    l = [[data[j] objectAtIndex:3] floatValue];
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
            NSMutableArray *itemD = [[NSMutableArray alloc] init];
            [itemD addObject:[@"" stringByAppendingFormat:@"%f",d]];
            [kdj_d addObject:itemD];
            NSMutableArray *itemJ = [[NSMutableArray alloc] init];
            [itemJ addObject:[@"" stringByAppendingFormat:@"%f",j]];
            [kdj_j addObject:itemJ];
        }
        dic[@"kdj_k"] = kdj_k;
        dic[@"kdj_d"] = kdj_d;
        dic[@"kdj_j"] = kdj_j;

        //VR
        NSMutableArray *vr = [[NSMutableArray alloc] init];
        for(int i = 60;i < data.count;i++){
            float inc = 0;
            float dec = 0;
            float eq  = 0;
            for(int j=i;j>i-24;j--){
                float o = [[data[j] objectAtIndex:0] floatValue];
                float c = [[data[j] objectAtIndex:1] floatValue];

                if(c > o){
                    inc += [[data[j] objectAtIndex:4] intValue];
                }else if(c < o){
                    dec += [[data[j] objectAtIndex:4] intValue];
                }else{
                    eq  += [[data[j] objectAtIndex:4] intValue];
                }
            }

            float val = (inc+1*eq/2)/(dec+1*eq/2);
            NSMutableArray *item = [[NSMutableArray alloc] init];
            [item addObject:[@"" stringByAppendingFormat:@"%f",val]];
            [vr addObject:item];
        }
        dic[@"vr"] = vr;

    }else{
        //price
        NSMutableArray *price = [[NSMutableArray alloc] init];
        for(int i = 0;i < data.count;i++){
            [price addObject:data[i]];
        }
        dic[@"price"] = price;

        //VOL
        NSMutableArray *vol = [[NSMutableArray alloc] init];
        for(int i = 0;i < data.count;i++){
            NSMutableArray *item = [[NSMutableArray alloc] init];
            [item addObject:[@"" stringByAppendingFormat:@"%f",[[data[i] objectAtIndex:4] floatValue]/100]];
            [vol addObject:item];
        }
        dic[@"vol"] = vol;

    }
}

-(void)setData:(NSDictionary *)dic{
    [self.candleChart appendToData:dic[@"price"] forName:@"price"];
    [self.candleChart appendToData:dic[@"vol"] forName:@"vol"];

    [self.candleChart appendToData:dic[@"ma10"] forName:@"ma10"];
    [self.candleChart appendToData:dic[@"ma30"] forName:@"ma30"];
    [self.candleChart appendToData:dic[@"ma60"] forName:@"ma60"];

    [self.candleChart appendToData:dic[@"rsi6"] forName:@"rsi6"];
    [self.candleChart appendToData:dic[@"rsi12"] forName:@"rsi12"];

    [self.candleChart appendToData:dic[@"wr"] forName:@"wr"];
    [self.candleChart appendToData:dic[@"vr"] forName:@"vr"];

    [self.candleChart appendToData:dic[@"kdj_k"] forName:@"kdj_k"];
    [self.candleChart appendToData:dic[@"kdj_d"] forName:@"kdj_d"];
    [self.candleChart appendToData:dic[@"kdj_j"] forName:@"kdj_j"];

    NSMutableDictionary *serie = [self.candleChart getSerie:@"price"];
    if(serie == nil)
        return;
    if(self.chartMode == 1){
        serie[@"type"] = @"candle";
    }else{
        serie[@"type"] = @"line";
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

@end
