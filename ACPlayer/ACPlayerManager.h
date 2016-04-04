//
//  ACPlayerManager.h
//  VedioDemo
//
//  Created by 袁永国 on 16/4/4.
//  Copyright © 2016年 袁永国. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ACPlayerManager : UIView

@property(assign,nonatomic) BOOL isAutoPlay;

- (instancetype) initWithUrl:(NSURL *)url;

- (void) relplacePlayerItemWithUrl:(NSURL *)url;

@end
