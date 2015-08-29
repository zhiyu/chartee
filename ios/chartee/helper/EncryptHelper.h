//  https://github.com/zhiyu/chartee/
//
//  Created by zhiyu on 7/11/11.
//  Copyright 2011 zhiyu. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface EncryptHelper : NSObject {

}

+(NSString *) md5:(NSString *) str;
+(NSString *)fileMd5:(NSString *) path;

@end
