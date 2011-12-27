//
//  CharteeViewController.m
//  https://github.com/zhiyu/chartee/
//
//  Created by zhiyu on 7/11/11.
//  Copyright 2011 zhiyu. All rights reserved.
//

#import "CharteeViewController.h"
#import "ResourceHelper.h"

@implementation CharteeViewController

@synthesize kline;
@synthesize toolBar;
@synthesize chartMode;
@synthesize req_security_id;

- (void)viewDidLoad {
    [super viewDidLoad];
	
	//init
	self.chartMode  = 0; //0-default,1-kline
    self.req_security_id = @"000002.SZ";
	
	[self.view setFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.height, [[UIScreen mainScreen] bounds].size.width)];
	self.view.backgroundColor =[[UIColor alloc] initWithRed:0.8 green:0.8 blue:0.8 alpha:1];
	
	//kline
	self.kline = [[CandleChart alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-40)];
	[self.view addSubview:kline];
	
	//toolbar
	self.toolBar = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 40, self.view.frame.size.width, 40)];
	[self.toolBar release];
		
	toolBar.backgroundColor = [[UIColor alloc] initWithRed:0.8 green:0.8 blue:0.8 alpha:1];
	[self.view addSubview:toolBar];
	[toolBar release];
	
    UIImage *btnImg = [[ResourceHelper loadImage:@"fenshi"] retain];
	UIImage *btnImgBg = [[ResourceHelper loadImage:[@"fenshi" stringByAppendingFormat:@"_%@",@"selected"]] retain];
	UIButton *btn = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
	btn.tag = 1;
	btn.selected = YES;
	[btn setFrame:CGRectMake(0,0, 60, 40)];
	[btn setImage:btnImg forState:UIControlStateNormal];
	[btn setImage:btnImgBg forState:UIControlStateSelected];
	[btn addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
	[self.toolBar addSubview:btn];
	[btn release];
	[btnImg release];
	
	btnImg = [[ResourceHelper loadImage:@"kline"] retain];
	btnImgBg = [[ResourceHelper loadImage:[@"kline" stringByAppendingFormat:@"_%@",@"selected"]] retain];
	btn = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
	btn.tag = 2;
	[btn setFrame:CGRectMake(60,0, 60, 40)];
	[btn setImage:btnImg forState:UIControlStateNormal];
	[btn setImage:btnImgBg forState:UIControlStateSelected];
	[btn addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
	[self.toolBar addSubview:btn];
	[btn release];
	[btnImg release];
		
	//kline init
	NSMutableArray *padding = [NSMutableArray arrayWithObjects:@"20",@"20",@"20",@"20",nil];
	[self.kline setPadding:padding];
	NSMutableArray *secs = [[NSMutableArray alloc] init];
	[secs addObject:@"4"];
	[secs addObject:@"1"];
	[secs addObject:@"1"];
	[self.kline addSections:3 withRatios:secs];
	[self.kline getSection:2].hidden = YES;
	[[[self.kline sections] objectAtIndex:0] addYAxis:0];
	[[[self.kline sections] objectAtIndex:1] addYAxis:0];
	[[[self.kline sections] objectAtIndex:2] addYAxis:0];
	
	[self.kline getYAxisInSection:2 AtIndex:0].baseValueSticky = NO;
	[self.kline getYAxisInSection:2 AtIndex:0].symmetrical = NO;
	[self.kline getYAxisInSection:0 AtIndex:0].ext = 0.05;
	NSMutableArray *series = [[NSMutableArray alloc] init];
	NSMutableArray *secOne = [[NSMutableArray alloc] init];
	NSMutableArray *secTwo = [[NSMutableArray alloc] init];
	NSMutableArray *secThree = [[NSMutableArray alloc] init];
	
	//price
	NSMutableDictionary *serie = [[NSMutableDictionary alloc] init]; 
	NSMutableArray *data = [[NSMutableArray alloc] init];
	[serie setObject:@"price" forKey:@"name"];
	[serie setObject:@"价格" forKey:@"label"];
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
	
	
	//kline init
    [self.kline setSeries:series];
	[series release];
	
	[[[self.kline sections] objectAtIndex:0] setSeries:secOne];
	[secOne release];
	[[[self.kline sections] objectAtIndex:1] setSeries:secTwo];
	[secTwo release];
	[[[self.kline sections] objectAtIndex:2] setSeries:secThree];
	[[[self.kline sections] objectAtIndex:2] setPaging:YES];
	[secThree release];
	
	
	NSString *indicatorsString = nil;
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	if ([paths count] > 0){
		indicatorsString =[NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"indicators" ofType:@"json"] encoding:NSUTF8StringEncoding error:nil];		
	}
	
	if(indicatorsString != nil){
		NSArray *indicators = [indicatorsString JSONValue];
		for(NSObject *indicator in indicators){
			if([indicator isKindOfClass:[NSArray class]]){
				NSMutableArray *arr = [[NSMutableArray alloc] init];
				for(NSDictionary *indic in indicator){
					NSMutableDictionary *serie = [[NSMutableDictionary alloc] init]; 
					[self setOptions:indic ForSerie:serie];
					[arr addObject:serie];
					[serie release];
				}
			    [self.kline addSerie:arr];
				[arr release];
			}else{
				NSDictionary *indic = (NSDictionary *)indicator;
				NSMutableDictionary *serie = [[NSMutableDictionary alloc] init]; 
				[self setOptions:indic ForSerie:serie];
				[self.kline addSerie:serie];
				[serie release];
			}
		}
	}
	
    
    //request data
    [self getData];
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
	btn.selected = YES;
	
    switch (index) {
		case 1:{
			UIButton *sel = (UIButton *)[self.toolBar viewWithTag:2];
			sel.selected = NO;
			self.chartMode  = 0;
			[self getData];
			break;
	    }
		case 2:{
			UIButton *sel = (UIButton *)[self.toolBar viewWithTag:1];
			sel.selected = NO;
			self.chartMode  = 1;
			[self getData];
			break;
	    }
        default:
			break;
    }

}

-(void)getData{
	if(chartMode == 0){
		[self.kline getSection:2].hidden = YES;
	}else{
	    [self.kline getSection:2].hidden = NO;
	}
	
    NSMutableDictionary *res = [[NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"demo_data" ofType:@"json"] encoding:NSUTF8StringEncoding error:nil] JSONValue];
    NSArray *data =[[res objectForKey:req_security_id] objectForKey:@"data"];
    NSLog(@"%d",data.count);
	NSArray *category =[[res objectForKey:req_security_id] objectForKey:@"category"];
	
	[self.kline reset];
    [self.kline clearData];
    [self.kline clearCategory];
    
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
	
	[self.kline setNeedsDisplay];
    
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
			[item addObject:[@"" stringByAppendingFormat:@"%f",[[[data objectAtIndex:i] objectAtIndex:5] floatValue]/100]];
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
			
			float rsv = (c-l)/(h-l)*100;
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
				    inc += [[[data objectAtIndex:j] objectAtIndex:5] intValue];
				}else if(c < o){
				    dec += [[[data objectAtIndex:j] objectAtIndex:5] intValue];
				}else{
				    eq  += [[[data objectAtIndex:j] objectAtIndex:5] intValue];
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
			[item addObject:[@"" stringByAppendingFormat:@"%f",[[[data objectAtIndex:i] objectAtIndex:5] floatValue]/100]];
			[vol addObject:item];
			[item release];
		}
		[dic setObject:vol forKey:@"vol"];
		[vol release];
		
	}
}

-(void)setData:(NSDictionary *)dic{
	[self.kline appendToData:[dic objectForKey:@"price"] forName:@"price"];
	[self.kline appendToData:[dic objectForKey:@"vol"] forName:@"vol"];
	
	[self.kline appendToData:[dic objectForKey:@"ma10"] forName:@"ma10"];
	[self.kline appendToData:[dic objectForKey:@"ma30"] forName:@"ma30"];
	[self.kline appendToData:[dic objectForKey:@"ma60"] forName:@"ma60"];
	
	[self.kline appendToData:[dic objectForKey:@"rsi6"] forName:@"rsi6"];
	[self.kline appendToData:[dic objectForKey:@"rsi12"] forName:@"rsi12"];
	
	[self.kline appendToData:[dic objectForKey:@"wr"] forName:@"wr"];
	[self.kline appendToData:[dic objectForKey:@"vr"] forName:@"vr"];
	
	[self.kline appendToData:[dic objectForKey:@"kdj_k"] forName:@"kdj_k"];
	[self.kline appendToData:[dic objectForKey:@"kdj_d"] forName:@"kdj_d"];
	[self.kline appendToData:[dic objectForKey:@"kdj_j"] forName:@"kdj_j"];
	
	NSMutableDictionary *serie = [self.kline getSerieByName:@"price"];
	if(serie == nil)
		return;
	if(self.chartMode == 1){
		[serie setObject:@"candle" forKey:@"type"];
	}else{
		[serie setObject:@"line" forKey:@"type"];
	}
}

-(void)setCategory:(NSArray *)category{
	[self.kline appendToCategory:category forName:@"price"];
	[self.kline appendToCategory:category forName:@"line"];
	
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillDisappear:(BOOL)animated{

}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (void)dealloc {
    [super dealloc];
	[kline release];
	[toolBar release];
	[req_security_id release];
}

@end
