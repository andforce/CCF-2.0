//
// Created by 迪远 王 on 2017/8/22.
// Copyright (c) 2017 andforce. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ViewForumPage.h"

@class Message;

typedef void (^HandlerWithBool)(BOOL isSuccess, id message);

@protocol vBulletinApiDelegate <NSObject>

// 登录论坛
- (void)loginWithName:(NSString *)name andPassWord:(NSString *)passWord withCode:(NSString*) code question:(NSString *) q answer:(NSString *) a handler:(HandlerWithBool)handler;

// 刷新验证码
- (void)refreshVCodeToUIImageView:(UIImageView *)vCodeImageView;

- (void)showThreadWithP:(NSString *)p handler:(HandlerWithBool)handler;

#pragma 短消息相关
- (void)listPrivateMessageWithType:(int)type andPage:(int)page handler:(HandlerWithBool)handler;

// 发表一个新的帖子
- (void)createNewThreadWithCategory:(NSString *)category
                      categoryIndex:(int)index
                          withTitle:(NSString *)title
                         andMessage:(NSString *)message
                         withImages:(NSArray *)images
                             inPage:(ViewForumPage *) page
                            handler:(HandlerWithBool)handler;

@end