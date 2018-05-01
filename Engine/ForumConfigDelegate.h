//
// Created by 迪远 王 on 2017/4/30.
// Copyright (c) 2017 andforce. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ForumCommonConfigDelegate.h"
#import "DiscuzConfigDelegate.h"
#import "PhpWindConfigDelegage.h"
#import "vBulletinConfigDelegate.h"

#define THREAD_PAGE [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"post_view" ofType:@"html"] encoding:NSUTF8StringEncoding error:nil]
#define THREAD_PAGE_NOTITLE [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"post_view_notitle" ofType:@"html"] encoding:NSUTF8StringEncoding error:nil]
#define POST_MESSAGE [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"post_message" ofType:@"html"] encoding:NSUTF8StringEncoding error:nil]
#define PRIVATE_MESSAGE [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"private_message" ofType:@"html"] encoding:NSUTF8StringEncoding error:nil]

@protocol ForumConfigDelegate <ForumCommonConfigDelegate, DiscuzConfigDelegate, PhpWindConfigDelegage, vBulletinConfigDelegate>

- (NSURL *)forumURL;

- (NSString *)archive;

// 附件相关
- (NSString *)newattachmentForThread:(int)threadId time:(NSString *)time postHash:(NSString *)postHash;

- (NSString *)newattachmentForForum:(int)forumId time:(NSString *)time postHash:(NSString *)postHash;

- (NSString *)newattachment;

// 搜索相关
- (NSString *)search;

- (NSString *)searchWithSearchId:(NSString *)searchId withPage:(int)page;

- (NSString *)searchThreadWithUserId:(NSString *)userId;

- (NSString *)searchMyThreadWithUserName:(NSString *)name;

// 收藏论坛
- (NSString *)favForumWithId:(NSString *)forumId;

- (NSString *)favForumWithIdParam:(NSString *)forumId;

- (NSString *)unfavForumWithId:(NSString *)forumId;

// 收藏主题
- (NSString *)favThreadWithIdPre:(NSString *)threadId;

- (NSString *)favThreadWithId:(NSString *)threadId;

- (NSString *)unFavorThreadWithId:(NSString *)threadId;

- (NSString *)listFavorThreads:(int)userId withPage:(int) page;

// FormDisplay
- (NSString *)forumDisplayWithId:(NSString *)forumId;

- (NSString *)forumDisplayWithId:(NSString *)forumId withPage:(int)page;

// 查看新帖
- (NSString *)searchNewThread:(int)page;

// 回复主题帖子
- (NSString *)replyWithThreadId:(int)threadId forForumId:(int)forumId replyPostId:(int)postId;

// 回复楼层，引用回复
- (NSString *)quoteReply:(int)fid threadId:(int)threadId postId:(int)postId;

// ShowThread
- (NSString *)showThreadWithThreadId:(NSString *)threadId withPage:(int)page;

- (NSString *)showThreadWithP:(NSString *)p;

// 复制
- (NSString *)copyThreadUrl:(NSString *) threadId withPostId:(NSString *)postId withPostCout:(int)postCount;

// 头像
- (NSString *)avatar:(NSString *)avatar;

- (NSString *)avatarBase;

- (NSString *)avatarNo;

// User Page
- (NSString *)memberWithUserId:(NSString *)userId;

// 准备发表帖子
- (NSString *)createNewThreadWithForumId:(NSString *)forumId;

// 发表新帖子
- (NSString *)enterCreateNewThreadWithForumId:(NSString *)forumId;

// UserCP
- (NSString *)favoriteForums;

// report
- (NSString *)report;

- (NSString *)reportWithPostId:(int)postId;

- (NSString *)loginControllerId;

@optional
- (NSString *) listUserThreads:(NSString *) userId withPage:(int) page;

@end