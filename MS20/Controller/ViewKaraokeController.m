//
//  ViewKaraokeController.m
//  TestDemo
//
//  Created by Multak on 2018/6/5.
//  Copyright © 2018年 Multak. All rights reserved.
//

#import "ViewKaraokeController.h"
#import "ViewProgController.h"
#import "ViewPlayController.h"
#import "UIView+Extension.h"
#import "KaraokeCell.h"
#import "SongsMode.h"
#import "KaraokeMode.h"
#import "LocalMusicMode.h"
#import "FavoriteMode.h"

//#define SEARCH_BUTTON_X 10.0

@interface ViewKaraokeController () <UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate,KaraokeCellDelegate>

@property (weak, nonatomic) IBOutlet UIView *playsupView;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UIButton *playButton;

@property (weak, nonatomic) IBOutlet UIView *bottonView; //列表选择按钮
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak,nonatomic) UIButton* tableViewButton;

@property (nonatomic,strong) NSMutableArray* songs;

@property (nonatomic,strong) NSMutableArray* karaokeSongs;
@property (nonatomic,strong) NSMutableArray* favoSongs;
@property (nonatomic,strong) NSMutableArray* localSongs;

@property (nonatomic, strong) ViewProgController *progView;
@property (nonatomic, assign) Boolean progViewIsHiden;

@property (nonatomic, strong) ViewPlayController* playView;

@property (nonatomic, strong) NSTimer* searchTimer;

@end

@implementation ViewKaraokeController

- (NSArray*)progSongs
{
    NSArray* arry = [self.progView proSongs];
    NSLog(@"progSong == %@",arry);
    NSMutableArray* songs = [NSMutableArray array];
    for(NSDictionary* dict in arry){
        SongsMode* mode = dict[@"mode"];
        [songs addObject:[NSNumber numberWithInt:mode.songIndex]];
    }
    return songs;
}

- (NSMutableArray*)karaokeSongs
{
    if(_karaokeSongs == nil)
    {
        NSArray* array = [self progSongs];
        _karaokeSongs = [KaraokeMode karaokedbSongsWithProgArray:array];
    }
    return _karaokeSongs;
}

- (NSMutableArray*)favoSongs
{
    if(_favoSongs == nil)
    {
//        NSMutableArray* favosongs = [NSMutableArray array];
//        for(KaraokeMode* kmode in self.karaokeSongs)
//        {
//            NSLog(@"karaoke++++++++");
//            if(kmode.favo)
//            {
//                NSLog(@"favo++++++++mode:%@",kmode.songName);
//                [favosongs addObject:kmode];
//                NSLog(@"-favo.count=====%ld",favosongs.count);
//            }
//        }
        _favoSongs = [FavoriteMode favoritedbSongsWithProgArray:[self progSongs]];
    }
    return _favoSongs;
}

- (NSMutableArray*)localSongs
{
    if(_localSongs == nil){
        _localSongs = [LocalMusicMode localMusicList];
    }
    return _localSongs;
}


- (ViewProgController *)progView
{
    if (!_progView) {
        _progView = [[ViewProgController alloc] init];
    }
    return _progView;
}

- (ViewPlayController*)playView
{
    if(_playView == nil){
        _playView = [ViewPlayController playView];
    }
    return _playView;
}


- (UIView*)playSuperView
{
    return self.playsupView;
}


#pragma mark -- 显示
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

#pragma mark -- 退出
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


#pragma mark - 预约喜爱代理协议
- (void)karaokeCellDidClickFavo:(KaraokeCell *)karaokeCell select:(BOOL)select SongMode:(SongsMode *)kmode
{
    if(select)
    {
        //[self.favoSongs addObject:kmode];
        //添加到数据库
        [FavoriteMode addFavoriteWithSongMode:kmode];
        self.favoSongs = nil;
        self.karaokeSongs = nil;
    }
    else
    {
        //[self.favoSongs removeObject:kmode];
        [FavoriteMode deleteFavoriteWithSongMode:kmode];
        self.favoSongs = nil;
        self.karaokeSongs = nil;
    }
}

- (void)karaokeCellDidClickProg:(KaraokeCell *)karaokeCell select:(BOOL)select SongMode:(SongsMode *)kmode
{
    if(select)
    {
        //
        [self.progView addCell:karaokeCell withMode:kmode];
        self.favoSongs = nil;
        self.karaokeSongs = nil;
    }
    else
    {
        [self.progView deleteCell:karaokeCell withMode:kmode];
        self.favoSongs = nil;
        self.karaokeSongs = nil;
    }
}


#pragma mark -  ----数据源方法
//分组数
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.songs.count;
}

//每一组行数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger row = [[self.songs valueForKeyPath:@"songs"][section] count];
    //NSLog(@"tableView.row=========%ld===========",row);
    return row;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    KaraokeCell* cell = nil;
    SongsMode* smode = nil;
    switch (self.tableViewButton.tag)
    {
        case 0:
        {
            //local
            LocalMusicMode* kmode = self.songs[indexPath.section];
            smode = kmode.songs[indexPath.row];
            cell = [KaraokeCell localCellWithtableView:self.tableView];
            break;
        }
        case 1:
        {
            //karaoke
            KaraokeMode* kmode = self.songs[indexPath.section];
            smode = kmode.songs[indexPath.row];
            cell = [KaraokeCell karaokeCellWithtableView:self.tableView];
            break;
        }
        case 2:
        {
            //fav
            FavoriteMode* kmode = self.songs[indexPath.section];
            smode = kmode.songs[indexPath.row];
            cell = [KaraokeCell favoriteCellWithtableView:self.tableView];
            break;
        }
        default:
            break;
    }

    cell.smode = smode;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.delegate = self;
    return cell;
}

//选择行
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

//索引
- (NSArray<NSString*>*)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return [self.songs valueForKeyPath:@"index"];
}

//标题
- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSArray* indexArray = [self.songs valueForKeyPath:@"index"];
    return indexArray[section];
}



#pragma mark -- 列表按钮点击
- (IBAction)buttonClicked:(UIButton *)sender
{
    if(self.tableViewButton != sender)
    {
        self.tableViewButton.selected = NO;
        self.tableViewButton = sender;
        self.tableViewButton.selected = YES;
        
        switch (sender.tag)
        {
            case 0:
                //local
                self.searchBar.placeholder = @"搜索 local";
                self.songs = self.localSongs;
                [self.tableView reloadData];
                break;
            case 1:
                //karaoke
                self.searchBar.placeholder = @"搜索 karaoke";
                self.songs = self.karaokeSongs;
                [self.tableView reloadData];
                break;
            case 2:
                //fav
                self.searchBar.placeholder = @"搜索 favo";
                self.songs = self.favoSongs;
                //NSLog(@"favoSongs.count ===== %ld",self.favoSongs.count);
                //NSLog(@"songs.count ===== %ld",self.songs.count);
                [self.tableView reloadData];
                break;
            default:
                break;
        }
        NSLog(@"=-=-=-=search=-=-=-=%ld",sender.tag);
        //self.localSongs = nil;
        //self.karaokeSongs = nil;
        //self.favoSongs = nil;
    }
}

#pragma mark -- 打开预约列表
- (IBAction)progViewClicked:(UIButton *)sender
{
    if(self.progViewIsHiden == YES)
    {
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        CGRect frame = [sender.superview convertRect:sender.frame toView:window];
        CGPoint point = CGPointMake(0, frame.origin.y + sender.bounds.size.height + 1);

        [self.progView showWithPoint:point];
        self.progViewIsHiden = NO;
        self.backButton.enabled = NO;
        self.playButton.enabled = NO;
    }
    else
    {
        [self.progView hide];
        self.progViewIsHiden = YES;
        self.backButton.enabled = YES;
        self.playButton.enabled = YES;
    }
}


#pragma mark ---  点击播放按钮
- (IBAction)play
{
    [self.playView showWithsuperRect:self.playsupView.frame];
}



#pragma mark -- searchBar代理
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    NSLog(@"shouldBeginEditing");
    [self disableBotton];
    return YES;
}

//开始编辑textview
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
//    [searchBar setShowsCancelButton:YES animated:YES];
//    searchBar.tintColor = [UIColor colorWithRed:57/255.0 green:159/255.0 blue:162/255.0 alpha:1.0];
//    for(UIView* subView in searchBar.subviews)
//    {
//        for(UIView* cnView in subView.subviews)
//        {
//            if([cnView isKindOfClass:NSClassFromString(@"UINavigationButton")])
//            {
//                UIButton* cancel = (UIButton*)cnView;
//                //[cancel setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//                [cancel setTitle:@"取消" forState:UIControlStateNormal];
//            }
//        }
//    }
//    NSLog(@"didBeginEditing");
}

//搜索文本改变
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    NSLog(@"textChange:%@",searchText);
    [self startTimerWithSearchString:searchText];
}

//点击键盘搜索按钮
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    NSLog(@"searchButtonClick");
}

//点击取消按钮
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    //[searchBar setShowsCancelButton:NO animated:YES];
    searchBar.text = nil;
    [searchBar resignFirstResponder];
    //[self downmoveFram];
    //[self enableBotton];
}

#pragma mark -- 弹出键盘
- (void)keybordChange:(NSNotification*)noti
{
    //NSLog(@"=========%@",noti.userInfo);
    /*
     UIKeyboardAnimationCurveUserInfoKey = 7;
     UIKeyboardAnimationDurationUserInfoKey = "0.25";
     UIKeyboardBoundsUserInfoKey = "NSRect: {{0, 0}, {375, 216}}";
     UIKeyboardCenterBeginUserInfoKey = "NSPoint: {187.5, 775}";
     UIKeyboardCenterEndUserInfoKey = "NSPoint: {187.5, 559}";
     UIKeyboardFrameBeginUserInfoKey = "NSRect: {{0, 667}, {375, 216}}";
     UIKeyboardFrameEndUserInfoKey = "NSRect: {{0, 451}, {375, 216}}";
     UIKeyboardIsLocalUserInfoKey = 1;
     */
    
    /*
    CGFloat keyY = [noti.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue].origin.y;
    CGFloat screeH = [[UIScreen mainScreen] bounds].size.height;
    CGFloat duration = [noti.userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue];
    
    [UIView animateWithDuration:duration animations:^{
        self.view.transform = CGAffineTransformMakeTranslation(0, keyY - screeH);
    }];
    */
//    CGFloat keyY = [noti.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue].origin.y;
//    if(keyY != 0)
//    {
//        [self upmoveFrame];
//    }
}

//界面上移
- (void)upmoveFrame
{
    CGFloat playviewH = self.playsupView.size.height;
    CGFloat buttonH = self.bottonView.size.height;
    CGFloat moveH = playviewH + buttonH;
    
    [UIView animateWithDuration:0.25 animations:^{
        self.view.transform = CGAffineTransformMakeTranslation(0, - moveH);
    }];
}
//界面下移
- (void)downmoveFram
{
    [UIView animateWithDuration:0.25 animations:^{
        self.view.transform = CGAffineTransformMakeTranslation(0, 0);
    }];
}

//滚动tableview
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.searchBar endEditing:YES];
    [self enableBotton];
}

//按键禁用和开启
- (void)enableBotton
{
    self.backButton.enabled = YES;
    self.playsupView.userInteractionEnabled = YES;
    self.bottonView.userInteractionEnabled = YES;
}

- (void)disableBotton
{
    self.backButton.enabled = NO;
    self.playsupView.userInteractionEnabled = NO;
    self.bottonView.userInteractionEnabled = NO;
}

#pragma mark -- 计时器相关
- (void)startTimerWithSearchString:(NSString*)string
{
    if(_searchTimer != nil){
        [_searchTimer invalidate];
    }
    NSDictionary* dict = [NSDictionary dictionaryWithObject:string forKey:@"searchString"];
    _searchTimer = [NSTimer scheduledTimerWithTimeInterval:0.3 target:self selector:@selector(searchOnDB:) userInfo:dict repeats:NO];
}

- (void)stopTimer
{
    [_searchTimer invalidate];
}

#pragma mark -- 查询数据库
- (void)searchOnDB:(NSTimer*)timer
{
    NSString* searchText = [[timer userInfo] objectForKey:@"searchString"];
    NSArray* progarray = [self progSongs];
    NSLog(@"searchOnDB:===%@=={%@}",searchText,progarray);
    switch (self.tableViewButton.tag)
    {
        case 0:
        {
            //local
            self.songs = [LocalMusicMode localMusicListWithString:searchText];
            [self.tableView reloadData];
            break;
        }
        case 1:
        {
            //karaoke
            self.songs = [KaraokeMode karaokedbSongsWithProgArray:progarray SQLstring:searchText];
            [self.tableView reloadData];
            break;
        }
        case 2:
            //fav
            self.songs = [FavoriteMode favoritedbSongsWithProgArray:progarray SQLstring:searchText];
            [self.tableView reloadData];
            break;
        default:
            break;
    }
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tableView.rowHeight = 60;
    self.progViewIsHiden = YES;
    
    /**
     为tableview注册可重用单元格
     单元格缓冲池会默认生成可重用单元格,不用判断cell==nil
     */
    //[self.tableView registerClass:[KaraokeCell class] forCellReuseIdentifier:@"Cell"];
    self.songs = self.karaokeSongs;
    self.tableViewButton = [self.bottonView viewWithTag:1];
    self.tableViewButton.selected = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keybordChange:) name:UIKeyboardWillChangeFrameNotification object:nil];
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
