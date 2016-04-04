//
//  ATPlayerMainView.m
//  VedioDemo
//
//  Created by 袁永国 on 16/3/5.
//  Copyright © 2016年 袁永国. All rights reserved.
//

#import "ATPlayerMainView.h"
#import "ATPlayerView.h"
#import "ProgressBarView.h"
#import "ProgressBarPointView.h"
#import "CAStateButton.h"
#import "ProgressBarViewDelegate.h"

#define  colorWithRGB(r,g,b) ([UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1])

@interface ATPlayerMainView ()<ATPlayerViewDelegate,ProgressBarViewDelegate>

@property (strong,nonatomic) NSURL * url;
@property (strong,nonatomic) ATPlayerView *playerView;

@property (strong,nonatomic) CAStateButton * btnControl;
@property (strong,nonatomic) ProgressBarView * progressBar;

@property (strong,nonatomic) UILabel * lableTime;
@property (strong,nonatomic) UIButton * btnSound;
@property (strong,nonatomic) UISlider * sliderSound;
@property (strong,nonatomic) UIButton * btnSize;
@property (assign,nonatomic) CGFloat currentPlayingScale;

@end

@implementation ATPlayerMainView {
   BOOL  isDrag;
}

- (ATPlayerView *)playerView {
    if(!_playerView){
        _playerView=[[ATPlayerView alloc]initWithUrl:self.url];
        _playerView.frame=self.frame;
        _playerView.delegate=self;
    }
    return _playerView;
}

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
    self.lableTime.textColor=[UIColor redColor];
    self.lableTime.translatesAutoresizingMaskIntoConstraints=NO;
    [self addSubview:self.lableTime];
    
    
    
    NSArray *layoutH=[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[btnControl(20)]-5-[slider(250)]-5-[lableTime]-10-|" options:0 metrics:nil views:@{@"btnControl":self.btnControl,@"slider":self.progressBar,@"lableTime":self.lableTime}];
    NSArray *layoutV=[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-22-[btnControl(20)]" options:0 metrics:nil views:@{@"btnControl":self.btnControl}];
    [self addConstraints:layoutH];
    [self addConstraints:layoutV];
    
    NSArray *layoutV1=[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-22-[slider(20)]" options:0 metrics:nil views:@{@"slider":self.progressBar}];
    [self addConstraints:layoutV1];
    
    NSArray *layoutV2=[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-22-[lableTime]" options:0 metrics:nil views:@{@"lableTime":self.lableTime}];
    [self addConstraints:layoutV2];
    
}

//修改btn的状态
- (void) changeBtnStatus {
    if(self.playerView.currentStatus==0){
        self.btnControl.enabled=NO;
        self.btnControl.stateButtonStyle=CAStatusButtonStyleStop;
    }else if(self.playerView.currentStatus==1){
        self.btnControl.enabled=YES;
        self.btnControl.stateButtonStyle=CAStatusButtonStyleStop;
    }else if (self.playerView.currentStatus==2){
        self.btnControl.enabled=YES;
        self.btnControl.stateButtonStyle=CAStatusButtonStylePlay;
    }else if (self.playerView.currentStatus==3){
        self.btnControl.enabled=YES;
        self.btnControl.stateButtonStyle=CAStatusButtonStyleStop;
    }
}

//设置总是长
- (void) setLableTimeInfo {
    self.lableTime.text=[NSString stringWithFormat:@"%02ld:%02ld:%02ld",(long)self.playerView.totalSecond/3600,(long)self.playerView.totalSecond/60,(long)self.playerView.totalSecond%60];
}

- (void)controlAction:(UIButton *)sender {
    if(self.playerView.currentStatus==1||self.playerView.currentStatus==3){
        [self.playerView play];
    }else if(self.playerView.currentStatus==2){
        [self.playerView pause];
    }
    [self changeBtnStatus];
}

#pragma mark-ATPlayerViewDelegate

-(void)playerStatusChange:(AVPlayerItemStatus) status {
    if(status==AVPlayerItemStatusReadyToPlay){
        [self changeBtnStatus];
        [self setLableTimeInfo];
    }
}

-(void)bufferLoadedScale:(CGFloat)scale {
    self.progressBar.bufferScale=scale;
}

-(void)playerCurrentTime:(CGFloat) currentTime {
    if(!isDrag){
      self.progressBar.playingScale=currentTime/self.playerView.totalSecond;
      self.currentPlayingScale=self.progressBar.playingScale;
    }
  
}


#pragma  mark-ProgressBarViewDelegate

-(void) ProgressBarBeginMove {
    isDrag=YES;
}

-(void) ProgressBarMoving {
    
}

-(void) ProgressBarEndMove:(CGFloat)  scale {
    
    __weak typeof (self) weakSelf=self;
   [self.playerView setCurrentTime:self.playerView.totalSecond*scale completionHandler:^(BOOL finished) {
       if(finished){
            [weakSelf.playerView play];
            [weakSelf changeBtnStatus];
       }else{
           weakSelf.progressBar.playingScale=weakSelf.currentPlayingScale;
       }
       isDrag=NO;
   }];
    
}

-(void) ProgressBarCancelMove {
    isDrag=NO;
}





@end
