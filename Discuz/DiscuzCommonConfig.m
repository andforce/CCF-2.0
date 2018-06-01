//
// Created by 迪远 王 on 2018/6/2.
// Copyright (c) 2018 andforce. All rights reserved.
//

#import "DiscuzCommonConfig.h"


@implementation DiscuzCommonConfig {

}
- (NSString *)archive {
    return @"http://bbs.smartisan.com/search.php?mod=forum&adv=yes";
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


- (NSString *)search {
    return @"http://bbs.smartisan.com/search.php?";
}

- (NSString *)searchWithSearchId:(NSString *)searchId withPage:(int)page {
    return [NSString stringWithFormat:@"http://bbs.smartisan.com/search.php?step=2&sid=%@&seekfid=all&page=%d", searchId, page];
}


- (NSString *)favThreadWithIdPre:(NSString *)threadId {
    return [NSString stringWithFormat:@"http://bbs.smartisan.com/read.php?tid=%@", threadId];
}

- (NSString *)favThreadWithId:(NSString *)threadId {
    NSDate *date = [NSDate date];
    NSInteger timeStamp = (NSInteger) [date timeIntervalSince1970];
    return [NSString stringWithFormat:@"http://bbs.smartisan.com/pw_ajax.php?action=favor&type=0&nowtime=%ldl&tid=%@", (long) timeStamp, threadId];
}

- (NSString *)unFavorThreadWithId:(NSString *)threadId {
    return @"http://bbs.smartisan.com/u.php?action=favor&";
}

- (NSString *)listFavorThreads:(int)userId withPage:(int)page {
    return [NSString stringWithFormat:@"http://bbs.smartisan.com/home.php?mod=space&do=favorite&type=thread&page=%d", page];
}

- (NSString *)forumDisplayWithId:(NSString *)forumId withPage:(int)page {
    return [NSString stringWithFormat:@"http://bbs.smartisan.com/forum-%@-%d.html", forumId, page];
}

- (NSString *)searchNewThread:(int)page {
    NSDate *date = [NSDate date];
    NSInteger timeStamp = (NSInteger) [date timeIntervalSince1970];
    return [NSString stringWithFormat:@"http://bbs.smartisan.com/api/web/index.php?version=5&module=newIndex&action=threadRecommend&page=%d&rand=%ld", page, (long) timeStamp];
}

- (NSString *)replyWithThreadId:(int)threadId forForumId:(int)forumId replyPostId:(int)postId {
    return @"http://bbs.smartisan.com/post.php?";
}

- (NSString *)quoteReply:(int)fid threadId:(int)threadId postId:(int)postId {
    return [NSString stringWithFormat:@"http://bbs.smartisan.com/post.php?action=quote&fid=%d&tid=%d&pid=%d", fid, threadId, postId];
}

- (NSString *)showThreadWithThreadId:(NSString *)threadId withPage:(int)page {
    return [NSString stringWithFormat:@"http://bbs.smartisan.com/thread-%@-%d-1.html", threadId, page];
}

- (NSString *)showThreadWithP:(NSString *)p {
    return nil;
}

- (NSString *)copyThreadUrl:(NSString *)threadId withPostId:(NSString *)postId withPostCout:(int)postCount {
    NSString *fixPostId = postId;
    if ([fixPostId isEqualToString:@"0"]) {
        fixPostId = @"tpc";
    }
    return [NSString stringWithFormat:@"http://bbs.smartisan.com/read.php?tid=%@#%@", threadId, fixPostId];
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
    return [NSString stringWithFormat:@"http://bbs.smartisan.com/home.php?mod=space&uid=%@", userId];
}

- (NSString *)createNewThreadWithForumId:(NSString *)forumId {
    return [NSString stringWithFormat:@"http://bbs.smartisan.com/forum.php?mod=post&action=newthread&fid=%@&extra=&topicsubmit=yes", forumId];
}


- (NSString *)privateWithType:(int)type withPage:(int)page {
    //  0 receive box
    if (type == 0) {
        return [NSString stringWithFormat:@"http://bbs.smartisan.com/message.php?action=receivebox&page=%d", page];
    } else {
        //  -1 send box
        return [NSString stringWithFormat:@"http://bbs.smartisan.com/message.php?action=sendbox&page=%d", page];
    }
}

- (NSString *)deletePrivateWithType:(int)type {
    if (type == 0) {
        return @"http://bbs.smartisan.com/message.php?action=receivebox";
    } else {
        return @"http://bbs.smartisan.com/message.php?action=sendbox";
    }
}

- (NSString *)privateShowWithMessageId:(int)messageId withType:(int)type {
    // 0 群发公共消息 1 普通收件 2 发给别人的消息
    if (type == 0) {
        return [NSString stringWithFormat:@"http://bbs.smartisan.com/message.php?action=readpub&mid=%d", messageId];
    } else if (type == 1) {
        return [NSString stringWithFormat:@"http://bbs.smartisan.com/message.php?action=read&mid=%d", messageId];
    } else if (type == 2) {
        return [NSString stringWithFormat:@"http://bbs.smartisan.com/message.php?action=readsnd&mid=%d", messageId];
    } else {
        return nil;
    }
}

- (NSString *)privateReplyWithMessageIdPre:(int)messageId {
    return [NSString stringWithFormat:@"http://bbs.smartisan.com/message.php?action=write&remid=%d", messageId];
}

- (NSString *)privateReplyWithMessage {
    return @"http://bbs.smartisan.com/message.php";
}

- (NSString *)privateNewPre {
    return @"http://bbs.smartisan.com/message.php?action=write";
}

- (NSString *)loginControllerId {
    return @"TForumLoginWebViewController";
}

- (NSString *)listUserThreads:(NSString *)userId withPage:(int)page {
    return [NSString stringWithFormat:@"http://bbs.smartisan.com/u.php?action=topic&uid=%@&page=%d", userId, page];
}

- (NSString *)privateMessage:(int)page {
    return [NSString stringWithFormat:@"http://bbs.smartisan.com/home.php?mod=space&do=pm&filter=privatepm&page=%d", page];
}

- (NSString *)noticeMessage:(int)page {
    return [NSString stringWithFormat:@"http://bbs.smartisan.com/home.php?mod=space&do=notice&view=mypost&page=%d", page];
}

- (NSString *)enterCreateNewThreadWithForumId:(NSString *)forumId {
    return [NSString stringWithFormat:@"http://bbs.smartisan.com/forum.php?mod=post&action=newthread&fid=%@", forumId];
}

@end