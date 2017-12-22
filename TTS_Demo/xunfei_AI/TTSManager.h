//
//  TTSManager.h
//  TTS_Demo
//
//  Created by guolinsong on 2017/11/8.
//  Copyright © 2017年 guolin song. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TTSManager : NSObject
//已经说完
@property (nonatomic,copy) void (^TTSCompeleteBlock)(void);
+(instancetype)shareInstance;
-(void)playText:(NSString *)text;
-(void)stop;


@end
