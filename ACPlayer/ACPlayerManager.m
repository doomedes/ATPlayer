//
//  ACPlayerManager.m
//  VedioDemo
//
//  Created by 袁永国 on 16/4/4.
//  Copyright © 2016年 袁永国. All rights reserved.
//

#import "ACPlayerManager.h"
#import "ACPlayer.h"
#import "ProgressBarView.h"
#import "ProgressBarPointView.h"
#import "CAStateButton.h"
#import "ProgressBarViewDelegate.h"

#define  colorWithRGB(r,g,b) ([UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1])

@interface ACPlayerManager ()<ACPlayerDelegate,ProgressBarViewDelegate>

@property (strong,nonatomic) NSURL * url;
@property (strong,nonatomic) ACPlayer *playerView;

@property (strong,nonatomic) CAStateButton * btnControl;
@property (strong,nonatomic) ProgressBarView * progressBar;

@property (strong,nonatomic) UILabel * lableTime;
@property (strong,nonatomic) UIButton * btnSound;
@property (strong,nonatomic) UISlider * sliderSound;
@property (strong,nonatomic) UIButton * btnSize;
@property (assign,nonatomic) CGFloat currentPlayingScale;

@end

@implementation ACPlayerManager {
    BOOL  isDrag;
}

#pragma mark- 相关属性

- (ACPlayer *)playerView {
    if(!_playerView){
        _playerView=[[ACPlayer alloc]initWithUrl:self.url];
        _playerView.delegate=self;
    }
    return _playerView;
}

-(void)setIsAutoPlay:(BOOL)isAutoPlay {
    _isAutoPlay=isAutoPlay;
    self.playerView.isAutoPlay=isAutoPlay;
}

#pragma mark-相关事件

- (instancetype) initWithUrl:(NSURL *)url {
    self = [super init];
    if (self) {
        self.url=url;
        [self addSubview:self.playerView];
        self.playerView.translatesAutoresizingMaskIntoConstraints=NO;
        NSArray *layoutH=[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[playerView]-0-|" options:0 metrics:nil views:@{@"playerView":self.playerView}];
        NSArray *layoutV=[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[playerView]-0-|" options:0 metrics:nil views:@{@"playerView":self.playerView}];
        [self addConstraints:layoutH];
        [self addConstraints:layoutV];
        [self loadControlInfo];
    }
    return self;
}

- (void) relplacePlayerItemWithUrl:(NSURL *)url {
    [self.playerView relplacePlayerItemWithUrl:url];
}

//加载控件信息
- (void) loadControlInfo {
    self.btnControl=[[CAStateButton alloc]init];
    self.btnControl.stateButtonColor=[UIColor grayColor];
    self.btnControl.translatesAutoresizingMaskIntoConstraints=NO;
    [self.btnControl addTarget:self action:@selector(controlAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.btnControl];
    
    self.progressBar=[[ProgressBarView alloc]init];
    self.progressBar.thickWithd=2;
    self.progressBar.thickRadius=1;
    self.progressBar.pointViewRadius=7;
    self.progressBar.horizontalPadding=3;
    self.progressBar.backgroundViewColor=colorWithRGB(180,205,205);
    self.progressBar.bufferViewColor=[UIColor redColor];
    self.progressBar.playingViewColor=colorWithRGB(0,191,255);
    self.progressBar.translatesAutoresizingMaskIntoConstraints=NO;
    self.progressBar.delegate=self;
    [self addSubview:self.progressBar];
    
    self.lableTime=[[UILabel alloc]init];
    [self setLableTimeInfo];
    self.lableTime.font=[UIFont systemFontOfSize:12];
    self.lableTime.textColor=[UIColor redColor];
    self.lableTime.translatesAutoresizingMaskIntoConstraints=NO;
    [self addSubview:self.lableTime];
    
    NSArray *layoutH=[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[btnControl(20)]-5-[slider(250)]-5-[lableTime]-10-|" options:0 metrics:nil views:@{@"btnControl":self.btnControl,@"slider":self.progressBar,@"lableTime":self.lableTime}];
    NSArray *layoutV=[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-22-[btnControl(20)]" options:0 metrics:nil views:@{@"btnControl":self.btnControl}];
    [self addConstraints:layoutH];
    [self addConstraints:layoutV];
    
    NSArray *layoutV1=[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-22-[slider(20)]" options:0 metrics:nil views:@{@"slider":self.progressBar}];
    [self addConstraints:layoutV1];
    
    NSArray *layoutV2=[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-24-[lableTime]" options:0 metrics:nil views:@{@"lableTime":self.lableTime}];
    [self addConstraints:layoutV2];
    
}

//设置总是长
- (void) setLableTimeInfo {
    self.lableTime.text=[NSString stringWithFormat:@"%02ld:%02ld:%02ld",(long)self.playerView.totalTime/3600,(long)self.playerView.totalTime/60,(long)self.playerView.totalTime%60];
}

- (void)controlAction:(CAStateButton *)sender {
    if(sender.stateButtonStyle==CAStatusButtonStyleStop && (self.playerView.status==StatusLayerInit||self.playerView.status==StatusReadyToPlay||self.playerView.status==StatusPlayPause ||self.playerView.status==StatusBufferEnough)){
        [self.playerView play];
    }else if(sender.stateButtonStyle==CAStatusButtonStylePlay){
        [self.playerView pause];
    }
}

#pragma  mark-ProgressBarViewDelegate

-(void) ProgressBarBeginMove {
    isDrag=YES;
}

-(void) ProgressBarMoving {
    
}

-(void) ProgressBarEndMove:(CGFloat) scale {
    __weak typeof (self) weakSelf=self;
    [self.playerView setCurrentTime:self.playerView.totalTime*scale completionHandler:^(BOOL finished) {
        if(finished){
            [weakSelf.playerView play];
        }else{
            //返回之前的进度
            weakSelf.progressBar.playingScale=weakSelf.currentPlayingScale;
        }
        isDrag=NO;
    }];
    
}

-(void) ProgressBarCancelMove {
    isDrag=NO;
}

#pragma mark-ACPlayerDelegate

//状态切换时
-(void)playerStatusChange:(CAPlayerStatus) status {
    switch (status) {
        case StatusInitialize://创建 ▶︎
            self.btnControl.stateButtonStyle=CAStatusButtonStyleStop;
            self.progressBar.enableDrag=NO;
            NSLog(@"创建");
            
            break;
        case StatusFailed:   //加载失败 ▶︎
            self.btnControl.stateButtonStyle=CAStatusButtonStyleStop;
            self.progressBar.enableDrag=NO;
            NSLog(@"加载失败");

            break;
        case StatusLayerInit: //layer加载成功
            self.progressBar.enableDrag=YES;
            NSLog(@"avplayer的layer加载成功");
            break;
        case StatusUnknown:   //加载未知 ▶︎
            self.btnControl.stateButtonStyle=CAStatusButtonStyleStop;
            self.progressBar.enableDrag=NO;
             NSLog(@"加载未知");
            break;
        case StatusReadyToPlay: //可以播放（调用player播放） ▶︎
            self.btnControl.stateButtonStyle=CAStatusButtonStyleStop;
            self.progressBar.enableDrag=YES;
            [self setLableTimeInfo];
            NSLog(@"可以播放（调用player播放)");
            break;
        case StatusInPlaying:      //播放中 ◼︎
            self.btnControl.stateButtonStyle=CAStatusButtonStylePlay;
            self.progressBar.enableDrag=YES;
             NSLog(@"播放中");
             break;
        case  StatusPlayPause:      //暂停 ▶︎
            self.btnControl.stateButtonStyle=CAStatusButtonStyleStop;
            self.progressBar.enableDrag=YES;
            NSLog(@"暂停");

             break;
        case  StatusBufferEmpty:    //缓存不足 ▶︎
            self.btnControl.stateButtonStyle=CAStatusButtonStyleStop;
            self.progressBar.enableDrag=YES;
             NSLog(@"缓存不足");
            
             break;
        case  StatusBufferNotEmpty: //缓存>播放时间
            self.progressBar.enableDrag=YES;
            NSLog(@"缓存>播放时间");
            
             break;
        case  StatusBufferEnough:   //缓存充足（缓存>=（播放时间＋cacheTime:自定义的缓存时间长））▶︎
            if(self.isAutoPlay)
            {
                self.btnControl.stateButtonStyle=CAStatusButtonStyleStop;
            }
            self.progressBar.enableDrag=YES;
            NSLog(@"缓存充足");

            break;
        case  StatusPalyEnd:         //播放结束 ▶︎
            self.btnControl.stateButtonStyle=CAStatusButtonStyleStop;
            self.progressBar.enableDrag=YES;
            NSLog(@"播放结束");
             break;
        default:
            break;
    }
    
}

//更新播放进度条
-(void)playerCurrentTime:(NSTimeInterval) currentTime {
    if(!isDrag){
        if(self.playerView.totalTime==0){
            self.progressBar.playingScale=0;
            self.currentPlayingScale=0;
        }else{
            self.progressBar.playingScale=currentTime/self.playerView.totalTime;
            self.currentPlayingScale=self.progressBar.playingScale;
        }
       
    }
}

//更新缓冲进度条
-(void)playerloadedTime:(NSTimeInterval) loadedTime {
    if(self.playerView.totalTime==0){
        self.progressBar.bufferScale=0;
    }else{
        CGFloat scale=loadedTime/self.playerView.totalTime;
        self.progressBar.bufferScale=scale;
    }
    
}

 
@end
