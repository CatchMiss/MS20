//
//  SongsMode.m
//  TestDemo
//
//  Created by Multak on 2018/7/19.
//  Copyright © 2018年 Multak. All rights reserved.
//

#import "SongsMode.h"

@implementation SongsMode

- (instancetype)initWithDict:(NSDictionary *)dict
{
    self = [super init];
    
    if(self){
        [self setValuesForKeysWithDictionary:dict];
    }
    return self;
}

+ (instancetype)songWithDict:(NSDictionary *)dict
{
    return [[self alloc] initWithDict:dict];
}

+ (NSArray*)songsWithArray:(NSArray*)array;
{
    NSMutableArray* marray = [NSMutableArray array];
    for(NSDictionary* dict in array){
        // 添加模型
        [marray addObject:[self songWithDict:dict]];
    }
    return marray;
}

@end
