//
//  String.m
//  tzz
//
//  Created by zzy on 10/26/11.
//  Copyright 2011 Zhengzhiyu. All rights reserved.
//

#import "NSString.h"


@implementation NSString(Helpers)

-(NSString *)toUTF8String{  
    CFStringRef nonAlphaNumValidChars = CFSTR("![DISCUZ_CODE_1]’()*+,-./:;=?@_~");          
    NSString *preprocessedString = (NSString *)CFURLCreateStringByReplacingPercentEscapesUsingEncoding(kCFAllocatorDefault, (CFStringRef)self, CFSTR(""), kCFStringEncodingUTF8);          
    NSString *newStr = [(NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,(CFStringRef)preprocessedString,NULL,nonAlphaNumValidChars,kCFStringEncodingUTF8) autorelease];  
    [preprocessedString release];  
    return newStr;          
}

@end
