//
//
//
//  Created by Diyuan Wang on 2019/11/21.
//  Copyright © 2019年 Diyuan Wang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BBSConfigDelegate.h"
#import "BBSApiDelegate.h"
#import "BBSParserDelegate.h"

@class AFHTTPSessionManager;
@class BaseForumHtmlParser;


@interface BBSApiHelper : NSObject

+ (id <BBSApiDelegate>)forumApi:(NSString *)host;

+ (id <BBSConfigDelegate>)forumConfig:(NSString *)host;

@end
