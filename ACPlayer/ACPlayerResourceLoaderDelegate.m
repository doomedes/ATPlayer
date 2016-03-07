//
//  ACPlayerResourceLoaderDelegate.m
//  VedioDemo
//
//  Created by yuanyongguo on 16/3/7.
//  Copyright © 2016年 袁永国. All rights reserved.
//

#import "ACPlayerResourceLoaderDelegate.h"
#import "ACPlayerResourceConnection.h"

@interface ACPlayerResourceLoaderDelegate ()<ACPlayerResourceConnectionDelegate>

@property(strong,nonatomic) NSMutableArray * arraryLodingRequest;
@property(strong,nonatomic) ACPlayerResourceConnection *resourceConnection;
@property(copy,nonatomic) NSString * cachePath;
@property(copy,nonatomic) NSString * savePath;
@end

@implementation ACPlayerResourceLoaderDelegate

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.arraryLodingRequest=[NSMutableArray array];
    }
    return self;
}


#pragma  mark- AVAssetResourceLoaderDelegate

- (BOOL)resourceLoader:(AVAssetResourceLoader *)resourceLoader  shouldWaitForLoadingOfRequestedResource:(AVAssetResourceLoadingRequest *)loadingRequest{

     NSURL *resourceURL = [loadingRequest.request URL];
    if([resourceURL.scheme isEqualToString:@"streaming"]){
        
        [self.arraryLodingRequest addObject:loadingRequest];
        
        self.resourceConnection=[[ACPlayerResourceConnection alloc]init];
        self.resourceConnection.delegate=self;
        
        NSURLComponents *components=[[NSURLComponents alloc]initWithURL:resourceURL resolvingAgainstBaseURL:YES];
        components.scheme=@"http";
        NSString *dir=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject;
        self.cachePath=[dir stringByAppendingPathComponent:@"cache.mp4"];
        self.savePath=[dir stringByAppendingPathComponent:@"save.mp4"];
        
        [self.resourceConnection startRequestWithUrl:[components URL] startSize:loadingRequest.dataRequest.currentOffset cachePath:self.cachePath savePath:self.savePath];
        return YES;
    }
    return NO;
}

- (void)resourceLoader:(AVAssetResourceLoader *)resourceLoader  didCancelLoadingRequest:(AVAssetResourceLoadingRequest *)loadingRequest{
      NSLog(@"%s",__func__);
    [self.arraryLodingRequest removeObject:loadingRequest];
    
}


- (void) loadingResource {
    NSMutableArray *arraryLoadedRequest=[NSMutableArray array];

    for (AVAssetResourceLoadingRequest * loadingRequest in self.arraryLodingRequest) {

        [self fillInContentInformation:loadingRequest.contentInformationRequest];
        if([self respondDataWithRequest:loadingRequest.dataRequest]){
            [loadingRequest finishLoading];
            [arraryLoadedRequest addObject:loadingRequest];
        }
    }
    [self.arraryLodingRequest removeObjectsInArray:arraryLoadedRequest];
}

- (void)fillInContentInformation:(AVAssetResourceLoadingContentInformationRequest *)contentInformationRequest
{
    contentInformationRequest.byteRangeAccessSupported = YES;
    contentInformationRequest.contentType = self.resourceConnection.contentType;
    contentInformationRequest.contentLength = self.resourceConnection.contentLength;
}


- (BOOL) respondDataWithRequest:(AVAssetResourceLoadingDataRequest *) loadingDataRequest {
    long long startOffset=loadingDataRequest.currentOffset;
    if (loadingDataRequest.currentOffset != 0) {
        startOffset = loadingDataRequest.currentOffset;
    }
    //loadingRequest的起始位置 < 下载请求Rang的起始位置
    if(startOffset<self.resourceConnection.startSize){
        return  NO;
    }
    //loadingRequest的起始位置 > 下载请求的下载到的位置
    if(startOffset>(self.resourceConnection.startSize+self.resourceConnection.downSize)){
        return NO;
    }
    //loadingRequest.requestedOffset 开始一直为0
//    NSLog(@"%ld,%ld",loadingDataRequest.requestedLength,self.resourceConnection.downSize);
    long long contentLength=MIN((self.resourceConnection.downSize-self.resourceConnection.startSize), loadingDataRequest.requestedLength);
    
    NSData *data=[NSData dataWithContentsOfFile:self.cachePath];
    NSRange range=NSMakeRange(startOffset-self.resourceConnection.startSize, contentLength);
    [loadingDataRequest respondWithData:[data subdataWithRange:range]];
    if((startOffset+contentLength)>=self.resourceConnection.contentLength){
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
