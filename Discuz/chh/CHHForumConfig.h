//
// Created by 迪远 王 on 2017/5/6.
// Copyright (c) 2017 andforce. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ForumConfigDelegate.h"
#import "DiscuzCommonConfig.h"

#define BBS_HOST @"https://chiphell.com/"

#define ARCHIVE BBS_HOST@"archiver/"

#define SEARCH BBS_HOST@"search.php?"

#define SEARCH_WITH_SEARCHID SEARCH@"step=2&sid=%@&seekfid=all&page=%d"

#define READ BBS_HOST@"read.php?tid=%@"

#define FAV_THREAD BBS_HOST@"pw_ajax.php?action=favor&type=0&nowtime=%ldl&tid=%@"

#define UNFAV BBS_HOST@"u.php?action=favor&"

#define LST_FAV_THREAD BBS_HOST@"home.php?mod=space&do=favorite&type=thread&page=%d"

#define FORUM_DIS BBS_HOST@"forum-%@-%d.html"

#define SEARCH_NEW BBS_HOST@"api/web/index.php?version=5&module=newIndex&action=threadRecommend&page=%d&rand=%ld"

#define REPLY BBS_HOST@"post.php?"

#define NEW_THREAD BBS_HOST@"forum.php?mod=post&action=newthread&fid=%@&extra=&topicsubmit=yes"

#define ENTER_NEW_POST BBS_HOST@"forum.php?mod=post&action=newthread&fid=%@"

#define QUOTE_REPLY BBS_HOST@"post.php?action=quote&fid=%d&tid=%d&pid=%d"

#define SHOW_THREAD BBS_HOST@"thread-%@-%d-1.html"

#define COPY_URL READ@"#%@"

#define MEMBER BBS_HOST@"home.php?mod=space&uid=%@"

#define MESSAGE BBS_HOST@"message.php"

#define WRITE_MESSAGE MESSAGE@"?action=write"

#define RECEIVE_BOX MESSAGE@"?action=receivebox&page=%d"

#define SEND_BOX MESSAGE@"?action=sendbox&page=%d"

#define DEL_RECEIVE_BOX MESSAGE@"?action=receivebox"

#define DEL_SEND_BOX MESSAGE@"?action=sendbox"

#define READ_PUBLIC_MESSAGE MESSAGE@"?action=readpub&mid=%d"

#define READ_PRI_MESSAGE MESSAGE@"?action=read&mid=%d"

#define READ_SEND_PRI_MSG MESSAGE@"?action=readsnd&mid=%d"

#define REPLY_MSG_PRE MESSAGE@"?action=write&remid=%d"

#define LIST_USER_THREAD BBS_HOST@"u.php?action=topic&uid=%@&page=%d"

#define PRIVATE_MESSAGE BBS_HOST@"home.php?mod=space&do=pm&filter=privatepm&page=%d"

#define NOTICE_MESSAGE BBS_HOST@"home.php?mod=space&do=notice&view=mypost&page=%d"

@interface CHHForumConfig : DiscuzCommonConfig<DiscuzConfigDelegate>
@end