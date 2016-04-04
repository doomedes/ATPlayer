//
//  StateButton.h
//  VedioDemo
//
//  Created by 袁永国 on 16/4/1.
//  Copyright © 2016年 袁永国. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ACPlayerCommonType.h"

@interface CAStateButton : UIButton

@property(assign,nonatomic) CAStateButtonStyle stateButtonStyle;

@property(copy,nonatomic) UIColor * stateButtonColor;
 
@end
