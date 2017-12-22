//
//  AIResultModel.h
//  TTS_Demo
//
//  Created by guolinsong on 2017/11/10.
//  Copyright © 2017年 guolin song. All rights reserved.
//

#import <Foundation/Foundation.h>


/**
 予以结果
 */
@interface AIResultModel : NSObject

@property (nonatomic,copy) NSString * category;
@property (nonatomic,copy) NSString * intentType;
@property (nonatomic,copy) NSString * query;
@property (nonatomic,copy) NSString * query_ws;
@property (nonatomic,copy) NSString * rc;
@property (nonatomic,copy) NSString * nlis;
@property (nonatomic,copy) NSString * service;
@property (nonatomic,copy) NSString * uuid;
@property (nonatomic,copy) NSString * vendor;
@property (nonatomic,copy) NSString * version;
@property (nonatomic,strong) NSDictionary * semantic;

@property (nonatomic,copy) NSString * state;
@property (nonatomic,copy) NSString * sid;
@property (nonatomic,copy) NSString * text;



@end
/**
"category": "SGLSAPCE.skill_1",
"intentType": "custom",
"query": "查一查老人与海",
"query_ws": "查/NN//  一/NM//  查/NN//  老人/NP//  与/P//  海/NS//",
"rc": 0,
"nlis": "true",
"service": "SGLSAPCE.skill_1",
"uuid": "atn002699c1@ch74900d60a09a6f2601",
"vendor": "SGLSAPCE",
"version": "13.0",
"semantic": [
             {
                 "entrypoint": "ent",
                 "intent": "book_detail",
                 "score": 1.0,
                 "slots": [
                           {
                               "begin": 3,
                               "end": 7,
                               "name": "book",
                               "normValue": "老人与海",
                               "value": "老人与海"
                           }
                           ]
             }
             ],
"state": null,
"sid": "cid6f1991a5@ch00510d60a097010001",
"text": "查一查老人与海"
 
 
 

 "answer": {
 "text": "现在的时间是2017年11月10日 星期五 15:41:27",
 "type": "T"
 },
 "match_info": {
 "type": "gparser_path",
 "value": "-----"
 },
 "operation": "ANSWER",
 "rc": 0,
 "service": "datetime",
 "state": null,
 "text": "现在的时间",
 "uuid": "atn0026be09@ch74900d60a4276f2601",
 "sid": "cid6f199838@ch00510d60a425010001"

 **/
