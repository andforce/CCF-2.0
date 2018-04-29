//
//  CrskyForumConfig.m
//  Forum
//
//  Created by 迪远 王 on 2017/7/29.
//  Copyright © 2017年 andforce. All rights reserved.
//

#import "CrskyForumConfig.h"
#import "DeviceName.h"

@implementation CrskyForumConfig {
    NSURL *_forumURL;
}

- (instancetype)init {
    self = [super init];
    _forumURL = [NSURL URLWithString:BBS_HOST];
    return self;
}

- (UIColor *)themeColor {
    return [[UIColor alloc] initWithRed:56.f / 255.f green:133.f / 255.f blue:233.f / 255.f alpha:1];;
}

- (NSURL *)forumURL {
    return _forumURL;
}

- (NSString *)archive {
    return ARCHIVE;
}

- (NSString *)cookieUserIdKey {
    return nil;
}

- (NSString *)cookieExpTimeKey {
    return @"217cd_ol_offset";
}


- (NSString *)search {
    return SEARCH;
}

- (NSString *)searchWithSearchId:(NSString *)searchId withPage:(int)page {
    return [NSString stringWithFormat:SEARCH_WITH_SEARCHID, searchId, page];
}


- (NSString *)favThreadWithIdPre:(NSString *)threadId {
    return [NSString stringWithFormat:READ, threadId];
}

- (NSString *)favThreadWithId:(NSString *)threadId {
    NSDate *date = [NSDate date];
    NSInteger timeStamp = (NSInteger) [date timeIntervalSince1970];
    return [NSString stringWithFormat:FAV_THREAD, (long) timeStamp, threadId];
}

- (NSString *)unFavorThreadWithId:(NSString *)threadId {
    return UNFAV;
}

- (NSString *)listFavorThreads:(int)userId withPage:(int)page {
    return [NSString stringWithFormat:LST_FAV, userId];
}

- (NSString *)forumDisplayWithId:(NSString *)forumId withPage:(int)page {
    return [NSString stringWithFormat:FORUM_DIS, forumId, page];
}

- (NSString *)searchNewThread:(int)page {
    return SEARCH_NEW;
}

- (NSString *)replyWithThreadId:(int)threadId forForumId:(int)forumId replyPostId:(int)postId {
    return REPLY;
}

- (NSString *)quoteReply:(int)fid threadId:(int)threadId postId:(int)postId {
    return [NSString stringWithFormat:QUOTE_REPLY, fid, threadId, postId];
}

- (NSString *)showThreadWithThreadId:(NSString *)threadId withPage:(int)page {
    return [NSString stringWithFormat:SHOW_THREAD, threadId, page];
}

- (NSString *)showThreadWithP:(NSString *)p {
    return nil;
}

- (NSString *)copyThreadUrl:(NSString *)threadId withPostId:(NSString *)postId withPostCout:(int)postCount {
    NSString *fixPostId = postId;
    if ([fixPostId isEqualToString:@"0"]) {
        fixPostId = @"tpc";
    }
    return [NSString stringWithFormat:COPY_URL, threadId, fixPostId];
}


- (NSString *)avatar:(NSString *)avatar {
    return avatar;
}

- (NSString *)avatarBase {
    return @"";
}

- (NSString *)avatarNo {
    return @"/no_avatar.gif";
}

- (NSString *)memberWithUserId:(NSString *)userId {
    return [NSString stringWithFormat:MEMBER, userId];
}

- (NSString *)createNewThreadWithForumId:(NSString *)forumId {
    return REPLY;
}


- (NSString *)privateWithType:(int)type withPage:(int)page {
    //  0 receive box
    if (type == 0) {
        return [NSString stringWithFormat:RECEIVE_BOX, page];
    } else {
        //  -1 send box
        return [NSString stringWithFormat:SEND_BOX, page];
    }
}

- (NSString *)deletePrivateWithType:(int)type {
    if (type == 0) {
        return DEL_RECEIVE_BOX;
    } else {
        return DEL_SEND_BOX;
    }
}

- (NSString *)privateShowWithMessageId:(int)messageId withType:(int)type {
    // 0 群发公共消息 1 普通收件 2 发给别人的消息
    if (type == 0) {
        return [NSString stringWithFormat:READ_PUBLIC_MESSAGE, messageId];
    } else if (type == 1) {
        return [NSString stringWithFormat:READ_PRI_MESSAGE, messageId];
    } else if (type == 2) {
        return [NSString stringWithFormat:READ_SEND_PRI_MSG, messageId];
    } else {
        return nil;
    }
}

- (NSString *)privateReplyWithMessageIdPre:(int)messageId {
    return [NSString stringWithFormat:REPLY_MSG_PRE, messageId];
}

- (NSString *)privateReplyWithMessage {
    return MESSAGE;
}

- (NSString *)privateNewPre {
    return WRITE_MESSAGE;
}

- (NSString *)loginControllerId {
    return @"CrskyLoginViewController";
}

- (NSString *)listUserThreads:(NSString *)userId withPage:(int)page {
    return [NSString stringWithFormat:LIST_USER_THREAD, userId, page];
}

- (NSString *)signature {
    NSString *phoneName = [DeviceName deviceNameDetail];
    NSString *signature = [NSString stringWithFormat:@"\n\n发自 %@ 使用 霏凡客户端", phoneName];
    return signature;
}

//----------------

- (NSString *)enterCreateNewThreadWithForumId:(NSString *)forumId {
    return nil;
}


- (NSString *)login {
    return nil;
}

- (NSString *)loginvCode {
    return nil;
}

- (NSString *)forumDisplayWithId:(NSString *)forumId {
    return nil;
}

- (NSString *)favoriteForums {
    return nil;
}

- (NSString *)report {
    return nil;
}

- (NSString *)reportWithPostId:(int)postId {
    return nil;
}

- (NSString *)searchThreadWithUserId:(NSString *)userId {
    return nil;
}

- (NSString *)searchMyThreadWithUserName:(NSString *)name {
    return nil;
}

- (NSString *)favForumWithId:(NSString *)forumId {
    return nil;
}

- (NSString *)favForumWithIdParam:(NSString *)forumId {
    return nil;
}

- (NSString *)unfavForumWithId:(NSString *)forumId {
    return nil;
}

- (NSString *)newattachmentForThread:(int)threadId time:(NSString *)time postHash:(NSString *)postHash {
    return nil;
}

- (NSString *)newattachmentForForum:(int)forumId time:(NSString *)time postHash:(NSString *)postHash {
    return nil;
}

- (NSString *)newattachment {
    return nil;
}

@end
