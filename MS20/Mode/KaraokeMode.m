//
//  KaraokeMode.m
//  TestDemo
//
//  Created by Multak on 2018/6/5.
//  Copyright © 2018年 Multak. All rights reserved.
//

#import "KaraokeMode.h"
#import "SongsMode.h"
#import "SongDB.h"

static NSArray* _progarray;

@interface KaraokeMode()

//db转化成karaoke模型
- (instancetype)initWithDB:(NSDictionary*)dict;
+ (instancetype)karaokeWithDB:(NSDictionary*)dict;

@end

@implementation KaraokeMode


#pragma mark ==字典转模型===
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
//+ (instancetype)karaokeWithDict:(NSDictionary *)dict
//{
//    return [[self alloc] initWithDict:dict];
//}
//
//+ (NSMutableArray*)karaokeSongs
//{
//    NSArray* array = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Karaoke.plist" ofType:nil]];
//
//    NSMutableArray* songs = [NSMutableArray array];
//    for(NSDictionary* dict in array){
//        //NSLog(@"1*****%@*******",dict);
//        // 添加模型
//        [songs addObject:[self karaokeWithDict:dict]];
//    }
//    return songs;
//}

#pragma mark ==db转模型==
- (instancetype)initWithDB:(NSDictionary*)dict
{
    self = [super init];
    
    if(self){
        [self setValue:dict[@"index"] forKey:@"index"];
        self.songs = [SongsMode songsWithArray:dict[@"songs"]];
    }
    return self;
}

+ (instancetype)karaokeWithDB:(NSDictionary*)dict
{
    return [[self alloc] initWithDB:dict];
}

+ (NSMutableArray*)karaokedbSongsWithProgArray:(NSArray*)progArray
{
    _progarray = progArray;
    
    NSString* sql = [NSString stringWithFormat:@"SELECT * FROM TableSong left join FavoriteSong on TableSong.SongIndex = FavoriteSong.SongIndex;"];
    NSArray* dbSongs = [self execuDBWithSQL:sql];
    
    //字典转模型
    NSMutableArray* songs = [NSMutableArray array];
    for(NSDictionary* dict in dbSongs){
        [songs addObject:[self karaokeWithDB:dict]];
    }

    return songs;
}

+ (NSMutableArray*)karaokedbSongsWithProgArray:(NSArray*)progArray SQLstring:(NSString *)string
{
    _progarray = progArray;
    
    //无效的查询语句
    //NSString* sql = [NSString stringWithFormat:@"SELECT * FROM TableSong left join FavoriteSong on TableSong.SongIndex = FavoriteSong.SongIndex AND FirstWord LIKE '%%%@%%';",string];
    //错误查询语句
    //NSString* sql = [NSString stringWithFormat:@"SELECT * FROM TableSong,FavoriteSong WHERE FirstWord LIKE '%%%@%%';",string];
    //正确语句
    NSString* sql = [NSString stringWithFormat:@"SELECT * FROM TableSong left join FavoriteSong on TableSong.SongIndex = FavoriteSong.SongIndex WHERE FirstWord LIKE '%%%@%%';",string];
    NSArray* dbSongs = [self execuDBWithSQL:sql];
    
    //字典转模型
    NSMutableArray* songs = [NSMutableArray array];
    for(NSDictionary* dict in dbSongs){
        [songs addObject:[self karaokeWithDB:dict]];
    }
    
    return songs;
}

+ (NSArray*)execuDBWithSQL:(NSString* )sql
{
    FMDatabase* db = [SongDB songDB];
    
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
    
    FMResultSet* set = [db executeQuery:sql];
//    for(int i = 0; i < set.columnCount; i++){
//        NSLog(@"columnName:%@ -- columnValue:%@",[set columnNameForIndex:i],[set objectForColumnIndex:i]);
//    }
    while (set.next)
    {
        NSNumber* songIndex = [NSNumber numberWithInt:[set intForColumnIndex:1]];
        NSNumber* fileType = [NSNumber numberWithInt:[set intForColumn:@"FileType"]];
        NSNumber* subFileType = [NSNumber numberWithInt:[set intForColumn:@"SubFileType"]];
        NSNumber* lanType = [NSNumber numberWithInt:[set intForColumn:@"LanType"]];
        NSString* firstWord = [set stringForColumn:@"FirstWord"];
        NSString* songName = [set stringForColumnIndex:5];
        NSString* singerName = [set stringForColumn:@"SingerName"];
        NSNumber* need_favo = [NSNumber numberWithBool:YES];
        
        NSMutableDictionary* songDict = [NSMutableDictionary dictionary];
        [songDict setValue:songIndex forKey:@"songIndex"];
        [songDict setValue:fileType forKey:@"fileType"];
        [songDict setValue:subFileType forKey:@"subFileType"];
        [songDict setValue:lanType forKey:@"lanType"];
        [songDict setValue:firstWord forKey:@"firstWord"];
        [songDict setValue:songName forKey:@"songName"];
        [songDict setValue:singerName forKey:@"singerName"];
        [songDict setValue:need_favo forKey:@"need_favo"];
        
        if([_progarray containsObject:songIndex]){
            NSNumber* prog = [NSNumber numberWithBool:YES];
            [songDict setValue:prog forKey:@"pro"];
        }
        
        int favo_index = [set intForColumnIndex:(set.columnCount - 3)];
        if(favo_index != 0){
            NSNumber* favo = [NSNumber numberWithBool:YES];
            [songDict setValue:favo forKey:@"favo"];
        }
        
        NSInteger inde = [indexArray indexOfObject:[firstWord substringToIndex:1]];
        if(inde != NSNotFound)
        {
            [[tmpsongs[inde] valueForKey:@"songs"] addObject:songDict];
        }
        else
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
    
    return tmpsongs;
}


+ (void)updateDBwithSQL:(NSString*)sql
{
    FMDatabase* db = [SongDB songDB];
    
    //除查询以外的所有操作
    //@"CREATE TABLE IF NOT EXISTS t_test (id integer PRIMARY KEY, name text NOT NULL, price real);"
    [db executeUpdate:sql];
    
//    NSString* name = @"";
//    float price = 0;
//    [db executeUpdateWithFormat:@"INSERT INTO t_test(name, price) VALUS (%@, %f);",name,price];
}


@end
