//  https://github.com/zhiyu/chartee/
//
//  Created by zhiyu on 7/11/11.
//  Copyright 2011 zhiyu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AutoCompleteDelegate : NSObject<UITableViewDelegate,UITableViewDataSource> {
	NSMutableArray * items;
	NSMutableArray * selectedItems;	
	UISearchBar *searchBar;
}

@property (nonatomic, retain) NSMutableArray * items;
@property (nonatomic, retain) NSMutableArray * selectedItems;
@property (nonatomic, retain) UISearchBar *searchBar;

- (id)initWithBar:(UISearchBar *) bar;
@end
