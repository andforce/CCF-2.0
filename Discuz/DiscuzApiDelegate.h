//
// Created by 迪远 王 on 2017/8/22.
// Copyright (c) 2017 andforce. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ViewForumPage.h"

@protocol DiscuzApiDelegate <NSObject>

#pragma 短消息相关
- (void)listPrivateMessage:(int)page handler:(HandlerWithBool)handler;

- (void)listNoticeMessage:(int)page handler:(HandlerWithBool)handler;

- (void)showThreadWithPTid:(NSString *)ptid pid:(NSString *)pid handler:(HandlerWithBool)handler;

// 发表一个新的帖子
- (void)createNewThreadWithCategory:(NSString *)categoryName
                      categoryValue:(NSString *)categoryValue
                          withTitle:(NSString *)title
                         andMessage:(NSString *)message
                         withImages:(NSArray *)images
                             inPage:(ViewForumPage *) page

                           postHash:(NSString *)posthash
                           formHash:(NSString *)formhash
                        secCodeHash:(NSString *)seccodehash
                      seccodeverify:(NSString *)seccodeverify
                           postTime:(NSString *)postTime
                            handler:(HandlerWithBool)handler;

@end