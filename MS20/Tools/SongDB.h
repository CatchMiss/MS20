//
//  SongDB.h
//  TestDemo
//
//  Created by Multak on 2018/7/25.
//  Copyright © 2018年 Multak. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDB.h"

@interface SongDB : NSObject

+ (FMDatabase*)songDB;

@end
