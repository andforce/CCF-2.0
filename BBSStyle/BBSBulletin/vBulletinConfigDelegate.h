//
// Created by Diyuan Wang on 2019/11/12
// Copyright (c) 2018 andforce. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol vBulletinConfigDelegate <NSObject>

// 登录
- (NSString *)login;

- (NSString *)loginvCode;

- (NSString *)deletePrivateWithType:(int)type;

- (NSString *)privateReplyWithMessageIdPre:(int)messageId;

- (NSString *)privateReplyWithMessage;

- (NSString *)privateNewPre;

- (NSString *)showThreadWithP:(NSString *)p;
@end