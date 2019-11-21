//
//  Created by Diyuan Wang on 2019/11/21.
//  Copyright © 2019年 Diyuan Wang. All rights reserved.
//

#import "BBSApiHelper.h"

#import "Et8NetApi.h"
#import "DreamLandApi.h"
#import "ChiphellForumApi.h"
#import "FeiFanBBSApi.h"
#import "Et8NetConfig.h"
#import "DreamLandConfig.h"
#import "FeiFanConfig.h"
#import "ChiphellConfig.h"
#import "BBSLocalApi.h"
// Smartisan
#import "SmartisanForumApi.h"
#import "SmartisanConfig.h"

typedef id (^Runnable)(NSString *bundle, NSString *host);

#define CCF_HOST @"bbs.et8.net"
#define DRL_HOST @"dream4ever.org"
#define CRSKY_HOST @"bbs.crsky.com"
#define CHIPHELL_HOST @"www.chiphell.com"
#define SMARTISAN @"bbs.smartisan.com"


@implementation BBSApiHelper
+ (id <BBSApiDelegate>)forumApi:(NSString *)host {

    if ([host isEqualToString:CCF_HOST]) {

        Et8NetApi *ccfForumApi = [[Et8NetApi alloc] init];
        return ccfForumApi;

    } else if ([host isEqualToString:DRL_HOST]) {

        DreamLandApi *drlForumApi = [[DreamLandApi alloc] init];
        return drlForumApi;

    } else if ([host isEqualToString:CRSKY_HOST]) {

        FeiFanBBSApi *crskyForumApi = [[FeiFanBBSApi alloc] init];
        return crskyForumApi;

    } else if ([host isEqualToString:CHIPHELL_HOST]) {

        ChiphellForumApi *chhForumApi = [[ChiphellForumApi alloc] init];
        return chhForumApi;

    } else if ([host isEqualToString:SMARTISAN]) {
        SmartisanForumApi *tForumApi = [[SmartisanForumApi alloc] init];
        return tForumApi;
    }
    return nil;
}

+ (id <BBSConfigDelegate>)forumConfig:(NSString *)host {
    if ([host isEqualToString:CCF_HOST]) {

        Et8NetConfig *ccfForumApi = [[Et8NetConfig alloc] init];
        return ccfForumApi;

    } else if ([host isEqualToString:DRL_HOST]) {

        DreamLandConfig *drlForumApi = [[DreamLandConfig alloc] init];
        return drlForumApi;

    } else if ([host isEqualToString:CRSKY_HOST]) {

        FeiFanConfig *crskyForumApi = [[FeiFanConfig alloc] init];
        return crskyForumApi;

    } else if ([host isEqualToString:CHIPHELL_HOST]) {

        ChiphellConfig *chhForumApi = [[ChiphellConfig alloc] init];
        return chhForumApi;

    } else if ([host isEqualToString:SMARTISAN]) {
        SmartisanConfig *tForumConfig = [[SmartisanConfig alloc] init];
        return tForumConfig;
    }

    return nil;
}


+ (id <BBSConfigDelegate>)forumConfig {
    BBSLocalApi *localForumApi = [[BBSLocalApi alloc] init];
    NSString *bundleId = [localForumApi bundleIdentifier];
    NSString *host = localForumApi.currentForumHost;

    if ([bundleId isEqualToString:@"com.andforce.et8"] || [host isEqualToString:CCF_HOST]) {

        Et8NetConfig *ccfForumApi = [[Et8NetConfig alloc] init];
        return ccfForumApi;

    } else if ([bundleId isEqualToString:@"com.andforce.DRL"] || [host isEqualToString:DRL_HOST]) {

        DreamLandConfig *drlForumApi = [[DreamLandConfig alloc] init];
        return drlForumApi;

    } else if ([bundleId isEqualToString:@"com.andforce.Crsky"] || [host isEqualToString:CRSKY_HOST]) {

        FeiFanConfig *crskyForumApi = [[FeiFanConfig alloc] init];
        return crskyForumApi;

    } else if ([bundleId isEqualToString:@"com.andforce.CHH"] || [host isEqualToString:@"www.chiphell.com"] || [host isEqualToString:CHIPHELL_HOST]) {

        ChiphellConfig *chhForumApi = [[ChiphellConfig alloc] init];
        return chhForumApi;

    } else if ([host isEqualToString:SMARTISAN]) {
        SmartisanConfig *tForumConfig = [[SmartisanConfig alloc] init];
        return tForumConfig;
    }

    return nil;
}

+ (id <BBSApiDelegate>)forumApi {

    BBSLocalApi *localForumApi = [[BBSLocalApi alloc] init];
    NSString *bundleId = [localForumApi bundleIdentifier];
    NSString *host = localForumApi.currentForumHost;

    if ([bundleId isEqualToString:@"com.andforce.et8"] || [host isEqualToString:CCF_HOST]) {

        Et8NetApi *ccfForumApi = [[Et8NetApi alloc] init];
        return ccfForumApi;

    } else if ([bundleId isEqualToString:@"com.andforce.DRL"] || [host isEqualToString:DRL_HOST]) {

        DreamLandApi *drlForumApi = [[DreamLandApi alloc] init];
        return drlForumApi;

    } else if ([bundleId isEqualToString:@"com.andforce.Crsky"] || [host isEqualToString:CRSKY_HOST]) {

        FeiFanBBSApi *crskyForumApi = [[FeiFanBBSApi alloc] init];
        return crskyForumApi;

    } else if ([bundleId isEqualToString:@"com.andforce.CHH"] || [host isEqualToString:@"www.chiphell.com"] || [host isEqualToString:CHIPHELL_HOST]) {

        ChiphellForumApi *chhForumApi = [[ChiphellForumApi alloc] init];
        return chhForumApi;

    } else if ([host isEqualToString:SMARTISAN]) {
        SmartisanForumApi *tForumApi = [[SmartisanForumApi alloc] init];
        return tForumApi;
    }

    return nil;
}


@end
