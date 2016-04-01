//
//  ATPlayerViewDelegate.h
//  VedioDemo
//
//  Created by yuanyongguo on 16/4/1.
//  Copyright © 2016年 袁永国. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "ACPlayerCommonType.h"

@protocol ACPlayerDelegate <NSObject>

//状态切换时
-(void)playerStatusChange:(CAPlayerStatus) status;

//更新播放时间
-(void)playerCurrentTime:(NSTimeInterval) currentTime;

//更新缓冲时间
-(void)playerloadedTime:(NSTimeInterval) loadedTime;


@end
