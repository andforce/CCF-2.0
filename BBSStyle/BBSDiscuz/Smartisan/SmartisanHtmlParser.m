//
//  TForumHtmlParser.m
//  Created by Diyuan Wang on 2019/11/21.
//  Copyright © 2019年 Diyuan Wang. All rights reserved.
//

#import "ForumEntry+CoreDataClass.h"
#import <IGHTMLQuery/IGHTMLDocument.h>
#import "BBSParserDelegate.h"
#import "SmartisanHtmlParser.h"
#import "IGXMLNode+Children.h"
#import "BBSCoreDataManager.h"
#import "NSString+Extensions.h"
#import "SmartisanHotTHotThreadPage.h"
#import "SmartisanHotData.h"
#import "SmartisanHotPage.h"
#import "SmartisanHotList.h"
#import "CommonUtils.h"
#import "IGHTMLDocument+QueryNode.h"
#import "BBSLocalApi.h"
#import "IGXMLNode+QueryNode.h"

@implementation SmartisanHtmlParser {

}
- (ViewThreadPage *)parseShowThreadWithHtml:(NSString *)html {
    NSString *fixImagesHtml = html;
    NSString *newImagePattern = @"<img src=\"%@\" />";
    NSArray *orgImages = [fixImagesHtml arrayWithRegular:@"(?is)<img (style=\"cursor:pointer\" )?id=\"aimg_\\w+\" ((?<key>[^=]+)=\"*(?<value>[^\"]+)\")+? (alt=\"\"|inpost=\"\\d+\") />"];
    for (NSString *img in orgImages) {

        IGXMLDocument *igxmlDocument = [[IGXMLDocument alloc] initWithXMLString:img error:nil];
        NSString *file = [igxmlDocument attribute:@"file"];
        NSString *newImage = [NSString stringWithFormat:newImagePattern, file];
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
    NSMutableArray<PostFloor *> *posts = [NSMutableArray array];
    IGXMLNode *postListNode = [document queryNodeWithXPath:@"//*[@id=\"postlist\"]"];

    for (int i = 2; i < postListNode.childrenCount; ++i) {
        IGXMLNode *postNode = [postListNode childAt:i];
        NSString *postNodeHtml = postNode.html;

        PostFloor *post = [[PostFloor alloc] init];
        // 1. postId
        NSString *postIdStr = [postNode attribute:@"id"];
        if (![postIdStr hasPrefix:@"post_"]) {
            continue;
        }
        NSString *pid = [postIdStr stringWithRegular:@"\\d+"];
        post.postID = pid;

        //2. 楼层
        NSString *floor = [postNodeHtml stringWithRegular:@"(?<=<em>)\\d+(?=</em>楼</a>)"];
        post.postLouCeng = floor;

        //3. time
        IGXMLNode *timeNode = [postNode queryNodeWithXPath:[NSString stringWithFormat:@"//*[@id='authorposton%@']", pid]];
        NSString *time = [timeNode.text.trim stringByReplacingOccurrencesOfString:@"发表于 " withString:@""];
        post.postTime = [CommonUtils timeForShort:time withFormat:@"yyyy-MM-dd HH:mm"];

        //4. content
        IGHTMLDocument *contentDoc = [[IGHTMLDocument alloc] initWithHTMLString:postNodeHtml error:nil];
        IGXMLNode *contentNode = [contentDoc queryNodeWithClassName:@"t_fsz"];
        NSString *contentHtml = [[contentNode childAt:0] html];
        post.postContent = [NSString stringWithFormat:@"<div class=\"tpc_content\">%@</div>", contentHtml];

        //5. user
        UserCount *user = [[UserCount alloc] init];

        IGXMLNode *userNode = [postNode queryNodeWithXPath:[NSString stringWithFormat:@"//*[@id='favatar%@']", pid]];
        //1. userId
        user.userID = [userNode.html stringWithRegular:@"(?<=uid=)\\d+"];

        //2. userName
        IGHTMLDocument *userDoc = [[IGHTMLDocument alloc] initWithHTMLString:userNode.html error:nil];
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
    NSString *token = @"";
    showThreadPage.securityToken = token;

    // 10. quick reply title
    NSString *quickReplyTitle = @"";
    showThreadPage.quickReplyTitle = quickReplyTitle;

    return showThreadPage;
}

- (ViewForumPage *)parseThreadListFromHtml:(NSString *)html withThread:(int)threadId andContainsTop:(BOOL)containTop {
    IGHTMLDocument *document = [[IGHTMLDocument alloc] initWithHTMLString:html error:nil];

    IGXMLNodeSet *threadNodeSet = [[document queryNodeWithXPath:@"//*[@id=\"moderate\"]/div"] childAt:0].children;

    NSMutableArray<Thread *> *threadList = [NSMutableArray<Thread *> array];

    for (IGXMLNode *threadNode in threadNodeSet) {
        Thread *thread = [[Thread alloc] init];

        // 1. ID
        NSString *tID = [threadNode.html stringWithRegular:@"(?<=tid=)\\d+"];
        thread.threadID = tID;

        // 2. 标题
        // 分类
        IGXMLNode *categoryNode = [[[[threadNode childAt:1] childAt:0] childAt:0] childAt:0];
        // 标题的节点
        IGXMLNode *titleNode = [[[[threadNode childAt:1] childAt:0] childAt:0] childAt:1];
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
        NSString *openCount = [[viewCountNode text] trim];
        thread.openCount = openCount;

        //11. 最后回帖时间
        IGXMLNode *lastPostTimeNode = [[threadNode childAt:1] childAt:1];
        NSString *timeHtml = [lastPostTimeNode childAt:1].text.trim;
        NSString *lastPostTime = [timeHtml stringWithRegular:@"\\d+-\\d+-\\d+ \\d+:\\d+"];
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
        if ([node.html containsString:@"<strong>"]) {
            pageNumber.currentPageNumber = [[node.text trim] intValue];
            break;
        }
    }

    IGXMLNode *totalPageNode = [pgNode childAt:pgNode.childrenCount - 3];
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

    PageNumber *pageNumber = [[PageNumber alloc] init];
    IGXMLNode *pageNode = [document queryNodeWithClassName:@"pg"];
    if (pageNode != nil && pageNode.childrenCount > 0) {
        for (IGXMLNode *n in pageNode.children) {
            if ([[n.html trim] hasPrefix:@"<strong>"]) {
                pageNumber.currentPageNumber = [[[n text] trim] intValue];
                break;
            }
        }
        NSString *pageText = [pageNode.text trim];
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

- (ViewForumPage *)parsePrivateMessageFromHtml:(NSString *)html forType:(int)type {
    ViewForumPage *page = [[ViewForumPage alloc] init];

    IGHTMLDocument *document = [[IGHTMLDocument alloc] initWithHTMLString:html error:nil];

    IGXMLNode *messageNode = [document queryNodeWithXPath:@"//*[@id=\"deletepmform\"]"];
    if (messageNode == nil || messageNode.childrenCount == 0) {
        return page;
    }

    NSMutableArray<BBSPrivateMessage *> *messagesList = [NSMutableArray array];

    PageNumber *pageNumber = [self parserPageNumber:html];

    IGXMLNodeSet *messagesNodeSet = [messageNode childAt:0].children;

    for (IGXMLNode *node in messagesNodeSet) {

        BBSPrivateMessage *message = [[BBSPrivateMessage alloc] init];

        // 1. 是不是未读短信
        message.isReaded = ![[node attribute:@"class"] containsString:@"newpm"];

        // BBSPrivateMessage Id
        message.pmID = [[node attribute:@"id"] stringWithRegular:@"\\d+"];

        // 2. 标题
        IGXMLNode *title = [document queryNodeWithXPath:[NSString stringWithFormat:@"//*[@id=\"pmlist_%@\"]/dd[2]/text()[5]", message.pmID]];
        message.pmTitle = title.text.trim;

        // 3. 发送PM作者
        IGXMLNode *author = [document queryNodeWithXPath:[NSString stringWithFormat:@"//*[@id=\"pmlist_%@\"]/dd[2]/a", message.pmID]];
        message.pmAuthor = author.text.trim;

        // 4. 发送者ID
        message.pmAuthorId = [[author attribute:@"href"] stringWithRegular:@"\\d+"];

        // 5. 时间
        IGXMLNode *timeNode = [document queryNodeWithXPath:[NSString stringWithFormat:@"//*[@id=\"pmlist_%@\"]/dd[2]/span[2]", message.pmID]];
        message.pmTime = [CommonUtils timeForShort:[[timeNode text] trim] withFormat:@"yyyy-MM-dd HH:mm"];

        [messagesList addObject:message];
    }

    page.dataList = [messagesList copy];

    page.pageNumber = pageNumber;

    return page;
}

- (BBSSearchResultPage *)parseSearchPageFromHtml:(NSString *)html {
    BBSSearchResultPage *resultPage = [[BBSSearchResultPage alloc] init];

    NSData *data = [html dataUsingEncoding:NSUTF8StringEncoding];

    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:(NSJSONReadingOptions) kNilOptions error:nil];

    SmartisanHotTHotThreadPage *hotTHotThreadPage = [SmartisanHotTHotThreadPage modelObjectWithDictionary:dictionary];

    PageNumber *pageNumber = [[PageNumber alloc] init];
    pageNumber.currentPageNumber = 1;
    pageNumber.totalPageNumber = (int) hotTHotThreadPage.data.page.pageTotal;
    NSArray<SmartisanHotList *> *list = hotTHotThreadPage.data.list;

    NSMutableArray<Thread *> *dataList = [NSMutableArray array];
    for (SmartisanHotList *tHotList in list) {
        Thread *thread = [[Thread alloc] init];
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

- (BBSSearchResultPage *)parseZhanNeiSearchPageFromHtml:(NSString *)html type:(int)type {
    BBSSearchResultPage *page = [[BBSSearchResultPage alloc] init];

    NSMutableArray<Thread *> *threadList = [NSMutableArray<Thread *> array];

    IGHTMLDocument *document = [[IGHTMLDocument alloc] initWithHTMLString:html error:nil];

    NSString *xpath = @"result f s0";
    if (type == 1) {
        xpath = @"result f s3";
    }
    IGXMLNodeSet *contents = [document queryWithClassName:xpath];
    int childCount = contents.count;

    for (int i = 0; i < childCount; ++i) {
        IGXMLNode *node = contents[(NSUInteger) i];
        IGXMLNode *titleNode = [[node childAt:0] childAt:0];
        NSString *href = [titleNode attribute:@"href"];
        if (![href containsString:@"/thread-"]) {
            continue;
        }

        Thread *thread = [[Thread alloc] init];
        NSString *tid = [href stringWithRegular:@"(?<=thread-)\\d+"];
        NSString *title = [[titleNode text] trim];

        thread.threadID = tid;
        thread.threadTitle = title;

        [threadList addObject:thread];
    }

    page.dataList = threadList;

    // 总页数
    PageNumber *pageNumber = [[PageNumber alloc] init];
    IGXMLNode *curPageNode = [document queryWithClassName:@"pager-current-foot"].firstObject;
    NSString *cnHtml = [curPageNode html];
    int cNumber = [[[curPageNode text] trim] intValue];
    pageNumber.currentPageNumber = cNumber == 0 ? cNumber + 1 : cNumber;
    NSString *totalCount = [[document queryNodeWithXPath:@"//*[@id=\"results\"]/span"].text stringWithRegular:@"\\d+"];
    int tInt = [totalCount intValue];
    if (tInt % 10 == 0) {
        pageNumber.totalPageNumber = [totalCount intValue] / 10;
    } else {
        pageNumber.totalPageNumber = [totalCount intValue] / 10 + 1;
    }

    page.pageNumber = pageNumber;


    return page;
}

- (BBSPrivateMessagePage *)parsePrivateMessageContent:(NSString *)html avatarBase:(NSString *)avatarBase noavatar:(NSString *)avatarNO {

    IGHTMLDocument *document = [[IGHTMLDocument alloc] initWithHTMLString:html error:nil];

    IGXMLNodeSet *pmUlSet = [document queryNodeWithXPath:@"//*[@id=\"pm_ul\"]"].children;

    BBSPrivateMessagePage *privateMessage = [[BBSPrivateMessagePage alloc] init];
    NSMutableArray *datas = [NSMutableArray array];
    privateMessage.viewMessages = datas;
    for (IGXMLNode *node in pmUlSet) {
        BBSPrivateMessageDetail *viewMessage = [[BBSPrivateMessageDetail alloc] init];

        if (![node.tag isEqualToString:@"dl"]) {
            continue;
        }

        IGXMLNode *contentNode = [node childAt:2];
        NSString *fixContent = contentNode.html;
        fixContent = [fixContent removeStringWithRegular:@"<span class=\"xi2 xw1\">\\w+</span>"];
        fixContent = [fixContent removeStringWithRegular:@"(?<=<span class=\"xg1\">)\\d+-\\d+-\\d+ \\d+:\\d+(?=</span>)"];
        fixContent = [fixContent removeStringWithRegular:@"<a href=\"space-uid-\\d+.html\" target=\"_blank\" class=\"xw1\">\\w+</a>"];
        viewMessage.pmContent = fixContent;
        // 回帖时间
        NSString *timeLong = [[[node childAt:2] html] stringWithRegular:@"(?<=<span class=\"xg1\">)\\d+-\\d+-\\d+ \\d+:\\d+(?=</span>)"];
        viewMessage.pmTime = [CommonUtils timeForShort:timeLong withFormat:@"yyyy-MM-dd HH:mm"];
        // PM ID
        NSString *pmId = [[node attribute:@"id"] stringWithRegular:@"\\d+"];
        viewMessage.pmID = pmId;

        // PM Title
        viewMessage.pmTitle = @"NULL";

        // User Info
        UserCount *pmAuthor = [[UserCount alloc] init];
        // 用户名
        NSString *name = [node childAt:2].firstChild.text.trim;
        pmAuthor.userName = name;
        // 用户ID
        NSString *userId = [[[node childAt:2].firstChild attribute:@"href"] stringWithRegular:@"\\d+"];
        pmAuthor.userID = userId;

        // 用户头像
        NSString *userAvatar = [[[node childAt:1].firstChild.firstChild attribute:@"src"] componentsSeparatedByString:@"?"].firstObject;
        if (!userAvatar) {
            userAvatar = avatarNO;
        }
        pmAuthor.userAvatar = userAvatar;

        // 用户等级
        pmAuthor.userRank = @"NULL";
        // 注册日期
        pmAuthor.userSignDate = @"NULL";
        // 帖子数量
        pmAuthor.userPostCount = @"NULL";

        viewMessage.pmUserInfo = pmAuthor;
        [datas addObject:viewMessage];
    }
    return privateMessage;
}

- (CountProfile *)parserProfile:(NSString *)html userId:(NSString *)userId {
    IGHTMLDocument *document = [[IGHTMLDocument alloc] initWithHTMLString:html error:nil];

    CountProfile *userProfile = [[CountProfile alloc] init];
    userProfile.profileUserId = userId;

    IGXMLNode *info = [document queryNodeWithXPath:@"//*[@id=\"ct\"]/div/div[2]/div/div[1]/div[3]"];
    NSString *infoHtml = info.html;

    userProfile.profileRank = [info.html stringWithRegular:@"(?<=_blank\">)第 \\d+ 级(?=</a>)"];

    IGXMLNode *nameNode = [document queryNodeWithXPath:@"//*[@id=\"uhd\"]/div/h2"];
    userProfile.profileName = [nameNode.text trim];


    //<li><em>注册时间</em>2014-7-24 10:15</li>
    userProfile.profileRegisterDate = [infoHtml stringWithRegular:@"(?<=注册时间</em>)\\d+-\\d+-\\d+ \\d+:\\d+"];
    userProfile.profileRecentLoginDate = [infoHtml stringWithRegular:@"(?<=最后访问</em>)\\d+-\\d+-\\d+ \\d+:\\d+"];;

    NSString *replyCount = [html stringWithRegular:@"(?<=回帖数 )\\d+"];
    NSString *threadCount = [html stringWithRegular:@"(?<=主题数 )\\d+"];
    int count = [replyCount intValue] + [threadCount intValue];

    userProfile.profileTotalPostCount = [NSString stringWithFormat:@"%d", count];
    return userProfile;
}

- (NSArray<Forum *> *)parserForums:(NSString *)html forumHost:(NSString *)host {
    IGHTMLDocument *document = [[IGHTMLDocument alloc] initWithHTMLString:html error:nil];

    IGXMLNode *fourRowNode = [document queryNodeWithXPath:@"//*[@id=\"srchfid\"]"];

    NSMutableArray<Forum *> *forums = [NSMutableArray array];

    Forum *lastForum = nil;
    NSMutableArray<Forum *> *childForums = [NSMutableArray array];
    int replaceId = 10000;
    for (IGXMLNode *child in fourRowNode.children) {

        if (child.childrenCount == 0) {
            continue;
        }

        // 总分类
        Forum *parent = [[Forum alloc] init];

        NSString *pName = [[child attribute:@"label"] stringByReplacingOccurrencesOfString:@"--" withString:@""];
        parent.forumName = pName;
        parent.forumId = replaceId++;
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
            if ([nameOrg containsString:@"      "]) {
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

- (NSMutableArray<Forum *> *)parseFavForumFromHtml:(NSString *)html {
    IGHTMLDocument *document = [[IGHTMLDocument alloc] initWithHTMLString:html error:nil];
    //*[@id="favorite_ul"]
    IGXMLNode *favoriteUl = [document queryNodeWithXPath:@"//*[@id=\"favorite_ul\"]"];
    IGXMLNodeSet *favoriteLis = favoriteUl.children;

    NSMutableArray *ids = [NSMutableArray array];

    for (IGXMLNode *favLi in favoriteLis) {
        IGXMLNode *forumIdNode = [favLi childAt:2];
        NSString *forumIdNodeHtml = forumIdNode.html;
        //<a href="forum-196-1.html" target="_blank">GALAX</a>
        NSString *idsStr = [forumIdNodeHtml stringWithRegular:@"forum-\\d+" andChild:@"\\d+"];
        [ids addObject:@(idsStr.intValue)];
        NSLog(@"%@", forumIdNodeHtml);
    }

    // 通过ids 过滤出Form
    BBSCoreDataManager *manager = [[BBSCoreDataManager alloc] initWithEntryType:EntryTypeForm];
    BBSLocalApi *localeForumApi = [[BBSLocalApi alloc] init];
    NSArray *result = [manager selectData:^NSPredicate * {
        return [NSPredicate predicateWithFormat:@"forumHost = %@ AND forumId IN %@", localeForumApi.currentForumHost, ids];
    }];

    NSMutableArray<Forum *> *forms = [NSMutableArray arrayWithCapacity:result.count];

    for (ForumEntry *entry in result) {
        Forum *form = [[Forum alloc] init];
        form.forumName = entry.forumName;
        form.forumId = [entry.forumId intValue];
        [forms addObject:form];
    }
    return forms;
}

- (PageNumber *)parserPageNumber:(NSString *)html {
    IGHTMLDocument *document = [[IGHTMLDocument alloc] initWithHTMLString:html error:nil];

    PageNumber *pageNumber = [[PageNumber alloc] init];

    IGXMLNode *rootNode = [document queryNodeWithClassName:@"pgt"];

    if (rootNode && rootNode.children != nil && rootNode.childrenCount > 0) {
        IGXMLNode *pgNode = [rootNode childAt:0];

        if (pgNode.childrenCount > 0) {
            for (IGXMLNode *node in pgNode.children) {
                if ([node.html containsString:@"<strong>"]) {
                    NSString *cPage = [node.text trim];
                    pageNumber.currentPageNumber = [cPage intValue];
                    break;
                }
            }

            IGXMLNode *totalPageNode = [pgNode childAt:pgNode.childrenCount - 3];
            NSString *totalPage = [totalPageNode.text.trim stringByReplacingOccurrencesOfString:@"... " withString:@""];
            pageNumber.totalPageNumber = [totalPage intValue];

            return pageNumber;
        }
    }
    pageNumber.totalPageNumber = 1;
    pageNumber.currentPageNumber = 1;

    return pageNumber;
}

- (NSString *)parseUserAvatar:(NSString *)html userId:(NSString *)userId {
    IGHTMLDocument *document = [[IGHTMLDocument alloc] initWithHTMLString:html error:nil];
    IGXMLNode *avatarNode = [document queryNodeWithClassName:@"icn avt"];
    NSString *attrSrc = [[avatarNode.firstChild.firstChild attribute:@"src"] stringByReplacingOccurrencesOfString:@"_avatar_small" withString:@"_avatar_middle"];
    return attrSrc;
}

- (NSString *)parseListMyThreadSearchId:(NSString *)html {
    return nil;
}

- (NSString *)parseErrorMessage:(NSString *)html {
    return nil;
}

- (ViewForumPage *)parsePrivateMessageFromHtml:(NSString *)html {
    ViewForumPage *page = [[ViewForumPage alloc] init];

    IGHTMLDocument *document = [[IGHTMLDocument alloc] initWithHTMLString:html error:nil];

    IGXMLNode *pmRootNode = [document queryNodeWithXPath:@"//*[@id=\"deletepmform\"]/div[1]"];

    //forumHash
    NSString *forumHash = [html stringWithRegular:@"(?<=<input type=\"hidden\" name=\"formhash\" value=\")\\w+(?=\" />)"];

    NSMutableArray<BBSPrivateMessage *> *messagesList = [NSMutableArray array];
    for (IGXMLNode *pmNode in pmRootNode.children) {
        BBSPrivateMessage *message = [[BBSPrivateMessage alloc] init];
        NSString *newPm = [pmNode attribute:@"class"];
        BOOL isReaded = ![newPm isEqualToString:@"bbda cur1 cl newpm"];
        NSString *pmId = [[pmNode attribute:@"id"] componentsSeparatedByString:@"_"].lastObject;

        //*[@id="pmlist_973711"]/dd[2]/text()[1]
        IGXMLNodeSet *dd = [pmNode queryWithXPath:@"dd[2]/text()"];
        NSString *title = [[[dd[4] text] trim] stringByReplacingOccurrencesOfString:@"\n" withString:@" "];

        IGXMLNode *authorNode = [pmNode queryWithXPath:@"dd[2]/a"].firstObject;
        NSString *authorName = [[authorNode text] trim];
        NSString *authorId = [[authorNode attribute:@"href"] stringWithRegular:@"\\d+"];

        IGXMLNode *timeNode = [pmNode queryWithXPath:@"dd[2]/span[2]"].firstObject;
        NSString *time = [timeNode text];

        message.isReaded = isReaded;
        message.pmID = pmId;
        message.pmAuthor = authorName;
        message.pmAuthorId = authorId;
        message.pmTime = time;
        message.pmTitle = title;

        message.forumhash = forumHash;

        [messagesList addObject:message];

    }

    page.dataList = messagesList;
    PageNumber *pageNumber = [self parserPageNumber:html];
    page.pageNumber = pageNumber;
    return page;
}

- (ViewForumPage *)parseNoticeMessageFromHtml:(NSString *)html {
    ViewForumPage *page = [[ViewForumPage alloc] init];

    IGHTMLDocument *document = [[IGHTMLDocument alloc] initWithHTMLString:html error:nil];

    IGXMLNode *messageNode = [document queryNodeWithClassName:@"nts"];
    if (messageNode == nil || messageNode.childrenCount == 0) {
        return page;
    }

    NSMutableArray<BBSPrivateMessage *> *messagesList = [NSMutableArray array];

    PageNumber *pageNumber = [self parserPageNumber:html];

    IGXMLNodeSet *messagesNodeSet = messageNode.children;

    for (IGXMLNode *node in messagesNodeSet) {

        BBSPrivateMessage *message = [[BBSPrivateMessage alloc] init];

        // 1. 是不是未读短信
        message.isReaded = ![[node attribute:@"class"] containsString:@"newpm"];

        // BBSPrivateMessage Id
        message.pmID = [[node attribute:@"notice"] stringWithRegular:@"\\d+"];

        // 2. 标题
        IGXMLNode *title = [node childAt:2];
        message.pmTitle = title.text.trim;

        // 3. 发送PM作者
        IGXMLNode *authorNode = [node childAt:0];
        message.pmAuthor = authorNode.text.trim;

        // 4. 发送者ID
        message.pmAuthorId = [authorNode.html stringWithRegular:@"(?<=uid-)\\d+"];

        // 5. 时间
        IGXMLNode *timeNode = [node childAt:1];
        message.pmTime = [CommonUtils timeForShort:[[timeNode text] trim] withFormat:@"yyyy-MM-dd HH:mm"];

        [messagesList addObject:message];
    }

    page.dataList = [messagesList copy];

    page.pageNumber = pageNumber;

    return page;
}

- (NSString *)parseSecurityToken:(NSString *)html {
    //<input type="hidden" name="formhash" value="fc436b99" />
    NSString *forumHashHtml = [html stringWithRegular:@"<input type=\"hidden\" name=\"formhash\" value=\"\\w+\" />" andChild:@"value=\"\\w+\""];
    NSString *forumHash = [[forumHashHtml componentsSeparatedByString:@"="].lastObject stringByReplacingOccurrencesOfString:@"\"" withString:@""];
    return forumHash;
}

- (NSArray *)flatForm:(Forum *)form {
    NSMutableArray *resultArray = [NSMutableArray array];
    [resultArray addObject:form];
    for (Forum *childForm in form.childForums) {
        [resultArray addObjectsFromArray:[self flatForm:childForm]];
    }
    return resultArray;
}

- (NSString *)parsePostHash:(NSString *)html {
    //<input type="hidden" name="formhash" value="142b2f4e" />
    NSString *forumHash = [html stringWithRegular:@"(?<=<input type=\"hidden\" name=\"formhash\" value=\")\\w+(?=\" />)"];
    return forumHash;
}

@end
