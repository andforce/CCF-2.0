//
// Created by Diyuan Wang on 2019/11/12
// Copyright (c) 2017 andforce. All rights reserved.
//

#import "ChiphellConfig.h"
#import "DeviceName.h"


@implementation ChiphellConfig

#pragma mark

- (instancetype)init {
    self = [super init];
    super.forumURL = [NSURL URLWithString:@"https://www.chiphell.com/"];
    return self;
}

#pragma mark Overide

- (NSString *)archive {
    return [NSString stringWithFormat:@"%@archiver/", super.forumURL.absoluteString];
}


- (NSString *)searchThreadWithUserId:(NSString *)userId {
    return [NSString stringWithFormat:@"%@home.php?mod=space&uid=%@&do=thread&view=me&type=thread&order=dateline&from=space&page=", super.forumURL.absoluteString, userId];
}


- (NSString *)unFavorThreadWithId:(NSString *)threadId {
    return @"%@home.php?mod=spacecp&ac=favorite&op=delete&type=all&checkall=1";
}

- (NSString *)forumDisplayWithId:(NSString *)forumId withPage:(int)page {

    return [NSString stringWithFormat:@"%@forum.php?mod=forumdisplay&fid=%@&forumdefstyle=yes&page=%d", super.forumURL.absoluteString, forumId, page];
}

- (NSString *)searchNewThread:(int)page {
    return [NSString stringWithFormat:@"%@forum.php?mod=guide&view=hot&page=%d", super.forumURL.absoluteString, page];
}

- (NSString *)replyWithThreadId:(int)threadId forForumId:(int)forumId replyPostId:(int)postId {

    if (postId != -1) {  //  回复某个楼层
        return [NSString stringWithFormat:@"%@forum.php?mod=post&action=reply&fid=%d&tid=%d&extra=page%%3D1&replysubmit=yes", super.forumURL.absoluteString, forumId, threadId];
    } else {
        return [NSString stringWithFormat:@"%@forum.php?mod=post&action=reply&fid=%d&tid=%d&extra=&replysubmit=yes", super.forumURL.absoluteString, forumId, threadId];
    }
}


- (NSString *)login {
    return [NSString stringWithFormat:@"%@member.php?mod=logging&action=login&referer=https%%3A%%2F%%2Fwww.chiphell.com%%2Fforum.php&cookietime=1", super.forumURL.absoluteString];
}


- (NSString *)privateWithType:(int)type withPage:(int)page {

    if (type == 0) {
        return [NSString stringWithFormat:@"%@home.php?mod=space&do=pm&filter=privatepm&page=%d", super.forumURL.absoluteString, page];
    } else {
        return [NSString stringWithFormat:@"%@home.php?mod=space&do=notice&view=mypost&page=%d", super.forumURL.absoluteString, page];
    }
}

- (NSString *)privateShowWithMessageId:(int)messageId withType:(int)type {
    return [NSString stringWithFormat:@"%@home.php?mod=space&do=pm&subop=view&touid=%d#last", super.forumURL.absoluteString, messageId];
}


- (NSString *)favoriteForums {
    return [NSString stringWithFormat:@"%@home.php?mod=space&do=favorite&type=forum", super.forumURL.absoluteString];
}


- (NSString *)loginControllerId {
    return @"LoginForumWebView";
}

#pragma mark ForumCommonConfigDelegate

- (UIColor *)themeColor {
    return [UIColor redColor];
}

- (NSString *)cookieUserIdKey {
    return @"v2x4_48dd_lastcheckfeed";;
}

- (NSString *)cookieExpTimeKey {
    return @"v2x4_48dd_lastcheckfeed";
}

- (NSString *)signature {
    NSString *phoneName = [DeviceName deviceNameDetail];
    NSString *signature = [NSString stringWithFormat:@"\n\n发自 %@ 使用 CHH客户端", phoneName];
    return signature;
}


@end
