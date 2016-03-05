//
//  ViewController.m
//  VedioDemo
//
//  Created by 袁永国 on 16/3/5.
//  Copyright © 2016年 袁永国. All rights reserved.
//

/*
 AVAudioPalyer实现播放音乐
 */

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface ViewController ()<AVAudioPlayerDelegate>

@property (weak, nonatomic) IBOutlet UISlider *mySlider;
@property (strong,nonatomic) AVAudioPlayer *player;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSURL *url=[[NSBundle mainBundle] URLForResource:@"ghsy" withExtension:@"mp3"];
    self.player=[[AVAudioPlayer alloc]initWithContentsOfURL:url error:nil];
    self.player.volume=self.mySlider.value;
    self.player.delegate=self;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)play:(id)sender {
    if(self.player){
        [self.player play];
    }
}

- (IBAction)stop:(id)sender {
    if(self.player){
        [self.player stop];
    }
}

- (IBAction)changeValue:(id)sender {
    self.player.volume=self.mySlider.value;
}


#pragma mark- AVAudioPlayerDelegate
- (void)audioPlayerBeginInterruption:(AVAudioPlayer *)player {
    [self.player stop];
}

- (void)audioPlayerEndInterruption:(AVAudioPlayer *)player withOptions:(NSUInteger)flags {
    [self.player play];
}
@end
