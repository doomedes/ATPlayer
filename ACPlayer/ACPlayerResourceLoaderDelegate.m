//
//  ACPlayerResourceLoaderDelegate.m
//  VedioDemo
//
//  Created by yuanyongguo on 16/3/7.
//  Copyright © 2016年 袁永国. All rights reserved.
//

#import "ACPlayerResourceLoaderDelegate.h"

@interface ACPlayerResourceLoaderDelegate ()

@property(strong,nonatomic) NSMutableArray * arraryRequest;

@end

@implementation ACPlayerResourceLoaderDelegate

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.arraryRequest=[NSMutableArray array];
    }
    return self;
}


#pragma  mark- AVAssetResourceLoaderDelegate

- (BOOL)resourceLoader:(AVAssetResourceLoader *)resourceLoader  shouldWaitForLoadingOfRequestedResource:(AVAssetResourceLoadingRequest *)loadingRequest{
     NSLog(@"%s",__func__);
     NSURL *resourceURL = [loadingRequest.request URL];
    if([resourceURL.scheme isEqualToString:@"streaming"]){
        [self.arraryRequest addObject:loadingRequest];
        
        return YES;
    }
    return NO;
}

- (void)resourceLoader:(AVAssetResourceLoader *)resourceLoader  didCancelLoadingRequest:(AVAssetResourceLoadingRequest *)loadingRequest{
      NSLog(@"%s",__func__);
    [self.arraryRequest removeObject:loadingRequest];
    
}


- (void) loadResource {
    for (AVAssetResourceLoadingRequest * loadingRequest in self.arraryRequest) {
        
//     loadingRequest.dataRequest 
        
        
    }
}



//- (BOOL)resourceLoader:(AVAssetResourceLoader *)resourceLoader shouldWaitForResponseToAuthenticationChallenge:(NSURLAuthenticationChallenge *)authenticationChallenge {
//    NSLog(@"%s",__func__);
//    return YES;
//}


//- (void)resourceLoader:(AVAssetResourceLoader *)resourceLoader didCancelAuthenticationChallenge:(NSURLAuthenticationChallenge *)authenticationChallenge {
//    NSLog(@"%s",__func__);
//}


- (void)dealloc {
    NSLog(@"dealloc");
}

@end
