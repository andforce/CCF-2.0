//
// Created by 迪远 王 on 2017/12/9.
// Copyright (c) 2017 andforce. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <UserNotifications/UserNotifications.h>


@interface ForumPushManager : NSObject

- (instancetype)initWithNotificationCenterDelegate:(id <UNUserNotificationCenterDelegate>)delegate;

- (void)registerPushManagerWithOptions:(NSDictionary *)launchOptions;

- (void)handleRemoteNotificationsWithDeviceToken:(NSData *)deviceToken;

@end