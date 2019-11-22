//
// Created by Diyuan Wang on 2019/11/12
// Copyright (c) 2017 andforce. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ViewForumPage.h"

@class BBSPrivateMessage;

typedef void (^HandlerWithBool)(BOOL isSuccess, id message);

@protocol vBulletinApiDelegate <NSObject>

// 登录论坛
- (void)loginWithName:(NSString *)name andPassWord:(NSString *)passWord withCode:(NSString *)code question:(NSString *)q answer:(NSString *)a handler:(HandlerWithBool)handler;

// 刷新验证码
- (void)refreshVCodeToUIImageView:(UIImageView *)vCodeImageView;

- (void)showThreadWithP:(NSString *)p handler:(HandlerWithBool)handler;

#pragma 短消息相关

- (void)listPrivateMessageWithType:(int)type andPage:(int)page handler:(HandlerWithBool)handler;

@end