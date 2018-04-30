//
//  TForumHtmlParser.m
//  Forum
//
//  Created by 迪远 王 on 2018/4/29.
//  Copyright © 2018年 andforce. All rights reserved.
//

#import <IGHTMLQuery/IGHTMLDocument.h>
#import "ForumParserDelegate.h"
#import "TForumHtmlParser.h"
#import "IGXMLNode+Children.h"
#import "NSString+Extensions.h"
#import "THotTHotThreadPage.h"
#import "THotData.h"
#import "THotPage.h"
#import "THotList.h"
#import "CommonUtils.h"
#import "IGHTMLDocument+QueryNode.h"
#import "IGXMLNode+QueryNode.h"

@implementation TForumHtmlParser
- (ViewThreadPage *)parseShowThreadWithHtml:(NSString *)html {

    NSString * fixImagesHtml = html;
    NSString *newImagePattern = @"<img src=\"%@\" />";
    NSArray *orgImages = [fixImagesHtml arrayWithRegular:@"(?is)<img (style=\"cursor:pointer\" )?id=\"aimg_\\w+\" ((?<key>[^=]+)=\"*(?<value>[^\"]+)\")+? (alt=\"\"|inpost=\"\\d+\") />"];
    for (NSString *img in orgImages) {

        IGXMLDocument *igxmlDocument = [[IGXMLDocument alloc] initWithXMLString:img error:nil];
        NSString * file = [igxmlDocument attribute:@"file"];
        NSString * newImage = [NSString stringWithFormat:newImagePattern, file];
        NSLog(@"parseShowThreadWithHtml orgimage: %@ %@", img, newImage);

        fixImagesHtml = [fixImagesHtml stringByReplacingOccurrencesOfString:img withString:newImage];
    }

    IGHTMLDocument *document = [[IGHTMLDocument alloc] initWithHTMLString:fixImagesHtml error:nil];

    ViewThreadPage *showThreadPage = [[ViewThreadPage alloc] init];

    //1. tid
    int tid = [[fixImagesHtml stringWithRegular:@"(?<=tid=)\\d+"] intValue];
    showThreadPage.threadID = tid;

    //2. fid
    int fid = [[fixImagesHtml stringWithRegular:@"(?<=fid=)\\d+"] intValue];
    showThreadPage.forumId = fid;

    //3. title
    IGXMLNode *locationNode = [document queryNodeWithXPath:@"//*[@id=\"thread_subject\"]"];
    showThreadPage.threadTitle = [locationNode.text trim];

    //4. posts
    NSMutableArray<Post*> * posts = [NSMutableArray array];
    IGXMLNode *postListNode = [document queryNodeWithXPath:@"//*[@id=\"postlist\"]"];

    for (int i = 2; i < postListNode.childrenCount; ++i) {
        IGXMLNode *postNode = [postListNode childAt:i];
        NSString *postNodeHtml = postNode.html;

        Post * post = [[Post alloc] init];
        // 1. postId
        NSString *postIdStr = [postNode attribute:@"id"];
        if (![postIdStr hasPrefix:@"post_"]){
            continue;
        }
        NSString *pid = [postIdStr stringWithRegular:@"\\d+"];
        post.postID = pid;

        //2. 楼层
        NSString *louceng = [postNodeHtml stringWithRegular:@"(?<=<em>)\\d+(?=</em>楼</a>)"];
        post.postLouCeng = louceng;

        //3. time
        IGXMLNode *timeNode = [postNode queryNodeWithXPath:[NSString stringWithFormat:@"//*[@id='authorposton%@']", pid]];
        NSString *time = [timeNode.text.trim stringByReplacingOccurrencesOfString:@"发表于: " withString:@""];
        post.postTime = [CommonUtils timeForShort:time withFormat:@"yyyy-MM-dd HH:mm:ss"];

        //4. content
        IGHTMLDocument * contentDoc = [[IGHTMLDocument alloc] initWithHTMLString:postNodeHtml error:nil];
        IGXMLNode *contentNode = [contentDoc queryNodeWithClassName:@"t_fsz"];
        NSString * contentHtml = [[contentNode childAt:0] html];
        post.postContent = [NSString stringWithFormat:@"<div class=\"tpc_content\">%@</div>", contentHtml];

        //5. user
        User * user = [[User alloc] init];

        IGXMLNode * userNode = [postNode queryNodeWithXPath:[NSString stringWithFormat:@"//*[@id='favatar%@']", pid]];
        //1. userId
        user.userID = [userNode.html stringWithRegular:@"(?<=uid=)\\d+"];

        //2. userName
        IGHTMLDocument * userDoc = [[IGHTMLDocument alloc] initWithHTMLString:userNode.html error:nil];
        IGXMLNode *userNameNode = [userDoc queryNodeWithClassName:@"authi"];
        NSString *uname = userNameNode.text.trim;
        user.userName = uname;

        //3. avatar
        NSString *avatar = [NSString stringWithFormat:@"http://bbs.smartisan.com/uc_server/avatar.php?uid=%@&size=middle", user.userID];
        user.userAvatar = avatar;

        //4. rank
        //5. signDate
        //6. postCount
        //7.forumHost
        post.postUserInfo = user;

        [posts addObject:post];
    }

    showThreadPage.postList = posts;

    //5. orgHtml
    NSString *orgHtml = [document queryNodeWithXPath:@"//*[@id=\"postlist\"]"].html;
    showThreadPage.originalHtml = orgHtml;

    //6. number
    PageNumber *pageNumber = [self parserPageNumber:fixImagesHtml];
    showThreadPage.pageNumber = pageNumber;

    //7. token
    NSString * token = @"";
    showThreadPage.securityToken = token;

    // 10. quick reply title
    NSString * quickReplyTitle = @"";
    showThreadPage.quickReplyTitle = quickReplyTitle;

    return showThreadPage;
}

- (PageNumber *)parserPageNumber:(NSString *)html {
    IGHTMLDocument *document = [[IGHTMLDocument alloc] initWithHTMLString:html error:nil];

    PageNumber *pageNumber = [[PageNumber alloc] init];

    IGXMLNode *rootNode = [document queryNodeWithClassName:@"pgt"];

    if (rootNode && rootNode.children != nil && rootNode.childrenCount > 0){
        IGXMLNode *pgNode = [rootNode childAt:0];

        if (pgNode.childrenCount > 0){
            for (IGXMLNode *node in pgNode.children) {
                if ([node.html containsString:@"<strong>"]){
                    NSString * cPage = [node.text trim];
                    pageNumber.currentPageNumber = [cPage intValue];
                    break;
                }
            }

            IGXMLNode *totalPageNode = [pgNode childAt:pgNode.childrenCount -3];
            NSString *totalPage = [totalPageNode.text.trim stringByReplacingOccurrencesOfString:@"... " withString:@""];
            pageNumber.totalPageNumber = [totalPage intValue];

            return pageNumber;
        }
    }
    pageNumber.totalPageNumber = 1;
    pageNumber.currentPageNumber = 1;

    return pageNumber;
}

- (ViewForumPage *)parseThreadListFromHtml:(NSString *)html withThread:(int)threadId andContainsTop:(BOOL)containTop {

    IGHTMLDocument *document = [[IGHTMLDocument alloc] initWithHTMLString:html error:nil];

    IGXMLNodeSet *threadNodeSet = [[document queryNodeWithXPath:@"//*[@id=\"moderate\"]/div"] childAt:0].children;

    NSMutableArray<Thread *> *threadList = [NSMutableArray<Thread *> array];

    for (IGXMLNode * threadNode in threadNodeSet) {
        Thread *thread = [[Thread alloc] init];

        // 1. ID
        NSString *tID = [threadNode.html stringWithRegular:@"(?<=tid=)\\d+"];
        thread.threadID = tID;

        // 2. 标题
        // 分类
        IGXMLNode *categoryNode = [[[[threadNode childAt:1] childAt:0] childAt:0] childAt:0];
        // 标题的节点
        IGXMLNode *titleNode  = [[[[threadNode childAt:1] childAt:0] childAt:0] childAt:1];
        NSString *title = [categoryNode.text.trim stringByAppendingString:titleNode.text.trim];
        thread.threadTitle = title;

        NSLog(@"p_title \t%@", title);

        //3 是否是置顶帖子
        BOOL isTop = [threadNode.html containsString:@"<span class=\"icon icon-arrow-3\">"];
        thread.isTopThread = isTop;

        //4 是否是精华帖子
        BOOL isGoodness = [threadNode.html containsString:@"<span title=\"精华  1\" class=\"icon icon-finepick\">"];
        thread.isGoodNess = isGoodness;

        //5 是否包含图片
        BOOL isContainsImage = [threadNode.html containsString:@"<span title=\"图片附件\" class=\"icon icon-img\">"];
        thread.isContainsImage = isContainsImage;

        //6 总回帖页数
        IGXMLNode *commentNode = [[threadNode childAt:2] childAt:1];
        int commentCount = [[commentNode.text trim] intValue];
        thread.totalPostPageCount = commentCount % 10 == 0 ? commentCount / 10 : commentCount / 10 + 1;


        //7. 帖子作者
        IGXMLNode *authorNode = [[threadNode childAt:1] childAt:1];
        NSString *authorName = [[[authorNode childAt:0] text] trim];
        thread.threadAuthorName = authorName;

        //8. 作者ID
        thread.threadAuthorID = [[authorNode childAt:0].html stringWithRegular:@"(?<=uid=)\\d+"];

        //9. 回复数量
        thread.postCount = [[commentNode text] trim];

        //10. 查看数量
        IGXMLNode *viewCountNode = [[threadNode childAt:2] childAt:0];
        NSString * openCount = [[viewCountNode text] trim];
        thread.openCount = openCount;

        //11. 最后回帖时间
        IGXMLNode *lastPostTimeNode = [[threadNode childAt:1] childAt:1];
        NSString *lastPostTime = [[lastPostTimeNode childAt:0].text.trim stringWithRegular:@"\\d+-\\d+-\\d+ \\d+:\\d+"];
        thread.lastPostTime = [CommonUtils timeForShort:lastPostTime withFormat:@"yyyy-MM-dd HH:mm"];

        //12. 最后发表的人
        thread.lastPostAuthorName = authorName;

        [threadList addObject:thread];
    }

    ViewForumPage *threadListPage = [[ViewForumPage alloc] init];
    threadListPage.dataList = threadList;

    IGXMLNode *locationNode = [document queryNodeWithClassName:@"location"];
    NSString *fid = [locationNode.html stringWithRegular:@"(?<=forum-)\\d+"];
    threadListPage.forumId = [fid intValue];

    PageNumber *pageNumber = [[PageNumber alloc] init];
    IGXMLNode *pgNode = [document queryNodeWithClassName:@"pg"];
    for (IGXMLNode *node in pgNode.children) {
        if ([node.html containsString:@"<strong>"]){
            pageNumber.currentPageNumber = [[node.text trim] intValue];
            break;
        }
    }

    IGXMLNode *totalPageNode = [pgNode childAt:pgNode.childrenCount -3];
    NSString *totalPage = [totalPageNode.text.trim stringByReplacingOccurrencesOfString:@"... " withString:@""];
    pageNumber.totalPageNumber = [totalPage intValue];

    threadListPage.pageNumber = pageNumber;

    return threadListPage;
}

- (ViewForumPage *)parseFavorThreadListFromHtml:(NSString *)html {
    ViewForumPage *page = [[ViewForumPage alloc] init];

    NSMutableArray<Thread *> *threadList = [NSMutableArray<Thread *> array];

    IGHTMLDocument *document = [[IGHTMLDocument alloc] initWithHTMLString:html error:nil];

    IGXMLNodeSet *contents = [document queryNodeWithXPath:@"//*[@id=\"favorite_ul\"]"].children;

    for (IGXMLNode *node in contents) {
        Thread *simpleThread = [[Thread alloc] init];

        //分离出Title
        simpleThread.threadTitle = [node childAt:2].text.trim;

        // Id
        simpleThread.threadID = [[node childAt:2].html stringWithRegular:@"(?<=thread-)\\d+"];

        simpleThread.threadAuthorID = @"-1";

        simpleThread.threadAuthorName = @"未知";

        simpleThread.lastPostTime = @"";

        [threadList addObject:simpleThread];
    }

    PageNumber *pageNumber = [[PageNumber alloc]init];
    IGXMLNode * pageNode = [document queryNodeWithClassName:@"pg"];
    if (pageNode != nil && pageNode.childrenCount > 0){
        for (IGXMLNode *n in pageNode.children) {
            if ([[n.html trim] hasPrefix:@"<strong>"]){
                pageNumber.currentPageNumber = [[[n text] trim] intValue];
                break;
            }
        }
        NSString * pageText = [pageNode.text trim];
        int max = [[[[pageText componentsSeparatedByString:@"/"][1] trim] componentsSeparatedByString:@" "].firstObject intValue];
        pageNumber.totalPageNumber = max;
    } else {
        pageNumber.currentPageNumber = 1;
        pageNumber.totalPageNumber = 1;
    }


    
    
    page.pageNumber = pageNumber;
    page.dataList = threadList;

    return page;
}

- (NSString *)parseErrorMessage:(NSString *)html {
    return nil;
}

- (NSString *)parseSecurityToken:(NSString *)html {
    return nil;
}

- (NSString *)parsePostHash:(NSString *)html {
    return nil;
}

- (NSString *)parserPostStartTime:(NSString *)html {
    return nil;
}

- (NSString *)parseLoginErrorMessage:(NSString *)html {
    return nil;
}

- (NSString *)parseQuote:(NSString *)html {
    return nil;
}

- (NSArray<Forum *> *)parserForums:(NSString *)html forumHost:(NSString *)host {
    IGHTMLDocument *document = [[IGHTMLDocument alloc] initWithHTMLString:html error:nil];

    IGXMLNode *fourRowNode = [document queryNodeWithXPath:@"//*[@id=\"srchfid\"]"];

    NSMutableArray<Forum *> *forums = [NSMutableArray array];

    Forum *lastForum = nil;
    NSMutableArray<Forum *> *childForums = [NSMutableArray array];
    int replaceId = 10000;
    for (IGXMLNode * child in fourRowNode.children) {

        if (child.childrenCount == 0){
            continue;
        }

        // 总分类
        Forum *parent = [[Forum alloc] init];

        NSString *pName = [[child attribute:@"label"] stringByReplacingOccurrencesOfString:@"--" withString:@""];
        parent.forumName = pName;
        parent.forumId = replaceId ++;
        parent.forumHost = host;
        parent.parentForumId = -1;

        [forums addObject:parent];

        for (int i = 0; i < child.childrenCount; ++i) {

            IGXMLNode *childNode = [child childAt:i];
            //NSLog(@">>>>>>>> %@", childNode.html);
            Forum *forum = [[Forum alloc] init];
            forum.forumId = [[childNode attribute:@"value"] intValue];
            forum.forumHost = host;

            NSString *nameOrg = [childNode text];
            if ([nameOrg containsString:@"      "]){
                // 说明是二级子论坛
                forum.parentForumId = lastForum.forumId;
                forum.forumName = [nameOrg trim];
                [childForums addObject:forum];
            } else {
                childForums = [NSMutableArray array];

                forum.parentForumId = parent.forumId;
                forum.forumName = [nameOrg trim];
                forum.childForums = childForums;

                lastForum = forum;
                [forums addObject:lastForum];
            }
        }
    }
    NSMutableArray<Forum *> *needInsert = [NSMutableArray array];

    for (Forum *forum in forums) {
        [needInsert addObjectsFromArray:[self flatForm:forum]];
    }
    return [needInsert copy];
}

- (NSArray *)flatForm:(Forum *)form {
    NSMutableArray *resultArray = [NSMutableArray array];
    [resultArray addObject:form];
    for (Forum *childForm in form.childForums) {
        [resultArray addObjectsFromArray:[self flatForm:childForm]];
    }
    return resultArray;
}

- (ViewSearchForumPage *)parseSearchPageFromHtml:(NSString *)html {
    ViewSearchForumPage *resultPage = [[ViewSearchForumPage alloc] init];

    NSData *data = [html dataUsingEncoding:NSUTF8StringEncoding];

    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:(NSJSONReadingOptions) kNilOptions error:nil];

    THotTHotThreadPage *hotTHotThreadPage = [THotTHotThreadPage modelObjectWithDictionary:dictionary];

    PageNumber * pageNumber = [[PageNumber alloc] init];
    pageNumber.currentPageNumber = 1;
    pageNumber.totalPageNumber = (int)hotTHotThreadPage.data.page.pageTotal;
    NSArray<THotList*> * list = hotTHotThreadPage.data.list;

    NSMutableArray<Thread *> *dataList = [NSMutableArray array];
    for (THotList * tHotList in list){
        Thread * thread = [[Thread alloc] init];
        thread.threadTitle = tHotList.subject;
        thread.threadAuthorID = tHotList.authorid;
        thread.threadAuthorName = tHotList.author;
        thread.threadID = tHotList.tid;
        thread.fromFormName = @"";
        thread.isContainsImage = tHotList.attachment != nil && ![tHotList.attachment isEqualToString:@""];
        thread.isGoodNess = NO;
        thread.isTopThread = NO;
        thread.openCount = tHotList.views;
        thread.postCount = tHotList.replies;
        thread.lastPostAuthorName = tHotList.author;
        thread.lastPostTime = [CommonUtils timeForShort:tHotList.dbdateline];
        [dataList addObject:thread];
    }

    resultPage.pageNumber = pageNumber;
    resultPage.dataList = dataList;

    return resultPage;
}

- (UserProfile *)parserProfile:(NSString *)html userId:(NSString *)userId {
    IGHTMLDocument *document = [[IGHTMLDocument alloc] initWithHTMLString:html error:nil];
    
    UserProfile *userProfile = [[UserProfile alloc] init];
    userProfile.profileUserId = userId;

    IGXMLNode *info = [document queryNodeWithXPath:@"//*[@id=\"ct\"]/div/div[2]/div/div[1]/div[3]"];
    NSString * infoHtml = info.html;
    
    userProfile.profileRank = [info.html stringWithRegular:@"(?<=_blank\">)第 \\d+ 级(?=</a>)"];

    IGXMLNode *nameNode = [document queryNodeWithXPath:@"//*[@id=\"uhd\"]/div/h2"];
    userProfile.profileName = [nameNode.text trim];


    //<li><em>注册时间</em>2014-7-24 10:15</li>
    userProfile.profileRegisterDate = [infoHtml stringWithRegular:@"(?<=注册时间</em>)\\d+-\\d+-\\d+ \\d+:\\d+"];
    userProfile.profileRecentLoginDate = [infoHtml stringWithRegular:@"(?<=最后访问</em>)\\d+-\\d+-\\d+ \\d+:\\d+"];;

    NSString * replyCount = [html stringWithRegular:@"(?<=回帖数 )\\d+"];
    NSString * threadCount = [html stringWithRegular:@"(?<=主题数 )\\d+"];
    int count = [replyCount integerValue] + [threadCount integerValue];

    userProfile.profileTotalPostCount = [NSString stringWithFormat:@"%d", count];
    return userProfile;
}
@end
