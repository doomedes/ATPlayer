//
//  StateButton.m
//  VedioDemo
//
//  Created by 袁永国 on 16/4/1.
//  Copyright © 2016年 袁永国. All rights reserved.
//

#import "CAStateButton.h"

@interface CAStateButton ()

@property(strong,nonatomic) CAShapeLayer * stateShapeLayer;

@end

@implementation CAStateButton

#pragma mark- 相关属性

-(CAShapeLayer *)stateShapeLayer {
    if(!_stateShapeLayer)
    {
        _stateShapeLayer=[CAShapeLayer layer];
        [self.layer addSublayer:_stateShapeLayer];
    }
    return _stateShapeLayer;
}

-(UIBezierPath *)playingPath {
   
    CGSize size=self.frame.size;
    CGFloat padding=5;
    CGFloat rwidth=size.width/2;
    
    UIBezierPath *path=[[UIBezierPath alloc]init];
    [path moveToPoint:CGPointMake(padding, padding)];
    [path addLineToPoint:CGPointMake(padding, size.height-padding)];
    [path addLineToPoint:CGPointMake(rwidth-padding/2, size.height-padding)];
    [path addLineToPoint:CGPointMake(rwidth-padding/2,padding)];
    [path addLineToPoint:CGPointMake(padding, padding)];
    
    [path moveToPoint:CGPointMake(rwidth+padding/2, padding)];
    [path addLineToPoint:CGPointMake(rwidth+padding/2, size.height-padding)];
    [path addLineToPoint:CGPointMake(size.width-padding, size.height-padding)];
    [path addLineToPoint:CGPointMake(size.width-padding,padding)]; 
    [path closePath];
    return  path;
   
}

-(UIBezierPath *) stopPath {
    
    CGSize size=self.frame.size;
    CGFloat padding=5;
    UIBezierPath *path=[[UIBezierPath alloc]init];
    [path moveToPoint:CGPointMake(padding, padding)];
    [path addLineToPoint:CGPointMake(padding, size.height-padding)];
    [path addLineToPoint:CGPointMake(size.width-padding, size.height/2)];
    [path closePath];
    return path;
}

-(UIBezierPath *)nextPath {
    
    CGSize size=self.frame.size;
    CGFloat padding=5;
    CGFloat rate=0.7;

    UIBezierPath *path=[[UIBezierPath alloc]init];
    
    [path moveToPoint:CGPointMake(padding, padding)];
    [path addLineToPoint:CGPointMake(padding, size.height-padding)];
    [path addLineToPoint:CGPointMake(size.width*rate, size.height/2)];
    [path addLineToPoint:CGPointMake(padding, padding)];
    
    [path moveToPoint:CGPointMake(size.width*rate, padding)];
    [path addLineToPoint:CGPointMake(size.width*rate, size.height-padding)];
    [path addLineToPoint:CGPointMake(size.width-padding, size.height-padding)];
    [path addLineToPoint:CGPointMake(size.width-padding, padding)];
    [path closePath];
        
    return path;
}

-(UIBezierPath *)previousPath {
    
    CGSize size=self.frame.size;
    CGFloat padding=5;
    CGFloat rate=0.3;
    UIBezierPath *path=[[UIBezierPath alloc]init];

    [path moveToPoint:CGPointMake(padding, padding)];
    [path addLineToPoint:CGPointMake(padding, size.height-padding)];
    [path addLineToPoint:CGPointMake(size.width*rate, size.height-padding)];
    [path addLineToPoint:CGPointMake(size.width*rate, padding)];
    [path addLineToPoint:CGPointMake(padding, padding)];

    [path moveToPoint:CGPointMake(size.width*rate, size.height/2)];
    [path addLineToPoint:CGPointMake(size.width-padding, size.height-padding)];
    [path addLineToPoint:CGPointMake(size.width-padding, padding)];
    [path closePath];
    
    return path;
}

-(void)setStateButtonStyle:(CAStateButtonStyle)stateButtonStyle {
     _stateButtonStyle=stateButtonStyle;
    [self loadStateLayer];
}

-(void)setStateButtonColor:(UIColor *)stateButtonColor {
    _stateButtonColor=stateButtonColor;
    self.stateShapeLayer.fillColor=stateButtonColor.CGColor;
}



#pragma  mark- 相关事件

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self loadStateLayer];
    }
    return self;
}

-(void)layoutSubviews {
    [self loadStateLayer];
}


- (void) loadStateLayer {
      self.stateShapeLayer.fillColor=self.stateButtonColor.CGColor;
      self.stateShapeLayer.frame=self.bounds;
    switch (self.stateButtonStyle) {
        case CAStatusButtonStyleStop:
            self.stateShapeLayer.path=[self stopPath].CGPath;
            break;
        case CAStatusButtonStylePlay:
           self.stateShapeLayer.path=[self playingPath].CGPath;
            break;
        case CAStatusButtonStyleNext:
            self.stateShapeLayer.path=[self nextPath].CGPath;
            break;
        case CAStatusButtonStylePrevious:
             self.stateShapeLayer.path=[self previousPath].CGPath;
            break;
        default:
            break;
    }
   
}


@end
