//
//  ATPlayerMainView.m
//  VedioDemo
//
//  Created by 袁永国 on 16/3/5.
//  Copyright © 2016年 袁永国. All rights reserved.
//

#import "ATPlayerMainView.h"
#import "ATPlayerView.h"

@interface ATPlayerMainView ()<ATPlayerViewDelegate>

@property (strong,nonatomic) NSURL * url;
@property (strong,nonatomic) ATPlayerView *playerView;

@property (strong,nonatomic) UIButton * btnControl;
@property (strong,nonatomic) UISlider * slider;
@property (strong,nonatomic) UILabel * lableTime;
@property (strong,nonatomic) UIButton * btnSound;
@property (strong,nonatomic) UISlider * sliderSound;
@property (strong,nonatomic) UIButton * btnSize;

@end

@implementation ATPlayerMainView

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
    self.btnControl=[[UIButton alloc]init];
        self.btnControl.backgroundColor=[UIColor redColor];
    self.btnControl.translatesAutoresizingMaskIntoConstraints=NO;
    [self changeBtnStatus];
    [self.btnControl addTarget:self action:@selector(controlAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.btnControl];
    
    self.slider=[[UISlider alloc]init];
    self.slider.value=0;
    self.slider.translatesAutoresizingMaskIntoConstraints=NO;
    [self addSubview:self.slider];
    
    self.lableTime=[[UILabel alloc]init];
    [self setLableTimeInfo];
    self.lableTime.textColor=[UIColor redColor];
    self.lableTime.translatesAutoresizingMaskIntoConstraints=NO;
    [self addSubview:self.lableTime];
    
    
    
    NSArray *layoutH=[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[btnControl(28)]-10-[slider(250)]-5-[lableTime]-10-|" options:0 metrics:nil views:@{@"btnControl":self.btnControl,@"slider":self.slider,@"lableTime":self.lableTime}];
    NSArray *layoutV=[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-20-[btnControl(32)]" options:0 metrics:nil views:@{@"btnControl":self.btnControl}];
    [self addConstraints:layoutH];
    [self addConstraints:layoutV];
    
    NSArray *layoutV1=[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-20-[slider]" options:0 metrics:nil views:@{@"slider":self.slider}];
    [self addConstraints:layoutV1];
    
    NSArray *layoutV2=[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-25-[lableTime]" options:0 metrics:nil views:@{@"lableTime":self.lableTime}];
    [self addConstraints:layoutV2];
    
}

//修改btn的状态对应的图片
- (void) changeBtnStatus {
    NSString *imageName=@"icon_play_hl";
    if(self.playerView.currentStatus==0){
        self.btnControl.enabled=NO;
        imageName=@"icon_play_hl";
    }else if(self.playerView.currentStatus==1){
        self.btnControl.enabled=YES;
        imageName=@"icon_play";
    }else if (self.playerView.currentStatus==2){
        self.btnControl.enabled=YES;
        imageName=@"icon_pause";
    }else if (self.playerView.currentStatus==3){
        self.btnControl.enabled=YES;
        imageName=@"icon_play";
    }
    [self.btnControl setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    [self.btnControl setImage:[UIImage imageNamed:imageName] forState:UIControlStateHighlighted];
    
}

//设置总是长
- (void) setLableTimeInfo {
    self.lableTime.text=[NSString stringWithFormat:@"%2ld:%2ld:%2ld",(long)self.playerView.totalSecond/3600,(long)self.playerView.totalSecond/60,(long)self.playerView.totalSecond%60];
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

-(void)playerCurrentTime:(CGFloat) currentTime {
    NSLog(@"%f",currentTime/self.playerView.totalSecond);
    self.slider.value=currentTime/self.playerView.totalSecond;
}

@end
