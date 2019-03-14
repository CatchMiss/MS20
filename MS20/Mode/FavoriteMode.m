//
//  FavoriteMode.m
//  TestDemo
//
//  Created by Multak on 2018/7/25.
//  Copyright © 2018年 Multak. All rights reserved.
//

#import "FavoriteMode.h"
#import "SongDB.h"

static NSArray* _progarray;

@interface FavoriteMode()

//db转化成favorite模型
- (instancetype)initWithDB:(NSDictionary*)dict;
+ (instancetype)favoriteWithDB:(NSDictionary*)dict;

@end

@implementation FavoriteMode

- (instancetype)initWithDB:(NSDictionary*)dict
{
    self = [super init];
    
    if(self){
        [self setValue:dict[@"index"] forKey:@"index"];
        self.songs = [SongsMode songsWithArray:dict[@"songs"]];
    }
    return self;
}


+ (instancetype)favoriteWithDB:(NSDictionary*)dict
{
    return [[self alloc] initWithDB:dict];
}



+ (NSMutableArray*)favoritedbSongsWithProgArray:(NSArray*)progArray
{
    _progarray = progArray;
    
    NSString* sql = [NSString stringWithFormat:@"SELECT * FROM TableSong inner join FavoriteSong on TableSong.SongIndex = FavoriteSong.SongIndex;"];
    NSArray* dbSongs = [self execuDBWithSQL:sql];
    
    //字典转模型
    NSMutableArray* songs = [NSMutableArray array];
    for(NSDictionary* dict in dbSongs){
        [songs addObject:[self favoriteWithDB:dict]];
    }
    
    return songs;
}

+ (NSMutableArray*)favoritedbSongsWithProgArray:(NSArray*)progArray SQLstring:(NSString *)string
{
    _progarray = progArray;
    
    //错误语句
    //NSString* sql = [NSString stringWithFormat:@"SELECT * FROM TableSong inner join FavoriteSong on TableSong.SongIndex = FavoriteSong.SongIndex AND TableSong.FirstWord LIKE '%@%%';",string];
    //正确语句
    NSString* sql = [NSString stringWithFormat:@"SELECT * FROM TableSong inner join FavoriteSong on TableSong.SongIndex = FavoriteSong.SongIndex WHERE FirstWord LIKE '%%%@%%';",string];
    NSArray* dbSongs = [self execuDBWithSQL:sql];
    
    //字典转模型
    NSMutableArray* songs = [NSMutableArray array];
    for(NSDictionary* dict in dbSongs){
        [songs addObject:[self favoriteWithDB:dict]];
    }
    
    return songs;
}

+ (void)addFavoriteWithSongMode:(SongsMode*)song
{
    //替换歌曲名中单引号字符
    NSString* sqlSongName = [song.songName stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    NSString* sql = [NSString stringWithFormat:@"INSERT INTO FavoriteSong (SongIndex, SongName) VALUES (%d,'%@');",song.songIndex,sqlSongName];
    NSLog(@"Favorite:%@",sql);
    [self updateDBwithSQL:sql];
}

+ (void)deleteFavoriteWithSongMode:(SongsMode*)song
{
    NSString* sql = [NSString stringWithFormat:@"DELETE FROM FavoriteSong WHERE SongIndex = %d;",song.songIndex];
    [self updateDBwithSQL:sql];
}

//查询
+ (NSArray*)execuDBWithSQL:(NSString* )sql
{
    FMDatabase* db = [SongDB songDB];
    
    NSArray* indexArray = @[@"#",
                            @"A",@"B",@"C",@"D",@"E",@"F",@"G",@"H",@"I",@"J",@"K",
                            @"L",@"M",@"N",@"O",@"P",@"Q",@"R",@"S",@"T",@"U",@"V",
                            @"W",@"X",@"Y",@"Z",
                            ];
    //NSLog(@"indexArray:count(%ld)",indexArray.count);
    
    //初始化歌曲列表
    NSMutableArray* tmpsongs = [NSMutableArray array];
    for(NSString* index in indexArray)
    {
        NSMutableArray* tmparray = [NSMutableArray array];
        NSDictionary* dict = @{@"index":index,@"songs":tmparray};
        [tmpsongs addObject:dict];
    }
    
    FMResultSet* set = [db executeQuery:sql];
    while (set.next)
    {
        NSNumber* songIndex = [NSNumber numberWithInt:[set intForColumn:@"SongIndex"]];
        NSNumber* fileType = [NSNumber numberWithInt:[set intForColumn:@"FileType"]];
        NSNumber* subFileType = [NSNumber numberWithInt:[set intForColumn:@"SubFileType"]];
        NSNumber* lanType = [NSNumber numberWithInt:[set intForColumn:@"LanType"]];
        NSString* firstWord = [set stringForColumn:@"FirstWord"];
        NSString* songName = [set stringForColumn:@"SongName"];
        NSString* singerName = [set stringForColumn:@"SingerName"];
        NSNumber* favo = [NSNumber numberWithBool:YES];
        NSNumber* need_favo = [NSNumber numberWithBool:YES];
        
        NSMutableDictionary* songDict = [NSMutableDictionary dictionary];
        [songDict setValue:songIndex forKey:@"songIndex"];
        [songDict setValue:fileType forKey:@"fileType"];
        [songDict setValue:subFileType forKey:@"subFileType"];
        [songDict setValue:lanType forKey:@"lanType"];
        [songDict setValue:firstWord forKey:@"firstWord"];
        [songDict setValue:songName forKey:@"songName"];
        [songDict setValue:singerName forKey:@"singerName"];
        [songDict setValue:favo forKey:@"favo"];
        [songDict setValue:need_favo forKey:@"need_favo"];
        
        if([_progarray containsObject:songIndex]){
            NSNumber* prog = [NSNumber numberWithBool:YES];
            [songDict setValue:prog forKey:@"pro"];
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


//除了查询以外
+ (void)updateDBwithSQL:(NSString*)sql
{
    FMDatabase* db = [SongDB songDB];
    
    //除查询以外的所有操作
    //@"CREATE TABLE IF NOT EXISTS FavoriteSong (SongIndex integer PRIMARY KEY, SongName text NOT NULL, SongType integer);"
    [db executeUpdate:sql];
    
//    NSString* name = @"";
//    float price = 0;
//    [db executeUpdateWithFormat:@"INSERT INTO t_test(name, price) VALUS (%@, %f);",name,price];
}

@end
