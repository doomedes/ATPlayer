//
//  ACPlayerResourceConnection.m
//  VedioDemo
//
//  Created by yuanyongguo on 16/3/7.
//  Copyright © 2016年 袁永国. All rights reserved.
//

#import "ACPlayerResourceConnection.h"

@interface ACPlayerResourceConnection ()<NSURLConnectionDataDelegate>

@property(strong,nonatomic) NSURLConnection * connection;
@property(strong,nonatomic) NSFileHandle * fileHandle;
@property(copy,nonatomic) NSString * cachePath;
@property(copy,nonatomic) NSString * savePath;
@end


@implementation ACPlayerResourceConnection

- (void)startRequestWithUrl:(NSURL *) url startSize:(NSInteger) startSize cachePath:(NSString *) cachePath savePath:(NSString *) savePath {
    
    self.startSize=startSize;
    self.downSize=0;
    self.cachePath=cachePath;
    self.savePath=savePath;
    
//    NSString *dir=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject;
//    NSString *path=[dir stringByAppendingPathComponent:@"cache.mp4"];
    
    NSMutableURLRequest *request=[[NSMutableURLRequest alloc]initWithURL:url];
    request.cachePolicy=NSURLRequestReloadIgnoringCacheData;
    request.timeoutInterval=10;
    self.connection=[NSURLConnection connectionWithRequest:request delegate:self];
    [self.connection start];

}

#pragma mark -NSURLConnectionDataDelegate


- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {

    self.fileHandle=[NSFileHandle fileHandleForWritingAtPath:self.cachePath];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.fileHandle seekToEndOfFile];
    [self.fileHandle writeData:data];
    self.downSize+=data.length;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
    if(self.startSize==0){
       NSError *error;
       BOOL juge=[[NSFileManager defaultManager] copyItemAtPath:self.cachePath toPath:self.savePath error:&error];
       
        if(juge){
            
        }else{
            
        }
    }
    
    
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    
}

@end
