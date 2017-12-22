//
//  TTSManager.m
//  TTS_Demo
//
//  Created by guolinsong on 2017/11/8.
//  Copyright © 2017年 guolin song. All rights reserved.
//

#import "TTSManager.h"

#import <AVFoundation/AVFoundation.h>
@interface TTSManager ()<AVSpeechSynthesizerDelegate>


{
    // 合成器 控制播放，暂停
    AVSpeechSynthesizer *_synthesizer;

}
@end

@implementation TTSManager

+(instancetype)shareInstance
{
    static TTSManager * manager=nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager=[[TTSManager alloc] init];
    });
    return manager;
}
-(id)init
{
    if (self=[super init]) {
         _synthesizer = [[AVSpeechSynthesizer alloc] init];
        _synthesizer.delegate=self;
    }
    return self;
}

-(void)playText:(NSString *)text
{
    // 朗诵文本框中的内容
    // 实例化发声的对象，及朗读的内容
    //合成器的说话内容 可以控制说话的语速 等
    AVSpeechUtterance *utterance = [AVSpeechUtterance speechUtteranceWithString:text];
    utterance.voice = [AVSpeechSynthesisVoice voiceWithLanguage:@"zh_CN"];
    utterance.volume = 1.0; //音量 [0-1] Default = 1
    utterance.rate=0.5;// 设置语速，范围0-1，注意0最慢，1最快；AVSpeechUtteranceMinimumSpeechRate最慢，AVSpeechUtteranceMaximumSpeechRate最快
    
    utterance.pitchMultiplier = 1; //语调0.5 - 2] Default = 1
    [_synthesizer speakUtterance:utterance];
}

-(void)stop
{
    //停止说话
    [_synthesizer stopSpeakingAtBoundary:AVSpeechBoundaryWord];
}
-(void)pause
{
    [_synthesizer pauseSpeakingAtBoundary:AVSpeechBoundaryWord];//暂停
}
-(void)continuePlay
{
    [_synthesizer continueSpeaking];
}
#pragma mark AVSpeechSynthesizerDelegate
- (void)speechSynthesizer:(AVSpeechSynthesizer*)synthesizer didStartSpeechUtterance:(AVSpeechUtterance*)utterance{
    
    NSLog(@"---开始播放");
    
}
- (void)speechSynthesizer:(AVSpeechSynthesizer*)synthesizer didFinishSpeechUtterance:(AVSpeechUtterance*)utterance{
    
    NSLog(@"---完成播放");
    if (self.TTSCompeleteBlock) {
        self.TTSCompeleteBlock();
    }
    
}
- (void)speechSynthesizer:(AVSpeechSynthesizer*)synthesizer didPauseSpeechUtterance:(AVSpeechUtterance*)utterance{
    
    NSLog(@"---播放中止");
    
}
- (void)speechSynthesizer:(AVSpeechSynthesizer*)synthesizer didContinueSpeechUtterance:(AVSpeechUtterance*)utterance{
    
    NSLog(@"---恢复播放");
    
}
- (void)speechSynthesizer:(AVSpeechSynthesizer*)synthesizer didCancelSpeechUtterance:(AVSpeechUtterance*)utterance{
    
    NSLog(@"---播放取消");
    
}

@end
