//
//  ForumApi.h
//
//  Created by 迪远 王 on 16/10/2.
//  Copyright © 2016年 andforce. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LoginUser.h"
#import "ViewForumPage.h"
#import "ViewSearchForumPage.h"
#import "ForumConfigDelegate.h"
#import "Forum.h"
#import "vBulletinDelegate.h"
#import "DiscuzDelegate.h"
#import "PhpWindDelegate.h"
#import "ForumCommonDelegate.h"

@class ViewThreadPage;
@class ViewMessagePage;
@class Message;
@class ForumWebViewController;

typedef void (^HandlerWithBool)(BOOL isSuccess, id message);

typedef void (^UserInfoHandler)(BOOL isSuccess, id userName, id userId);

@protocol ForumBrowserDelegate <ForumCommonDelegate, vBulletinDelegate, DiscuzDelegate, PhpWindDelegate>

// 引用回复楼层
- (void)replyWithMessage:(NSString *)message withImages:(NSArray *)images toPostId:(NSString *)postId thread:(ViewThreadPage *)threadPage isQoute:(BOOL)quote handler:(HandlerWithBool)handler;

// 搜索论坛
// 0.标题 1. 内容 2. 用户
- (void)searchWithKeyWord:(NSString *)keyWord forType:(int)type handler:(HandlerWithBool)handler;

// 查看新帖
- (void)listNewThreadWithPage:(int)page handler:(HandlerWithBool)handler;

- (void)listSearchResultWithSearchId:(NSString *)searchId keyWord:(NSString *)keyWord andPage:(int)page type:(int)type  handler:(HandlerWithBool)handler;


// 举报违规帖子
- (void)reportThreadPost:(int)postId andMessage:(NSString *)message handler:(HandlerWithBool)handler;

- (BOOL) openUrlByClient:(ForumWebViewController *) controller request:(NSURLRequest *)request;

@end
