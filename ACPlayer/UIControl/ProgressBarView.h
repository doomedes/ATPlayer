//
//  ProgressBarView.h
//  VedioDemo
//
//  Created by 袁永国 on 16/4/1.
//  Copyright © 2016年 袁永国. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProgressBarPointViewDelegate.h"
#import "ProgressBarViewDelegate.h"

@interface ProgressBarView : UIView

//进度条的粗细
@property(assign,nonatomic) CGFloat thickWithd;
//进度条圆角设置
@property(assign,nonatomic) CGFloat thickRadius;
//缓存的比例
@property (assign,nonatomic) CGFloat bufferScale;
//播放的比例
@property (assign,nonatomic) CGFloat playingScale;
//水平方向的padding
@property (assign,nonatomic) CGFloat horizontalPadding;
//圆点的半径
@property (assign,nonatomic) CGFloat pointViewRadius;

@property(copy,nonatomic) UIColor *backgroundViewColor;
@property(copy,nonatomic) UIColor *bufferViewColor;
@property(copy,nonatomic) UIColor *playingViewColor;
@property(copy,nonatomic) UIColor *progressBarPointColor;
 @property(assign,nonatomic) BOOL enableDrag;

@property(weak,nonatomic) id<ProgressBarViewDelegate> delegate;

@end
