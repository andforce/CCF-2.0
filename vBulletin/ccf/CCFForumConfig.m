//
//  CCFForumConfig.m
//  Forum
//
//  Created by WDY on 2016/12/8.
//  Copyright © 2016年 andforce. All rights reserved.
//

#import "CCFForumConfig.h"
#import "DeviceName.h"

@implementation CCFForumConfig {
    NSURL *_forumURL;
}

- (instancetype)init {
    self = [super init];
    _forumURL = [NSURL URLWithString:@"https://bbs.et8.net/bbs/"];

    return self;
}

#pragma mark optional
- (NSString *)privateWithType:(int)type withPage:(int)page {
    return [NSString stringWithFormat:@"%@private.php?folderid=%d&pp=30&sort=date&page=%d", _forumURL.absoluteString, type, page];
}

- (NSString *)deletePrivateWithType:(int)type {
    int fixType = type;
    if (fixType != 0){
        fixType = -1;
    }
    return [NSString stringWithFormat:@"%@private.php?folderid=%d", _forumURL.absoluteString, fixType];
}

- (NSString *)privateShowWithMessageId:(int)messageId withType:(int)type {
    return [NSString stringWithFormat:@"%@private.php?do=showpm&pmid=%d", _forumURL.absoluteString, messageId];
}

- (NSString *)privateReplyWithMessageIdPre:(int)messageId {
    return [NSString stringWithFormat:@"%@private.php?do=insertpm&pmid=%d", _forumURL.absoluteString, messageId];
}

- (NSString *)privateReplyWithMessage {
    return [NSString stringWithFormat:@"%@private.php?do=insertpm&pmid=0", _forumURL.absoluteString];
}

- (NSString *)privateNewPre {
    return [NSString stringWithFormat:@"%@private.php?do=newpm", _forumURL.absoluteString];
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
