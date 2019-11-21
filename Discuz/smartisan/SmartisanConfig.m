//
//  TForumConfig.m
//
//
//  Created by Diyuan Wang on 2019/11/21.
//  Copyright © 2019年 Diyuan Wang. All rights reserved.
//

#import "SmartisanConfig.h"
#import "DeviceName.h"
#import "UIColor+MyColor.h"

@implementation SmartisanConfig

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
