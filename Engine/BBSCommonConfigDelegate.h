//
// Created by Diyuan Wang on 2019/11/12
// Copyright (c) 2018 andforce. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol BBSCommonConfigDelegate <NSObject>

- (UIColor *)themeColor;

- (NSString *)cookieUserIdKey;

- (NSString *)cookieExpTimeKey;

- (NSString *)signature;

@end