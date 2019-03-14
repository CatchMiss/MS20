//
//  ViewController.m
//  TestDemo
//
//  Created by Multak on 2018/5/22.
//  Copyright © 2018年 Multak. All rights reserved.
//

#import "ViewController.h"
#import "ViewKaraokeController.h"
#import "ViewLocalMusicController.h"
#import "ViewSettingController.h"
#import "ViewRecordController.h"

#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

#import <SystemConfiguration/SystemConfiguration.h>
#import <SystemConfiguration/CaptiveNetwork.h>
#import <CoreFoundation/CoreFoundation.h>

//由UUID标识对应的服务
#define BT_PLAY @" "
#define BT_PAUSE @" "
#define BT_STOP @" "
#define BT_WRITE @" "

#pragma mark - 私有扩展 === 不开放的属性声明在这
@interface ViewController () <CBCentralManagerDelegate,CBPeripheralDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *mainpic;

@property (weak, nonatomic) IBOutlet UIButton *connectBTbutton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityView;
@property (weak, nonatomic) IBOutlet UILabel *conectLabel;

@property (nonatomic, strong) ViewKaraokeController *karaokeView;
@property (nonatomic, strong) ViewLocalMusicController *localMusicView;
@property (nonatomic, strong) ViewSettingController *settingView;
@property (nonatomic, strong) ViewRecordController *recordView;

@property (nonatomic, strong) CBCentralManager* MKmgr;      //蓝牙中心角色
@property (nonatomic, strong) CBPeripheral* MKphe;         //蓝牙外设

@property (nonatomic, strong) CBCharacteristic* MKwrite;    //发送数据特征
@property (nonatomic, assign) NSInteger IP;

@end



#pragma mark - 方法实现
@implementation ViewController

- (ViewKaraokeController*)karaokeView
{
    if(_karaokeView == nil){
        //UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        //_karaokeView = [storyboard instantiateViewControllerWithIdentifier:@"karaokeView"];
        _karaokeView = [[[NSBundle mainBundle] loadNibNamed:@"KaraokeView" owner:nil options:nil] lastObject]; 
    }
    return _karaokeView;
}

- (ViewLocalMusicController*)localMusicView
{
    if(_localMusicView == nil){
        _localMusicView = [[[NSBundle mainBundle] loadNibNamed:@"LocalMusicView" owner:nil options:nil] lastObject];
    }
    return _localMusicView;
}

- (ViewSettingController*)settingView
{
    if(_settingView == nil){
        _settingView = [[[NSBundle mainBundle] loadNibNamed:@"SettingView" owner:nil options:nil] lastObject];
    }
    return _settingView;
}

- (ViewRecordController*)recordView
{
    if(_recordView == nil){
        _recordView = [[[NSBundle mainBundle] loadNibNamed:@"RecordView" owner:nil options:nil] lastObject];
    }
    return _recordView;
}


#pragma mark - UI加载完成调用
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    //self.view.multipleTouchEnabled = NO;
    //[self.view setExclusiveTouch:YES];
    
    self.MKmgr = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    self.connectBTbutton.enabled = NO;
    self.activityView.hidden = YES;
    
    //监听UIApplicationDidBecomeActiveNotification
    [[NSNotificationCenter  defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    [self copyDBtoDocument];
}

//控制器销毁时调用
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)changeView:(UIButton *)button
{

}

- (IBAction)unwindForSegue:(UIStoryboardSegue*)sender
{
    //NSLog(@"unwindForSegue %@",sender);
}

- (IBAction)viewButtonClick:(UIButton *)sender
{
    switch (sender.tag) {
        case 0:
            [self.localMusicView show];
            break;
        case 1:
            [self.recordView show];
            break;
        case 2:
            [self.settingView show];
            break;
        case 3:
            [self.karaokeView show];
            break;
            
        default:
            break;
    }
}

//连接蓝牙
- (IBAction)connectBT:(UIButton *)sender
{
    if(self.MKmgr.state == CBManagerStatePoweredOn)
    {
        sender.enabled = NO;
        self.conectLabel.text = @"扫描中...";
        self.activityView.hidden = NO;
        [self.activityView startAnimating];
        [self.MKmgr scanForPeripheralsWithServices:nil options:nil];
    }
}

//断开蓝牙
- (IBAction)disConnectBT:(UIButton *)sender
{
    if(self.MKphe)
    {
        [self.MKmgr cancelPeripheralConnection:self.MKphe];
        self.MKmgr = nil;
        self.MKphe = nil;
        self.title = @"设备连接已断开";
    }
}

#pragma mark --- 蓝牙代理
// 一旦中心角色创建,蓝牙状态改变的代理方法就会执行,返回当前蓝牙状态
- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    if(central.state == CBManagerStatePoweredOn)
    {
        self.conectLabel.text = @"蓝牙已就绪";
        self.connectBTbutton.enabled  = YES;
        //nil表示扫描所有设备
        //[self.MKmgr scanForPeripheralsWithServices:nil options:nil];
    }
    else
    {
        self.conectLabel.text = @"蓝牙未准备好";
        [self.activityView stopAnimating];
        self.activityView.hidden = YES;
        
        switch (central.state)
        {
            case CBManagerStateUnknown:
                NSLog(@">>>CBCentralManagerStateUnknown");//未知的设备类型
                break;
            case CBManagerStateResetting:
                NSLog(@">>>CBCentralManagerStateResetting");//设备初始化中
                break;
            case CBManagerStateUnsupported:
                NSLog(@">>>CBCentralManagerStateUnsupported");//不支持蓝牙
                break;
            case CBManagerStateUnauthorized:
                NSLog(@">>>CBCentralManagerStateUnauthorized");//设备未授权
                break;
            case CBManagerStatePoweredOff:
                NSLog(@">>>CBCentralManagerStatePoweredOff");//蓝牙未开启
                break;
            default:
                break;
        }
    }
}

//每扫描到一个设备都会进入方法
/**
 central:            中心管理者
 peripheral:         外设
 advertisementData:  外设数据
 RSSI:               信号强度
 */
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *,id> *)advertisementData RSSI:(NSNumber *)RSSI
{
    NSLog(@"=====扫描连接外设：name = %@,=====",peripheral.name);
    NSString* localName = [advertisementData objectForKey:@"kCBAdvDataLocalName"];
    NSLog(@"======localName:%@====",localName);
    
    [central connectPeripheral:peripheral options:nil];
    if ([localName hasPrefix:@"085d"])
    {
        //NSString* tmpIP = [localName substringToIndex:4];
        NSString* tmpIP = [localName substringFromIndex:4];
        self.IP = [self numberWithHexString:tmpIP];
        NSString* log = [NSString stringWithFormat:@"正在连接:%ld",self.IP];
        
        self.conectLabel.text = log;
        self.MKphe = peripheral;
        [central stopScan];
        //连接设备
        [central connectPeripheral:peripheral options:nil];
    }
    
}

//连接成功
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    [self.MKphe setDelegate:self];
    [self.MKphe discoverServices:nil];
    
    NSString* log = [NSString stringWithFormat:@"连接成功:  %@",[self IPstringWithNumber:self.IP]];
    self.conectLabel.text = log;
    
    [self.activityView stopAnimating];
    self.activityView.hidden = YES;
}

//连接失败
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    self.conectLabel.text = @"连接失败";
    
    [self.activityView stopAnimating];
    self.activityView.hidden = YES;
}

//丢失连接
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    self.conectLabel.text = @"失去连接";
    
    [self.activityView stopAnimating];
    self.activityView.hidden = YES;
}


//扫描到服务,外设调用discoverServices后调用以下代理
-(void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    if (error)
    {
        NSLog(@"扫描外设服务出错：%@-> %@", peripheral.name, [error localizedDescription]);
        return;
    }
    
    NSLog(@"扫描到外设服务：%@ -> %@",peripheral.name,peripheral.services);
    for (CBService *service in peripheral.services)
    {
        [peripheral discoverCharacteristics:nil forService:service];
    }
    NSLog(@"开始扫描外设服务的特征 %@...",peripheral.name);
    
}

//扫描到特征,重要的方法
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    if (error)
    {
        NSLog(@"扫描外设的特征失败！%@->%@-> %@",peripheral.name,service.UUID, [error localizedDescription]);
        return;
    }
    
    NSLog(@"扫描到外设服务特征有：%@->%@->%@",peripheral.name,service.UUID,service.characteristics);
    //获取Characteristic的值
    for (CBCharacteristic *characteristic in service.characteristics){
        {
            //外部蓝牙设备给中心设备发送信息能够在didUpdateValueForCharacteristic代理中获取
            [self.MKphe setNotifyValue:YES forCharacteristic:characteristic];
            
            //播放
            if ([characteristic.UUID.UUIDString isEqualToString:BT_PLAY])
            {
                
            }
            
            //暂停
            else if ([characteristic.UUID.UUIDString isEqualToString:BT_PAUSE])
            {
                
            }
            
            //停止
            else if ([characteristic.UUID.UUIDString isEqualToString:BT_STOP])
            {

            }
            
            //发送数据
            else if ([characteristic.UUID.UUIDString isEqualToString:BT_WRITE])
            {
                self.MKwrite = characteristic;
            }
            
        }
    }
    
}

//接受外设数据
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(nullable NSError *)error
{
    if (error) {
        NSLog(@"扫描外设的特征失败！%@-> %@",peripheral.name, [error localizedDescription]);
        return;
    }
    
    NSLog(@"%@ %@",characteristic.UUID.UUIDString,characteristic.value);
    
    if ([characteristic.UUID.UUIDString isEqualToString:BT_PLAY])
    {
        
    }
    else if ([characteristic.UUID.UUIDString isEqualToString:BT_PAUSE])
    {
        
    }
    else if ([characteristic.UUID.UUIDString isEqualToString:BT_STOP])
    {
       
    }
    
}

//向外设发送数据
- (void)sendDatatoPeripheralWithData:(NSData*)data
{
    //不回调
    [self.MKphe writeValue:data forCharacteristic:self.MKwrite type:CBCharacteristicWriteWithoutResponse];
}




//连接热点
- (IBAction)connectWifi:(UIButton *)sender
{
    NSURL* url = [NSURL URLWithString:@"App-Prefs:root=WIFI"];
    //[[UIApplication sharedApplication] openURL:url];
    
    if([[UIApplication sharedApplication] canOpenURL:url])
    {
        [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:^(BOOL success) {
            NSLog(@"打开设置%@",success?@"成功":@"失败");
        }];
    }
}


- (void)getWifiName
{
    NSString* wifiname = @"not found";
    
    CFArrayRef myArray = CNCopySupportedInterfaces();
    if(myArray != nil)
    {
        CFDictionaryRef myDict = CNCopyCurrentNetworkInfo(CFArrayGetValueAtIndex(myArray, 0));
        if(myDict != nil)
        {
            NSDictionary* dict = (NSDictionary*)CFBridgingRelease(myDict);
            wifiname = [dict valueForKey:@"SSID"];
        }
    }

    self.conectLabel.text = [NSString stringWithFormat:@"连接WI-FI:  %@",wifiname];
}

//转到前台调用
- (void)applicationDidBecomeActive:(UIApplication *)application
{
    NSLog(@"......^-^.........");
    [self getWifiName];
}

//- (void)applicationDidEnterBackground:(UIApplication*)application
//{
//    NSLog(@"进入后台23333");
//}

#pragma mark -- 复制db文件
- (void)copyDBtoDocument
{
    /*
     NSString* filename = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"test.db"];
     */
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* documentsDir = [paths objectAtIndex:0];
    NSString* documentFile = [documentsDir stringByAppendingPathComponent:@"Song.db"];
    
    NSFileManager* fileManager = [NSFileManager defaultManager];
    if([fileManager fileExistsAtPath:documentFile] == NO)
    {
        NSLog(@"copy db file");
        NSError* error = NULL;
        NSString* recFile = [[NSBundle mainBundle] pathForResource:@"Song.db" ofType:nil];
        [fileManager copyItemAtPath:recFile toPath:documentFile error:&error];
        if(error != NULL){
            NSLog(@"copy db file error:%@",error);
        }
    }
}


/*
//数字转十六进制字符串
- (NSString*)stringWithHexNumber:(NSUInteger)hexNumber
{
    char hexChar[8];
    sprintf(hexChar, "%x", (int)hexNumber);
    
    return [NSString stringWithCString:hexChar encoding:NSUTF8StringEncoding];
}

*/


//十六进制字符串转数字
- (NSInteger)numberWithHexString:(NSString*)hexString
{
    const char* hexChar = [hexString cStringUsingEncoding:NSUTF8StringEncoding];
    
    int hexNumber;
    sscanf(hexChar, "%x", &hexNumber);
    
    return hexNumber;
}

//数字转换成IP地址
- (NSString*)IPstringWithNumber:(NSInteger)number
{
    int num = (int)number;
    NSString* ip = [NSString stringWithFormat:@"%d.%d.%d.%d", num & 0xFF, (num >> 8) & 0xFF, (num >> 16) & 0xFF, (num >> 24) & 0xFF];
    return ip;
}


//acc转wav
- (void)convetM4aToWav:(NSURL *)originalUrl  destUrl:(NSURL *)destUrl
{
    AVURLAsset *songAsset = [AVURLAsset URLAssetWithURL:originalUrl options:nil];
    
    //读取原始文件信息
    NSError *error = nil;
    AVAssetReader *assetReader = [AVAssetReader assetReaderWithAsset:songAsset error:&error];
    if (error) {
        NSLog (@"error: %@", error);
        return;
    }
    
    AVAssetReaderOutput *assetReaderOutput = [AVAssetReaderAudioMixOutput
                                              assetReaderAudioMixOutputWithAudioTracks:songAsset.tracks
                                              audioSettings: nil];
    
    if (![assetReader canAddOutput:assetReaderOutput])
    {
        NSLog (@"can't add reader output... die!");
        return;
    }
    
    [assetReader addOutput:assetReaderOutput];
    
    AVAssetWriter *assetWriter = [AVAssetWriter assetWriterWithURL:destUrl
                                                          fileType:AVFileTypeCoreAudioFormat
                                                             error:&error];
    if (error)
    {
        NSLog (@"error: %@", error);
        return;
    }
    
    AudioChannelLayout channelLayout;
    memset(&channelLayout, 0, sizeof(AudioChannelLayout));
    channelLayout.mChannelLayoutTag = kAudioChannelLayoutTag_Stereo;
    NSDictionary *outputSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                        [NSNumber numberWithInt:kAudioFormatLinearPCM], AVFormatIDKey,
                                        [NSNumber numberWithFloat:16000.0], AVSampleRateKey,
                                        [NSNumber numberWithInt:2], AVNumberOfChannelsKey,
                                        [NSData dataWithBytes:&channelLayout length:sizeof(AudioChannelLayout)],AVChannelLayoutKey,
                                        [NSNumber numberWithInt:16], AVLinearPCMBitDepthKey,
                                        [NSNumber numberWithBool:NO], AVLinearPCMIsNonInterleaved,
                                        [NSNumber numberWithBool:NO],AVLinearPCMIsFloatKey,
                                        [NSNumber numberWithBool:NO], AVLinearPCMIsBigEndianKey,
                                    nil];
    AVAssetWriterInput *assetWriterInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeAudio
                                                                              outputSettings:outputSettings];
    if ([assetWriter canAddInput:assetWriterInput])
    {
        [assetWriter addInput:assetWriterInput];
    }
    else
    {
        NSLog (@"can't add asset writer input... die!");
        return;
    }
    
    assetWriterInput.expectsMediaDataInRealTime = NO;
    
    [assetWriter startWriting];
    [assetReader startReading];
    
    AVAssetTrack *soundTrack = [songAsset.tracks objectAtIndex:0];
    CMTime startTime = CMTimeMake (0, soundTrack.naturalTimeScale);
    [assetWriter startSessionAtSourceTime:startTime];
    
    __block UInt64 convertedByteCount = 0;
    
    dispatch_queue_t mediaInputQueue = dispatch_queue_create("mediaInputQueue", NULL);
    [assetWriterInput requestMediaDataWhenReadyOnQueue:mediaInputQueue
                                            usingBlock: ^
     {
         while (assetWriterInput.readyForMoreMediaData) {
             CMSampleBufferRef nextBuffer = [assetReaderOutput copyNextSampleBuffer];
             if (nextBuffer) {
                 // append buffer
                 [assetWriterInput appendSampleBuffer: nextBuffer];
                 NSLog (@"appended a buffer (%zu bytes)",
                        CMSampleBufferGetTotalSampleSize (nextBuffer));
                 convertedByteCount += CMSampleBufferGetTotalSampleSize (nextBuffer);
                 
                 
             } else {
                 [assetWriterInput markAsFinished];
                 [assetWriter finishWritingWithCompletionHandler:^{
                     
                 }];
                 [assetReader cancelReading];
                 NSDictionary *outputFileAttributes = [[NSFileManager defaultManager]
                                                       attributesOfItemAtPath:[destUrl path]
                                                       error:nil];
                 NSLog (@"FlyElephant %lld",[outputFileAttributes fileSize]);
                 break;
             }
         }
         
     }];
}

@end
