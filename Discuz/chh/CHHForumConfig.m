//
// Created by 迪远 王 on 2017/5/6.
// Copyright (c) 2017 andforce. All rights reserved.
//

#import "CHHForumConfig.h"
#import "DeviceName.h"


@implementation CHHForumConfig {

}
- (UIColor *)themeColor {
    return [UIColor redColor];
}

- (NSURL *)forumURL {
    return [NSURL URLWithString:@"https://chiphell.com/"];
}

- (NSString *)archive {
    return @"https://www.chiphell.com/archiver/";
}

- (NSString *)cookieUserIdKey {
    // name:"v2x4_48dd_lastcheckfeed" value:"238210%7C1494126638" expiresDate:2018-05-07 03:10:38 +0000
    return @"v2x4_48dd_lastcheckfeed";
}

- (NSString *)cookieExpTimeKey {
    // name:"v2x4_48dd_lastcheckfeed" value:"238210%7C1494126638" expiresDate:2018-05-07 03:10:38 +0000
    return @"v2x4_48dd_lastcheckfeed";
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
    return nil;
}

- (NSString *)searchWithSearchId:(NSString *)searchId withPage:(int)page {
    return nil;
}

- (NSString *)searchThreadWithUserId:(NSString *)userId {
    return [NSString stringWithFormat:@"https://www.chiphell.com/home.php?mod=space&uid=%@&do=thread&view=me&type=thread&order=dateline&from=space&page=", userId];
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
    return @"https://www.chiphell.com/home.php?mod=spacecp&ac=favorite&op=delete&type=all&checkall=1";
}

- (NSString *)listFavorThreads:(int)userId withPage:(int)page {
    return [NSString stringWithFormat:@"https://www.chiphell.com/home.php?mod=space&do=favorite&type=thread&page=%d", page];
}

- (NSString *)forumDisplayWithId:(NSString *)forumId {
    return nil;
}

- (NSString *)forumDisplayWithId:(NSString *)forumId withPage:(int)page {

    return [NSString stringWithFormat:@"https://www.chiphell.com/forum.php?mod=forumdisplay&fid=%@&forumdefstyle=yes&page=%d", forumId, page];
}

- (NSString *)searchNewThread:(int)page {
    return [NSString stringWithFormat:@"https://www.chiphell.com/forum.php?mod=guide&view=hot&page=%d", page];
}

- (NSString *)replyWithThreadId:(int)threadId forForumId:(int)forumId replyPostId:(int)postId {

    if (postId != -1){  //  回复某个楼层
        return [NSString stringWithFormat:@"https://www.chiphell.com/forum.php?mod=post&action=reply&fid=%d&tid=%d&extra=page%%3D1&replysubmit=yes", forumId ,threadId];
    } else{
        return [NSString stringWithFormat:@"https://www.chiphell.com/forum.php?mod=post&action=reply&fid=%d&tid=%d&extra=&replysubmit=yes", forumId, threadId];
    }
}

- (NSString *)quoteReply:(int)fid threadId:(int)threadId postId:(int)postId {
    return nil;
}

- (NSString *)deletePrivateWithType:(int)type {
    return nil;
}

- (NSString *)showThreadWithThreadId:(NSString *)threadId withPage:(int)page {
    return [NSString stringWithFormat:@"https://www.chiphell.com/thread-%@-%d-1.html", threadId, page];
}

- (NSString *)showThreadWithP:(NSString *)p {
    return nil;
}

- (NSString *)copyThreadUrl:(NSString *)threadId withPostId:(NSString *)postId withPostCout:(int)postCount {
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
    return [NSString stringWithFormat:@"https://www.chiphell.com/space-uid-%@.html", userId];
}

- (NSString *)login {
    return @"https://www.chiphell.com/member.php?mod=logging&action=login&referer=https%3A%2F%2Fwww.chiphell.com%2Fforum.php&cookietime=1";
}

- (NSString *)loginvCode {
    return nil;
}

- (NSString *)createNewThreadWithForumId:(NSString *)forumId {
    return [NSString stringWithFormat:@"https://www.chiphell.com/forum.php?mod=post&action=newthread&fid=%@&extra=&topicsubmit=yes", forumId];
}

- (NSString *)enterCreateNewThreadWithForumId:(NSString *)forumId {
    return [NSString stringWithFormat:@"https://www.chiphell.com/forum.php?mod=post&action=newthread&fid=%@", forumId];
}


- (NSString *)privateWithType:(int)type withPage:(int)page {
    if (type == 0){
        return [NSString stringWithFormat:@"https://www.chiphell.com/home.php?mod=space&do=pm&filter=privatepm&page=%d", page];
    } else{
        return [NSString stringWithFormat:@"https://www.chiphell.com/home.php?mod=space&do=notice&view=mypost&page=%d", page];
    }
}

- (NSString *)privateShowWithMessageId:(int)messageId withType:(int)type {
    return [NSString stringWithFormat:@"https://www.chiphell.com/home.php?mod=space&do=pm&subop=view&touid=%d#last", messageId];
}

- (NSString *)privateReplyWithMessageIdPre:(int)messageId {
    return nil;
}

- (NSString *)privateReplyWithMessage {
    return nil;
}

- (NSString *)privateNewPre {
    return nil;
}

- (NSString *)favoriteForums {
    return @"https://www.chiphell.com/home.php?mod=space&do=favorite&type=forum";
}

- (NSString *)report {
    return nil;
}

- (NSString *)reportWithPostId:(int)postId {
    return nil;
}

- (NSString *)loginControllerId {
    return @"LoginForumWebView";
}

- (NSString *)signature {
    NSString *phoneName = [DeviceName deviceNameDetail];
    NSString *signature = [NSString stringWithFormat:@"\n\n发自 %@ 使用 CHH客户端", phoneName];
    return signature;
}


@end
