//
//  ProgressBarPointView.h
//  VedioDemo
//
//  Created by 袁永国 on 16/4/2.
//  Copyright © 2016年 袁永国. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProgressBarPointViewDelegate.h"

@interface ProgressBarPointView : UIView

@property(weak,nonatomic) id<ProgressBarPointViewDelegate> delegate;

@property(assign,nonatomic) CGFloat horizontalPadding;

@property(assign,nonatomic) BOOL enableDrag;
@property(copy,nonatomic) UIColor *bottomColor;
@property(copy,nonatomic) UIColor *pointColor;


@end
