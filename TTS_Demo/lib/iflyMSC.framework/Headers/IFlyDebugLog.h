//
//  IFlyDebugLog.h
//  MSC

//  description: 程序中的log处理类

//  Created by ypzhao on 12-11-22.
//  Copyright (c) 2012年 iflytek. All rights reserved.
//

#import <Foundation/Foundation.h>

/*!
 *  调试信息
 */
@interface IFlyDebugLog : NSObject

/*!
 *  设置是否将log写入文件中
 *
 *  @param isWriteLog YES:写入；NO:不写入
 */
+ (void) setWriteLog:(BOOL)isWriteLog;

/*!
 *  设置是否显示log
 *
 *  @param isShowLog YES:显示；NO:不显示
 */
+ (void) setShowLog:(BOOL) isShowLog;

@end
