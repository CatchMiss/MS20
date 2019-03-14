//
//  ViewSettingController.m
//  TestDemo
//
//  Created by Multak on 2018/6/1.
//  Copyright © 2018年 Multak. All rights reserved.
//

#import "ViewSettingController.h"
#import "UIView+Extension.h"

#import <SystemConfiguration/CaptiveNetwork.h>

@interface ViewSettingController () <UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic,strong) NSArray* itemList;

@end

@implementation ViewSettingController


- (NSArray *)itemList
{
    //懒加载
    if(_itemList == nil){
        NSArray* array = @[@"WLAN",@"录像开关",@"背景视频",@"颜色主题更改",@"恢复默认"];
        
        NSDictionary* set = @{@"titel" : @"分组标题", @"dec" : @"分组描述", @"contents" : array};
        
        _itemList = @[set];
    }
    return _itemList;
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


//不写默认1
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.itemList.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray* array = self.itemList[section][@"contents"];
    return array.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //缓存池查找
    //static NSString* ID = @"Cell";//可重用标志符
    //UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:ID];
    //if(cell == nil)
    //{
        //共有属性设置
    //   cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
    //}
    
    UITableViewCell* cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
    NSDictionary* set = self.itemList[indexPath.section];
    
    //非公有属性设置
    cell.textLabel.text = set[@"contents"][indexPath.row];
    
    switch (indexPath.row) {
        case 0:
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            break;
           
        case 1:
        case 2:
        {
            UISwitch* switcher = [[UISwitch alloc] init];
            [switcher addTarget:self action:@selector(switchChange:) forControlEvents:UIControlEventValueChanged];
            cell.accessoryView = switcher;
        }
            break;
            
        default:
            break;
    }
    
    return cell;
}

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)switchChange:(UISwitch*)sender
{
    
}


#pragma mark -- Wi-Fi功能

//Wi-Fi热点
+ (NSString*)currentWifiSSID
{
    NSArray* ifs = (__bridge id)CNCopySupportedInterfaces();
    
    id info = nil;
    for(NSString* ifname in ifs)
    {
        info = (__bridge id)CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifname);
        if(info && [info count])
        {
            break;
        }
    }
    NSDictionary* SSIDdict = (NSDictionary*)info;
    NSString* ssid = [SSIDdict objectForKey:@"SSID"];
    return ssid;
}

//Wi-Fi IP
//+ (NSString*)localWifiIPAdress
//{
//    struct ifaddrs* addrs;
//    const struct ifaddrs* cursor;
//
//    BOOL success = getifaddrs(&addrs) == 0;
//    if(success)
//    {
//        cursor = addrs;
//        while (cursor != NULL) {
//            if(cursor->ifa_addr->sa_family == AF_INET);
//        }
//    }
//}

//Wi-Fi

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tableView.rowHeight = 60;
    self.tableView.tableFooterView = [[UIView alloc] init];
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
