//
//  CrskyForumConfig.h
//  Created by Diyuan Wang on 2019/11/21.
//  Copyright © 2019年 Diyuan Wang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BBSConfigDelegate.h"

#define BBS_HOST @"http://bbs.crsky.com/"

#define ARCHIVE BBS_HOST@"index.php?skinco=wind"

#define SEARCH BBS_HOST@"search.php?"

#define SEARCH_WITH_SEARCHID SEARCH@"step=2&sid=%@&seekfid=all&page=%d"

#define READ BBS_HOST@"read.php?tid=%@"

#define FAV_THREAD BBS_HOST@"pw_ajax.php?action=favor&type=0&nowtime=%ldl&tid=%@"

#define UNFAV BBS_HOST@"u.php?action=favor&"

#define LST_FAV_THREAD BBS_HOST@"u.php?action=favor&uid=%d"

#define FORUM_DIS BBS_HOST@"thread.php?fid=%@&page=%d"

#define SEARCH_NEW BBS_HOST@"search.php?sch_time=all&orderway=lastpost&asc=desc&newatc=1"

#define REPLY BBS_HOST@"post.php?"

#define QUOTE_REPLY BBS_HOST@"post.php?action=quote&fid=%d&tid=%d&pid=%d"

#define SHOW_THREAD READ@"&fpage=0&toread=&page=%d"

#define COPY_URL READ@"#%@"

#define MEMBER BBS_HOST@"u.php?action=show&uid=%@"

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

@interface FeiFanConfig : NSObject <BBSConfigDelegate>

@end
