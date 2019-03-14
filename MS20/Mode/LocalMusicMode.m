//
//  LocalMusicMode.m
//  TestDemo
//
//  Created by Multak on 2018/6/4.
//  Copyright © 2018年 Multak. All rights reserved.
//

#import "LocalMusicMode.h"
#import "SongsMode.h"
#import "Convert.h"

@implementation LocalMusicMode

//- (instancetype)initWithDict:(NSDictionary *)dict
//{
//    self = [super init];
//
//    if(self){
//        [self setValuesForKeysWithDictionary:dict];
//    }
//    return self;
//}
//
//+ (instancetype)localMusicWithDict:(NSDictionary *)dict
//{
//    return [[self alloc] initWithDict:dict];
//}
//
//+ (NSArray*)localMusicList
//{
//    NSArray* array = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Musics.plist" ofType:nil]];
//
//    NSMutableArray* marray = [NSMutableArray array];
//    for(NSDictionary* dict in array){
//        // 添加模型
//        [marray addObject:[self localMusicWithDict:dict]];
//    }
//    return marray;
//}

#pragma mark ==本地音乐模型==
- (instancetype)initWithDict:(NSDictionary *)dict
{
    self = [super init];

    if(self){
        [self setValue:dict[@"index"] forKey:@"index"];
        self.songs = [SongsMode songsWithArray:dict[@"songs"]];
    }
    return self;
}

+ (instancetype)localMusicWithDict:(NSDictionary *)dict
{
    return [[self alloc] initWithDict:dict];
}

+ (NSMutableArray*)localMusicList
{
    NSArray* array = [self localMusicSongsWithString:@""];

    NSMutableArray* marray = [NSMutableArray array];
    for(NSDictionary* dict in array){
        // 添加模型
        [marray addObject:[self localMusicWithDict:dict]];
    }
    return marray;
}

+ (NSMutableArray*)localMusicListWithString:(NSString*)string
{
    string = [string uppercaseString];
    NSArray* array = [self localMusicSongsWithString:string];
    
    NSMutableArray* marray = [NSMutableArray array];
    for(NSDictionary* dict in array){
        // 添加模型
        [marray addObject:[self localMusicWithDict:dict]];
    }
    return marray;
}

+ (NSArray*)localMusicSongsWithString:(NSString*)string
{
    NSArray* indexArray = @[@"#",
                            @"A",@"B",@"C",@"D",@"E",@"F",@"G",@"H",@"I",@"J",@"K",
                            @"L",@"M",@"N",@"O",@"P",@"Q",@"R",@"S",@"T",@"U",@"V",
                            @"W",@"X",@"Y",@"Z",
                            ];
    NSLog(@"indexArray:count(%ld)",indexArray.count);
    
    //初始化歌曲列表
    NSMutableArray* tmpsongs = [NSMutableArray array];
    for(NSString* index in indexArray)
    {
        NSMutableArray* tmparray = [NSMutableArray array];
        NSDictionary* dict = @{@"index":index,@"songs":tmparray};
        [tmpsongs addObject:dict];
    }
    NSLog(@"初始化歌曲列表完成");
    
    NSArray* array = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Musics.plist" ofType:nil]];
    for(NSDictionary* dict in array){
        //NSNumber* songIndex = -1;
        NSString* firstWord = [Convert transformString:dict[@"songname"]];
        //NSLog(@"firstWord: %@",firstWord);
        NSString* songName = dict[@"songname"];
        NSString* singerName = dict[@"singername"];
        NSString* filename = dict[@"filename"];
        NSString* singerIcon = dict[@"singerIcon"];
        
        NSDictionary* songDict = @{
                                //@"songIndex":songIndex,
                                @"firstWord":firstWord,
                                @"songName":songName,
                                @"singerName":singerName,
                                @"filename":filename,
                                @"singerIcon":singerIcon
                                   };
        
        NSInteger inde = [indexArray indexOfObject:[firstWord substringToIndex:1]];

        if(inde != NSNotFound && ([firstWord containsString:string] || string.length == 0))
        {
            [[tmpsongs[inde] valueForKey:@"songs"] addObject:songDict];
        }
        else if([firstWord containsString:string] || string.length == 0)
        {
            [[tmpsongs[0] valueForKey:@"songs"] addObject:songDict];
        }
    }
    
    //过滤歌曲列表
    NSArray* songs = [NSArray arrayWithArray:tmpsongs];
    for(NSDictionary* dict in songs)
    {
        NSArray* array = dict[@"songs"];
        if(array.count == 0){
            [tmpsongs removeObject:dict];
        }
    }
    
//    [tmpsongs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//        NSArray* array = obj[@"songs"];
//        if (array.count == 0) {
//            *stop = YES;
//            if (*stop == YES) {
//                [tmpsongs removeObject:obj];
//            }
//        }
//    }];
    
    return tmpsongs;
}

@end
