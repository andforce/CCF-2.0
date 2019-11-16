//
// Created by 迪远 王 on 2017/12/9.
// Copyright (c) 2017 andforce. All rights reserved.
//

#import "ForumPushManager.h"
#import <AVOSCloud/AVOSCloud.h>


@implementation ForumPushManager {

    id <UNUserNotificationCenterDelegate> _delegate;
}

- (void)registerPushManagerWithOptions:(NSDictionary *)launchOptions {

//    // 配置 SDK 储存
//    [AVOSCloud setServerURLString:@"https://n2qq6vea.lc-cn-n1-shared.com" forServiceModule:AVServiceModuleAPI];
//    // 配置 SDK 推送
//    [AVOSCloud setServerURLString:@"https://n2qq6vea.lc-cn-n1-shared.com" forServiceModule:AVServiceModulePush];
//    // 配置 SDK 云引擎（用于访问云函数，使用 API 自定义域名，而非云引擎自定义域名）
//    [AVOSCloud setServerURLString:@"https://n2qq6vea.lc-cn-n1-shared.com" forServiceModule:AVServiceModuleEngine];
//    // 配置 SDK 即时通讯
//    [AVOSCloud setServerURLString:@"https://n2qq6vea.lc-cn-n1-shared.com" forServiceModule:AVServiceModuleRTM];
//    // 配置 SDK 统计
//    [AVOSCloud setServerURLString:@"https://n2qq6vea.lc-cn-n1-shared.com" forServiceModule:AVServiceModuleStatistics];
//    // 初始化应用
//    [AVOSCloud setApplicationId:@"6bb0jjSB7QgBIJ24q7dshAtl-gzGzoHsz" clientKey:@"tTpCum0ACwFsvEgWlNU0vkB0"];

    [AVOSCloud setApplicationId:@"6bb0jjSB7QgBIJ24q7dshAtl-gzGzoHsz" clientKey:@"tTpCum0ACwFsvEgWlNU0vkB0"
                serverURLString:@"https://n2qq6vea.lc-cn-n1-shared.com"];

    [AVOSCloud setAllLogsEnabled:YES];

    [self registerForRemoteNotification];

    // 添加跟踪App的打开状况
    [AVAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
}

- (instancetype)init {
    // 禁止调用原来的init方法
    return nil;
}

- (instancetype)initWithNotificationCenterDelegate:(id <UNUserNotificationCenterDelegate>)delegate {
    if (self = [super init]) {
        _delegate = delegate;
    };
    return self;
}

- (void)handleRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    // 向系统申请推送服务
    //[AVOSCloud handleRemoteNotificationsWithDeviceToken:deviceToken];
}


/**
 * 初始化UNUserNotificationCenter
 */
- (void)registerForRemoteNotification {
    // iOS10 兼容
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 10.0) {
        // 使用 UNUserNotificationCenter 来管理通知
        UNUserNotificationCenter *uncenter = [UNUserNotificationCenter currentNotificationCenter];
        // 监听回调事件
        [uncenter setDelegate:_delegate];
        //iOS10 使用以下方法注册，才能得到授权
        [uncenter requestAuthorizationWithOptions:(UNAuthorizationOptionAlert + UNAuthorizationOptionBadge + UNAuthorizationOptionSound)
                                completionHandler:^(BOOL granted, NSError *_Nullable error) {
                                    [[UIApplication sharedApplication] registerForRemoteNotifications];
                                    //授权状态改变
                                    NSLog(@"是否允许推送消息？ \t%@", granted ? @"授权成功" : @"授权失败");
                                }];
        // 获取当前的通知授权状态, UNNotificationSettings
        [uncenter getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings *_Nonnull settings) {
            //NSLog(@"%s\nline:%@\n-----\n%@\n\n", __func__, @(__LINE__), settings);
            /*
             UNAuthorizationStatusNotDetermined : 没有做出选择
             UNAuthorizationStatusDenied : 用户未授权
             UNAuthorizationStatusAuthorized ：用户已授权
             */
//            if (settings.authorizationStatus == UNAuthorizationStatusNotDetermined) {
//                NSLog(@"未选择");
//            } else if (settings.authorizationStatus == UNAuthorizationStatusDenied) {
//                NSLog(@"未授权");
//            } else if (settings.authorizationStatus == UNAuthorizationStatusAuthorized) {
//                NSLog(@"已授权");
//            }
        }];
    }
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
        UIUserNotificationType types = UIUserNotificationTypeAlert |
                UIUserNotificationTypeBadge |
                UIUserNotificationTypeSound;
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:types categories:nil];

        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    } else {
        UIRemoteNotificationType types = UIRemoteNotificationTypeBadge |
                UIRemoteNotificationTypeAlert |
                UIRemoteNotificationTypeSound;
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:types];
    }
#pragma clang diagnostic pop
}


@end
