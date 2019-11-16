//
// Created by 迪远 王 on 2018/4/30.
// Copyright (c) 2018 andforce. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ForumCommonConfigDelegate <NSObject>

- (UIColor *)themeColor;

- (NSString *)cookieUserIdKey;

- (NSString *)cookieExpTimeKey;

- (NSString *)signature;

@end