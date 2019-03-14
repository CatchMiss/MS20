//
//  ViewRecordController.m
//  TestDemo
//
//  Created by Multak on 2018/6/14.
//  Copyright © 2018年 Multak. All rights reserved.
//

#import "ViewRecordController.h"
#import "UIView+Extension.h"


@interface ViewRecordController () <UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic,strong) NSMutableArray* recordList;

@end

@implementation ViewRecordController

- (NSMutableArray*)recordList
{
    if(_recordList == nil){
        _recordList = [NSMutableArray array];
    }
    return _recordList;
}

- (void)show
{
    // 1. 拿到Window
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    
    // 2. 设置当前控制器的frame
    //self.view.frame = window.bounds;
    // 3. 将当前控制器的view添加到Window上
    [window addSubview:self.view];
    self.view.hidden = NO;
    
    // 禁用交互功能
    window.userInteractionEnabled = NO;
    
    // 4.执行动画, 让控制器的view从下面转出来
    self.view.x = window.bounds.size.width;
    [UIView animateWithDuration:0.5 animations:^{
        // 执行动画
        self.view.x = 0;
    } completion:^(BOOL finished) {
        // 开启交互
        window.userInteractionEnabled = YES;
        
    }];
}







#pragma mark -  数据源方法
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.recordList.count;
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    static NSString* ID = @"recCell";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if(cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
    }  
    return cell;
}









- (IBAction)formBack:(UIButton *)sender
{
    // 1. 拿到Window
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    
    // 禁用交互功能
    window.userInteractionEnabled = NO;
    
    // 2.执行退出动画
    [UIView animateWithDuration:0.5 animations:^{
        self.view.x = window.bounds.size.width;
        
    } completion:^(BOOL finished) {
        
        // 隐藏控制器的view
        self.view.hidden = YES;
        
        // 开启交互
        window.userInteractionEnabled = YES;
    }];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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
