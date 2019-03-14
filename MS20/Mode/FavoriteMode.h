//
//  FavoriteMode.h
//  TestDemo
//
//  Created by Multak on 2018/7/25.
//  Copyright © 2018年 Multak. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SongsMode.h"

@interface FavoriteMode : NSObject

//索引
@property (nonatomic, copy) NSString* index;

//歌曲数组
@property (nonatomic, strong) NSArray* songs;

+ (NSMutableArray*)favoritedbSongsWithProgArray:(NSArray*)progArray;
+ (NSMutableArray*)favoritedbSongsWithProgArray:(NSArray*)progArray SQLstring:(NSString*)string;

+ (void)addFavoriteWithSongMode:(SongsMode*)song;
+ (void)deleteFavoriteWithSongMode:(SongsMode*)song;


@end
