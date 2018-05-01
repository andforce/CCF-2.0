//
//  TForumConfig.h
//  Forum
//
//  Created by 迪远 王 on 2018/4/29.
//  Copyright © 2018年 andforce. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ForumConfigDelegate.h"

#define BBS_HOST @"http://bbs.smartisan.com/"

#define ARCHIVE BBS_HOST@"search.php?mod=forum&adv=yes"

#define SEARCH BBS_HOST@"search.php?"

#define SEARCH_WITH_SEARCHID SEARCH@"step=2&sid=%@&seekfid=all&page=%d"

#define READ BBS_HOST@"read.php?tid=%@"

#define FAV_THREAD BBS_HOST@"pw_ajax.php?action=favor&type=0&nowtime=%ldl&tid=%@"

#define UNFAV BBS_HOST@"u.php?action=favor&"

#define LST_FAV_THREAD BBS_HOST@"home.php?mod=space&do=favorite&type=thread&page=%d"

#define FORUM_DIS BBS_HOST@"forum-%@-%d.html"

#define SEARCH_NEW BBS_HOST@"api/web/index.php?version=5&module=newIndex&action=threadRecommend&page=%d&rand=%ld"

#define REPLY BBS_HOST@"post.php?"

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

@interface TForumConfig : NSObject<ForumConfigDelegate>

@end
