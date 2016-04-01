//
//  MyVedioImageViewController.m
//  VedioDemo
//
//  Created by 袁永国 on 16/3/6.
//  Copyright © 2016年 袁永国. All rights reserved.
//

#import "MyVedioImageViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface MyVedioImageViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation MyVedioImageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    //获取视频指定帧的图片
    
   NSURL* url=[NSURL URLWithString:@"http://v.jxvdy.com/sendfile/w5bgP3A8JgiQQo5l0hvoNGE2H16WbN09X-ONHPq3P3C1BISgf7C-qVs6_c8oaw3zKScO78I--b0BGFBRxlpw13sf2e54QA"];
    
    
    /*
     AVURLAssetPreferPreciseDurationAndTimingKey表示AVURLAsset是否提供一个精确的duration。
     AVURLAssetPreferPreciseDurationAndTimingKeydictionary
     */
    NSDictionary *dic=[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:AVURLAssetPreferPreciseDurationAndTimingKey];
    AVURLAsset *set=[[AVURLAsset alloc]initWithURL:url options:dic];
    
    AVAssetImageGenerator *imageGenerator=[[AVAssetImageGenerator alloc]initWithAsset:set];
    imageGenerator.appliesPreferredTrackTransform=YES;
    imageGenerator.apertureMode = AVAssetImageGeneratorApertureModeEncodedPixels;
    CMTime atTime=CMTimeMake(6000, 60);
    /*
     AVAssetImageGenerator同步方法
     - (nullable CGImageRef)copyCGImageAtTime:(CMTime)requestedTime actualTime:(nullable CMTime *)actualTime error:(NSError * __nullable * __nullable)outError
     获取指定帧的图片设置时间太长则会获取不到（估计是超时了）
     */
    
//    CMTime actualTime;
//    NSError *eror;
//    CGImageRef imageRef=[imageGenerator copyCGImageAtTime:atTime actualTime:&actualTime error:&eror];
//    NSLog(@"%@,%@",imageRef,eror);
//    self.image.image=[UIImage imageWithCGImage:imageRef];
    
    /*
     AVAssetImageGenerator异步方法
     - (void)generateCGImagesAsynchronouslyForTimes:(NSArray<NSValue *> *)requestedTimes completionHandler:(AVAssetImageGeneratorCompletionHandler)handler;
       该方法则可以获取到指定的时间帧对应的图片
     */
    
    __weak typeof (self) weakSelf=self;
    [imageGenerator generateCGImagesAsynchronouslyForTimes:[NSArray arrayWithObject:[NSValue valueWithCMTime:atTime]] completionHandler:^(CMTime requestedTime, CGImageRef  _Nullable image, CMTime actualTime, AVAssetImageGeneratorResult result, NSError * _Nullable error) {
        
        if(result==AVAssetImageGeneratorSucceeded){
            NSLog(@"%@",[NSThread currentThread]);
            UIImage *ftpImage=[[UIImage alloc]initWithCGImage:image];//此处创建UIImage：因为在主线程中使用image会异常
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.imageView.image=ftpImage;
            });
            
        }else{
            NSLog(@"error:%@",error);
        }
    }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
