//
//  Convert.m
//  TestDemo
//
//  Created by Multak on 2018/7/23.
//  Copyright © 2018年 Multak. All rights reserved.
//

#import "Convert.h"

@implementation Convert

+ (NSString*)transformString:(NSString *)string
{
    NSMutableString* str = [[NSMutableString alloc] initWithString:string];
    CFStringTransform((CFMutableStringRef)str, NULL, kCFStringTransformMandarinLatin, NO);
    CFStringTransform((CFMutableStringRef)str, NULL, kCFStringTransformStripDiacritics, NO);
    //NSString* result = [[str uppercaseString] stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSString* result = [str uppercaseString];
    return result;
}

@end
