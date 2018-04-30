//
// Created by 迪远 王 on 2018/4/30.
// Copyright (c) 2018 andforce. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Message;

@protocol ForumCommonDelegate <NSObject>

// 获取所有的论坛列表
- (void)listAllForums:(HandlerWithBool)handler;

// 发表新帖子时候，支持的主题分类
- (void)listThreadCategory:(NSString *)fid handler:(HandlerWithBool)handler;

// 发表一个新的帖子
- (void)createNewThreadWithCategory:(NSString *)category categoryIndex:(int)index withTitle:(NSString *)title andMessage:(NSString *)message withImages:(NSArray *)images inPage:(ViewForumPage *) page handler:(HandlerWithBool)handler;

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

@end