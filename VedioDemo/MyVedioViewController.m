//
//  MyVedioViewController.m
//  VedioDemo
//
//  Created by 袁永国 on 16/3/5.
//  Copyright © 2016年 袁永国. All rights reserved.
//

/*
 视频相关
 */

#import "MyVedioViewController.h"
#import "ATPlayerView.h"
#import "ATPlayerMainView.h"
#import "ACPlayer.h"

@interface MyVedioViewController ()
@property (strong,nonatomic) ATPlayerMainView * playerView;
@end

@implementation MyVedioViewController




- (void)viewDidLoad {
    [super viewDidLoad];
     NSURL* url=[NSURL URLWithString:@"http://v.jxvdy.com/sendfile/w5bgP3A8JgiQQo5l0hvoNGE2H16WbN09X-ONHPq3P3C1BISgf7C-qVs6_c8oaw3zKScO78I--b0BGFBRxlpw13sf2e54QA"];
    
    _playerView=[[ATPlayerMainView alloc]initWithUrl:url];
    _playerView.frame=self.view.frame;
    [self.view addSubview:_playerView];

//    ACPlayer *player=[[ACPlayer alloc]initWithUrl:url];
//    player.frame=self.view.frame;
//    [self.view addSubview:player];
    

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    //改地址不可以使用了
    //http://zyvideo1.oss-cn-qingdao.aliyuncs.com/zyvd/7c/de/04ec95f4fd42d9d01f63b9683ad0
//    NSURL *url=  [NSURL URLWithString:@"http://zyvideo1.oss-cn-qingdao.aliyuncs.com/zyvd/7c/de/04ec95f4fd42d9d01f63b9683ad0"];
    
    NSURL* url=[NSURL URLWithString:@"http://v.jxvdy.com/sendfile/w5bgP3A8JgiQQo5l0hvoNGE2H16WbN09X-ONHPq3P3C1BISgf7C-qVs6_c8oaw3zKScO78I--b0BGFBRxlpw13sf2e54QA"];
    [self.playerView relplacePlayerItemWithUrl:url];
    
}


@end
