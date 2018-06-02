//
//  ForumBrowserFactory.h
//
//  Created by 迪远 王 on 16/10/3.
//  Copyright © 2016年 andforce. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ForumConfigDelegate.h"
#import "ForumApiDelegate.h"
#import "ForumParserDelegate.h"

@class AFHTTPSessionManager;
@class BaseForumHtmlParser;


@interface ForumApiHelper : NSObject

+ (id <ForumApiDelegate>)forumApi:(NSString *)host;

+ (id <ForumConfigDelegate>)forumConfig:(NSString *)host;

@end
