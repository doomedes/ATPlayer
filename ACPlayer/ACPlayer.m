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
//@property (strong,nonatomic) AVPlayerItem *playerItem;
@property (strong,nonatomic) AVPlayerLayer *playerLayer;

@property (strong,nonatomic) ACPlayerResourceLoaderDelegate*  resourceLoaderDelegate;
@end

@implementation ACPlayer

- (instancetype)initWithUrl:(NSURL *)url {
    self=[super init];
    if(self){
        [self loadInfoWithUrl:url];
    }
    return self;
}

- (void)loadInfoWithUrl:(NSURL *)url {
    
    NSURL *newUrl=[self relaceSchemaWithRrl:url];
    self.urlAsset=[AVURLAsset URLAssetWithURL:newUrl options:nil];
    self.resourceLoaderDelegate=[[ACPlayerResourceLoaderDelegate alloc]init];
    [self.urlAsset.resourceLoader setDelegate:self.resourceLoaderDelegate queue:dispatch_get_main_queue()];
    
    AVPlayerItem* playerItem=[AVPlayerItem playerItemWithAsset:self.urlAsset];
    self.player=[AVPlayer playerWithPlayerItem:playerItem];
    
    //添加对播放状态和缓冲进度的监控
    [self.player.currentItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    [self.player.currentItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
    
    //定时更新播放时间
    [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1, 1) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        
    }];
    
    self.playerLayer=[AVPlayerLayer playerLayerWithPlayer:self.player];
    self.playerLayer.frame=[UIScreen mainScreen].bounds;
    self.playerLayer.videoGravity=AVLayerVideoGravityResizeAspect;
    [self.layer addSublayer:self.playerLayer];
    
}

- (NSURL *)relaceSchemaWithRrl:(NSURL *) url {
   NSURLComponents *urlComponents=[NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:NO];
    urlComponents.scheme=@"streaming";
    return urlComponents.URL;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if([keyPath isEqualToString:@"loadedTimeRanges"]){
       NSArray *arrary=self.player.currentItem.loadedTimeRanges;
       CMTimeRange timerRange=[[arrary firstObject] CMTimeRangeValue];
       CGFloat cacheTime=CMTimeGetSeconds(timerRange.start)+CMTimeGetSeconds(timerRange.duration);
//        NSLog(@"loading:%f",cacheTime);
        
    }else if ([keyPath isEqualToString:@"status"]){
        if (self.player.currentItem.status==AVPlayerItemStatusReadyToPlay) {
         CGFloat totalTime=CMTimeGetSeconds(self.player.currentItem.duration);
//         NSLog(@"total:%f",totalTime);
            [self.player play];
        }else if(self.player.currentItem.status==AVPlayerItemStatusFailed){
            NSLog(@"failed");
        }else {
            NSLog(@"unkown");
        }
    }
}

-(void)dealloc {
    [self.player.currentItem removeObserver:self forKeyPath:@"status"];
    [self.player.currentItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
    [self.player removeTimeObserver:self];
    
}

@end
