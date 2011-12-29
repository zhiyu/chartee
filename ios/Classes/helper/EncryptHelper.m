//  https://github.com/zhiyu/chartee/
//
//  Created by zhiyu on 7/11/11.
//  Copyright 2011 zhiyu. All rights reserved.
//

#import "EncryptHelper.h"
#import <commoncrypto/CommonDigest.h>  

#define CHUNK_SIZE 1024

@implementation EncryptHelper

+(NSString *) md5:(NSString *) str{  
    const char *cStr = [str UTF8String];  
    unsigned char result[CC_MD5_DIGEST_LENGTH];  
    CC_MD5( cStr, strlen(cStr), result );
    NSMutableString *hash = [NSMutableString string];
    for(int i=0;i<CC_MD5_DIGEST_LENGTH;i++)
    {
        [hash appendFormat:@"%02X",result[i]];
    }
    return [hash lowercaseString];
}


+(NSString *)fileMd5:(NSString *) path {  
    NSFileHandle* handle = [NSFileHandle fileHandleForReadingAtPath:path];  
    if(handle == nil)  
        return nil;
    CC_MD5_CTX md5_ctx;  
    CC_MD5_Init(&md5_ctx);
    NSData* filedata;  
    do {  
        filedata = [handle readDataOfLength:CHUNK_SIZE];  
        CC_MD5_Update(&md5_ctx, [filedata bytes], [filedata length]);  
    }  
    while([filedata length]);
	
    unsigned char result[CC_MD5_DIGEST_LENGTH];  
    CC_MD5_Final(result, &md5_ctx);  
    [handle closeFile];  
    NSMutableString *hash = [NSMutableString string];
    for(int i=0;i<CC_MD5_DIGEST_LENGTH;i++){
        [hash appendFormat:@"%02x",result[i]];
    }
    return [hash lowercaseString];
}

@end
