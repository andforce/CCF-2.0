//
// Created by 迪远 王 on 2018/6/2.
// Copyright (c) 2018 andforce. All rights reserved.
//

#import "vBulletinCommonConfig.h"
#import "DeviceName.h"


@implementation vBulletinCommonConfig

#pragma mark ForumURLCommonConfig

- (NSURL *)forumURL {
    return _forumURL;
}

- (NSString *)archive {
    return [_forumURL.absoluteString stringByAppendingString:@"archive/index.php"];
}

- (NSString *)newattachmentForThread:(int)threadId time:(NSString *)time postHash:(NSString *)postHash {
    return [NSString stringWithFormat:@"%@newattachment.php?t=%d&poststarttime=%@&posthash=%@", _forumURL.absoluteString, threadId, time, postHash];
}

- (NSString *)newattachmentForForum:(int)forumId time:(NSString *)time postHash:(NSString *)postHash {
    return [NSString stringWithFormat:@"%@newattachment.php?f=%d&poststarttime=%@&posthash=%@", _forumURL.absoluteString, forumId, time, postHash];
}

- (NSString *)newattachment {
    return [NSString stringWithFormat:@"%@newattachment.php", _forumURL.absoluteString];
}

- (NSString *)search {
    return [_forumURL.absoluteString stringByAppendingString:@"search.php"];
}

- (NSString *)searchWithSearchId:(NSString *)searchId withPage:(int)page {
    return [NSString stringWithFormat:@"%@search.php?searchid=%@&pp=30&page=%d", _forumURL.absoluteString, searchId, page];
}

- (NSString *)searchThreadWithUserId:(NSString *)userId {
    return [NSString stringWithFormat:@"%@search.php?do=finduser&u=%@&starteronly=1", _forumURL.absoluteString, userId];
}

- (NSString *)searchMyThreadWithUserName:(NSString *)name {
    return [NSString stringWithFormat:@"%@search.php?do=process&showposts=0&starteronly=1&exactname=1&searchuser=%@", _forumURL.absoluteString, name];
}

- (NSString *)favForumWithId:(NSString *)forumId {
    return [NSString stringWithFormat:@"%@subscription.php?do=addsubscription&f=%@", _forumURL.absoluteString, forumId];
}

- (NSString *)favForumWithIdParam:(NSString *)forumId {
    return [NSString stringWithFormat:@"%@subscription.php?do=doaddsubscription&forumid=%@", _forumURL.absoluteString, forumId];
}

- (NSString *)unfavForumWithId:(NSString *)forumId {
    return [NSString stringWithFormat:@"%@subscription.php?do=removesubscription&f=%@", _forumURL.absoluteString, forumId];
}

- (NSString *)favThreadWithIdPre:(NSString *)threadId {
    return [NSString stringWithFormat:@"%@subscription.php?do=addsubscription&t=%@", _forumURL.absoluteString, threadId];
}

- (NSString *)favThreadWithId:(NSString *)threadId {
    return [NSString stringWithFormat:@"%@subscription.php?do=doaddsubscription&threadid=%@", _forumURL.absoluteString, threadId];
}

- (NSString *)unFavorThreadWithId:(NSString *)threadId {
    return [NSString stringWithFormat:@"%@subscription.php?do=removesubscription&t=%@", _forumURL.absoluteString, threadId];
}

- (NSString *)listFavorThreads:(int)userId withPage:(int)page {
    return [NSString stringWithFormat:@"%@subscription.php?do=viewsubscription&pp=35&folderid=0&sort=lastpost&order=desc&page=%d", _forumURL.absoluteString, page];
}

- (NSString *)forumDisplayWithId:(NSString *)forumId {
    return [NSString stringWithFormat:@"%@forumdisplay.php?f=%@", _forumURL.absoluteString, forumId];
}

- (NSString *)forumDisplayWithId:(NSString *)forumId withPage:(int)page {
    return [NSString stringWithFormat:@"%@forumdisplay.php?f=%@&order=desc&page=%d", _forumURL.absoluteString, forumId, page];
}

- (NSString *)searchNewThread:(int)page {
    return [NSString stringWithFormat:@"%@search.php?do=getnew", _forumURL.absoluteString];
}

- (NSString *)replyWithThreadId:(int)threadId forForumId:(int)forumId replyPostId:(int)postId {
    return [NSString stringWithFormat:@"%@newreply.php?do=postreply&t=%d", _forumURL.absoluteString, threadId];
}

- (NSString *)quoteReply:(int)fid threadId:(int)threadId postId:(int)postId {
    return [NSString stringWithFormat:@"%@newreply.php?do=newreply&p=%d", _forumURL.absoluteString, postId];
}

- (NSString *)showThreadWithThreadId:(NSString *)threadId withPage:(int)page {
    return [NSString stringWithFormat:@"%@showthread.php?t=%@&page=%d", _forumURL.absoluteString, threadId, page];
}

- (NSString *)showThreadWithP:(NSString *)p {
    return [NSString stringWithFormat:@"%@showthread.php?p=%@", _forumURL.absoluteString, p];
}

- (NSString *)copyThreadUrl:(NSString *)threadId withPostId:(NSString *)postId withPostCout:(int)postCount {
    return [NSString stringWithFormat:@"%@showpost.php?p=%@&postcount=%d", _forumURL.absoluteString, postId, postCount];
}

- (NSString *)avatar:(NSString *)avatar {
    return [NSString stringWithFormat:@"%@customavatars%@", _forumURL.absoluteString, avatar];
}

- (NSString *)avatarBase {
    return [_forumURL.absoluteString stringByAppendingString:@"customavatars"];
}

- (NSString *)avatarNo {
    return [[self avatarBase] stringByAppendingString:@"/no_avatar.gif"];
}

- (NSString *)memberWithUserId:(NSString *)userId {
    return [NSString stringWithFormat:@"%@member.php?u=%@", _forumURL.absoluteString, userId];
}

- (NSString *)createNewThreadWithForumId:(NSString *)forumId {
    return [NSString stringWithFormat:@"%@newthread.php?do=newthread&f=%@", _forumURL.absoluteString, forumId];
}

- (NSString *)enterCreateNewThreadWithForumId:(NSString *)forumId {
    return [NSString stringWithFormat:@"%@newthread.php?do=newthread&f=%@", _forumURL.absoluteString, forumId];
}

- (NSString *)favoriteForums {
    return [NSString stringWithFormat:@"%@usercp.php", _forumURL.absoluteString];
}

- (NSString *)report {
    return [NSString stringWithFormat:@"%@report.php?do=sendemail", _forumURL.absoluteString];
}

- (NSString *)reportWithPostId:(int)postId {
    return [NSString stringWithFormat:@"%@report.php?p=%d", _forumURL.absoluteString, postId];
}

- (NSString *)loginControllerId {
    return @"LoginForum";
}

#pragma mark vBulletinConfigDelegate
- (NSString *)login {
    return [NSString stringWithFormat:@"%@login.php?do=login", _forumURL.absoluteString];
}

- (NSString *)loginvCode {
    return [NSString stringWithFormat:@"%@login.php?do=vcode", _forumURL.absoluteString];
}


@end
