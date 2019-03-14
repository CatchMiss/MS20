//
//  ViewProgController.m
//  TestDemo
//
//  Created by Multak on 2018/6/12.
//  Copyright © 2018年 Multak. All rights reserved.
//

#import "ViewProgController.h"
#import "UIView+Extension.h"
#import "SongsMode.h"
#import "KaraokeCell.h"

static NSMutableArray* proSongs;

@interface ViewProgController ()

//@property (nonatomic,strong) NSMutableArray* proSongs;

@end

@implementation ViewProgController

- (NSMutableArray*)proSongs
{
    if(proSongs == nil){
        proSongs = [NSMutableArray array];
    }
    return proSongs;
}

- (void)addCell:(KaraokeCell*)kcell withMode:(SongsMode *)kmode
{
    NSLog(@"----add:%@----",kmode);
    NSDictionary* dict = @{@"cell":kcell,@"mode":kmode};
    [self.proSongs addObject:dict];
}

- (void)deleteCell:(KaraokeCell*)kcell withMode:(SongsMode *)kmode
{
    NSLog(@"----add:%@----",kmode);
    NSDictionary* dict = @{@"cell":kcell,@"mode":kmode};
    [self.proSongs removeObject:dict];
}

- (void)showWithPoint:(CGPoint)point
{
    //刷新预约列表
    [self.tableView reloadData];
    
    // 1. 拿到Window
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    
    // 2. 设置当前控制器的frame
    //self.view.frame = window.bounds;
    self.view.frame = CGRectMake(point.x, point.y, window.bounds.size.width,window.bounds.size.height - point.y);
    NSLog(@"progViewFram = %@",NSStringFromCGRect(self.view.frame));
    //self.view.backgroundColor = [UIColor lightGrayColor];
    
    // 3. 将当前控制器的view添加到Window上
    [window addSubview:self.view];
    self.view.hidden = NO;
    
    //绘图
    //self.view.alpha = 0.5;
//    UIBezierPath* path = [UIBezierPath bezierPathWithArcCenter:
//                          CGPointMake((window.bounds.size.width) / 2.f,(window.bounds.size.height - point.y)/2.f )
//                                radius:(window.bounds.size.width) / 2.f
//                                startAngle:0
//                                endAngle:M_PI * 2
//                                clockwise:YES];
//    CAShapeLayer* layer = [CAShapeLayer layer];
//    layer.frame = self.view.bounds;
//    layer.path = path.CGPath;
//    [self.view.layer addSublayer:layer];
    
    // 禁用交互功能
    window.userInteractionEnabled = NO;
    
    // 4.执行动画, 让控制器的view从下面转出来
    self.view.y = window.bounds.size.height;
    [UIView animateWithDuration:0.5 animations:^{
        // 执行动画
        self.view.y = point.y;
    } completion:^(BOOL finished) {
        // 开启交互
        window.userInteractionEnabled = YES;

    }];
}

- (void)hide
{
    // 1. 拿到Window
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    
    // 禁用交互功能
    window.userInteractionEnabled = NO;
    
    // 2.执行退出动画
    [UIView animateWithDuration:0.5 animations:^{
        self.view.y = window.bounds.size.height;
        
    } completion:^(BOOL finished) {
        
        // 隐藏控制器的view
        self.view.hidden = YES;
        
        // 开启交互
        window.userInteractionEnabled = YES;
    }];
}


#pragma mark - 数据源方法
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSLog(@"---row:%ld----",self.proSongs.count);
    return self.proSongs.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* ID = @"Cell";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if(cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
    }
    
    SongsMode* mode = [self.proSongs[indexPath.row] objectForKey:@"mode"];
    
    cell.textLabel.text = mode.songName;
    cell.detailTextLabel.text = mode.singerName;
    
    return cell;
}



//支持删除
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(editingStyle == UITableViewCellEditingStyleDelete)
    {
        NSLog(@"--delete---");
        [[self.proSongs[indexPath.row] objectForKey:@"cell"] deleteProg];
        [self.proSongs removeObjectAtIndex:indexPath.row];
        
        //刷新表格
        //[self.tableView reloadData];
        
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
    }
}

//排序
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    //[self.favoMusicList exchangeObjectAtIndex:<#(NSUInteger)#> withObjectAtIndex:<#(NSUInteger)#>];
    //NSLog(@"***%@***",self.favoMusicList);
    id source = self.proSongs[sourceIndexPath.row];
    [self.proSongs removeObjectAtIndex:sourceIndexPath.row];
    [self.proSongs insertObject:source atIndex:destinationIndexPath.row];
    //NSLog(@"***%@***",self.favoMusicList);
}



- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //self.tableView registerClass:<#(nullable Class)#> forCellReuseIdentifier:<#(nonnull NSString *)#>
    
    self.tableView.editing = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
