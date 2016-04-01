//
//  CommonType.m
//  VedioDemo
//
//  Created by yuanyongguo on 16/4/1.
//  Copyright © 2016年 袁永国. All rights reserved.
//

#import <Foundation/Foundation.h>

//0、创建 1、可以播放（调用player播放） 2、播放中 3、暂停 4、缓存不足 5、播放结束 6、未知状态
typedef NS_ENUM(NSInteger, CAPlayerStatus) {
    StatusInitialize,
    StatusReadyToPlay,
    StatusInPlaying,
    StatusPlayPause,
    StatusBufferEmpty,
    StatusPalyEnd,
    StatusFailed,
    StatusUnknown
};