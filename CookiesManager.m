//
//  CookieManager.m
//  iBeeboPro
//
//  Created by Diyuan Wang on 2019/11/21.
//  Copyright © 2019年 Diyuan Wang. All rights reserved.
//

#import "CookiesManager.h"
#include "iconv.h"

@implementation CookiesManager

+ (void)saveCookies {
    NSArray<NSHTTPCookie *> *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:cookies];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:@"cookies"];
}

+ (NSString *)cookiesString {
    NSData *cookiesdata = [[NSUserDefaults standardUserDefaults] objectForKey:@"cookies"];

    NSString *cookiesString = @"";

    if ([cookiesdata length]) {


        NSArray *cookies = [NSKeyedUnarchiver unarchiveObjectWithData:cookiesdata];
        NSHTTPCookie *cookie;
        int i = 0;
        for (cookie in cookies) {
            if (i == cookies.count - 1) {
                cookiesString = [cookiesString stringByAppendingString:[NSString stringWithFormat:@"%@=%@", cookie.name, cookie.value]];

            } else {
                cookiesString = [cookiesString stringByAppendingString:[NSString stringWithFormat:@"%@=%@; ", cookie.name, cookie.value]];
            }
            [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
        }
    }

    return cookiesString;
}

+ (NSArray<NSHTTPCookie *> *)cookiesArray {
    NSData *cookiesData = [[NSUserDefaults standardUserDefaults] objectForKey:@"cookies"];

    if ([cookiesData length]) {
        NSArray *cookies = [NSKeyedUnarchiver unarchiveObjectWithData:cookiesData];
        return cookies;
    } else {
        return nil;
    }
}

@end
