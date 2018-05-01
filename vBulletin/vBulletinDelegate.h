//
// Created by 迪远 王 on 2017/8/22.
// Copyright (c) 2017 andforce. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class Message;

typedef void (^HandlerWithBool)(BOOL isSuccess, id message);

@protocol vBulletinDelegate <NSObject>

// 登录论坛
@optional
- (void)loginWithName:(NSString *)name andPassWord:(NSString *)passWord withCode:(NSString*) code question:(NSString *) q answer:(NSString *) a handler:(HandlerWithBool)handler;

// 刷新验证码
@optional
- (void)refreshVCodeToUIImageView:(UIImageView *)vCodeImageView;

- (void)showThreadWithP:(NSString *)p handler:(HandlerWithBool)handler;

#pragma 短消息相关
@optional
- (void)listPrivateMessageWithType:(int)type andPage:(int)page handler:(HandlerWithBool)handler;

@optional
- (void)deletePrivateMessage:(Message *)privateMessage withType:(int)type handler:(HandlerWithBool)handler;

// 根据PM ID 显示一条私信内容
// 0 系统短信   1 正常私信
- (void)showPrivateMessageContentWithId:(int)pmId withType:(int ) type handler:(HandlerWithBool)handler;

// 发送站内短信
- (void)sendPrivateMessageToUserName:(NSString *)name andTitle:(NSString *)title andMessage:(NSString *)message handler:(HandlerWithBool)handler;

// 回复站内短信
- (void)replyPrivateMessage:(Message *)privateMessage andReplyContent:(NSString *)content handler:(HandlerWithBool)handler;

// 发表一个新的帖子
- (void)createNewThreadWithCategory:(NSString *)category
                      categoryIndex:(int)index
                          withTitle:(NSString *)title
                         andMessage:(NSString *)message
                         withImages:(NSArray *)images
                             inPage:(ViewForumPage *) page
                            handler:(HandlerWithBool)handler;

@end