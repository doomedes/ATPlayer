//
//  ProgressBarView.m
//  VedioDemo
//
//  Created by 袁永国 on 16/4/1.
//  Copyright © 2016年 袁永国. All rights reserved.
//

#import "ProgressBarView.h"
#import "ProgressBarPointView.h"


/*
 注意：
 有时候圆点点击无效，
 因为horizontalPadding设置的值小于pointViewRadius时圆点，圆点视图可能超出当前滚动条了，所以点击事件无效
 */

@interface ProgressBarView ()<ProgressBarPointViewDelegate>

@property(strong,nonatomic) UIView *backgroundView;
@property(strong,nonatomic) UIView *bufferView;
@property(strong,nonatomic) UIView *playingView;
@property(strong,nonatomic) ProgressBarPointView *pointView;


@property(strong,nonatomic)  NSLayoutConstraint *heigthConstraint_Background;
@property(strong,nonatomic)  NSLayoutConstraint *leftConstraint_Background;
@property(strong,nonatomic)  NSLayoutConstraint *rightConstraint_Background;

@property(strong,nonatomic)  NSLayoutConstraint *heigthConstraint_Buffer;

@property(strong,nonatomic)  NSLayoutConstraint *heigthConstraint_Playing;

@property(strong,nonatomic)  NSLayoutConstraint *heigthConstraint_Point;
@property(strong,nonatomic)  NSLayoutConstraint *widthConstraint_Point;

@end

@implementation ProgressBarView
{
    NSLayoutConstraint *widthConstraint_Buffer;
    NSLayoutConstraint *widthConstraint_Playing;
    NSLayoutConstraint *leftConstraint_Point;
    //是否处于拖拽中
    BOOL isDrag;
}




#pragma mark-相关属性


//backgroundView相关
-(UIView *)backgroundView {
    if(!_backgroundView){
        _backgroundView=[[UIView alloc]init];
        [self addSubview:_backgroundView];
        _backgroundView.translatesAutoresizingMaskIntoConstraints=NO;
      
        NSLayoutConstraint *centerYLayout=[NSLayoutConstraint  constraintWithItem:_backgroundView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1 constant:0];
     
        [self addConstraints:@[self.leftConstraint_Background,self.rightConstraint_Background,centerYLayout]];
        [_backgroundView addConstraint:self.heigthConstraint_Background];
    }
    return _backgroundView;
}

-(NSLayoutConstraint *)heigthConstraint_Background {
    if(!_heigthConstraint_Background){
        _heigthConstraint_Background=[NSLayoutConstraint constraintWithItem:self.backgroundView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1 constant:self.thickWithd];
        
    }
    return _heigthConstraint_Background;
}

-(NSLayoutConstraint *)leftConstraint_Background {
    if(!_leftConstraint_Background){
        _leftConstraint_Background=[NSLayoutConstraint constraintWithItem:self.backgroundView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeading multiplier:1 constant:-self.horizontalPadding];
    }
    return _leftConstraint_Background;
}

-(NSLayoutConstraint *)rightConstraint_Background {
    if(!_rightConstraint_Background){
        _rightConstraint_Background=[NSLayoutConstraint constraintWithItem:self.backgroundView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTrailing multiplier:1 constant:self.horizontalPadding];
    }
    return _rightConstraint_Background;
}

//bufferView相关
-(UIView *)bufferView {
    if(!_bufferView){
        _bufferView=[[UIView alloc]init];
        [self addSubview:_bufferView];
        _bufferView.translatesAutoresizingMaskIntoConstraints=NO;
        NSLayoutConstraint *centerYLayout=[NSLayoutConstraint  constraintWithItem:_bufferView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.backgroundView attribute:NSLayoutAttributeCenterY multiplier:1 constant:0];
        
      NSLayoutConstraint*  leftConstraint_Buffer=[NSLayoutConstraint constraintWithItem:self.bufferView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.backgroundView attribute:NSLayoutAttributeLeading multiplier:1 constant:0];
        
       NSLayoutConstraint *  widthLayout=[NSLayoutConstraint constraintWithItem:_bufferView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.backgroundView attribute:NSLayoutAttributeWidth multiplier:self.bufferScale constant:0];
        widthLayout.priority=UILayoutPriorityDefaultLow;
        
        [self addConstraints:@[leftConstraint_Buffer,self.heigthConstraint_Buffer,centerYLayout]];
        [_bufferView addConstraint:widthLayout];

    }
    return _bufferView;
}

-(NSLayoutConstraint *)heigthConstraint_Buffer {
    if(!_heigthConstraint_Buffer){
        _heigthConstraint_Buffer=[NSLayoutConstraint constraintWithItem:self.bufferView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1 constant:self.thickWithd];
        
    }
    return _heigthConstraint_Buffer;
}

//playingView相关
-(UIView *)playingView {
    if(!_playingView){ 
        _playingView=[[UIView alloc]init];
        [self addSubview:_playingView];
        
        _playingView.translatesAutoresizingMaskIntoConstraints=NO;
        NSLayoutConstraint *centerYLayout=[NSLayoutConstraint  constraintWithItem:_playingView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1 constant:0];
        NSLayoutConstraint* leftConstraint_Playing=[NSLayoutConstraint constraintWithItem:self.playingView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.backgroundView attribute:NSLayoutAttributeLeading multiplier:1 constant:0];
        
          NSLayoutConstraint *  widthLayout=[NSLayoutConstraint constraintWithItem:_playingView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.backgroundView attribute:NSLayoutAttributeWidth multiplier:self.playingScale constant:0];
          widthLayout.priority=UILayoutPriorityDefaultLow;

        [self addConstraints:@[leftConstraint_Playing,widthLayout,centerYLayout]];
        [_playingView addConstraint:self.heigthConstraint_Playing];
    }
    return _playingView;
}

-(NSLayoutConstraint *)heigthConstraint_Playing {
    if(!_heigthConstraint_Playing){
        _heigthConstraint_Playing=[NSLayoutConstraint constraintWithItem:self.playingView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1 constant:self.thickWithd];
        
    }
    return _heigthConstraint_Playing;
}

//pointView相关
-(ProgressBarPointView *)pointView {
    if(!_pointView){
        _pointView=[[ProgressBarPointView alloc]init];
        _pointView.delegate=self;
        [self addSubview:_pointView];
        _pointView.translatesAutoresizingMaskIntoConstraints=NO;
        NSLayoutConstraint *centerYLayout=[NSLayoutConstraint  constraintWithItem:_pointView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1 constant:0];
        
        NSLayoutConstraint *  leftLayout=[NSLayoutConstraint constraintWithItem:_pointView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.playingView attribute:NSLayoutAttributeTrailing multiplier:1 constant:0];
        leftLayout.priority=UILayoutPriorityDefaultLow;
        [self addConstraints:@[leftLayout,centerYLayout]];
        [self addConstraints:@[self.heigthConstraint_Point,self.widthConstraint_Point]];
    }
    return _pointView;
}

-(NSLayoutConstraint *)heigthConstraint_Point {
    if(!_heigthConstraint_Point){
        _heigthConstraint_Point=[NSLayoutConstraint constraintWithItem:self.pointView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1 constant:self.pointViewRadius*2];
        
    }
    return _heigthConstraint_Point;
}

-(NSLayoutConstraint *)widthConstraint_Point {
    if(!_widthConstraint_Point){
        _widthConstraint_Point=[NSLayoutConstraint constraintWithItem:self.pointView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeWidth multiplier:1 constant:self.pointViewRadius*2];
    }
    return _widthConstraint_Point;
}


/*宽度*/

-(CGFloat)thickWithd {
    if(_thickWithd<=0){
        return 2;
    }
    return _thickWithd;
}

-(void)setThickRadius:(CGFloat)thickRadius {
    _thickRadius=thickRadius;
    [self loadProgressViewRadius];
}

/*设置颜色*/

-(void)setBackgroundViewColor:(UIColor *)backgroundViewColor {
    _backgroundViewColor=backgroundViewColor;
    self.backgroundView.backgroundColor=backgroundViewColor;
}

-(void)setBufferViewColor:(UIColor *)bufferViewColor {
    _bufferViewColor=bufferViewColor;
    self.bufferView.backgroundColor=bufferViewColor;
}

-(void)setPlayingViewColor:(UIColor *)playingViewColor{
    _playingViewColor=playingViewColor;
    self.playingView.backgroundColor=playingViewColor;
    self.pointView.bottomColor=playingViewColor;
}

-(void)setProgressBarPointColor:(UIColor *)progressBarPointColor{
    _progressBarPointColor=progressBarPointColor;
    self.pointView.backgroundColor=progressBarPointColor;
    self.pointView.pointColor=progressBarPointColor;
}


/*更新进度*/

-(void)setBufferScale:(CGFloat)bufferScale {
    _bufferScale=bufferScale;
    
    if(widthConstraint_Buffer&&[[self constraints] containsObject:widthConstraint_Buffer]){
        [self removeConstraint:widthConstraint_Buffer];
    }
     widthConstraint_Buffer= [NSLayoutConstraint constraintWithItem:self.bufferView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.backgroundView attribute:NSLayoutAttributeWidth multiplier:self.bufferScale constant:0];
     widthConstraint_Buffer.priority=UILayoutPriorityDefaultHigh;
    [self addConstraint:widthConstraint_Buffer];
}

-(void)setPlayingScale:(CGFloat)playingScale {
    if(!isDrag){
        _playingScale=playingScale;
        
        if(widthConstraint_Playing&&[[self constraints] containsObject:widthConstraint_Playing]){
            [self removeConstraint:widthConstraint_Playing];
        }
        widthConstraint_Playing= [NSLayoutConstraint constraintWithItem:self.playingView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.backgroundView attribute:NSLayoutAttributeWidth multiplier:playingScale constant:0];
        widthConstraint_Playing.priority=UILayoutPriorityDefaultHigh;
        [self addConstraint:widthConstraint_Playing];
    }
 
}

//更新进度条
- (void) updateProgressWithNewScale:(CGFloat) newScale {
    if(widthConstraint_Playing&&[[self constraints] containsObject:widthConstraint_Playing]){
        [self removeConstraint:widthConstraint_Playing];
    }
    widthConstraint_Playing= [NSLayoutConstraint constraintWithItem:self.playingView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.backgroundView attribute:NSLayoutAttributeWidth multiplier:newScale constant:0];
    widthConstraint_Playing.priority=UILayoutPriorityDefaultHigh;
    [self addConstraint:widthConstraint_Playing];
    
}
 
-(void)setHorizontalPadding:(CGFloat)horizontalPadding {
    if(horizontalPadding<0){
        _horizontalPadding=0;
    }else{
        _horizontalPadding=horizontalPadding;
    }
    self.leftConstraint_Background.constant=horizontalPadding;
    self.rightConstraint_Background.constant=-horizontalPadding;
    self.pointView.horizontalPadding=horizontalPadding;

}

-(void)setPointViewRadius:(CGFloat)pointViewRadius {
    if(pointViewRadius<=0){
        _pointViewRadius=5;
    }else{
        _pointViewRadius=pointViewRadius;
    }
    self.heigthConstraint_Point.constant=2*self.pointViewRadius;
    self.widthConstraint_Point.constant=2*self.pointViewRadius;
}

-(void)setEnableDrag:(BOOL)enableDrag {
    _enableDrag=enableDrag;
    self.pointView.enableDrag=enableDrag;
}

#pragma  mark-相关事件

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _pointViewRadius=5;
        _horizontalPadding=5;
        [self loadProgressSubViews];
    }
    return self;
}

- (instancetype)init {
    self = [self initWithFrame:CGRectZero];
    if (self) {
    }
    return self;
}

//设置进度条相关的视图
- (void) loadProgressSubViews {
    if(![self.subviews containsObject:self.backgroundView]){
        [self addSubview:self.backgroundView];
    }
    if(![self.subviews containsObject:self.bufferView]){
        [self addSubview:self.bufferView];
    }
    if(![self.subviews containsObject:self.playingView]){
        [self addSubview:self.playingView];
    }
    if(![self.subviews containsObject:self.pointView]){
        [self addSubview:self.pointView];
    }
    self.pointView.horizontalPadding=self.horizontalPadding;
    [self loadProgressViewRadius];
}

//设置进度条相关视图Layer的cornerRadius
- (void) loadProgressViewRadius {
     self.backgroundView.layer.cornerRadius=_thickRadius;
     self.bufferView.layer.cornerRadius=_thickRadius;
     self.playingView.layer.cornerRadius=_thickRadius;
}

//更新进度条与进度条上面的圆点 (暂不使用，使用autolayout的方式)
- (void) updateProgressBarAndPoint {
    if(!isDrag){
        CGFloat width=(self.bounds.size.width-_horizontalPadding*2)*_playingScale;
        CGRect  newFrame=CGRectMake(self.playingView.frame.origin.x, self.playingView.frame.origin.y, width, self.thickWithd);
        CGPoint newCenter=CGPointMake(newFrame.origin.x+width, self.pointView.center.y);
        self.playingView.frame=newFrame;
        self.pointView.center=newCenter;
    }
}


#pragma  mark- ProgressBarPointViewDelegate

-(void) ProgressBarPointBeginMove {
    isDrag=YES;
    if(self.delegate&&[self.delegate respondsToSelector:@selector(ProgressBarBeginMove)]){
        [self.delegate ProgressBarBeginMove];
    }
}

-(void) ProgressBarPointMoving:(CGFloat) newX {
    /*
     CGFloat width=self.bounds.size.width-_horizontalPadding*2;
     CGFloat disX=self.pointView.center.x-_horizontalPadding;
     //计算设置的播放进度同时更新进度条
     CGFloat newScale=disX/width;
     [self updateProgressWithNewScale:newScale];
     }
   */
    
    CGFloat width=self.backgroundView.bounds.size.width;
    CGFloat disX=newX-_horizontalPadding;
    //计算设置的播放进度同时更新进度条
    CGFloat newScale=disX/width;
    [self updateProgressWithNewScale:newScale];
    
    if(self.delegate&&[self.delegate respondsToSelector:@selector(ProgressBarMoving)]){
        [self.delegate ProgressBarMoving];
    }

}

-(void) ProgressBarPointEndMove {
    CGFloat width=self.bounds.size.width-_horizontalPadding*2;
    CGFloat disX=self.pointView.center.x-_horizontalPadding;
    //计算设置的播放进度的最终值
    CGFloat newScale=disX/width;
    //更新播放进度
    if(self.delegate&&[self.delegate respondsToSelector:@selector(ProgressBarEndMove:)]){
        [self.delegate ProgressBarEndMove:newScale];
    }
    isDrag=NO;
}

-(void) ProgressBarPointCancelMove {
    isDrag=NO;
//    [self updateProgressBarAndPoint];
    [self setPlayingScale:self.playingScale];
    if(self.delegate&&[self.delegate respondsToSelector:@selector(ProgressBarCancelMove)]){
        [self.delegate ProgressBarCancelMove];
    }
}


@end
