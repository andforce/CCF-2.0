//
//  TForumConfig.m
//  Forum
//
//  Created by 迪远 王 on 2018/4/29.
//  Copyright © 2018年 andforce. All rights reserved.
//

#import "TForumConfig.h"
#import "DeviceName.h"

@implementation TForumConfig{
    NSURL *_forumURL;
}

- (instancetype)init {
    self = [super init];
    _forumURL = [NSURL URLWithString:BBS_HOST];
    return self;
}

- (UIColor *)themeColor {
    return [[UIColor alloc] initWithRed:176.f / 255.f green:63.f / 255.f blue:61.f / 255.f alpha:1];;;
}

- (NSURL *)forumURL {
    return _forumURL;
}

- (NSString *)archive {
    return ARCHIVE;
}

- (NSString *)cookieUserIdKey {
    return @"dazE_2132_st_p";
}

- (NSString *)cookieExpTimeKey {
    return @"smart_b_user";
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
    NSDate *date = [NSDate date];
    NSInteger timeStamp = (NSInteger) [date timeIntervalSince1970];
    return [NSString stringWithFormat:SEARCH_NEW, page, (long) timeStamp];
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
    return @"TForumLoginWebViewController";
}

- (NSString *)listUserThreads:(NSString *)userId withPage:(int)page {
    return [NSString stringWithFormat:LIST_USER_THREAD, userId, page];
}

- (NSString *)signature {
    NSString *phoneName = [DeviceName deviceNameDetail];
    NSString *signature = [NSString stringWithFormat:@"\n\n发自 %@ 使用 iOS客户端", phoneName];
    return signature;
}

@end
