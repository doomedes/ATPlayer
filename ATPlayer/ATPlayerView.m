//
//  ATPlayerView.m
//  VedioDemo
//
//  Created by 袁永国 on 16/3/5.
//  Copyright © 2016年 袁永国. All rights reserved.
//

#import "ATPlayerView.h"

@interface ATPlayerView ()

@property (strong,nonatomic) NSURL * url;
@property (strong,nonatomic) AVPlayer * player;
//@property (strong,nonatomic) AVPlayerItem * playerItem;
@property (strong,nonatomic) AVPlayerLayer *playerLayer;

@end

@implementation ATPlayerView

- (void)setUrl:(NSURL *)url {
    _url=url;
}

- (instancetype) initWithUrl:(NSURL *)url {
    self = [super init];
    if (self) {
        self.url=url;
        [self loadPlayerInfoWithUrl:url];

    }
    return self;
}

- (void)play {
    if(self.currentStatus==1||self.currentStatus==3){
        self.currentStatus=2;
        [self.player play];
    }
}

- (void)pause {
    if(self.currentStatus==2){
        self.currentStatus=3;
        [self.player pause];
    }
}

//加载视频
- (void) loadPlayerInfoWithUrl:(NSURL *)url {
    AVPlayerItem * playerItem=[AVPlayerItem playerItemWithURL:url];
    self.player=[AVPlayer playerWithPlayerItem:playerItem];
    [self.player pause];
    [self loadPlayerExtenedInfo];
}

//切换视频
- (void) relplacePlayerItemWithUrl:(NSURL *)url {
    if(!self.player){
        [self loadPlayerInfoWithUrl:url];
        return;
    }
    [self removeObserverWithPlayer];
    [self.player pause];
    AVPlayerItem * playerItem=[AVPlayerItem playerItemWithURL:url];
    [self.player replaceCurrentItemWithPlayerItem:playerItem];
    [self loadPlayerExtenedInfo];
}

//定时获取当前播放进度
-(void) loadPlayerExtenedInfo {
    __weak typeof (self) weakSelf=self;
    [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1, 1) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        weakSelf.currentSecond=CMTimeGetSeconds(time);;
        if(weakSelf.delegate){
            [weakSelf.delegate playerCurrentTime:weakSelf.currentSecond];
        }
    }];
    [self addObserverWithPlayer];
}

//添加状态、缓存的监控
- (void) addObserverWithPlayer {
    //添加状态、缓存的监控
    [self.player.currentItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    [self.player.currentItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
    
}

//移除监控
- (void) removeObserverWithPlayer {
    [self.player.currentItem removeObserver:self forKeyPath:@"status" ];
    [self.player.currentItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
}

//添加playerLayer
- (void) playerStartReady {
    self.currentStatus=1;
    //防止多次调用闪烁问题
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        self.playerLayer=[AVPlayerLayer playerLayerWithPlayer:self.player];
        self.playerLayer.frame=[UIScreen mainScreen].bounds;
        self.playerLayer.videoGravity= AVLayerVideoGravityResizeAspect;//布局方式
        [self.layer addSublayer:self.playerLayer];
    });
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if([keyPath isEqualToString:@"status"]){
        if(self.player.currentItem.status==AVPlayerItemStatusReadyToPlay){
        /*
         time指的就是時間(不是秒),
         而時間要換算成秒就要看第二個參數timeScale了.
         timeScale指的是1秒需要由幾個frame構成(可以視為fps),
         因此真正要表達的時間就會是 time / timeScale 才會是秒.”
         */
            CMTime totalTime=  self.player.currentItem.duration;
            self.totalSecond=(CGFloat)totalTime.value/totalTime.timescale;
            //准备播放
            [self playerStartReady];
        }else if(self.player.currentItem.status==AVPlayerItemStatusFailed){
            //失败
             NSLog(@"fial:%@",self.player.currentItem.errorLog);
        }else{
            //不知道原因
            NSLog(@"unkonw:%@",self.player.currentItem.errorLog);
        }
        if(self.delegate){
            [self.delegate playerStatusChange:self.player.currentItem.status];
        }
    }else if([keyPath isEqualToString:@"loadedTimeRanges"]){
        NSArray * array= self.player.currentItem.loadedTimeRanges;
        CMTimeRange range=[array.firstObject CMTimeRangeValue];
        CGFloat startSecond= CMTimeGetSeconds(range.start);
        CGFloat durationSecond=CMTimeGetSeconds(range.duration);
        CGFloat totalDurationSecond=startSecond+durationSecond;//总共缓存时长
        NSLog(@"缓冲:%lf",totalDurationSecond);
    }
}



@end
