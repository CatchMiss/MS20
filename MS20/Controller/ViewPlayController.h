//
//  PlayView.h
//  TestDemo
//
//  Created by Multak on 2018/6/13.
//  Copyright © 2018年 Multak. All rights reserved.
//

//#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>

typedef NS_ENUM(NSUInteger, PlayViewState) {
    PlayViewStateSmall,
    PlayViewStateAnimating,
    PlayViewStateFullscreen,
};

@interface ViewPlayController : GLKViewController

- (void)showWithsuperRect:(CGRect)supViewRect;
+ (instancetype)playView;

@end
