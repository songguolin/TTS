//
//  FloatView.m
//  TTS_Demo
//
//  Created by guolinsong on 2017/11/8.
//  Copyright © 2017年 guolin song. All rights reserved.
//

#import "FloatView.h"


#import "TTSManager.h"
#import <QuartzCore/QuartzCore.h>
#import "IFlyMSC/IFlyMSC.h"
#import "Definition.h"
#import "IATConfig.h"


#include "iflymsc/AIUI.h"
#include "iflymsc/AIUIConstant.h"
#include "AiuiService.h"

//主题颜色

#define MAINCOLOER [UIColor colorWithRed:100/255.0 green:100/255.0 blue:100/255.0 alpha:1]

#define kDownLoadWidth 60

#define kOffSet kDownLoadWidth / 2


class TestListener;


@interface FloatView ()<UIDynamicAnimatorDelegate>



//speech understanding control
@property (nonatomic,strong) IFlySpeechUnderstander *iFlySpeechUnderstander;
//text understanding control
@property (nonatomic,strong) IFlyTextUnderstander *iFlyUnderStand;

@property (nonatomic,strong)IFlyPcmRecorder *m_recorder;


//结果
@property (nonatomic,strong) NSString *result;

//正在录音
@property (nonatomic) BOOL isRecord;
//正在说话
@property (nonatomic) BOOL isSpeech;

//完成理解
@property (nonatomic) BOOL isUnderstandered;
//完成解析
@property (nonatomic) BOOL isAnalyticed;


//-----view--------
@property (nonatomic , strong ) UIView *backgroundView;//背景视图

@property (nonatomic , strong ) UIImageView *imageView;//图片视图

@property (nonatomic , strong ) UIDynamicAnimator *animator;//物理仿真动画



//提示
@property (nonatomic, strong) UILabel * hintLabel;
@end

@implementation FloatView

//aiui listener
extern TestListener m_listener;


-(id)init
{
    if (self=[super init]) {
        
    }
    return self;
}

//初始化
-(instancetype)initWithFrame:(CGRect)frame{
    
    frame.size.width = kDownLoadWidth;
    
    frame.size.height = kDownLoadWidth;
    
    if (self = [super initWithFrame:frame]) {
        
        [self initView];
        
    }
    
    return self;
    
}
-(void)initView
{
    
    
    //初始化背景视图
    
    _backgroundView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))];
    
    _backgroundView.layer.cornerRadius = _backgroundView.frame.size.width / 2;
    
    _backgroundView.clipsToBounds = YES;
    
    _backgroundView.backgroundColor = [MAINCOLOER colorWithAlphaComponent:0.7];
    
    
    [self addSubview:_backgroundView];
    
    //初始化图片背景视图
    
    UIView * imageBackgroundView = [[UIView alloc]initWithFrame:CGRectMake(5, 5, CGRectGetWidth(self.frame) - 10, CGRectGetHeight(self.frame) - 10)];
    
    imageBackgroundView.layer.cornerRadius = imageBackgroundView.frame.size.width / 2;
    
    imageBackgroundView.clipsToBounds = YES;
    
    imageBackgroundView.backgroundColor = [MAINCOLOER colorWithAlphaComponent:0.8f];
    
    
    
    [self addSubview:imageBackgroundView];
    
    
    
    //初始化图片
    //
    //        _imageView = [[UIImageView alloc]initWithImage:[[UIImage imageNamed:@"yiwa"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
    
    _imageView = [[UIImageView alloc]init];
    
    _imageView.image=[UIImage imageNamed:@"yiwa"];
    
    _imageView.tintColor = [UIColor whiteColor];
    
    _imageView.frame = CGRectMake(0, 0, 50, 50);
    
    _imageView.center = CGPointMake(kDownLoadWidth / 2 , kDownLoadWidth / 2);
    _imageView.layer.cornerRadius=50 / 2;
    _imageView.layer.masksToBounds=YES;
    
    [self addSubview:_imageView];
    
    self.hintLabel=[[UILabel alloc] initWithFrame:CGRectMake(0, -20, kDownLoadWidth, 20)];
    self.hintLabel.backgroundColor=[UIColor blackColor];
    self.hintLabel.layer.cornerRadius=3;
    self.hintLabel.layer.masksToBounds=YES;
    self.hintLabel.font=[UIFont systemFontOfSize:14];
    self.hintLabel.textColor=[UIColor whiteColor];
    
    self.hintLabel.hidden=YES;
    [self addSubview:self.hintLabel];
    
    
    //将正方形的view变成圆形
    
    self.layer.cornerRadius = kDownLoadWidth / 2;
    
    
    //开启呼吸动画
    
    [self HighlightAnimation];
    
    [self initAI];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    
    //得到触摸点
    
    UITouch *startTouch = [touches anyObject];
    
    //返回触摸点坐标
    
    self.startPoint = [startTouch locationInView:self.superview];
    
    // 移除之前的所有行为
    
    [self.animator removeAllBehaviors];
    
    
}

//触摸移动

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    
    //得到触摸点
    
    UITouch *startTouch = [touches anyObject];
    
    //将触摸点赋值给touchView的中心点 也就是根据触摸的位置实时修改view的位置
    
    self.center = [startTouch locationInView:self.superview];
    
}

//结束触摸

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    
    //得到触摸结束点
    
    UITouch *endTouch = [touches anyObject];
    
    //返回触摸结束点
    
    self.endPoint = [endTouch locationInView:self.superview];
    
    //判断是否移动了视图 (误差范围5)
    
    CGFloat errorRange = 5;
    
    if (( self.endPoint.x - self.startPoint.x >= -errorRange && self.endPoint.x - self.startPoint.x <= errorRange ) && ( self.endPoint.y - self.startPoint.y >= -errorRange && self.endPoint.y - self.startPoint.y <= errorRange )) {
        
        
        
    } else {
        
        //移动
        
        self.center = self.endPoint;
        
        //计算距离最近的边缘 吸附到边缘停靠
        
        CGFloat superwidth = self.superview.bounds.size.width;
        
        CGFloat superheight = self.superview.bounds.size.height;
        
        CGFloat endX = self.endPoint.x;
        
        CGFloat endY = self.endPoint.y;
        
        CGFloat topRange = endY;//上距离
        
        CGFloat bottomRange = superheight - endY;//下距离
        
        CGFloat leftRange = endX;//左距离
        
        CGFloat rightRange = superwidth - endX;//右距离
        
        
        //比较上下左右距离 取出最小值
        
        CGFloat minRangeTB = topRange > bottomRange ? bottomRange : topRange;//获取上下最小距离
        
        CGFloat minRangeLR = leftRange > rightRange ? rightRange : leftRange;//获取左右最小距离
        
        CGFloat minRange = minRangeTB > minRangeLR ? minRangeLR : minRangeTB;//获取最小距离
        
        
        //判断最小距离属于上下左右哪个方向 并设置该方向边缘的point属性
        
        CGPoint minPoint;
        
        if (minRange == topRange) {
            
            //上
            
            endX = endX - kOffSet < 0 ? kOffSet : endX;
            
            endX = endX + kOffSet > superwidth ? superwidth - kOffSet : endX;
            
            minPoint = CGPointMake(endX , 0 + kOffSet);
            
        } else if(minRange == bottomRange){
            
            //下
            
            endX = endX - kOffSet < 0 ? kOffSet : endX;
            
            endX = endX + kOffSet > superwidth ? superwidth - kOffSet : endX;
            
            minPoint = CGPointMake(endX , superheight - kOffSet);
            
        } else if(minRange == leftRange){
            
            //左
            
            endY = endY - kOffSet < 0 ? kOffSet : endY;
            
            endY = endY + kOffSet > superheight ? superheight - kOffSet : endY;
            
            minPoint = CGPointMake(0 + kOffSet , endY);
            
        } else {
            
            //右
            
            endY = endY - kOffSet < 0 ? kOffSet : endY;
            
            endY = endY + kOffSet > superheight ? superheight - kOffSet : endY;
            
            minPoint = CGPointMake(superwidth - kOffSet , endY);
            
        }
        
        
        
        //添加吸附物理行为
        
        UIAttachmentBehavior *attachmentBehavior = [[UIAttachmentBehavior alloc] initWithItem:self attachedToAnchor:minPoint];
        
        [attachmentBehavior setLength:0];
        
        [attachmentBehavior setDamping:0.1];
        
        [attachmentBehavior setFrequency:5];
        
        [self.animator addBehavior:attachmentBehavior];
        
        
    }
    
    
}

#pragma mark ---UIDynamicAnimatorDelegate

-(void)dynamicAnimatorDidPause:(UIDynamicAnimator *)animator{
    
    
    
}



#pragma mark ---LazyLoading

- (UIDynamicAnimator *)animator
{
    
    if (!_animator) {
        
        // 创建物理仿真器(ReferenceView : 仿真范围)
        
        _animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.superview];
        
        //设置代理
        
        _animator.delegate = self;
        
    }
    
    return _animator;
    
}



#pragma mark ---BreathingAnimation 呼吸动画


- (void)HighlightAnimation{
    
    __block typeof(self) Self = self;
    
    [UIView animateWithDuration:1.5f animations:^{
        
        Self.backgroundView.backgroundColor = [Self.backgroundView.backgroundColor colorWithAlphaComponent:0.1f];
        
    } completion:^(BOOL finished) {
        
        [Self DarkAnimation];
        
    }];
    
}

- (void)DarkAnimation{
    
    __block typeof(self) Self = self;
    
    [UIView animateWithDuration:1.5f animations:^{
        
        Self.backgroundView.backgroundColor = [Self.backgroundView.backgroundColor colorWithAlphaComponent:0.6f];
        
    } completion:^(BOOL finished) {
        
        [Self HighlightAnimation];
        
    }];
    
}
#pragma mark -------AI-------
-(void)initAI
{
    
    
    self.imageView.userInteractionEnabled=YES;
    self.imageView.multipleTouchEnabled=YES;
    
    UITapGestureRecognizer * tap=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapClick)];
    
    [self.imageView addGestureRecognizer:tap];
    
    __weak typeof(self) weakSelf=self;
    [TTSManager shareInstance].TTSCompeleteBlock = ^{
        
        
        [weakSelf resetHintLabel];
    };
    
    [[TTSManager shareInstance] playText:@"欢迎来到智能微图！点击我回答您的问题。"];
    
    [self resetHintLabel];
    
}

-(void)resetHintLabel
{
    self.isRecord=NO;
    self.isSpeech=NO;
    self.isUnderstandered=NO;
    self.isAnalyticed=NO;
    [self showHintLabelWithText:@"点击我提问"];
}
-(void)showHintLabelWithText:(NSString *)text
{
    
    self.hintLabel.adjustsFontSizeToFitWidth=YES;
    self.hintLabel.alpha=1;
    self.hintLabel.text=text;
    self.hintLabel.hidden=NO;
}
-(void)hiddenHintLabel
{
    
    [UIView animateWithDuration:0.4 animations:^{
        self.hintLabel.alpha=0;
    } completion:^(BOOL finished) {
        self.hintLabel.hidden=YES;
    }];
}

//点击
-(void)tapClick
{
    
    
    if (self.isRecord) {
        [self stop];
    }
    else if (self.isSpeech)
    {
        [[TTSManager shareInstance] stop];
        [self resetHintLabel];
    }
    else
    {
        [self onlinRecBtnHandler];
    }
}

//开始识别
- (void)onlinRecBtnHandler
{
    [self startRecord];
    
    
    //initlize recorder
    [IFlyAudioSession initRecordingAudioSession];
    
    m_listener.onSetController(self);
    
    //start listener
    m_listener.onStart();
    
    //#ifdef RECRORED
    //start recorder ,default  mono 16k rate pcm
    self.m_recorder = [IFlyPcmRecorder sharedInstance];
    
    self.m_recorder.delegate = self;
    
    [self.m_recorder start];
    
    
}
-(void)startRecord
{
    self.isRecord=YES;
    self.isSpeech=NO;
    self.isAnalyticed=NO;
    self.isUnderstandered=NO;
    [self showHintLabelWithText:@"正在倾听..."];
}
-(void)startSpeech
{
    
    self.isRecord=NO;
    self.isSpeech=YES;
    
    [self showHintLabelWithText:@"正在回答..."];
}


-(void) stop
{
    if (self.result==nil) {
        NSLog(@"没有反馈");
    }
    
    if(self.m_recorder){
        [self.m_recorder stop];
        self.m_recorder.delegate = nil;
    }
    
    AiuiSendBuffer(NULL,0 ,true);
    
    NSLog(@"停止录音");
    //完成语言理解
    self.isUnderstandered=YES;
    [self speakResult];
    
    
}
-(void)speakResult
{
    
    if (self.isUnderstandered&&self.isAnalyticed) {
        //播报
        [self startSpeech];
        
        [[TTSManager shareInstance] playText:self.result];
    }
    
}
-(void) showResult:(NSString *)result
{
    NSLog(@"result--%@",result);
    
    if (self.isSpeech) {
        return;
    }
    //重置结果
    self.result=@"我无法回答这个问题";
    if (result==nil||[result isEqualToString:@""]) {
        
        //解析完成
        self.isAnalyticed=YES;
        [self speakResult];
        return;
    }
    
    
    
    NSDictionary * dict=[self parseJSONStringToNSDictionary:result];
    
    if (dict==nil||[dict isKindOfClass:[NSDictionary class]]==NO) {
        //解析完成
        
        self.isAnalyticed=YES;
        [self speakResult];
        return;
    }
    
    NSDictionary * intentDict=dict[@"intent"];
    NSString * service=intentDict[@"service"];
    if ([service isEqualToString:@"SGLSAPCE.skill_1"]) {
        NSDictionary * semanticDict=[intentDict[@"semantic"] firstObject];;
        //意图 book_detail
        NSString * intent=semanticDict[@"intent"];
        NSDictionary * valueDict=[semanticDict[@"slots"] firstObject];
        NSString * value=valueDict[@"value"];
        if ([intent isEqualToString:@"book_detail"]) {
            
            
            self.result=[NSString stringWithFormat:@"马上为您查找%@",value];
        }
        else if ([intent isEqualToString:@"want_lookBook"]) {
            
            self.result=[NSString stringWithFormat:@"请到%@详情页借书",value];
        }
        else
        {
            self.result=value;
            
        }
    }
    else
    {
        
        self.result=intentDict[@"answer"][@"text"];
        
    }
    //解析完成
    self.isAnalyticed=YES;
    [self speakResult];
    
    
    
    
}
-(NSDictionary *)parseJSONStringToNSDictionary:(NSString *)JSONString {
    NSData *JSONData = [JSONString dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *responseJSON = [NSJSONSerialization JSONObjectWithData:JSONData options:NSJSONReadingMutableLeaves error:nil];
    return responseJSON;
}
#pragma mark - IFlyPcmRecorderDelegate
- (void) onIFlyRecorderBuffer: (const void *)buffer bufferSize:(int)size
{
    if(buffer != NULL && size > 0){
        AiuiSendBuffer(buffer,size,false);
    }
}
- (void) onIFlyRecorderError:(IFlyPcmRecorder*)recoder theError:(int) error
{
    NSLog(@"Error=%d",error);
}

//range from 0 to 30
- (void) onIFlyRecorderVolumeChanged:(int) power
{
    //    NSString * vol = [NSString stringWithFormat:@"%@：%d", NSLocalizedString(@"recVol", nil),power];
    
}
-(void)dealloc
{
    
    
    m_listener.onSetController(nil);
}
@end
