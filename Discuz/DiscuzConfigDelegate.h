//
// Created by 迪远 王 on 2018/4/30.
// Copyright (c) 2018 andforce. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol DiscuzConfigDelegate <NSObject>

@optional
// 站内短信
- (NSString *)privateMessage:(int)page;

// 帖子消息
- (NSString *)noticeMessage:(int)page;

@end