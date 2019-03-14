//
//  SongsMode.h
//  TestDemo
//
//  Created by Multak on 2018/7/19.
//  Copyright © 2018年 Multak. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SongsMode : NSObject

@property (nonatomic,assign) int songIndex;
@property (nonatomic,assign) int fileType;
@property (nonatomic,assign) int subFileType;
@property (nonatomic,assign) int lanType;

@property (nonatomic,copy) NSString* firstWord;
@property (nonatomic,copy) NSString* songName;
@property (nonatomic,copy) NSString* singerName;

@property (nonatomic,assign) Boolean need_favo;
@property (nonatomic,assign) Boolean favo;
@property (nonatomic,assign) Boolean pro;
@property (nonatomic,copy) NSString* filename;
@property (nonatomic,copy) NSString* singerIcon;

- (instancetype)initWithDict:(NSDictionary*)dict;
+ (instancetype)songWithDict:(NSDictionary*)dict;

+ (NSArray*)songsWithArray:(NSArray*)array;

@end
