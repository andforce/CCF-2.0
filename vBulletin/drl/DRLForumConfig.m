//
//  CCFForumConfig.m
//  Forum
//
//  Created by WDY on 2016/12/8.
//  Copyright © 2016年 andforce. All rights reserved.
//

#import "DRLForumConfig.h"
#import "DeviceName.h"

@implementation DRLForumConfig

- (instancetype)init {
    self = [super init];
    super.forumURL = [NSURL URLWithString:@"https://dream4ever.org/"];
    return self;
}

#pragma mark Overide

- (NSString *)archive {
    return [super.forumURL.absoluteString stringByAppendingString:@"forumdisplay.php?f=1"];
}


#pragma mark optional

- (NSString *)privateWithType:(int)type withPage:(int)page {
    return [NSString stringWithFormat:@"%@private.php?folderid=%d&pp=30&sort=date&page=%d", super.forumURL.absoluteString,type, page];
}

- (NSString *)deletePrivateWithType:(int)type {
    int fixType = type;
    if (fixType != 0){
        fixType = -1;
    }
    return [NSString stringWithFormat:@"%@private.php?folderid=%d", super.forumURL.absoluteString, fixType];
}

- (NSString *)privateShowWithMessageId:(int)messageId withType:(int)type {
    return [NSString stringWithFormat:@"%@private.php?do=showpm&pmid=%d", super.forumURL.absoluteString,messageId];
}

- (NSString *)privateReplyWithMessageIdPre:(int)messageId {
    return [NSString stringWithFormat:@"%@private.php?do=insertpm&pmid=%d", super.forumURL.absoluteString,messageId];
}

- (NSString *)privateReplyWithMessage {
    return [NSString stringWithFormat:@"%@private.php?do=insertpm&pmid=0", super.forumURL.absoluteString];
}

- (NSString *)privateNewPre {
    return [NSString stringWithFormat:@"%@private.php?do=newpm", super.forumURL.absoluteString];
}

#pragma mark ForumCommonConfigDelegate
- (UIColor *)themeColor {
    return [[UIColor alloc] initWithRed:111.f/255.f green:134.f/255.f blue:160.f/255.f alpha:1];
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
