//
//  ACPlayer.h
//  VedioDemo
//
//  Created by yuanyongguo on 16/3/7.
//  Copyright © 2016年 袁永国. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "ACPlayerDelegate.h"
#import "ACPlayerCommonType.h"

@interface ACPlayer :UIView

@property(weak,nonatomic) id<ACPlayerDelegate> delegate;

@property (assign,nonatomic) CAPlayerStatus status;

@property(assign,nonatomic) NSTimeInterval currentTime;
@property(assign,nonatomic) NSTimeInterval loadedTime;

//如果点击了开始播放缓存不足时会暂停，状态达到可播放状态时自动播放，否则需要点击播放开始播放
@property (assign,nonatomic) bool isClickPlay;

- (instancetype)initWithUrl:(NSURL *)url;

@end
