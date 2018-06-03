//
// Created by 迪远 王 on 2018/6/2.
// Copyright (c) 2018 andforce. All rights reserved.
//

#import "DiscuzCommonConfig.h"


@implementation DiscuzCommonConfig {

}
- (NSString *)archive {
    return [NSString stringWithFormat:@"%@search.php?mod=forum&adv=yes", _forumURL.absoluteString];
}

- (NSString *)newattachmentForThread:(int)threadId time:(NSString *)time postHash:(NSString *)postHash {
    return nil;
}

- (NSString *)newattachmentForForum:(int)forumId time:(NSString *)time postHash:(NSString *)postHash {
    return [NSString stringWithFormat:@"%@misc.php?mod=swfupload&operation=upload&simple=1&type=image", _forumURL.absoluteString];
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
    //formhash=95861144&
    // 需要请求时候添加
    return [NSString stringWithFormat:@"%@home.php?mod=spacecp&ac=favorite&type=forum&id=%@&handlekey=favoriteforum&"
                                      "infloat=yes&handlekey=a_favorite&inajax=1&ajaxtarget=fwin_content_a_favorite", _forumURL.absoluteString, forumId];
}

- (NSString *)favForumWithIdParam:(NSString *)forumId {
    return nil;
}

- (NSString *)unfavForumWithId:(NSString *)forumId {
    return nil;
}

- (NSString *)forumDisplayWithId:(NSString *)forumId {
    return [NSString stringWithFormat:@"%@forum-%@-1.html", _forumURL.absoluteString, forumId];;
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
    return [NSString stringWithFormat:@"%@search.php?",_forumURL.absoluteString];
}

- (NSString *)searchWithSearchId:(NSString *)searchId withPage:(int)page {
    return [NSString stringWithFormat:@"%@search.php?step=2&sid=%@&seekfid=all&page=%d", _forumURL.absoluteString, searchId, page];
}


- (NSString *)favThreadWithIdPre:(NSString *)threadId {
    return [NSString stringWithFormat:@"%@read.php?tid=%@", _forumURL.absoluteString, threadId];
}

- (NSString *)favThreadWithId:(NSString *)threadId {
    return [NSString stringWithFormat:@"%@home.php?mod=spacecp&ac=favorite&type=thread&id=%@&infloat=yes&handlekey=k_favorite&"
                                      "inajax=1&ajaxtarget=fwin_content_k_favorite", _forumURL.absoluteString, threadId];
}

- (NSString *)unFavorThreadWithId:(NSString *)threadId {
    return [NSString stringWithFormat:@"%@u.php?action=favor&",_forumURL.absoluteString];
}

- (NSString *)listFavorThreads:(int)userId withPage:(int)page {
    return [NSString stringWithFormat:@"%@home.php?mod=space&do=favorite&type=thread&page=%d", _forumURL.absoluteString, page];
}

- (NSString *)forumDisplayWithId:(NSString *)forumId withPage:(int)page {
    return [NSString stringWithFormat:@"%@forum-%@-%d.html", _forumURL.absoluteString, forumId, page];
}

- (NSString *)searchNewThread:(int)page {
    NSDate *date = [NSDate date];
    NSInteger timeStamp = (NSInteger) [date timeIntervalSince1970];
    return [NSString stringWithFormat:@"%@api/web/index.php?version=5&module=newIndex&action=threadRecommend&page=%d&rand=%ld", _forumURL.absoluteString, page, (long) timeStamp];
}

- (NSString *)replyWithThreadId:(int)threadId forForumId:(int)forumId replyPostId:(int)postId {
    return [NSString stringWithFormat:@"%@post.php?", _forumURL.absoluteString];
}

- (NSString *)quoteReply:(int)fid threadId:(int)threadId postId:(int)postId {
    return [NSString stringWithFormat:@"%@post.php?action=quote&fid=%d&tid=%d&pid=%d",  _forumURL.absoluteString,fid, threadId, postId];
}

- (NSString *)showThreadWithThreadId:(NSString *)threadId withPage:(int)page {
    return [NSString stringWithFormat:@"%@thread-%@-%d-1.html", _forumURL.absoluteString, threadId, page];
}

- (NSString *)copyThreadUrl:(NSString *)threadId withPostId:(NSString *)postId withPostCout:(int)postCount {
    NSString *fixPostId = postId;
    if ([fixPostId isEqualToString:@"0"]) {
        fixPostId = @"tpc";
    }
    return [NSString stringWithFormat:@"%@read.php?tid=%@#%@",  _forumURL.absoluteString,threadId, fixPostId];
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
    return [NSString stringWithFormat:@"%@home.php?mod=space&uid=%@", _forumURL.absoluteString, userId];
}

- (NSString *)createNewThreadWithForumId:(NSString *)forumId {
    return [NSString stringWithFormat:@"%@forum.php?mod=post&action=newthread&fid=%@&extra=&topicsubmit=yes", _forumURL.absoluteString, forumId];
}


- (NSString *)privateWithType:(int)type withPage:(int)page {
    //  0 receive box
    if (type == 0) {
        return [NSString stringWithFormat:@"%@message.php?action=receivebox&page=%d", _forumURL.absoluteString, page];
    } else {
        //  -1 send box
        return [NSString stringWithFormat:@"%@message.php?action=sendbox&page=%d", _forumURL.absoluteString, page];
    }
}

- (NSString *)deletePrivateWithType:(int)type {
    if (type == 0) {
        return [NSString stringWithFormat:@"%@message.php?action=receivebox", _forumURL.absoluteString];
    } else {
        return [NSString stringWithFormat:@"%@message.php?action=sendbox", _forumURL.absoluteString];
    }
}

- (NSString *)privateShowWithMessageId:(int)messageId withType:(int)type {
    // 0 群发公共消息 1 普通收件 2 发给别人的消息
    if (type == 0) {
        return [NSString stringWithFormat:@"%@message.php?action=readpub&mid=%d", _forumURL.absoluteString, messageId];
    } else if (type == 1) {
        return [NSString stringWithFormat:@"%@message.php?action=read&mid=%d", _forumURL.absoluteString, messageId];
    } else if (type == 2) {
        return [NSString stringWithFormat:@"%@message.php?action=readsnd&mid=%d", _forumURL.absoluteString, messageId];
    } else {
        return nil;
    }
}

- (NSString *)privateReplyWithMessageIdPre:(int)messageId {
    return [NSString stringWithFormat:@"%@message.php?action=write&remid=%d",  _forumURL.absoluteString,messageId];
}

- (NSString *)privateReplyWithMessage {
    return [NSString stringWithFormat:@"%@message.php", _forumURL.absoluteString];
}

- (NSString *)privateNewPre {
    return [NSString stringWithFormat:@"%@message.php?action=write", _forumURL.absoluteString];
}

- (NSString *)loginControllerId {
    return @"TForumLoginWebViewController";
}

- (NSString *)listUserThreads:(NSString *)userId withPage:(int)page {
    return [NSString stringWithFormat:@"%@u.php?action=topic&uid=%@&page=%d", _forumURL.absoluteString, userId, page];
}

- (NSString *)privateMessage:(int)page {
    return [NSString stringWithFormat:@"%@home.php?mod=space&do=pm&filter=privatepm&page=%d",  _forumURL.absoluteString,page];
}

- (NSString *)noticeMessage:(int)page {
    return [NSString stringWithFormat:@"%@home.php?mod=space&do=notice&view=mypost&page=%d", _forumURL.absoluteString, page];
}

- (NSString *)enterCreateNewThreadWithForumId:(NSString *)forumId {
    return [NSString stringWithFormat:@"%@forum.php?mod=post&action=newthread&fid=%@", _forumURL.absoluteString, forumId];
}

@end