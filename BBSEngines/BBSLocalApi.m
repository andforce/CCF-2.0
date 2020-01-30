//
// Created by Diyuan Wang on 2019/11/12
// Copyright (c) 2017 None. All rights reserved.
//

#import <CloudKit/CloudKit.h>
#import "BBSLocalApi.h"
#import "BBSUser.h"
#import "BBSConfigDelegate.h"
#import "BBSApiHelper.h"
#import "AppDelegate.h"
#import "WorkedBBS.h"
#import "HaveWorkedBBS.h"


@implementation BBSLocalApi {
    NSUserDefaults *_userDefaults;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _userDefaults = [NSUserDefaults standardUserDefaults];
    }

    return self;
}

- (BBSUser *)getLoginUserCrsky {

    NSArray<NSHTTPCookie *> *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
    if (cookies.count == 0) {
        return nil;
    }

    id <BBSConfigDelegate> forumConfig = [BBSApiHelper forumConfig:@"crskybbs.org"];

    BBSUser *user = [[BBSUser alloc] init];
    user.userName = [self userName:@"crskybbs.org"];
    if (user.userName == nil || [user.userName isEqualToString:@""]) {
        //[self logout];
        return nil;
    }
    user.userID = [self userId:@"crskybbs.org"];

    for (int i = 0; i < cookies.count; i++) {
        NSHTTPCookie *cookie = cookies[(NSUInteger) i];

        if ([cookie.name isEqualToString:forumConfig.cookieExpTimeKey]) {
            user.expireTime = cookie.expiresDate;
        }
    }
    return user;
}

- (BBSUser *)getLoginUserSmartisan {

    NSArray<NSHTTPCookie *> *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
    if (cookies.count == 0) {
        return nil;
    }

    id <BBSConfigDelegate> forumConfig = [BBSApiHelper forumConfig:@"bbs.smartisan.com"];

    BBSUser *user = [[BBSUser alloc] init];
    user.userName = [self userName:@"bbs.smartisan.com"];
    if (user.userName == nil || [user.userName isEqualToString:@""]) {
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

- (BBSUser *)getLoginUser:(NSString *)host {
    NSArray<NSHTTPCookie *> *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
    if (cookies.count == 0) {
        return nil;
    }
    BBSLocalApi *localForumApi = [[BBSLocalApi alloc] init];
    id <BBSConfigDelegate> forumConfig = [BBSApiHelper forumConfig:host];

    NSString *bundleId = [localForumApi bundleIdentifier];

    if ([host isEqualToString:@"crskybbs.org"]) {
        return [self getLoginUserCrsky];
    } else if ([host isEqualToString:@"bbs.smartisan.com"]) {
        return [self getLoginUserSmartisan];
    } else {
        BBSUser *user = [[BBSUser alloc] init];
        user.userName = [self userName:host];
        if (user.userName == nil || [user.userName isEqualToString:@""]) {
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

    BBSUser *user = [self getLoginUser:host];
    if (user == nil) {
        return NO;
    }

    if (user.userName == nil || user.userID == nil || user.expireTime == nil) {
        return NO;
    }
    if ([user.userName isEqualToString:@""] || [user.userID isEqualToString:@""] || [user.expireTime compare:[NSDate date]] == NSOrderedAscending) {
        return NO;
    }
    return YES;
}

- (BOOL)isHaveLoginForum {
    // 判断是否登录
    NSArray *fs = [self supportForums];
    int size = (int) fs.count;
    for (int i = 0; i < size; ++i) {
        WorkedBBS *forums = fs[(NSUInteger) i];
        NSURL *url = [NSURL URLWithString:forums.url];
        if ([self isHaveLogin:url.host]) {
            return YES;
        }
    }
    return NO;
}

- (void)deleteLoginUser:(BBSUser *)loginUser {
    NSString *uid = [self.currentForumHost stringByAppendingString:@"-UserId"];
    if (uid != nil) {
        [_userDefaults setValue:@"" forKey:uid];
    }

    NSString *name = [self.currentForumHost stringByAppendingString:@"-UserName"];

    if (name != nil) {
        [_userDefaults setValue:@"" forKey:name];
    }
}

- (void)logout {

    BBSLocalApi *localForumApi = [[BBSLocalApi alloc] init];
    id <BBSConfigDelegate> forumConfig = [BBSApiHelper forumConfig:localForumApi.currentForumHost];

    [self clearCookie];

    NSURL *url = forumConfig.forumURL;
    if (url) {
        NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:url];
        for (int i = 0; i < [cookies count]; i++) {
            NSHTTPCookie *cookie = (NSHTTPCookie *) cookies[(NSUInteger) i];
            [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
        }
    }

    BBSUser *user = [localForumApi getLoginUser:localForumApi.currentForumHost];
    [self deleteLoginUser:user];
}

- (void)logout:(NSString *)forumUrl {

    NSURL *forumURL = [NSURL URLWithString:forumUrl];

    BBSLocalApi *localForumApi = [[BBSLocalApi alloc] init];
    id <BBSConfigDelegate> forumConfig = [BBSApiHelper forumConfig:forumURL.host];

    [self clearCookie:forumURL.host];

    //NSURL *url = forumConfig.forumURL;
    if (forumURL) {
        NSArray *cookiesArray = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
        for (NSHTTPCookie *cookie in cookiesArray) {
            [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
        }

        NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:forumURL];
        for (int i = 0; i < [cookies count]; i++) {
            NSHTTPCookie *cookie = (NSHTTPCookie *) cookies[(NSUInteger) i];
            [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
        }
    }

    BBSUser *user = [localForumApi getLoginUser:forumURL.host];
    [self deleteLoginUser:user];
}


- (NSString *)currentForumHost {
    NSString *urlStr = [self currentForumURL];
    NSURL *url = [NSURL URLWithString:urlStr];
    return url.host;
}

- (NSArray<WorkedBBS *> *)supportForums {
    NSData *data = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"bbs_have_support" ofType:@"json"]];

    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:(NSJSONReadingOptions) kNilOptions error:nil];

    HaveWorkedBBS *supportForums = [HaveWorkedBBS modelObjectWithDictionary:dictionary];
    return supportForums.forums;
}

- (NSArray<WorkedBBS *> *)loginedSupportForums {

    NSArray *support = [self supportForums];

    NSMutableArray *result = [NSMutableArray array];

    for (WorkedBBS *forums in support) {
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

- (NSArray<NSHTTPCookie *> *)loadCookie {
    NSData *cookiesData = [_userDefaults objectForKey:[[self currentForumHost] stringByAppendingString:@"-Cookies"]];

    if ([cookiesData length]) {
        NSArray<NSHTTPCookie *> *cookies = [NSKeyedUnarchiver unarchiveObjectWithData:cookiesData];

        NSHTTPCookie *cookie;
        for (cookie in cookies) {
            [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
        }

        //NSString *result = [cookies componentsJoinedByString:@"|"];//分隔符

        return cookies;
    }

    return nil;
}

- (NSString *)loadCookieString {

    NSArray<NSHTTPCookie *> *cookies = [self loadCookie];
    NSMutableArray<NSString *> *cookieStrings = [NSMutableArray array];
    for (NSHTTPCookie *cookie in cookies) {
        [cookieStrings addObject:[NSString stringWithFormat:@"%@=%@", cookie.name, cookie.value]];
    }
    NSString *result = [cookies componentsJoinedByString:@"; "];
    return result;
}

- (void)saveCookie {
    NSArray<NSHTTPCookie *> *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:cookies];
    NSString *currentHost = [self currentForumHost];
    [_userDefaults setObject:data forKey:[currentHost stringByAppendingString:@"-Cookies"]];
}

- (void)saveCookiesForResponse:(NSHTTPURLResponse *)response {
    NSArray<NSHTTPCookie *> * cookies = [NSHTTPCookie cookiesWithResponseHeaderFields:[response allHeaderFields] forURL:response.URL];
    for (NSHTTPCookie *cookie in cookies) {
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
    }
}

- (void)clearCookie {
    [_userDefaults removeObjectForKey:[[self currentForumHost] stringByAppendingString:@"-Cookies"]];
}

- (void)clearCookie:(NSString *)host {
    [_userDefaults removeObjectForKey:[host stringByAppendingString:@"-Cookies"]];
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
    NSString *forumUrl = [_userDefaults valueForKey:@"currentForumURL"];
    return forumUrl;
}

- (NSString *)currentProductID {
    return @"com.andforce.fourms.001";
}

- (void)saveCurrentForumURL:(NSString *)url {
    [_userDefaults setValue:url forKey:@"currentForumURL"];
}

- (void)clearCurrentForumURL {
    [_userDefaults removeObjectForKey:@"currentForumURL"];
}


@end
