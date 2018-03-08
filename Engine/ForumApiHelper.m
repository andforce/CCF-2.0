//
//  ForumBrowserFactory.m
//
//  Created by 迪远 王 on 16/10/3.
//  Copyright © 2016年 andforce. All rights reserved.
//

#import "ForumApiHelper.h"

#import "CCFForumApi.h"
#import "DRLForumApi.h"
#import "CHHForumApi.h"
#import "CrskyForumApi.h"
#import "CCFForumConfig.h"
#import "DRLForumConfig.h"
#import "CrskyForumConfig.h"
#import "CHHForumConfig.h"
#import "LocalForumApi.h"

typedef id (^Runnable)(NSString *bundle, NSString *host);

#define CCF_HOST @"bbs.et8.net"
#define DRL_HOST @"dream4ever.org"
#define CRSKY_HOST @"bbs .crsky.com"
#define CHIPHELL_HOST @"chiphell.com"

@implementation ForumApiHelper
+ (id <ForumBrowserDelegate>)forumApi:(NSString *)host {

    if ([host isEqualToString:CCF_HOST]){

        CCFForumApi * ccfForumApi = [[CCFForumApi alloc] init];
        return ccfForumApi;

    } else if ([host isEqualToString:DRL_HOST]){

        DRLForumApi * drlForumApi = [[DRLForumApi alloc] init];
        return drlForumApi;

    } else if ([host isEqualToString:CRSKY_HOST]){

        CrskyForumApi *crskyForumApi = [[CrskyForumApi alloc] init];
        return crskyForumApi;

    } else if([host isEqualToString:CHIPHELL_HOST]){

        CHHForumApi * chhForumApi = [[CHHForumApi alloc] init];
        return chhForumApi;

    }
    return nil;
}

+ (id <ForumConfigDelegate>)forumConfig:(NSString *)host {
    if ([host isEqualToString:CCF_HOST]){

        CCFForumConfig * ccfForumApi = [[CCFForumConfig alloc] init];
        return ccfForumApi;

    } else if ([host isEqualToString:DRL_HOST]){

        DRLForumConfig * drlForumApi = [[DRLForumConfig alloc] init];
        return drlForumApi;

    } else if ([host isEqualToString:CRSKY_HOST]){

        CrskyForumConfig *crskyForumApi = [[CrskyForumConfig alloc] init];
        return crskyForumApi;

    } else if([host isEqualToString:CHIPHELL_HOST]){

        CHHForumConfig * chhForumApi = [[CHHForumConfig alloc] init];
        return chhForumApi;

    }

    return nil;
}


+ (id <ForumConfigDelegate>)forumConfig {
    LocalForumApi *localForumApi = [[LocalForumApi alloc] init];
    NSString *bundleId = [localForumApi bundleIdentifier];
    NSString * host = localForumApi.currentForumHost;

    if ([bundleId isEqualToString:@"com.andforce.et8"] || [host isEqualToString:CCF_HOST]){

        CCFForumConfig * ccfForumApi = [[CCFForumConfig alloc] init];
        return ccfForumApi;

    } else if ([bundleId isEqualToString:@"com.andforce.DRL"] || [host isEqualToString:DRL_HOST]){

        DRLForumConfig * drlForumApi = [[DRLForumConfig alloc] init];
        return drlForumApi;

    } else if ([bundleId isEqualToString:@"com.andforce.Crsky"] || [host isEqualToString:CRSKY_HOST]){

        CrskyForumConfig *crskyForumApi = [[CrskyForumConfig alloc] init];
        return crskyForumApi;

    } else if([bundleId isEqualToString:@"com.andforce.CHH"] || [host isEqualToString:@"www.chiphell.com"] || [host isEqualToString:CHIPHELL_HOST]){

        CHHForumConfig * chhForumApi = [[CHHForumConfig alloc] init];
        return chhForumApi;

    }
    return nil;
}

+ (id <ForumBrowserDelegate>)forumApi {

    LocalForumApi *localForumApi = [[LocalForumApi alloc] init];
    NSString *bundleId = [localForumApi bundleIdentifier];
    NSString * host = localForumApi.currentForumHost;

    if ([bundleId isEqualToString:@"com.andforce.et8"] || [host isEqualToString:CCF_HOST]){

        CCFForumApi * ccfForumApi = [[CCFForumApi alloc] init];
        return ccfForumApi;

    } else if ([bundleId isEqualToString:@"com.andforce.DRL"] || [host isEqualToString:DRL_HOST]){

        DRLForumApi * drlForumApi = [[DRLForumApi alloc] init];
        return drlForumApi;

    } else if ([bundleId isEqualToString:@"com.andforce.Crsky"] || [host isEqualToString:CRSKY_HOST]){

        CrskyForumApi *crskyForumApi = [[CrskyForumApi alloc] init];
        return crskyForumApi;

    } else if([bundleId isEqualToString:@"com.andforce.CHH"] || [host isEqualToString:@"www.chiphell.com"] || [host isEqualToString:CHIPHELL_HOST]){

        CHHForumApi * chhForumApi = [[CHHForumApi alloc] init];
        return chhForumApi;

    }
    return nil;
}


@end
