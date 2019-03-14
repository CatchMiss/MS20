//
//  ViewProgController.h
//  TestDemo
//
//  Created by Multak on 2018/6/12.
//  Copyright © 2018年 Multak. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SongsMode;
@class KaraokeCell;

@interface ViewProgController : UITableViewController

- (void)showWithPoint:(CGPoint)point;
- (void)hide;

- (NSMutableArray*)proSongs;

- (void)addCell:(KaraokeCell*)kcell withMode:(SongsMode *)kmode;
- (void)deleteCell:(KaraokeCell*)kcell withMode:(SongsMode *)kmode;

@end
