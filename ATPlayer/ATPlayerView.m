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

@implementation ATPlayerView{
    BOOL isBufferEmpty;
}

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

- (void) setCurrentTime:(NSTimeInterval) timeInterval completionHandler:(void (^)(BOOL finished))completionHandler{
    [self.player seekToTime:CMTimeMake(timeInterval, 1) completionHandler:^(BOOL finished) {
        completionHandler(finished);
    }];
}

//加载视频
- (void) loadPlayerInfoWithUrl:(NSURL *)url {
    AVPlayerItem * playerItem=[AVPlayerItem playerItemWithURL:url];
    self.player=[AVPlayer playerWithPlayerItem:playerItem];
    [self.player pause];
    [self addObserverWithPlayer];
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
   // self.player.currentItem.playbackLikelyToKeepUp=YES;
    [self addObserverWithPlayer];
}

//添加状态、缓存的监控
- (void) addObserverWithPlayer {
    //添加状态、缓存的监控
    [self.player.currentItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    [self.player.currentItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
    //缓存不足的监控
    [self.player.currentItem addObserver:self forKeyPath:@"playbackBufferEmpty" options:NSKeyValueObservingOptionNew context:nil];
    
    [self.player.currentItem addObserver:self forKeyPath:@"playbackLikelyToKeepUp" options:NSKeyValueObservingOptionNew context:nil];
    [self.player.currentItem addObserver:self forKeyPath:@"playbackBufferFull" options:NSKeyValueObservingOptionNew context:nil];
    //定时获取当前播放进度
    __weak typeof (self) weakSelf=self;
    [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1, 1) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        weakSelf.currentSecond=CMTimeGetSeconds(time);;
        if(weakSelf.delegate){
            [weakSelf.delegate playerCurrentTime:weakSelf.currentSecond];
        }
    }];
}

//移除监控
- (void) removeObserverWithPlayer {
    [self.player.currentItem removeObserver:self forKeyPath:@"status" ];
    [self.player.currentItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
    [self.player.currentItem removeObserver:self forKeyPath:@"playbackBufferEmpty"];
    [self.player.currentItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
    [self.player.currentItem removeObserver:self forKeyPath:@"playbackBufferFull"];
    
    [self.player removeTimeObserver:self];
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
        NSLog(@"状态变化：%ld",self.player.currentItem.status);
        if(self.delegate){
            [self.delegate playerStatusChange:self.player.currentItem.status];
        }
    }else if([keyPath isEqualToString:@"loadedTimeRanges"]){
        NSArray * array= self.player.currentItem.loadedTimeRanges;
        CMTimeRange range=[array.firstObject CMTimeRangeValue];
        CGFloat startSecond= CMTimeGetSeconds(range.start);
        CGFloat durationSecond=CMTimeGetSeconds(range.duration);
        CGFloat totalDurationSecond=startSecond+durationSecond;//总共缓存时长
        /*
         当缓存不足导致不播放时可以通过缓存的数据来判断是否播放
         （建议：可以设置一个缓存的时间间隔以便流畅的播放）
         */
        if(totalDurationSecond>(self.currentSecond+10)&&isBufferEmpty){
            isBufferEmpty=NO;
            [self.player play];
            NSLog(@"缓存充足播放！");
        }
        if(self.delegate){
            if(self.totalSecond!=0){
             [self.delegate bufferLoadedScale:totalDurationSecond/self.totalSecond];
            }
            
        }
        NSLog(@"缓冲:%lf",totalDurationSecond);
    }else if([keyPath isEqualToString:@"playbackBufferEmpty"]){
        NSLog(@"缓存不足avplayer会停止播放!");
        isBufferEmpty=YES;

        
    }else if([keyPath isEqualToString:@"playbackBufferFull"]){
        NSLog(@"缓存充足！");
        [self.player play];
    }else if([keyPath isEqualToString:@"playbackLikelyToKeepUp"]){
        
        
        NSLog(@"缓存：%ld",self.player.currentItem.playbackLikelyToKeepUp);
    }
}



@end
