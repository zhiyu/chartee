//  https://github.com/zhiyu/chartee/
//
//  Created by zhiyu on 7/11/11.
//  Copyright 2011 zhiyu. All rights reserved.
//

#import "CacheHelper.h"


@implementation CacheHelper

+ (void) setObject:(NSData *) data forKey:(NSString *) key withExpires:(int) expires{
	NSDate *dt = [NSDate date];
	double now = [dt timeIntervalSince1970];
    NSMutableString *expiresString = [[NSMutableString alloc] init];
	NSData *dataExpires = [[expiresString stringByAppendingFormat:@"%f",now+expires] dataUsingEncoding:NSUTF8StringEncoding];
	[dataExpires writeToFile:[[self getTempPath:key] stringByAppendingFormat:@"%@",@".expires"] atomically:NO];
    [data writeToFile:[self getTempPath:key] atomically:NO];
}

+ (NSData *) get:(NSString *) key{
	if(![self fileExists:[self getTempPath:key]] || [self isExpired:[self getTempPath:key]]){
		NSLog(@"no cache");
	    return nil;
	}
	
    NSData *data = [NSData dataWithContentsOfFile:[self getTempPath:key]];
	return data;
}

+ (void) clear{

}

+ (NSString *)getTempPath:(NSString*)key{
	NSString *tempPath = NSTemporaryDirectory();
	return [tempPath stringByAppendingPathComponent:key];
}

+ (BOOL)fileExists:(NSString *)filepath{
	NSFileManager *fileManager = [NSFileManager defaultManager];
	return [fileManager fileExistsAtPath:filepath];
}

+ (BOOL)isExpired:(NSString *) key{
	NSData *data = [NSData dataWithContentsOfFile:[key stringByAppendingFormat:@"%@",@".expires"]];
	NSString *expires = [[NSString alloc] initWithData:data  encoding:NSUTF8StringEncoding];
	double exp = [expires doubleValue];
	NSDate *dt = [NSDate date];
	double value = [dt timeIntervalSince1970];
	
	if(exp > value){
		
		return NO;
	}
	return YES;
}

@end