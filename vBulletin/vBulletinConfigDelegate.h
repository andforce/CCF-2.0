//
// Created by 迪远 王 on 2018/4/30.
// Copyright (c) 2018 andforce. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol vBulletinConfigDelegate <NSObject>

// 登录
- (NSString *)login;

- (NSString *)loginvCode;

@optional
// 站内短信
- (NSString *)privateWithType:(int)type withPage:(int)page;

- (NSString *)deletePrivateWithType:(int)type;

- (NSString *)privateShowWithMessageId:(int)messageId withType:(int)type;

- (NSString *)privateReplyWithMessageIdPre:(int)messageId;

- (NSString *)privateReplyWithMessage;

- (NSString *)privateNewPre;
@end