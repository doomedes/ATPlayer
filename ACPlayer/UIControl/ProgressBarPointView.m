//
//  ProgressBarPointView.m
//  VedioDemo
//
//  Created by 袁永国 on 16/4/2.
//  Copyright © 2016年 袁永国. All rights reserved.
//

#import "ProgressBarPointView.h"

@implementation ProgressBarPointView
{
    CAShapeLayer *bottomLayer;
    CAShapeLayer *pointLayer;
    CGPoint startPoint;
    BOOL isTouch;
}

#pragma mark- 相关属性
-(void)setBottomColor:(UIColor *)bottomColor {
    _bottomColor=bottomColor;
    bottomLayer.fillColor=bottomColor.CGColor;
}

-(void)setPointColor:(UIColor *)pointColor {
    _pointColor=pointColor;
    pointLayer.fillColor=pointColor.CGColor;
}

-(void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    [self loadLayers];
}

#pragma  mark- 相关事件

- (instancetype)init
{
    self = [self initWithFrame:CGRectZero];
    if (self) {
     
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self layersInit];
        [self loadLayers];
    }
    return self;
}


-(void) layersInit {
    bottomLayer =[[CAShapeLayer alloc]init];
    pointLayer =[[CAShapeLayer alloc]init];
    [self.layer addSublayer:bottomLayer];
    [self.layer addSublayer:pointLayer];
}

-(void)layoutSubviews{
    [self loadLayers];
}

-(void) loadLayers {

    CGSize size=self.frame.size;
    CGFloat radius=0;
    if(size.width<size.height)
    {
        radius=size.width/2;
    }else{
        radius=size.height/2;
    }
    bottomLayer.frame=self.bounds;
    UIBezierPath *path=[UIBezierPath bezierPathWithArcCenter:CGPointMake(size.width/2, size.height/2) radius:radius startAngle:0 endAngle:2*M_PI clockwise:YES];
    bottomLayer.path=path.CGPath;
    bottomLayer.fillColor=self.bottomColor.CGColor;
    
    pointLayer.frame=self.bounds;
    UIBezierPath *path1=[UIBezierPath bezierPathWithArcCenter:CGPointMake(size.width/2, size.height/2) radius:radius/2 startAngle:0 endAngle:2*M_PI clockwise:YES];
    pointLayer.path=path1.CGPath;
    pointLayer.fillColor=self.pointColor.CGColor;
    pointLayer.hidden=YES;
    
    [bottomLayer setNeedsLayout];
    [pointLayer setNeedsLayout];
    
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if(self.enableDrag){
        pointLayer.hidden=NO;
        UITouch *touch=[touches anyObject];
        CGPoint point=[touch locationInView:self.superview];
        startPoint=point;
        isTouch=YES;
        
        if(self.delegate&&[self.delegate respondsToSelector:@selector(ProgressBarPointBeginMove)]){
            [self.delegate ProgressBarPointBeginMove];
        }
    }
}

-(void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if(self.enableDrag){

        if(isTouch){
            // 直接设置frame的方式
            /*
             UITouch *touch=[touches anyObject];
             CGPoint point=[touch locationInView:self.superview];
             if((self.center.x+point.x-startPoint.x)>=self.horizontalPadding && (self.center.x+point.x-startPoint.x)<=(self.superview.bounds.size.width-self.horizontalPadding)) {
             self.center=CGPointMake(self.center.x+point.x-startPoint.x, self.center.y);
             startPoint=point;
             }
             if(self.delegate&&[self.delegate respondsToSelector:@selector(ProgressBarPointMoving)]){
             [self.delegate ProgressBarPointMoving];
             }
             
             */
            
            //使用autolayout的方式
            UITouch *touch=[touches anyObject];
            CGPoint point=[touch locationInView:self.superview];
            CGFloat newX=self.center.x+point.x-startPoint.x;
            if(newX>=self.horizontalPadding && newX<=(self.superview.bounds.size.width-self.horizontalPadding)) {
                startPoint=point;
                if(self.delegate&&[self.delegate respondsToSelector:@selector(ProgressBarPointMoving:)]){
                    [self.delegate ProgressBarPointMoving:newX];
                }
            }
        }
    }
    
}

-(void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if(self.enableDrag){
        isTouch=NO;
        pointLayer.hidden=YES;
        if(self.delegate&&[self.delegate respondsToSelector:@selector(ProgressBarPointCancelMove)]){
            [self.delegate ProgressBarPointCancelMove];
        }
    }
}

-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if(self.enableDrag){
        isTouch=NO;
        pointLayer.hidden=YES;
        if(self.delegate&&[self.delegate respondsToSelector:@selector(ProgressBarPointEndMove)]){
            [self.delegate ProgressBarPointEndMove];
        }
    }
}

@end
