//
//  ACPlayerResourceLoaderDelegate.m
//  VedioDemo
//
//  Created by yuanyongguo on 16/3/7.
//  Copyright © 2016年 袁永国. All rights reserved.
//

#import "ACPlayerResourceLoaderDelegate.h"
#import "ACPlayerResourceConnection.h"
#import <CoreFoundation/CoreFoundation.h>

#define  CustomeUrlSchme @"CustomeUrlSchme"


@interface ACPlayerResourceLoaderDelegate ()<ACPlayerResourceConnectionDelegate>

@property(strong,nonatomic) NSMutableArray * arraryLodingRequest;
@property(strong,nonatomic) ACPlayerResourceConnection *resourceConnection;
@property(copy,nonatomic) NSString * cachePath;

@end

@implementation ACPlayerResourceLoaderDelegate



- (instancetype)init {
    self = [super init];
    if (self) {
        self.arraryLodingRequest=[NSMutableArray array];
    }
    return self;
}

-(NSURL *) convertUrlToCustomUrl:(NSURL *) url {
    NSURLComponents *components=[[NSURLComponents alloc]initWithURL:url resolvingAgainstBaseURL:YES];
    components.scheme=CustomeUrlSchme;
    return [components URL];
}

-(NSURL *) backCustomUrlToUrl:(NSURL *) customURL {
    NSURLComponents *components=[[NSURLComponents alloc]initWithURL:customURL resolvingAgainstBaseURL:YES];
    components.scheme=@"http";
    return [components URL];
}


#pragma  mark- AVAssetResourceLoaderDelegate

- (BOOL)resourceLoader:(AVAssetResourceLoader *)resourceLoader  shouldWaitForLoadingOfRequestedResource:(AVAssetResourceLoadingRequest *)loadingRequest{

     NSURL *resourceURL = [loadingRequest.request URL];
    if([resourceURL.scheme isEqualToString:CustomeUrlSchme]){
        
       [self.arraryLodingRequest addObject:loadingRequest];
        NSURL *url=[self backCustomUrlToUrl:resourceURL];
        if(self.resourceConnection.downSize>0){
             [self loadingResource];
        }
        
        if(!self.resourceConnection){
            self.resourceConnection=[[ACPlayerResourceConnection alloc]init];
            self.resourceConnection.delegate=self;
            NSString *dir=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject;
            self.cachePath=[dir stringByAppendingPathComponent:@"cache.mp4"];
            self.savePath=[dir stringByAppendingPathComponent:@"save.mp4"];
            [self.resourceConnection startRequestWithUrl:url startSize:0 cachePath:self.cachePath savePath:self.savePath];
            
        }else if(loadingRequest.dataRequest.currentOffset>(self.resourceConnection.startSize+self.resourceConnection.downSize)||self.resourceConnection.startSize>loadingRequest.dataRequest.currentOffset){
            [self.resourceConnection startRequestWithUrl:url startSize:loadingRequest.dataRequest.currentOffset cachePath:self.cachePath savePath:self.savePath];
        }
     return YES;
        
    }
    return NO;
}

- (void)resourceLoader:(AVAssetResourceLoader *)resourceLoader  didCancelLoadingRequest:(AVAssetResourceLoadingRequest *)loadingRequest{

    [self.arraryLodingRequest removeObject:loadingRequest];
    
}

- (void) loadingResource {
    
    NSMutableArray *arraryLoadedRequest=[NSMutableArray array];
    for (AVAssetResourceLoadingRequest * loadingRequest in self.arraryLodingRequest) {
    
        [self fillRequestHeader:loadingRequest.contentInformationRequest];
        if([self respondDataWithRequest:loadingRequest.dataRequest]){
            [loadingRequest finishLoading];
            [arraryLoadedRequest addObject:loadingRequest];
        }
    }
    [self.arraryLodingRequest removeObjectsInArray:arraryLoadedRequest];
}

- (void)fillRequestHeader:(AVAssetResourceLoadingContentInformationRequest *)contentInformationRequest {
    contentInformationRequest.byteRangeAccessSupported = YES;
    contentInformationRequest.contentType = self.resourceConnection.contentType;
    contentInformationRequest.contentLength = self.resourceConnection.contentLength;
}

- (BOOL) respondDataWithRequest:(AVAssetResourceLoadingDataRequest *) request {

    NSInteger startSize=self.resourceConnection.startSize;
    NSInteger downSize= self.resourceConnection.downSize;
    NSInteger startOffset=request.currentOffset;
    NSInteger requestedLength= request.requestedLength;
   
    //loadingRequest的起始位置 < 下载请求Rang的起始位置
    if(startOffset<startSize){
        return  NO;
    }
    //loadingRequest的起始位置 > 下载请求的下载到的位置
    if(startOffset>(startSize+downSize)){
        return NO;
    }
    
    NSInteger minRequestLength=MIN(downSize+startSize, requestedLength+startOffset)-startOffset;
    NSData *data=[NSData dataWithContentsOfFile:self.cachePath];
    NSRange range=NSMakeRange(startOffset-startSize, minRequestLength);
    [request respondWithData:[data subdataWithRange:range]];
    
    //该请求需加载的数据完成
    if((startSize+downSize)>=(startOffset+requestedLength)){
        return YES;
    }
    return NO;
}

#pragma  mark -ACPlayerResourceConnectionDelegate

- (void) didReceiveData {
 [self loadingResource];
}

- (void)dealloc {
    NSLog(@"dealloc");
}

@end
