//
// Created by Diyuan Wang on 2019/11/12
// Copyright (c) 2017 andforce. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BBSApiDelegate.h"

typedef void (^UserInfoHandler)(BOOL isSuccess, id userName, id userId);

@protocol PhpWindApiDelegate <NSObject>

@optional

// user's name & id
- (void)fetchUserInfo:(UserInfoHandler)handler;

@end