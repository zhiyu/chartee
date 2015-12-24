//  https://github.com/zhiyu/chartee/
//
//  Created by zhiyu on 7/11/11.
//  Copyright 2011 zhiyu. All rights reserved.
//

#import "AutoCompleteDelegate.h"

@implementation AutoCompleteDelegate

@synthesize items;
@synthesize selectedItems;
@synthesize searchBar;

- (id)initWithBar:(UISearchBar *) bar{
	if(self = [super init]){
		self.searchBar = bar;
	}
	return self;
}

// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return NO;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [self.selectedItems count];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    static NSString *cellIdentifier = @"Cell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
		CGRect cellFrame = [cell frame];
		[cell setFrame:CGRectMake(cellFrame.origin.x, cellFrame.origin.y, cellFrame.size.width, 20)];
		[[cell textLabel] setFont:[UIFont systemFontOfSize:16]];
		cell.showsReorderControl=YES;
    }

	NSUInteger row=[indexPath row];
	cell.textLabel.backgroundColor = [UIColor clearColor];

	if (self.selectedItems!=nil) {
	    cell.textLabel.text = [[self.selectedItems[row] objectAtIndex:1] stringByAppendingFormat:@"   %@", [self.selectedItems[row] objectAtIndex:0]];
	}else {
		cell.textLabel.text = @"正在加载数据...";
	}
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row%2 ==0){
		cell.backgroundColor = [[UIColor alloc] initWithRed:1 green:1 blue:1 alpha:0];;
	}else {
		cell.backgroundColor = [[UIColor alloc] initWithRed:1 green:1 blue:1 alpha:0];
	}
}

-(void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath{
    NSInteger row = indexPath.row;
	self.searchBar.text = [[self.selectedItems[row] objectAtIndex:1] stringByAppendingFormat:@"（%@）", [self.selectedItems[row] objectAtIndex:0]];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
	[self tableView:tableView accessoryButtonTappedForRowWithIndexPath:indexPath];
}

@end

