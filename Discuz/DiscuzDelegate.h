//
// Created by 迪远 王 on 2017/8/22.
// Copyright (c) 2017 andforce. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol DiscuzDelegate <NSObject>

#pragma 短消息相关
@optional
- (void)listPrivateMessage:(int)page handler:(HandlerWithBool)handler;

@end