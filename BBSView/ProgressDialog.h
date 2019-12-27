//
// Created by Diyuan Wang on 2019/11/12
// Copyright (c) 2018 None. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ProgressDialog : NSObject

+ (void)show;

+ (void)dismiss;

+ (void)showStatus:(NSString *)message;

+ (void)showError:(NSString *)message;

+ (void)showSuccess:(NSString *)message;

@end