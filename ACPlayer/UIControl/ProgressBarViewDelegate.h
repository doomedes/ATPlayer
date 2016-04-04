//
//  ProgressBarViewDelegate.h
//  VedioDemo
//
//  Created by 袁永国 on 16/4/3.
//  Copyright © 2016年 袁永国. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ProgressBarViewDelegate <NSObject>


-(void) ProgressBarBeginMove ;

-(void) ProgressBarMoving ;

-(void) ProgressBarEndMove:(CGFloat)  scale;

-(void) ProgressBarCancelMove ;



@end
