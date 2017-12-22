//
//  FloatView.h
//  TTS_Demo
//
//  Created by guolinsong on 2017/11/8.
//  Copyright © 2017年 guolin song. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "iflyMSC/IFlyMSC.h"



@interface FloatView : UIView<IFlyPcmRecorderDelegate>

@property (nonatomic ,assign) CGPoint startPoint;//触摸起始点

@property (nonatomic ,assign) CGPoint endPoint;//触摸结束点

@property (nonatomic ,copy) void (^AIBlock)(NSString * result);




//停止录音
-(void) stop;
-(void) showResult:(NSString *)result;
@end

