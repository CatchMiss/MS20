//
//  SongDB.m
//  TestDemo
//
//  Created by Multak on 2018/7/25.
//  Copyright © 2018年 Multak. All rights reserved.
//

#import "SongDB.h"

@implementation SongDB

static FMDatabase* _db;

+ (FMDatabase*)songDB
{
    //连接数据库
    if(_db == nil){
        NSString* filename = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"Song.db"];
        
        _db = [FMDatabase databaseWithPath:filename];
        [_db open];
    }
    return _db;
}

@end
