//
// Created by 迪远 王 on 2017/8/22.
// Copyright (c) 2017 andforce. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ForumApiDelegate.h"

typedef void (^UserInfoHandler)(BOOL isSuccess, id userName, id userId);

@protocol PhpWindApiDelegate <NSObject>

@optional

// user's name & id
- (void)fetchUserInfo:(UserInfoHandler)handler;

@end