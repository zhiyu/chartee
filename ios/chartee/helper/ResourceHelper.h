//
//  ResourceHelper.h
//  tzz
//
//  Created by zzy on 7/21/11.
//  Copyright 2011 Zhengzhiyu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ResourceHelper : NSObject {

}

+(UIImage *) loadImageByTheme:(NSString *) name;
+(UIImage *) loadImage:(NSString *) name;

+(NSObject *) getUserDefaults:(NSString *) name;
+(void) setUserDefaults:(NSObject *) defaults forKey:(NSString *) key;

@end
