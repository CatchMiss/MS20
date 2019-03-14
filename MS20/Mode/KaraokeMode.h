//
//  KaraokeMode.h
//  TestDemo
//
//  Created by Multak on 2018/6/5.
//  Copyright © 2018年 Multak. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KaraokeMode : NSObject

//索引
@property (nonatomic, copy) NSString* index;

//歌曲数组
@property (nonatomic, strong) NSArray* songs;

////字典转化成karaoke模型
//- (instancetype)initWithDict:(NSDictionary*)dict;
//+ (instancetype)karaokeWithDict:(NSDictionary*)dict;
//+ (NSMutableArray*)karaokeSongs;

+ (NSMutableArray*)karaokedbSongsWithProgArray:(NSArray*)progArray;
+ (NSMutableArray*)karaokedbSongsWithProgArray:(NSArray*)progArray SQLstring:(NSString*)string;

@end
