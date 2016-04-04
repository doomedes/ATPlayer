//
//  ACPlayer.m
//  VedioDemo
//
//  Created by yuanyongguo on 16/3/7.
//  Copyright © 2016年 袁永国. All rights reserved.
//

#import "ACPlayer.h"
#import <AVFoundation/AVFoundation.h>
#import "ACPlayerResourceLoaderDelegate.h"

@interface ACPlayer ()

@property (strong,nonatomic) AVURLAsset *urlAsset;
@property (strong,nonatomic) AVAssetImageGenerator *assetImageGenerator;
@property (strong,nonatomic) AVPlayer *player;
@property (strong,nonatomic) AVPlayerLayer *playerLayer;

@property (strong,nonatomic) ACPlayerResourceLoaderDelegate*  resourceLoaderDelegate;
@end

@implementation ACPlayer {
    BOOL isBufferEnough;//缓存是否充足，足够播放
}

//播放
- (void)play {
    if(self.status==StatusReadyToPlay||self.status==StatusPlayPause||self.status==StatusBufferEnough){
        [self.player play];
        [self playerStatusChange:StatusInPlaying];
    }
}

//暂停
- (void)pause {
    if(self.status==StatusInPlaying){
        [self.player pause];
        [self playerStatusChange:StatusPlayPause];
    }
}

//设置播放时间
- (void) setCurrentTime:(NSTimeInterval) timeInterval completionHandler:(void (^)(BOOL finished))completionHandler{
    [self.player seekToTime:CMTimeMake(timeInterval, 1) completionHandler:^(BOOL finished) {
        completionHandler(finished);
    }];
}


-(ACPlayerResourceLoaderDelegate *)resourceLoaderDelegate {
    if(!_resourceLoaderDelegate){
        _resourceLoaderDelegate=[[ACPlayerResourceLoaderDelegate alloc]init];
    }
    return _resourceLoaderDelegate;
}

#pragma mark-相关事件

- (instancetype)initWithUrl:(NSURL *)url {
    self=[super init];
    if(self){
        [self loadInfoWithUrl:url];
    }
    return self;
}

- (AVPlayerItem *) createPlayerItemWithUrl:(NSURL *) url {
    NSURL *newUrl=[self.resourceLoaderDelegate convertUrlToCustomUrl:url];
    self.urlAsset=[AVURLAsset URLAssetWithURL:newUrl options:nil];
    [self.urlAsset.resourceLoader setDelegate:self.resourceLoaderDelegate queue:dispatch_get_main_queue()];
    AVPlayerItem* playerItem=[AVPlayerItem playerItemWithAsset:self.urlAsset];
    return playerItem;
}

//加载指定url的视频
- (void)loadInfoWithUrl:(NSURL *)url {
    AVPlayerItem * playerItem=[self createPlayerItemWithUrl:url];
    self.player=[AVPlayer playerWithPlayerItem:playerItem];
    [self addObserverWithPlayer];
     self.player.volume=5;//设置声音
    [self playerStatusChange:StatusInitialize];
    
}

//切换指定url的视频
- (void) relplacePlayerItemWithUrl:(NSURL *)url {
    if(!self.player){
        [self loadInfoWithUrl:url];
        return;
    }
    //注意：要先移除observer与暂停
    [self removeObserverWithPlayer];
    [self.player pause];
    AVPlayerItem * playerItem=[self createPlayerItemWithUrl:url];
    [self.player replaceCurrentItemWithPlayerItem:playerItem];
    [self addObserverWithPlayer];
}

-(void) loadPlayer {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        self.playerLayer=[AVPlayerLayer playerLayerWithPlayer:self.player];
        self.playerLayer.frame=[UIScreen mainScreen].bounds;
        self.playerLayer.videoGravity=AVLayerVideoGravityResizeAspect;
        [self.layer addSublayer:self.playerLayer];
    });
}

/*
 添加状态、缓存进度与缓冲不足,播放进度的监控
 */
- (void) addObserverWithPlayer {
    //播放状态的监控
    [self.player.currentItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    //缓冲进度的监控
    [self.player.currentItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
    //缓存不足的监控
    [self.player.currentItem addObserver:self forKeyPath:@"playbackBufferEmpty" options:NSKeyValueObservingOptionNew context:nil];
    //self.player.currentItem.playbackBufferEmpty   //缓存不足
    
    //定时更新播放时间
    __weak typeof (self) weakSelf=self;
    [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1, 1) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        weakSelf.currentTime=CMTimeGetSeconds(time);;
        if(weakSelf.delegate){
            [weakSelf.delegate playerCurrentTime:weakSelf.currentTime];
        }
    }];
    
}

/*
 移除监控
 */
- (void) removeObserverWithPlayer {
    [self.player.currentItem removeObserver:self forKeyPath:@"status"];
    [self.player.currentItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
    [self.player.currentItem removeObserver:self forKeyPath:@"playbackBufferEmpty"];
    [self.player removeTimeObserver:self];
    
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if([keyPath isEqualToString:@"loadedTimeRanges"]){
        /*
         缓存进度监控
         */
        NSArray * array= self.player.currentItem.loadedTimeRanges;
        CMTimeRange range=[array.firstObject CMTimeRangeValue];
        Float64 startSecond= CMTimeGetSeconds(range.start);
        Float64 durationSecond=CMTimeGetSeconds(range.duration);
        self.loadedTime=startSecond+durationSecond;//总共缓存时长
        NSLog(@"当前缓冲时间：%fld",self.loadedTime);
        /*
         当缓存不足导致不播放时可以通过缓存的数据来判断是否播放
         （建议：可以设置一个缓存的时间间隔以便流畅的播放）
         */
        if(self.loadedTime>(self.currentTime+self.cacheTime)&&!isBufferEnough)
        {
            isBufferEnough=YES;
            [self playerStatusChange:StatusBufferEnough];
            [self play];

        }
        if(self.delegate&&[self.delegate respondsToSelector:@selector(playerloadedTime:)]){
            [self.delegate playerloadedTime:self.loadedTime];
        }
        
    }else if ([keyPath isEqualToString:@"status"]) {
        /*
         状态变化监控
         */
        if (self.player.currentItem.status==AVPlayerItemStatusReadyToPlay) {
           
            [self loadPlayer];
            /*
             time指的就是時間(不是秒),
             而時間要換算成秒就要看第二個參數timeScale了.
             timeScale指的是1秒需要由幾個frame構成(可以視為fps),
             因此真正要表達的時間就會是 time / timeScale 才會是秒.”
             */
            CMTime totalTime=  self.player.currentItem.duration;
            self.totalTime=(CGFloat)totalTime.value/totalTime.timescale;
            
            [self playerStatusChange:StatusReadyToPlay];
            if(self.isAutoPlay){
                [self play];
            }
        }else if(self.player.currentItem.status==AVPlayerItemStatusFailed){
            [self playerStatusChange:StatusFailed];
        }else {
            [self playerStatusChange:StatusUnknown];
        }
        
    }else if([keyPath isEqualToString:@"playbackBufferEmpty"]) {
        /*
         缓存不足监控（网络慢）
         */
        if(self.player.currentItem.playbackBufferEmpty){
            //缓存不足＝YES
            isBufferEnough=NO;
            [self.player pause];//暂停
            [self playerStatusChange:StatusBufferEmpty];
        }else{
            //缓存不足＝NO
//          [self playerStatusChange:StatusBufferNotEmpty];
        }
        
    }
}


-(void) playerStatusChange:(CAPlayerStatus) status {
    self.status=status;
    if(self.delegate&& [self.delegate respondsToSelector:@selector(playerStatusChange:)]){
              [self.delegate playerStatusChange:status];
     
     }
}

-(void)dealloc {
    [self removeObserverWithPlayer];
}

@end
