//
// Created by Diyuan Wang on 2019/11/12
// Copyright (c) 2017 andforce. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BBSUser;
@class WorkedBBS;
@class BBSWebViewController;


@interface BBSLocalApi : NSObject

// 获取当前登录的账户信息
- (BBSUser *)getLoginUser:(NSString *)host;

// 获取当前登录的账户信息
- (BOOL)isHaveLogin:(NSString *)host;

// 获取当前登录的账户信息
- (BOOL)isHaveLoginForum;

// 退出论坛
- (void)logout;

- (void)logout:(NSString *)forumUrl;

- (NSString *)currentForumHost;

- (NSArray<WorkedBBS *> *)supportForums;

- (NSArray<WorkedBBS *> *)loginedSupportForums;

- (NSString *)currentForumBaseUrl;

- (NSString *)bundleIdentifier;

//---------------------------------------

- (NSArray<NSHTTPCookie *> *)loadCookie;

- (NSString *)loadCookieString;

- (void)saveCookie;

- (void)clearCookie;

- (void)saveFavFormIds:(NSArray *)ids;

- (NSArray *)favFormIds;

- (int)dbVersion;

- (void)setDBVersion:(int)version;

- (void)saveUserName:(NSString *)name forHost:(NSString *)host;

- (NSString *)userName:(NSString *)host;

- (void)saveUserId:(NSString *)uid forHost:(NSString *)host;

- (NSString *)userId:(NSString *)host;

- (NSString *)currentForumURL;

- (NSString *)currentProductID;

- (void)saveCurrentForumURL:(NSString *)url;

- (void)clearCurrentForumURL;

@end