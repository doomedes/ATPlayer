//
//  ACPlayerResourceConnection.h
//  VedioDemo
//
//  Created by yuanyongguo on 16/3/7.
//  Copyright © 2016年 袁永国. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MobileCoreServices/MobileCoreServices.h>

@protocol ACPlayerResourceConnectionDelegate <NSObject>

- (void) didReceiveData;

@end

@interface ACPlayerResourceConnection : NSObject

@property (assign,nonatomic) NSInteger startSize;
@property (assign,nonatomic) NSInteger downSize;
@property(assign,nonatomic) NSInteger contentLength;
@property(copy,nonatomic) NSString * contentType;
@property (copy,nonatomic) NSString *mimeType;
@property (weak,nonatomic) id<ACPlayerResourceConnectionDelegate> delegate;

- (void)startRequestWithUrl:(NSURL *) url startSize:(NSInteger) startSize cachePath:(NSString *) cachePath savePath:(NSString *) savePath ;

@end
