//
// Created by 迪远 王 on 2018/4/30.
// Copyright (c) 2018 andforce. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Message;
@class ForumWebViewController;
@class ViewThreadPage;

typedef void (^EnterNewThreadCallBack)(NSString * responseHtml, NSString *post_hash, NSString *forum_hash, NSString *posttime,
        NSString *seccodehash, NSString *seccodeverify, NSDictionary *typeidList);

@protocol ForumApiBaseDelegate <NSObject>

// 获取所有的论坛列表
- (void)listAllForums:(HandlerWithBool)handler;

// 收藏这个论坛
- (void)favoriteForumWithId:(NSString *)forumId handler:(HandlerWithBool)handler;

// 取消收藏论坛
- (void)unFavouriteForumWithId:(NSString *)forumId handler:(HandlerWithBool)handler;

// 收藏一个主题帖子
- (void)favoriteThreadWithId:(NSString *)threadPostId handler:(HandlerWithBool)handler;

// 取消收藏一个主题帖子
- (void)unFavoriteThreadWithId:(NSString *)threadPostId handler:(HandlerWithBool)handler;

// 获取收藏的论坛板块
- (void)listFavoriteForums:(HandlerWithBool)handler;

// 获取收藏的主题帖子
- (void)listFavoriteThreads:(int)userId withPage:(int) page handler:(HandlerWithBool)handler;

// 显示我发表的主题
- (void)listMyAllThreadsWithPage:(int)page handler:(HandlerWithBool)handler;

// 显示用户发表的主题
- (void)listAllUserThreads:(int)userId withPage:(int)page handler:(HandlerWithBool)handler;

// 显示主题帖子和所有回帖
- (void)showThreadWithId:(int)threadId andPage:(int)page handler:(HandlerWithBool)handler;

// 显示板块，子论坛和帖子列表
- (void)forumDisplayWithId:(int)forumId andPage:(int)page handler:(HandlerWithBool)handler;

// 根据ID 获取头像
- (void)getAvatarWithUserId:(NSString *)userId handler:(HandlerWithBool)handler;

// 显示用户信息页面
- (void)showProfileWithUserId:(NSString *)userId handler:(HandlerWithBool)handler;

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

- (void)enterCreateThreadPageFetchInfo:(int)forumId :(EnterNewThreadCallBack)callback;

@end