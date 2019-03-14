//
//  ViewLocalMusicController.m
//  TestDemo
//
//  Created by Multak on 2018/6/4.
//  Copyright © 2018年 Multak. All rights reserved.
//

#import "ViewLocalMusicController.h"
#import "UIView+Extension.h"
#import "UIImage+NJ.h"
#import "SongsMode.h"
#import "LocalMusicMode.h"
#import "AudioTool.h"
#import "Colours.h"

#define TABELVIEWCELL_H 80

@interface ViewLocalMusicController () <UITableViewDataSource,AVAudioPlayerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic,strong) NSArray* localMusicList;
@property (nonatomic, strong) AVAudioPlayer *player;
@property (nonatomic, strong) SongsMode* playingMode;

@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UIImageView *singerPicView;
@property (weak, nonatomic) IBOutlet UILabel *songnameLabel;
@property (weak, nonatomic) IBOutlet UILabel *singerNameLabel;

@end

@implementation ViewLocalMusicController


- (NSArray*)localMusicList
{
    if(_localMusicList == nil){
        _localMusicList = [LocalMusicMode localMusicList];
    }
    return _localMusicList;
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

#pragma mark -- 数据源
//分组数
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.localMusicList.count;
}

//每一组行数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    LocalMusicMode* mode = self.localMusicList[section];
    NSInteger row = mode.songs.count;
    return row;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* ID = @"Cell";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if(cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
        
        //UISwitch* more = [[UISwitch alloc] init];
        UIButton* more = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage* image = [UIImage imageNamed:@"more.png"];
        more.bounds = CGRectMake(0, 0, 5, TABELVIEWCELL_H/4);
        [more setBackgroundImage:image forState:UIControlStateNormal];
        cell.accessoryView = more;
    }
    
    LocalMusicMode* kmode = self.localMusicList[indexPath.section];
    SongsMode* smode = kmode.songs[indexPath.row];
    cell.imageView.image = [UIImage circleImageWithName:smode.singerIcon borderWidth:5 borderColor:[UIColor skyBlueColor]];
    //cell.imageView.image = [UIImage imageNamed:smode.icon];
    cell.textLabel.text = smode.songName;
    cell.detailTextLabel.text = smode.singerName;
    
    return cell;
}

 //选中某一个行
- (void)tableView:(UITableView* )tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //主动取消选中
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.playButton.selected = NO;//未选中,显示播放状态
    
    if(self.playingMode.filename != nil){
        [self stopPlaying];
    }
    
    LocalMusicMode* kmode = self.localMusicList[indexPath.section];
    self.playingMode = kmode.songs[indexPath.row];
    [self setPlayInfo];
    [self startPlaying];
}

//索引
- (NSArray<NSString*>*)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return [self.localMusicList valueForKeyPath:@"index"];
}

//标题
- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    LocalMusicMode* kmode = self.localMusicList[section];
    return kmode.index;
}


#pragma mark -- 播放音乐
- (void)setPlayInfo
{
    self.singerPicView.image = [UIImage imageNamed:self.playingMode.singerIcon];
    self.songnameLabel.text = self.playingMode.songName;
    self.singerNameLabel.text = self.playingMode.singerName;
}

- (void)startPlaying
{
    self.player = [AudioTool playMusicWithFilename:self.playingMode.filename];
    self.player.delegate = self;
}

- (void)stopPlaying
{
    [AudioTool stopMusicWithFilename:self.playingMode.filename];
}

- (IBAction)playOrPause
{
    // 判断按钮当前的状态
    if (self.playButton.selected) //选中是暂停
    {
        self.playButton.selected = NO;
        [self startPlaying];
    }
    else// 未选中, 显示播放-->显示的暂停
    {
        [AudioTool pauseMusicWithFilename:self.playingMode.filename];
        self.playButton.selected = YES;
    }
}


#pragma mark - 播放代理
// 播放结束时调用
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{

}

//// 播放器被打断时调用(例如电话)
//- (void)audioPlayerBeginInterruption:(AVAudioPlayer *)player
//{
//    // 暂停
//    if (self.player.playing) {
//        [AudioTool pauseMusicWithFilename:self.playingMode.filename];
//    }
//}
//
//// 播放器打断结束
//- (void)audioPlayerEndInterruption:(AVAudioPlayer *)player
//{
//    // 继续播放
//    if (!self.player.playing) {
//        [self startPlaying];
//    }
//}



// - (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag;
// 
//  /* if an error occurs while decoding it will be reported to the delegate. */
//- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError * __nullable)error;
//
//#if TARGET_OS_IPHONE
//
//  /* AVAudioPlayer INTERRUPTION NOTIFICATIONS ARE DEPRECATED - Use AVAudioSession instead. */
//
//  /* audioPlayerBeginInterruption: is called when the audio session has been interrupted while the player was playing. The player will have been paused. */
//- (void)audioPlayerBeginInterruption:(AVAudioPlayer *)player NS_DEPRECATED_IOS(2_2, 8_0);
//
//  /* audioPlayerEndInterruption:withOptions: is called when the audio session interruption has ended and this player had been interrupted while playing. */
//  /* Currently the only flag is AVAudioSessionInterruptionFlags_ShouldResume. */
//- (void)audioPlayerEndInterruption:(AVAudioPlayer *)player withOptions:(NSUInteger)flags NS_DEPRECATED_IOS(6_0, 8_0);
//
//- (void)audioPlayerEndInterruption:(AVAudioPlayer *)player withFlags:(NSUInteger)flags NS_DEPRECATED_IOS(4_0, 6_0);
//
//  /* audioPlayerEndInterruption: is called when the preferred method, audioPlayerEndInterruption:withFlags:, is not implemented. */
//- (void)audioPlayerEndInterruption:(AVAudioPlayer *)player NS_DEPRECATED_IOS(2_2, 6_0);
//
//#endif // TARGET_OS_IPHONE



- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tableView.rowHeight = TABELVIEWCELL_H;
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
