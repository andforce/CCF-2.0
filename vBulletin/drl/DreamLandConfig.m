//
//  CCFForumConfig.m
//
//
//  Created by Diyuan Wang on 2019/11/21.
//  Copyright © 2019年 Diyuan Wang. All rights reserved.
//

#import "DreamLandConfig.h"
#import "DeviceName.h"

@implementation DreamLandConfig

- (instancetype)init {
    self = [super init];
    super.forumURL = [NSURL URLWithString:@"https://dream4ever.org/"];
    return self;
}

#pragma mark Overide

- (NSString *)archive {
    return [super.forumURL.absoluteString stringByAppendingString:@"forumdisplay.php?f=1"];
}


#pragma mark ForumCommonConfigDelegate

- (UIColor *)themeColor {
    return [[UIColor alloc] initWithRed:111.f / 255.f green:134.f / 255.f blue:160.f / 255.f alpha:1];
}

- (NSString *)cookieUserIdKey {
    return @"drluserid";
}

- (NSString *)cookieExpTimeKey {
    return @"IDstack";
}

- (NSString *)signature {
    NSString *phoneName = [DeviceName deviceNameDetail];
    NSString *signature = [NSString stringWithFormat:@"\n\n发自 %@ 使用 DRL客户端", phoneName];
    return signature;
}


@end
