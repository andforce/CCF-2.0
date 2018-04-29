//
// Created by 迪远 王 on 2017/8/22.
// Copyright (c) 2017 andforce. All rights reserved.
//

#import <CloudKit/CloudKit.h>
#import "LocalForumApi.h"
#import "LoginUser.h"
#import "ForumConfigDelegate.h"
#import "ForumApiHelper.h"
#import "AppDelegate.h"
#import "Forums.h"
#import "SupportForums.h"


@implementation LocalForumApi {
    NSUserDefaults * _userDefaults;
}

- (instancetype)init {
    self = [super init];
    if (self){
        _userDefaults = [NSUserDefaults standardUserDefaults];
    }

    return self;
}

- (LoginUser *)getLoginUserCrsky {

    NSArray<NSHTTPCookie *> *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
    if (cookies.count == 0){
        return nil;
    }

    id<ForumConfigDelegate> forumConfig = [ForumApiHelper forumConfig:@"bbs.crsky.com"];

    LoginUser *user = [[LoginUser alloc] init];
    user.userName = [self userName:@"bbs.crsky.com"];
    if (user.userName == nil || [user.userName isEqualToString:@""]){
        //[self logout];
        return nil;
    }
    user.userID = [self userId:@"bbs.crsky.com"];

    for (int i = 0; i < cookies.count; i++) {
        NSHTTPCookie *cookie = cookies[(NSUInteger) i];

        if ([cookie.name isEqualToString:forumConfig.cookieExpTimeKey]) {
            user.expireTime = cookie.expiresDate;
        }
    }
    return user;
}

- (LoginUser *)getLoginUserSmartisan {
    
    NSArray<NSHTTPCookie *> *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
    if (cookies.count == 0){
        return nil;
    }
    
    id<ForumConfigDelegate> forumConfig = [ForumApiHelper forumConfig:@"bbs.smartisan.com"];
    
    LoginUser *user = [[LoginUser alloc] init];
    user.userName = [self userName:@"bbs.smartisan.com"];
    if (user.userName == nil || [user.userName isEqualToString:@""]){
        //[self logout];
        return nil;
    }
    user.userID = [self userId:@"bbs.smartisan.com"];
    
    for (int i = 0; i < cookies.count; i++) {
        NSHTTPCookie *cookie = cookies[(NSUInteger) i];
        
        if ([cookie.name isEqualToString:forumConfig.cookieExpTimeKey]) {
            user.expireTime = cookie.expiresDate;
            break;
        }
    }
    return user;
}

- (LoginUser *)getLoginUser:(NSString *)host {
    NSArray<NSHTTPCookie *> *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
    if (cookies.count == 0){
        return nil;
    }
    LocalForumApi *localForumApi = [[LocalForumApi alloc] init];
    id<ForumConfigDelegate> forumConfig = [ForumApiHelper forumConfig:host];

    NSString *bundleId = [localForumApi bundleIdentifier];

    if ([bundleId isEqualToString:@"com.andforce.Crsky"] || [host isEqualToString:@"bbs.crsky.com"]){
        return [self getLoginUserCrsky];
    } else if([host isEqualToString:@"bbs.smartisan.com"]){
        return [self getLoginUserSmartisan];
    } else {
        LoginUser *user = [[LoginUser alloc] init];
        user.userName = [self userName:host];
        if (user.userName == nil || [user.userName isEqualToString:@""]){
            return nil;
        }

        for (int i = 0; i < cookies.count; i++) {
            NSHTTPCookie *cookie = cookies[(NSUInteger) i];

            if ([cookie.name isEqualToString:forumConfig.cookieUserIdKey]) {
                user.userID = [cookie.value componentsSeparatedByString:@"%"][0];
            }
            
            if ([cookie.name isEqualToString:forumConfig.cookieExpTimeKey]) {
                user.expireTime = cookie.expiresDate;
            }
        }
        return user;
    }
}

- (BOOL)isHaveLogin:(NSString *)host {

    LoginUser *user = [self getLoginUser:host];
    if (user == nil){
        return NO;
    }

    if (user.userName == nil || user.userID == nil || user.expireTime == nil){
        return NO;
    }
    if ([user.userName isEqualToString:@""] || [user.userID isEqualToString:@""] || [user.expireTime compare:[NSDate date]] == NSOrderedAscending){
        return NO;
    }
    return YES;
}

- (BOOL)isHaveLoginForum {
    // 判断是否登录
    NSArray * fs = [self supportForums];
    int size = (int) fs.count;
    for (int i = 0; i < size; ++i) {
        Forums * forums = fs[(NSUInteger) i];
        NSURL *url = [NSURL URLWithString:forums.url];
        if ([self isHaveLogin:url.host]){
            return YES;
        }
    }
    return NO;
}

- (void)deleteLoginUser:(LoginUser *)loginUser {
    NSString *uid = [self.currentForumHost stringByAppendingString:@"-UserId"];
    [_userDefaults setValue:@"" forKey:uid];

    NSString *name = [self.currentForumHost stringByAppendingString:@"-UserName"];
    [_userDefaults setValue:@"" forKey:name];
}

- (void)logout {

    LocalForumApi *localForumApi = [[LocalForumApi alloc] init];
    id<ForumConfigDelegate> forumConfig = [ForumApiHelper forumConfig:localForumApi.currentForumHost];

    [self clearCookie];

    NSURL *url = forumConfig.forumURL;
    if (url) {
        NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:url];
        for (int i = 0; i < [cookies count]; i++) {
            NSHTTPCookie *cookie = (NSHTTPCookie *) cookies[(NSUInteger) i];
            [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
        }
    }

    LoginUser *user = [localForumApi getLoginUser:localForumApi.currentForumHost];
    [self deleteLoginUser:user];
}

- (NSString *)currentForumHost {
    NSString * urlStr = [self currentForumURL];
    NSURL *url = [NSURL URLWithString:urlStr];
    return url.host;
}

- (NSArray<Forums *> *)supportForums {
    NSData *data = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"supportForums" ofType:@"json"]];

    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:(NSJSONReadingOptions) kNilOptions error:nil];

    SupportForums *supportForums = [SupportForums modelObjectWithDictionary:dictionary];
    return supportForums.forums;
}

- (NSArray<Forums *> *)loginedSupportForums {

    NSArray * support = [self supportForums];

    NSMutableArray *result = [NSMutableArray array];

    for (Forums *forums in support) {
        NSURL *url = [NSURL URLWithString:forums.url];
        if ([self isHaveLogin:url.host]) {
            [result addObject:forums];
        }
    }
    return [result copy];
}

- (NSString *)currentForumBaseUrl {
    NSString *urlStr = [self currentForumURL];
    return urlStr;
}

- (NSString *)bundleIdentifier {
    NSString *bundleId = [[NSBundle mainBundle] bundleIdentifier];
    return bundleId;
}

- (NSString *)loadCookie {
    NSData *cookiesData = [_userDefaults objectForKey:[[self currentForumHost] stringByAppendingString:@"-Cookies"]];

    if ([cookiesData length]) {
        NSArray *cookies = [NSKeyedUnarchiver unarchiveObjectWithData:cookiesData];

        NSHTTPCookie *cookie;
        for (cookie in cookies) {
            [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
        }
        
        NSString *result = [cookies componentsJoinedByString:@"|"];//分隔符
        
        return result;
    }

    return nil;
}

- (void)saveCookie {
    NSArray<NSHTTPCookie *> *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:cookies];
    NSString *currentHost = [self currentForumHost];
    [_userDefaults setObject:data forKey:[currentHost stringByAppendingString:@"-Cookies"]];
}

- (void)clearCookie {
    [_userDefaults removeObjectForKey:[[self currentForumHost] stringByAppendingString:@"-Cookies"]];
}

- (void)saveFavFormIds:(NSArray *)ids {
    [_userDefaults setObject:ids forKey:[[self currentForumHost] stringByAppendingString:@"-FavIds"]];
}

- (NSArray *)favFormIds {
    return [_userDefaults objectForKey:[[self currentForumHost] stringByAppendingString:@"-FavIds"]];
}

#define kDB_VERSION @"DB_VERSION"
- (int)dbVersion {
    return [[_userDefaults objectForKey:kDB_VERSION] intValue];
}

- (void)setDBVersion:(int)version {
    [_userDefaults setObject:@(version) forKey:kDB_VERSION];
}

- (void)saveUserName:(NSString *)name forHost:(NSString *)host {
    NSString *key = [host stringByAppendingString:@"-UserName"];
    [_userDefaults setValue:name forKey:key];
}

- (NSString *)userName:(NSString *)host {
    NSString *key = [host stringByAppendingString:@"-UserName"];
    if (key == nil) {
        return nil;
    }
    return [_userDefaults valueForKey:key];
}


- (void)saveUserId:(NSString *)uid forHost:(NSString *)host {
    NSString *key = [host stringByAppendingString:@"-UserId"];
    [_userDefaults setValue:uid forKey:key];
}

- (NSString *)userId:(NSString *)host {
    NSString *key = [host stringByAppendingString:@"-UserId"];
    return [_userDefaults valueForKey:key];
}

- (NSString *)currentForumURL {
    LocalForumApi *localForumApi = [[LocalForumApi alloc] init];
    NSString *bundleId = [localForumApi bundleIdentifier];
    if ([bundleId isEqualToString:@"com.andforce.et8"]){
        return @"https://bbs.et8.net/bbs/";
    } else if ([bundleId isEqualToString:@"com.andforce.DRL"]){
        return @"https://dream4ever.org/";
    } else if([bundleId isEqualToString:@"com.andforce.Crsky"]){
        return @"http://bbs.crsky.com/";
    } else if ([bundleId isEqualToString:@"com.andforce.CHH"]){
        return @"https://chiphell.com/";
    } else{
        NSString *forumUrl = [_userDefaults valueForKey:@"currentForumURL"];
        return forumUrl;
    }
}

- (NSString *)currentProductID {
//    NSString *forumURL = [self currentForumURL];
//    if ([forumURL isEqualToString:@"https://bbs.et8.net/bbs/"]) {
//        return @"CCF";
//    } else if ([forumURL isEqualToString:@"https://dream4ever.org/"]) {
//        return @"DRL";
//    } else if ([forumURL isEqualToString:@"http://bbs.crsky.com/"]) {
//        return @"Crsky";
//    } else if ([forumURL isEqualToString:@""]) {
//        return @"CHH";
//    }

    return @"UnLockLimit";
}

- (void)saveCurrentForumURL:(NSString *)url {
    [_userDefaults setValue:url forKey:@"currentForumURL"];
}

- (void)clearCurrentForumURL {
    [_userDefaults removeObjectForKey:@"currentForumURL"];
}


@end
