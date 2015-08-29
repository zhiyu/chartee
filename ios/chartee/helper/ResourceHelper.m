//  https://github.com/zhiyu/chartee/
//
//  Created by zhiyu on 7/11/11.
//  Copyright 2011 zhiyu. All rights reserved.
//

#import "ResourceHelper.h"

@implementation ResourceHelper

+(UIImage *) loadImageByTheme:(NSString *) name{
	NSString *path = [[NSBundle mainBundle] pathForResource:[((NSString *)[ResourceHelper  getUserDefaults:@"theme"]) stringByAppendingFormat:@"_%@",name] ofType:@"png"];
	return [[UIImage alloc] initWithContentsOfFile:path];
	
}

+(UIImage *) loadImage:(NSString *) name{
    NSString *realName;
    if(UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad){
        realName = [[NSString alloc] initWithFormat:@"pad_%@",name];
    }else{
        realName = [[NSString alloc] initWithFormat:@"phone_%@",name];
    }
	NSString *path = [[NSBundle mainBundle] pathForResource:realName ofType:@"png"];
    
	return [[UIImage alloc] initWithContentsOfFile:path];
}

+(NSObject *) getUserDefaults:(NSString *) name{
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults objectForKey:name];
}

+(void) setUserDefaults:(NSObject *) defaults forKey:(NSString *) key{
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:defaults forKey:key];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

@end
