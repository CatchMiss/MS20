//
//  KaraokeCell.m
//  TestDemo
//
//  Created by Multak on 2018/6/5.
//  Copyright © 2018年 Multak. All rights reserved.
//

#import "KaraokeCell.h"
#import "SongsMode.h"

@interface KaraokeCell()

@property (weak, nonatomic) IBOutlet UILabel *songName;
@property (weak, nonatomic) IBOutlet UILabel *singerName;
@property (weak, nonatomic) IBOutlet UIButton *pic_favo;
@property (weak, nonatomic) IBOutlet UIButton *pic_pro;

@end

@implementation KaraokeCell

- (void)setSmode:(SongsMode *)smode
{
    _smode = smode;
    
    self.songName.text = smode.songName;
    self.singerName.text = smode.singerName;
    [self.pic_favo setSelected:smode.favo];
    [self.pic_pro setSelected:smode.pro];
    
    [self.pic_favo setHidden:(!smode.need_favo)];
}

+ (instancetype)karaokeCellWithtableView:(UITableView* )tableView
{
    //return [[[NSBundle mainBundle] loadNibNamed:@"KaraokeCell" owner:nil options:nil] lastObject];
    
    static NSString* ID = @"kCell";
    KaraokeCell* cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if(cell == nil)
    {
        NSLog(@"=== new cell =====");
        cell = [[[NSBundle mainBundle] loadNibNamed:@"KaraokeCell" owner:nil options:nil] lastObject];
    }
    return cell;
}

+ (instancetype)favoriteCellWithtableView:(UITableView* )tableView
{
    //return [[[NSBundle mainBundle] loadNibNamed:@"KaraokeCell" owner:nil options:nil] lastObject];
    
    static NSString* ID = @"fCell";
    KaraokeCell* cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if(cell == nil)
    {
        NSLog(@"=== new cell =====");
        cell = [[[NSBundle mainBundle] loadNibNamed:@"KaraokeCell" owner:nil options:nil] lastObject];
    }
    return cell;
}

+ (instancetype)localCellWithtableView:(UITableView* )tableView
{
    //return [[[NSBundle mainBundle] loadNibNamed:@"KaraokeCell" owner:nil options:nil] lastObject];
    
    static NSString* ID = @"lCell";
    KaraokeCell* cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if(cell == nil)
    {
        NSLog(@"=== new cell =====");
        cell = [[[NSBundle mainBundle] loadNibNamed:@"KaraokeCell" owner:nil options:nil] lastObject];
    }
    return cell;
}

//+ (instancetype)karaokeCellWithMode:(KaraokeMode *)kmode
//{
//    KaraokeCell* cell = [self karaokeCell];
//    cell.kmode = kmode;
//    return cell;
//}

- (IBAction)checkboxClick:(UIButton*)btn
{
    btn.selected = !btn.selected;
    NSLog(@"==click:%@-%ld==",btn,btn.tag);
    if(btn.tag == 0)
    {
        self.smode.favo = btn.selected;
        [self.delegate karaokeCellDidClickFavo:self select:btn.selected SongMode:self.smode];
    }
    else
    {
        self.smode.pro = btn.selected;
        [self.delegate karaokeCellDidClickProg:self select:btn.selected SongMode:self.smode];
    }
}

//- (void)deleteFavo
//{
//    self.pic_favo.selected = NO;
//}

- (void)deleteProg
{
    self.smode.pro = false;
    self.pic_pro.selected = NO;
}

#pragma mark - 每次加载XIB调用
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

#pragma mark - cell选中/取消时调用
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
