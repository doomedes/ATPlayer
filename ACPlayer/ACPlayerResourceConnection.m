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
    
        if([[NSFileManager defaultManager] fileExistsAtPath:self.cachePath]){
            [[NSFileManager defaultManager]removeItemAtPath:self.cachePath error:nil];
        }
        self.cachePath=cachePath;
        self.savePath=savePath;
  
    NSMutableURLRequest *request=[[NSMutableURLRequest alloc]initWithURL:url];
    request.cachePolicy=NSURLRequestReloadIgnoringCacheData;
    request.timeoutInterval=10;
    
    if(startSize!=0){
        NSString *rangeValue=[NSString stringWithFormat:@"Bytes=%ld-%ld",startSize,self.contentLength>0?self.contentLength:NSIntegerMax];
        [request addValue:rangeValue forHTTPHeaderField:@"Range"];
    }
    if(self.connection){
        [self.connection cancel];
    }
    self.connection=[NSURLConnection connectionWithRequest:request delegate:self];
    [self.connection start];

}

#pragma mark -NSURLConnectionDataDelegate


- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {

    NSHTTPURLResponse *httpResponse=(NSHTTPURLResponse *)response;
    self.mimeType=httpResponse.MIMEType;
   CFStringRef contentTypeRef= UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, (__bridge CFStringRef)self.mimeType, nil);
    
    NSDictionary *dic = (NSDictionary *)[httpResponse allHeaderFields] ;
    //注意contentType的获取方式 (MIMEType转换为UTI)
    self.contentType= CFBridgingRelease(contentTypeRef); //[httpResponse.allHeaderFields objectForKey:@"Content-Type"];
    
    NSString *content =[dic valueForKey:@"Content-Range"];
    NSArray *array = [content componentsSeparatedByString:@"/"];
    NSString *length = array.lastObject;
    NSUInteger videoLength;
    if ([length integerValue] == 0) {
        videoLength = (NSUInteger)httpResponse.expectedContentLength;
    } else {
        videoLength = [length integerValue];
    }
    self.contentLength=videoLength;
    
    if([[NSFileManager defaultManager] fileExistsAtPath:self.cachePath]){
        [[NSFileManager defaultManager] removeItemAtPath:self.cachePath error:nil];
    }

    [[NSFileManager defaultManager] createFileAtPath:self.cachePath contents:nil attributes:nil];
    self.fileHandle=[NSFileHandle fileHandleForWritingAtPath:self.cachePath];
    
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.fileHandle seekToEndOfFile];
    [self.fileHandle writeData:data];
    self.downSize+=data.length;
    if(self.delegate){
        if([self.delegate respondsToSelector:@selector(didReceiveData)]){
            [self.delegate didReceiveData];
        }
    }
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
