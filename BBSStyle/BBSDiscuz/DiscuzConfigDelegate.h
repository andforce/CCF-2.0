//
// Created by Diyuan Wang on 2019/11/12
// Copyright (c) 2018 None. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol DiscuzConfigDelegate <NSObject>

@optional
// 站内短信
- (NSString *)privateMessage:(int)page;

// 帖子消息
- (NSString *)noticeMessage:(int)page;

@end