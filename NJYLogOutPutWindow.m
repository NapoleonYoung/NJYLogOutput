//
//  NJYLogOutPutWindow.m
//  ObjcTest
//
//  Created by 尚轩瑕 on 2018/6/15.
//  Copyright © 2018年 Hisense. All rights reserved.
//

#import "NJYLogOutPutWindow.h"

@interface NJYLog: NSObject

/// log产生的时间
@property (nonatomic, assign) NSTimeInterval timeBirth;
/// 存放log的数组
@property (nonatomic, copy) NSString *log;

@end

@implementation NJYLog

+  (NJYLog *)logWithText:(NSString *)logText {
    NJYLog *log = [NJYLog new];
    log.timeBirth = [[NSDate date] timeIntervalSinceReferenceDate];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm:ss"];
    NSString *dateStr = [dateFormatter stringFromDate:[NSDate date]];
    log.log = [NSString stringWithFormat:@"%@ : %@", dateStr, logText];
    return log;
}

@end

@interface NJYLogOutPutWindow()

@property (nonatomic, strong) UITextView *textView;

@property (nonatomic, strong) NSMutableArray *logs;

@end

@implementation NJYLogOutPutWindow

+ (NJYLogOutPutWindow *)shareInstance {
    static NJYLogOutPutWindow *single;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        single = [[NJYLogOutPutWindow alloc] init];
    });
    return single;
}

- (NJYLogOutPutWindow *)init {
    self = [super initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height)];
    if (self) {
        self.rootViewController = [UIViewController new];
        self.windowLevel = UIWindowLevelAlert;
        self.backgroundColor = [UIColor colorWithRed:1.0 green:0.5 blue:0.5 alpha:0.2];
        self.userInteractionEnabled = NO;

        _textView = [[UITextView alloc] initWithFrame:self.bounds];
        _textView.font = [UIFont systemFontOfSize:12.0f];
        _textView.backgroundColor = [UIColor clearColor];
        _textView.scrollsToTop = NO;
        [self addSubview:_textView];

        _logs = [NSMutableArray array];

    }
    return self;
}

+ (void)printLog:(NSString *)log {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[self shareInstance] printLog:log];
    });
}

- (void)printLog:(NSString *)newLog {
    if (newLog.length == 0) {
        return;
    }

    @synchronized(self) {
        newLog = [NSString stringWithFormat:@"%@\n", newLog];
        NJYLog *logModel = [NJYLog logWithText:newLog];
        if (!logModel) {
            return;
        }
        [self.logs addObject:logModel];

        [self refreshLogDisplay];
    }
}

/// 刷新log展示
- (void)refreshLogDisplay {
    NSMutableAttributedString *attributeString = [NSMutableAttributedString new];
    NSTimeInterval currentTimeBirth = [[NSDate date] timeIntervalSinceReferenceDate];
    for (NJYLog *log in self.logs) {
        NSMutableAttributedString *logStr = [[NSMutableAttributedString alloc] initWithString:log.log];
        UIColor *logColor = (currentTimeBirth - log.timeBirth) > 0.1 ? [UIColor whiteColor] : [UIColor blueColor];
        [logStr addAttribute:NSForegroundColorAttributeName value:logColor range:NSMakeRange(0, logStr.length)];
        [attributeString appendAttributedString:logStr];
    }

    self.textView.attributedText = attributeString;

    if (attributeString.length > 0) {
        NSRange bottomRange = NSMakeRange(attributeString.length - 1, 1);
        [self.textView scrollRangeToVisible:bottomRange];
    }
}

+ (void)clearLogs {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[self shareInstance] clearLog];
    });
}

- (void)clearLog {
    self.textView.text = @"";
    [self.logs removeAllObjects];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
