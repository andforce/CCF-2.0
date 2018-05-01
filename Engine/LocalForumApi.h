//
// Created by 迪远 王 on 2017/8/22.
// Copyright (c) 2017 andforce. All rights reserved.
//

#import <Foundation/Foundation.h>

@class LoginUser;
@class Forums;
@class ForumWebViewController;


@interface LocalForumApi : NSObject

// 获取当前登录的账户信息
- (LoginUser *)getLoginUser:(NSString *)host;

// 获取当前登录的账户信息
- (BOOL)isHaveLogin:(NSString *) host;

// 获取当前登录的账户信息
- (BOOL)isHaveLoginForum;

// 退出论坛
- (void)logout;

- (NSString *)currentForumHost;

- (NSArray<Forums *> *) supportForums;

- (NSArray<Forums *> *) loginedSupportForums;

- (NSString *)currentForumBaseUrl;

- (NSString *) bundleIdentifier;

//---------------------------------------

- (NSArray<NSHTTPCookie *> *)loadCookie;

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

- (void) saveCurrentForumURL:(NSString*) url;

- (void) clearCurrentForumURL;

@end