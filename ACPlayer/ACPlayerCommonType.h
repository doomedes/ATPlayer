//
//  CommonType.m
//  VedioDemo
//
//  Created by yuanyongguo on 16/4/1.
//  Copyright © 2016年 袁永国. All rights reserved.
//

#import <Foundation/Foundation.h>

//player的状态
typedef NS_ENUM(NSInteger, CAPlayerStatus) {
    StatusNotInfo,        //未创建
    StatusInitialize,     //初始化成功
    StatusFailed,         //加载失败
    StatusUnknown,        //加载未知
    StatusLayerInit,      //avplayer的layer加载成功
    StatusReadyToPlay,    //可以播放（调用player播放）
    StatusInPlaying,      //播放中
    StatusPlayPause,      //暂停
    StatusBufferEmpty,    //缓存不足 (改状态多余，不要使用)
    StatusBufferNotEmpty, //缓存>播放时间
    StatusBufferEnough,   //缓存充足（缓存>=（播放时间＋cacheTime:自定义的缓存时间长））
    StatusPalyEnd         //播放结束

};



//CAStateButton的样式
typedef NS_ENUM(NSInteger, CAStateButtonStyle) {
    CAStatusButtonStyleStop,     //停止
    CAStatusButtonStylePlay,     //播放
    CAStatusButtonStyleNext,     //下一首
    CAStatusButtonStylePrevious  //上一首
};