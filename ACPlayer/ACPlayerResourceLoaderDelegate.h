//
//  ACPlayerResourceLoaderDelegate.h
//  VedioDemo
//
//  Created by yuanyongguo on 16/3/7.
//  Copyright © 2016年 袁永国. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface ACPlayerResourceLoaderDelegate : NSObject<AVAssetResourceLoaderDelegate>

@property(copy,nonatomic) NSString * savePath;

-(NSURL *) convertUrlToCustomUrl:(NSURL *) url ;
-(NSURL *) backCustomUrlToUrl:(NSURL *) customURL ;

@end
