//
//  CCFForumConfig.m
//
//
//  Created by Diyuan Wang on 2019/11/21.
//  Copyright © 2019年 Diyuan Wang. All rights reserved.
//

#import "Et8NetConfig.h"
#import "DeviceName.h"

@implementation Et8NetConfig

- (instancetype)init {
    self = [super init];
    super.forumURL = [NSURL URLWithString:@"https://bbs.et8.net/bbs/"];

    return self;
}

#pragma mark ForumCommonConfigDelegate

- (UIColor *)themeColor {
    return [[UIColor alloc] initWithRed:46.f / 255.f green:70.f / 255.f blue:126.f / 255.f alpha:1];
}

- (NSString *)cookieUserIdKey {
    return @"bbuserid";
}

- (NSString *)cookieExpTimeKey {
    return @"IDstack";
}

- (NSString *)signature {
    NSString *phoneName = [DeviceName deviceNameDetail];
    NSString *signature = [NSString stringWithFormat:@"\n\n发自 %@ 使用 CCF客户端", phoneName];
    return signature;
}

@end
