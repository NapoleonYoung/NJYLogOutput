//
//  NJYLogOutPutWindow.h
//  ObjcTest
//
//  Created by 尚轩瑕 on 2018/6/15.
//  Copyright © 2018年 Hisense. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NJYLogOutPutWindow : UIWindow
+ (NJYLogOutPutWindow *)shareInstance;

/// 打印日志
+ (void)printLog:(NSString *)log;

/// 清空日志
+ (void)clearLogs;
@end
