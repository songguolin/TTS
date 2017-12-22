//
//  ViewController.m
//  TTS_Demo
//
//  Created by guolinsong on 2017/11/8.
//  Copyright © 2017年 guolin song. All rights reserved.
//

#import "ViewController.h"

#import "FloatView.h"

#import "TTSManager.h"
#import <QuartzCore/QuartzCore.h>
#import "IFlyMSC/IFlyMSC.h"
#import "Definition.h"
#import "IATConfig.h"


@interface ViewController ()



@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *rightItem;

@property (weak, nonatomic) IBOutlet UIButton *btn;

@property (nonatomic,strong) FloatView * floatView;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.floatView = [[FloatView alloc]initWithFrame:CGRectMake(20, 180, 80, 80)];
    __weak typeof(self) weakSelf=self;
    self.floatView.AIBlock = ^(NSString *result) {
        weakSelf.textView.text=result;
       
    };
    
    [self.view addSubview:self.floatView];
    

    
}
- (IBAction)show:(id)sender {
    

}


////上传数据
//-(void)uploadData
//{
//    
////    SGLSAPCE
//
//    IFlyDataUploader * uploader=[IFlyDataUploader new];
//    
//    NSDictionary * param=@{@"appid": @"56ac196f",@"id_name": @"uid",@"id_value": @"bookName",@"res_name": @"want_book" };
//    
//    [uploader setParameter:@"" forKey:@""];
//    
//    
//    
//    NSDictionary * dict=@{@"name": @"老人与海",@"alias": @"海明威"};
//    
//    
//    [uploader uploadDataWithCompletionHandler:^(NSString *result, IFlySpeechError *error) {
//        
//    } name:@"bookName" data:@""];
//    
//    
//}





@end
