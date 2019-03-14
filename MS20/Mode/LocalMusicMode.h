//
//  LocalMusicMode.h
//  TestDemo
//
//  Created by Multak on 2018/6/4.
//  Copyright © 2018年 Multak. All rights reserved.
//

/**
 本地音乐模型
 
 */

#import <Foundation/Foundation.h>

@interface LocalMusicMode : NSObject

//索引
@property (nonatomic, copy) NSString* index;

//歌曲数组
@property (nonatomic, strong) NSArray* songs;

//字典转化成本地音乐模型
- (instancetype)initWithDict:(NSDictionary*)dict;
+ (instancetype)localMusicWithDict:(NSDictionary*)dict;

+ (NSMutableArray*)localMusicList;
+ (NSMutableArray*)localMusicListWithString:(NSString*)string;

@end
