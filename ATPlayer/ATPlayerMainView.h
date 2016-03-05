//
//  ATPlayerMainView.h
//  VedioDemo
//
//  Created by 袁永国 on 16/3/5.
//  Copyright © 2016年 袁永国. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ATPlayerMainView : UIView

- (instancetype) initWithUrl:(NSURL *)url;

- (void) relplacePlayerItemWithUrl:(NSURL *)url;

@end
