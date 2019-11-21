//
// Created by Diyuan Wang on 2019/11/12
// Copyright (c) 2018 andforce. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Forum.h"
#import "ViewThreadPage.h"
#import "ViewForumPage.h"
#import "ViewSearchForumPage.h"
#import "ViewMessagePage.h"
#import "UserProfile.h"

@protocol BBSBaseParserDelegate <NSObject>

// 页面相关
- (ViewThreadPage *)parseShowThreadWithHtml:(NSString *)html;

- (ViewForumPage *)parseThreadListFromHtml:(NSString *)html withThread:(int)threadId andContainsTop:(BOOL)containTop;

- (ViewForumPage *)parseFavorThreadListFromHtml:(NSString *)html;

- (ViewSearchForumPage *)parseSearchPageFromHtml:(NSString *)html;

- (ViewSearchForumPage *)parseZhanNeiSearchPageFromHtml:(NSString *)html type:(int)type;

- (ViewMessagePage *)parsePrivateMessageContent:(NSString *)html avatarBase:(NSString *)avatarBase noavatar:(NSString *)avatarNO;

- (UserProfile *)parserProfile:(NSString *)html userId:(NSString *)userId;

- (NSArray<Forum *> *)parserForums:(NSString *)html forumHost:(NSString *)host;

- (NSMutableArray<Forum *> *)parseFavForumFromHtml:(NSString *)html;

// 动作相关
- (PageNumber *)parserPageNumber:(NSString *)html;

- (NSString *)parseUserAvatar:(NSString *)html userId:(NSString *)userId;

- (NSString *)parseListMyThreadSearchId:(NSString *)html;

- (NSString *)parseErrorMessage:(NSString *)html;

- (NSString *)parseSecurityToken:(NSString *)html;

- (NSString *)parsePostHash:(NSString *)html;

@end