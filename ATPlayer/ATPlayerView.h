//
//  ATPlayerView.h
//  VedioDemo
//
//  Created by 袁永国 on 16/3/5.
//  Copyright © 2016年 袁永国. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@protocol ATPlayerViewDelegate <NSObject>

-(void)playerStatusChange:(AVPlayerItemStatus) status;

-(void) bufferLoadedScale:(CGFloat) scale;

-(void) playerCurrentTime:(CGFloat) currentTime;

@end

@interface ATPlayerView : UIView

//0、未播放 1、可以播放 2、播放中 3、暂停 4、播放结束
@property (assign,nonatomic) int currentStatus;
//总时间
@property (assign,nonatomic) CGFloat totalSecond;
@property (assign,nonatomic) CGFloat currentSecond;
@property(weak,nonatomic) id<ATPlayerViewDelegate> delegate;


- (instancetype) initWithUrl:(NSURL *)url;

- (void) relplacePlayerItemWithUrl:(NSURL *)url;

- (void) setCurrentTime:(NSTimeInterval) timeInterval completionHandler:(void (^)(BOOL finished))completionHandler;

- (void)play;

- (void)pause;

@end
