//
//  KaraokeCell.h
//  TestDemo
//
//  Created by Multak on 2018/6/5.
//  Copyright © 2018年 Multak. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SongsMode;
@class KaraokeCell;

//协议
@protocol KaraokeCellDelegate <NSObject>

- (void)karaokeCellDidClickFavo:(KaraokeCell*)karaokeCell select:(BOOL)select SongMode:(SongsMode*)kmode;
- (void)karaokeCellDidClickProg:(KaraokeCell*)karaokeCell select:(BOOL)select SongMode:(SongsMode*)kmode;

@end

@interface KaraokeCell : UITableViewCell

//代理属性
@property (nonatomic,weak) id<KaraokeCellDelegate> delegate;

//使用模型设置试图
@property (nonatomic,strong) SongsMode* smode;

/** 类方法,调用试图 */
//+ (instancetype)karaokeCell;

/** 实例化视图,并设置视图*/
+ (instancetype)karaokeCellWithtableView:(UITableView* )tableView;
+ (instancetype)favoriteCellWithtableView:(UITableView* )tableView;
+ (instancetype)localCellWithtableView:(UITableView* )tableView;

- (void)deleteFavo;
- (void)deleteProg;

@end
