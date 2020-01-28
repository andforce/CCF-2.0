//
// Created by Diyuan Wang on 2019/11/12
// Copyright (c) 2017 None. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BBSApiDelegate.h"

typedef void (^UserInfoHandler)(BOOL isSuccess, id userName, id userId);

@protocol PhpWindApiDelegate <NSObject>

@optional

- (void)fetchUserInfo:(UserInfoHandler)handler;

- (void)fetchUserInfo:(NSString *)html handler: (UserInfoHandler)handler;

@end