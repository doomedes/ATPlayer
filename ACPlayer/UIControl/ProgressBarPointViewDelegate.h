//
//  ProgressBarPointViewDelegate.h
//  VedioDemo
//
//  Created by 袁永国 on 16/4/2.
//  Copyright © 2016年 袁永国. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ProgressBarPointViewDelegate <NSObject>

-(void) ProgressBarPointBeginMove ;

-(void) ProgressBarPointMoving:(CGFloat) newX ;

-(void) ProgressBarPointEndMove ;

-(void) ProgressBarPointCancelMove ;


@end
