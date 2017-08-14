//
//  CrskyForumConfig.m
//  Forum
//
//  Created by 迪远 王 on 2017/7/29.
//  Copyright © 2017年 andforce. All rights reserved.
//

#import "CrskyForumConfig.h"

@implementation CrskyForumConfig{
    NSURL *_forumURL;
}

- (instancetype)init {
    self = [super init];
    _forumURL = [NSURL URLWithString:@"http://bbs.crsky.com/"];
    return self;
}

- (UIColor *)themeColor {
    return [[UIColor alloc] initWithRed:101.f/255.f green:96.f/255.f blue:65.f/255.f alpha:1];;
}

- (NSURL *)forumURL {
    return _forumURL;
}

- (NSString *)archive {
    return @"http://bbs.crsky.com/simple/";
}

- (NSString *)cookieUserIdKey {
    return nil;
}

- (NSString *)cookieExpTimeKey {
    return @"217cd_ol_offset";
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

- (NSString *)search {
    return @"http://bbs.crsky.com/search.php?";
}

- (NSString *)searchWithSearchId:(NSString *)searchId withPage:(int)page {
    return [NSString stringWithFormat:@"http://bbs.crsky.com/search.php?step=2&sid=%@&seekfid=all&page=%d", searchId, page];
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

- (NSString *)favThreadWithIdPre:(NSString *)threadId {
    return nil;
}

- (NSString *)favThreadWithId:(NSString *)threadId {
    return nil;
}

- (NSString *)unFavorThreadWithId:(NSString *)threadId {
    return nil;
}

- (NSString *)listFavorThreads:(int)userId withPage:(int)page {
    return [NSString stringWithFormat:@"http://bbs.crsky.com/u.php?action=favor&uid=%d", userId];
}

- (NSString *)forumDisplayWithId:(NSString *)forumId {
    return nil;
}

- (NSString *)forumDisplayWithId:(NSString *)forumId withPage:(int)page {
    return [NSString stringWithFormat:@"http://bbs.crsky.com/thread.php?fid=%@&page=%d", forumId, page];
}

- (NSString *)searchNewThread:(int)page {
    return @"http://bbs.crsky.com/search.php?sch_time=all&orderway=lastpost&asc=desc&newatc=1";
}

- (NSString *)replyWithThreadId:(int)threadId forForumId:(int)forumId replyPostId:(int)postId {
    return @"http://bbs.crsky.com/post.php?";
}

- (NSString *)showThreadWithThreadId:(NSString *)threadId withPage:(int)page {
    return [NSString stringWithFormat:@"http://bbs.crsky.com/read.php?tid=%@&fpage=0&toread=&page=%d",threadId, page];
}

- (NSString *)showThreadWithP:(NSString *)p {
    return nil;
}

- (NSString *)copyThreadUrl:(NSString *)postId withPostCout:(int)postCount {
    return nil;
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
    return [NSString stringWithFormat:@"http://bbs.crsky.com/u.php?action=show&uid=%@",userId];
}

- (NSString *)login {
    return nil;
}

- (NSString *)loginvCode {
    return nil;
}

- (NSString *)newThreadWithForumId:(NSString *)forumId {
    return @"http://bbs.crsky.com/post.php?";
}

- (NSString *)privateWithType:(int)type withPage:(int)page {
    //  0 receive box
    if (type == 0){
        return [NSString stringWithFormat:@"http://bbs.crsky.com/message.php?action=receivebox&page=%d", page];
    } else{
    //  -1 send box
        return [NSString stringWithFormat:@"http://bbs.crsky.com/message.php?action=sendbox&page=%d", page];
    }
}

- (NSString *)privateShowWithMessageId:(int)messageId withType:(int)type {
    if (type == 0){
        return [NSString stringWithFormat:@"http://bbs.crsky.com/message.php?action=readpub&mid=%d",messageId];
    } else {
        return [NSString stringWithFormat:@"http://bbs.crsky.com/message.php?action=read&mid=%d",messageId];
    }
}

- (NSString *)privateReplyWithMessageIdPre:(int)messageId {
    return [NSString stringWithFormat:@"http://bbs.crsky.com/message.php?action=write&remid=%d", messageId];
}

- (NSString *)privateReplyWithMessage {
    return @"http://bbs.crsky.com/message.php";
}

- (NSString *)privateNewPre {
    return @"http://bbs.crsky.com/message.php?action=write";
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

- (NSString *)loginControllerId {
    return @"CrskyLoginViewController";
}

- (NSString *)listUserThreads:(NSString *)userId withPage:(int)page {
    return [NSString stringWithFormat:@"http://bbs.crsky.com/u.php?action=topic&uid=%@&page=%d" ,userId, page];
}
@end
