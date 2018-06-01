//
//  TForumConfig.m
//  Forum
//
//  Created by 迪远 王 on 2018/4/29.
//  Copyright © 2018年 andforce. All rights reserved.
//

#import "TForumConfig.h"
#import "DeviceName.h"
#import "UIColor+MyColor.h"

@implementation TForumConfig

- (instancetype)init {
    self = [super init];
    super.forumURL = [NSURL URLWithString:@"http://bbs.smartisan.com/"];
    return self;
}


#pragma mark ForumCommonConfigDelegate

- (UIColor *)themeColor {
    return [UIColor colorWithHex:@"#FFAF2029"];
}

- (NSString *)cookieUserIdKey {
    return @"dazE_2132_st_p";
}

- (NSString *)cookieExpTimeKey {
    return @"smart_b_user";
}

- (NSString *)signature {
    NSString *phoneName = [DeviceName deviceNameDetail];
    NSString *signature = [NSString stringWithFormat:@"\n\n发自 %@ 使用 iOS客户端", phoneName];
    return signature;
}
@end
