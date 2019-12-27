//
//  CrskyForumHtmlParser.m
//  Created by Diyuan Wang on 2019/11/21.
//  Copyright © 2019年 Diyuan Wang. All rights reserved.
//

#import "FeiFanHtmlParser.h"
#import "IGHTMLDocument.h"
#import "IGHTMLDocument+QueryNode.h"
#import "IGXMLNode+Children.h"
#import "NSString+Extensions.h"
#import "BBSLocalApi.h"
#import "CommonUtils.h"
#import "BBSPrivateMessage.h"
#import "BBSUser.h"

@implementation FeiFanHtmlParser {
    BBSLocalApi *localApi;
    BBSUser *loginUser;
}


- (instancetype)init {
    self = [super init];
    if (self) {
        localApi = [[BBSLocalApi alloc] init];
    }
    return self;
}

- (ViewThreadPage *)parseShowThreadWithHtml:(NSString *)html {
    NSArray *fontSetString = [html arrayWithRegular:@"<font size=\"\\d+\">"];

    NSString *fixFontSizeHTML = html;

    for (NSString *tmp in fontSetString) {
        fixFontSizeHTML = [fixFontSizeHTML stringByReplacingOccurrencesOfString:tmp withString:@"<font size=\"\2\">"];
    }

    NSString *fixedHtml = fixFontSizeHTML;

    IGHTMLDocument *document = [[IGHTMLDocument alloc] initWithHTMLString:fixedHtml error:nil];

    ViewThreadPage *showThreadPage = [[ViewThreadPage alloc] init];
    //1. tid
    int tid = [[fixedHtml stringWithRegular:@"(?<=tid=)\\d+"] intValue];
    showThreadPage.threadID = tid;

    //2. fid
    int fid = [[fixedHtml stringWithRegular:@"(?<=fid=)\\d+"] intValue];
    showThreadPage.forumId = fid;

    //3. title
    IGXMLNode *titleNode = [document queryNodeWithClassName:@"crumbs-item current"];
    NSString *title = titleNode.text.trim;
    showThreadPage.threadTitle = title;

    //4. posts
    NSMutableArray *posts = [self parseShowThreadPosts:document];
    showThreadPage.postList = posts;

    //5. orgHtml
    NSString *orgHtml = [self postMessages:fixedHtml];
    showThreadPage.originalHtml = orgHtml;

    //6. number
    PageNumber *pageNumber = [self parserPageNumber:fixedHtml];
    showThreadPage.pageNumber = pageNumber;

    //7. token
    NSString *token = [self token:fixedHtml];
    showThreadPage.securityToken = token;

    // 10. quick reply title
    NSString *quickReplyTitle = [fixedHtml stringWithRegular:@"(?<=<input type=\"text\" class=\"input\" name=\"atc_title\" value=\")[\\S\\s]+(?=\" size=\"65\" />)"];
    showThreadPage.quickReplyTitle = quickReplyTitle;

    return showThreadPage;
}

- (ViewForumPage *)parseThreadListFromHtml:(NSString *)html withThread:(int)threadId andContainsTop:(BOOL)containTop {
    IGHTMLDocument *document = [[IGHTMLDocument alloc] initWithHTMLString:html error:nil];
    IGXMLNodeSet *threadNodeSet = [document queryWithClassName:@"tr3 t_one"];

    ViewForumPage *threadListPage = [[ViewForumPage alloc] init];
    NSMutableArray<Thread *> *threads = [NSMutableArray<Thread *> array];

    for (int i = 0; i < threadNodeSet.count; i++) {
        IGXMLNode *threadNode = threadNodeSet[(NSUInteger) i];

        if (threadNode.children.count >= 5) { // 要>=5的原因是：过滤已经被删除的帖子 以及 被移动的帖子

            Thread *thread = [[Thread alloc] init];

            // 1. ID
            NSString *tID = [threadNode.html stringWithRegular:@"(?<=tid=)\\d+"];
            thread.threadID = tID;

            // 2. 标题
            NSString *title = nil;
            // 分类和标题的节点
            IGXMLNode *categoryTitleNode = [threadNode childAt:1];

            NSString *tag = [categoryTitleNode childAt:0].tag;

            if ([tag isEqualToString:@"h3"]) {
                // 置顶公告
                title = [categoryTitleNode.text.trim stringByReplacingOccurrencesOfString:@"&nbsp" withString:@""];
                continue;
            } else if ([tag isEqualToString:@"img"]) {
                // 置顶公告
                title = [categoryTitleNode.text.trim stringByReplacingOccurrencesOfString:@"\t" withString:@""];
            } else if ([tag isEqualToString:@"span"] || [tag isEqualToString:@"a"]) {
                // 使用了沉淀卡之之类的 和 // 正常的主题
                NSMutableString *mtitle = [NSMutableString string];
                for (IGXMLNode *node in categoryTitleNode.children) {
                    NSString *text = node.text.trim;
                    [mtitle appendString:text];
                    if ([node.tag isEqualToString:@"h3"]) {
                        break;
                    }
                }
                title = [mtitle copy];
            }
            if (title == nil) {
                title = @"[Error-请联系开发者反馈BUG]";
            }

            thread.threadTitle = title;


            NSLog(@"p_title \t%@", title);
            //3 是否是置顶帖子
            BOOL isTop = [categoryTitleNode.html containsString:@"title=\"置顶帖标志\""];
            thread.isTopThread = isTop;

            //4 是否是精华帖子
            BOOL isGoodness = [categoryTitleNode.html containsString:@"title=\"精华帖标志\""];
            thread.isGoodNess = isGoodness;

            //5 是否包含图片
            BOOL isContainsImage = [categoryTitleNode.html containsString:@"file/img.gif"];
            thread.isContainsImage = isContainsImage;

            //6 总回帖页数
            int totalPage = 1;
            BOOL isMoreThanOnePage = [categoryTitleNode.html containsString:@"multipage.gif"];
            if (isMoreThanOnePage) {
                IGXMLNode *totalPageNode = categoryTitleNode.children[(NSUInteger) (categoryTitleNode.childrenCount - 1)];
                IGXMLNode *pageNode = totalPageNode.children[(NSUInteger) (totalPageNode.childrenCount - 1)];
                IGXMLNode *numberNode = pageNode.children[(NSUInteger) (pageNode.childrenCount - 1)];
                int number = [numberNode.text intValue];
                totalPage = number;
            }
            thread.totalPostPageCount = totalPage;


            IGXMLNode *authorNode = [threadNode childAt:2];
            //7. 帖子作者
            NSString *authorName = [authorNode childAt:0].text.trim;
            thread.threadAuthorName = authorName;

            //8. 作者ID
            thread.threadAuthorID = [self userId:[authorNode childAt:0].html];

            //9. 回复数量
            IGXMLNode *postOpenNode = [threadNode childAt:3];
            NSString *postOpen = postOpenNode.text.trim;
            NSString *postCount = [postOpen componentsSeparatedByString:@"/"][0].trim;
            thread.postCount = postCount;

            //10. 查看数量
            NSString *openCount = [postOpen componentsSeparatedByString:@"/"][1].trim;
            thread.openCount = openCount;

            IGXMLNode *lastPostTimeNode = [threadNode childAt:4];
            //11. 最后回帖时间
            NSString *lastPostTime = [lastPostTimeNode childAt:0].text.trim;
            thread.lastPostTime = [CommonUtils timeForShort:lastPostTime withFormat:@"yyyy-MM-dd HH:mm"];

            //12. 最后发表的人
            NSString *lastPostAuthorName = [[lastPostTimeNode childAt:1].text.trim stringByReplacingOccurrencesOfString:@"by: " withString:@""];
            thread.lastPostAuthorName = lastPostAuthorName;

            [threads addObject:thread];
        }
    }
    threadListPage.dataList = threads;

    PageNumber *pageNumber = [self parserPageNumber:html];
    threadListPage.pageNumber = pageNumber;

    //forumID
    IGXMLNode *forumId = [document queryNodeWithClassName:@"crumbs-item current"];
    int fid = [[forumId.html stringWithRegular:@"(?<=fid=)\\d+"] intValue];
    threadListPage.forumId = fid;

    threadListPage.token = [self token:html];
    return threadListPage;
}

- (ViewForumPage *)parseFavorThreadListFromHtml:(NSString *)html {
    ViewForumPage *page = [[ViewForumPage alloc] init];

    NSMutableArray<Thread *> *threadList = [NSMutableArray<Thread *> array];

    IGHTMLDocument *document = [[IGHTMLDocument alloc] initWithHTMLString:html error:nil];

    IGXMLNodeSet *contents = [document queryWithXPath:@"//*[@id=\"u-contentmain\"]/form/table/tr[position()>1]"];

    for (IGXMLNode *node in contents) {
        Thread *simpleThread = [[Thread alloc] init];

        //分离出Title
        simpleThread.threadTitle = [node childAt:0].text.trim;

        // Id
        simpleThread.threadID = [[node childAt:0].html stringWithRegular:@"(?<=tid=)\\d+"];

        simpleThread.threadAuthorID = [self userId:[node childAt:1].html];

        simpleThread.threadAuthorName = [node childAt:1].text.trim;

        simpleThread.lastPostTime = @"";

        [threadList addObject:simpleThread];
    }

    page.pageNumber = [self parserPageNumber:html];
    page.dataList = threadList;

    return page;
}

- (ViewForumPage *)parseListMyAllThreadsFromHtml:(NSString *)html {
    ViewForumPage *page = [[ViewForumPage alloc] init];

    NSMutableArray<Thread *> *threadList = [NSMutableArray<Thread *> array];

    IGHTMLDocument *document = [[IGHTMLDocument alloc] initWithHTMLString:html error:nil];

    IGXMLNodeSet *contents = [document queryWithXPath:@"//*[@id=\"u-contentmain\"]/table/tr[position()>1]"];

    for (IGXMLNode *node in contents) {
        Thread *simpleThread = [[Thread alloc] init];

        //分离出Title
        simpleThread.threadTitle = [[node childAt:0] childAt:0].text.trim;

        // Id
        simpleThread.threadID = [[node childAt:0].html stringWithRegular:@"(?<=tid=)\\d+"];

        simpleThread.threadAuthorID = [self userId:html];

        IGXMLNode *nameNode = [document queryNodeWithClassName:@"u-h1"];
        simpleThread.threadAuthorName = nameNode.text.trim;

        simpleThread.lastPostTime = [[[[node childAt:0] childAt:3].text.trim
                stringByReplacingOccurrencesOfString:@"[" withString:@""]
                stringByReplacingOccurrencesOfString:@"]" withString:@""];

        simpleThread.fromFormName = [[node childAt:0] childAt:2].text.trim;

        [threadList addObject:simpleThread];
    }

    page.pageNumber = [self parserPageNumber:html];
    page.dataList = threadList;

    return page;
}

- (ViewForumPage *)parsePrivateMessageFromHtml:(NSString *)html forType:(int)type {
    ViewForumPage *page = [[ViewForumPage alloc] init];

    IGHTMLDocument *document = [[IGHTMLDocument alloc] initWithHTMLString:html error:nil];

    NSMutableArray<BBSPrivateMessage *> *messagesList = [NSMutableArray array];

    PageNumber *pageNumber = [self parserPageNumber:html];

    if (type == 0) {

        if (pageNumber.currentPageNumber < 2) {

            IGXMLNodeSet *systemMessageSet = [document queryWithXPath:@"//*[@id=\"info_public\"]/table/tr[position()>1]"];
            for (IGXMLNode *node in systemMessageSet) {
                long childCount = (long) [[node children] count];
                if (childCount == 5) {
                    // 有4个节点说明是正常的站内短信
                    BBSPrivateMessage *message = [[BBSPrivateMessage alloc] init];

                    NSString *msgHtml = node.html;

                    // 1. 是不是未读短信
                    message.isReaded = ![msgHtml containsString:@"class=\"b\""];

                    // 2. 标题
                    IGXMLNode *title = [node childAt:2];
                    message.pmTitle = title.text.trim;

                    // BBSPrivateMessage Id
                    message.pmID = [msgHtml stringWithRegular:@"(?<=mid=)\\d+"];

                    // 3. 发送PM作者
                    IGXMLNode *author = [node childAt:1];
                    message.pmAuthor = author.text.trim;

                    // 4. 发送者ID
                    message.pmAuthorId = @"-1";

                    // 5. 时间
                    NSString *time = [node childAt:3].text.trim;
                    message.pmTime = [CommonUtils timeForShort:time withFormat:@"yyyy-MM-dd HH:mm"];

                    [messagesList addObject:message];

                }
            }
        }

        IGXMLNodeSet *privateMessageSet = [document queryWithXPath:@"//*[@id=\"info_base\"]/div[1]/table/tr[position()>2]"];
        for (IGXMLNode *node in privateMessageSet) {
            long childCount = (long) [[node children] count];
            if (childCount == 5) {
                // 有4个节点说明是正常的站内短信
                BBSPrivateMessage *message = [[BBSPrivateMessage alloc] init];

                NSString *msgHtml = node.html;

                // 1. 是不是未读短信
                message.isReaded = ![msgHtml containsString:@"class=\"b\""];

                // 2. 标题
                IGXMLNode *title = [node childAt:2];
                message.pmTitle = title.text.trim;

                // BBSPrivateMessage Id
                message.pmID = [msgHtml stringWithRegular:@"(?<=mid=)\\d+"];

                // 3. 发送PM作者
                IGXMLNode *author = [node childAt:1];
                message.pmAuthor = author.text.trim;

                // 4. 发送者ID
                message.pmAuthorId = [self userId:msgHtml];

                // 5. 时间
                NSString *time = [node childAt:3].text.trim;
                message.pmTime = [CommonUtils timeForShort:time withFormat:@"yyyy-MM-dd HH:mm"];

                [messagesList addObject:message];

            }
        }
    } else {
        IGXMLNodeSet *privateMessageSet = [document queryWithXPath:@"//*[@id=\"info_base\"]/table/tr[position()>1]"];
        for (IGXMLNode *node in privateMessageSet) {
            long childCount = (long) [[node children] count];
            if (childCount == 5) {
                // 有4个节点说明是正常的站内短信
                BBSPrivateMessage *message = [[BBSPrivateMessage alloc] init];

                NSString *msgHtml = node.html;

                // 1. 是不是未读短信
                message.isReaded = ![msgHtml containsString:@"class=\"b\""];

                // 2. 标题
                IGXMLNode *title = [node childAt:2];
                message.pmTitle = title.text.trim;

                // BBSPrivateMessage Id
                message.pmID = [msgHtml stringWithRegular:@"(?<=mid=)\\d+"];

                // 3. 发送PM作者
                IGXMLNode *author = [node childAt:1];
                message.pmAuthor = author.text.trim;

                // 4. 发送者ID
                message.pmAuthorId = [self userId:msgHtml];

                // 5. 时间
                NSString *time = [node childAt:3].text.trim;
                message.pmTime = [CommonUtils timeForShort:time withFormat:@"yyyy-MM-dd HH:mm"];

                [messagesList addObject:message];

            }
        }
    }

    page.pageNumber = [self parserPageNumber:html];
    page.dataList = messagesList;

    return page;
}

- (BBSSearchResultPage *)parseSearchPageFromHtml:(NSString *)html {
    IGHTMLDocument *document = [[IGHTMLDocument alloc] initWithHTMLString:html error:nil];

    BBSSearchResultPage *resultPage = [[BBSSearchResultPage alloc] init];
    NSMutableArray<Thread *> *threads = [NSMutableArray array];

    IGXMLNodeSet *searchNodeSet = [document queryWithClassName:@"tr3 tac"];

    for (IGXMLNode *threadNode in searchNodeSet) {
        NSString *h = threadNode.html;
        NSLog(@"Scrsky_parser \t%@", h);

        Thread *thread = [[Thread alloc] init];

        // 1. ID
        NSString *tID = [threadNode.html stringWithRegular:@"(?<=tid=)\\d+"];
        thread.threadID = tID;

        // 2. 标题
        // 分类和标题的节点
        IGXMLNode *categoryTitleNode = [threadNode childAt:1];
        NSString *title = [categoryTitleNode.text.trim stringByReplacingOccurrencesOfString:@"&nbsp" withString:@""];
        thread.threadTitle = title;

        //3 是否是置顶帖子
        BOOL isTop = NO;
        thread.isTopThread = isTop;

        //4 是否是精华帖子
        BOOL isGoodness = NO;
        thread.isGoodNess = isGoodness;

        //5 是否包含图片
        BOOL isContainsImage = NO;
        thread.isContainsImage = isContainsImage;

        //6 总回帖页数
        int totalPage = 1;
        thread.totalPostPageCount = totalPage;

        IGXMLNode *authorNode = [threadNode childAt:3];
        //7. 帖子作者
        NSString *authorName = [authorNode childAt:0].text.trim;
        thread.threadAuthorName = authorName;

        //8. 作者ID
        thread.threadAuthorID = [self userId:[authorNode childAt:0].html];

        //9. 回复数量
        IGXMLNode *postCountNode = [threadNode childAt:4];
        NSString *postCount = postCountNode.text.trim;
        thread.postCount = postCount;

        //10. 查看数量
        IGXMLNode *openCountNode = [threadNode childAt:5];
        NSString *openCount = openCountNode.text.trim;
        thread.openCount = openCount;

        IGXMLNode *lastPostTimeNode = [threadNode childAt:6];
        //11. 最后回帖时间
        NSString *lastPostTime = [lastPostTimeNode childAt:0].text.trim;
        thread.lastPostTime = [CommonUtils timeForShort:lastPostTime withFormat:@"yyyy-MM-dd HH:mm"];

        //12. 最后发表的人
        NSString *lastPostAuthorName = [lastPostTimeNode.text componentsSeparatedByString:@"by: "].lastObject;
        thread.lastPostAuthorName = lastPostAuthorName;

        //13. 所属论坛名称
        IGXMLNode *fourumNmaeNode = [threadNode childAt:2];
        NSString *forumName = fourumNmaeNode.text.trim;
        thread.fromFormName = forumName;

        if (loginUser == nil) {
            NSString *url = localApi.currentForumHost;
            loginUser = [localApi getLoginUser:url];
        }
        BOOL special = [loginUser.userName isEqualToString:@"pobaby"];

        NSArray *blackList = @[@"口- 非凡AD区", @"电影资源区", @"口- 虚拟交易", @"剧集资源区", @"口- 谈股论金", @"≮交易交流区≯", @"≮体坛竞猜≯", @"口- 实物交易", @"口- 交易事务", @"口- 苹果专区", @"╃资源专区=-", @"╃交易理财=-", @"娱乐资源区", @"综艺纪录片资源区", @"游戏动漫资源区"];

        if (special) {
            if ([blackList containsObject:forumName]) {
                continue;
            }
        }

        [threads addObject:thread];
    }

    resultPage.dataList = threads;

    // search id
    NSString *searchId = [html stringWithRegular:@"(?<=sid=)\\d+"];
    resultPage.searchId = searchId;

    // page Number
    resultPage.pageNumber = [self parserPageNumber:html];


    return resultPage;
}

- (BBSSearchResultPage *)parseZhanNeiSearchPageFromHtml:(NSString *)html type:(int)type {
    return nil;
}

- (BBSPrivateMessagePage *)parsePrivateMessageContent:(NSString *)html avatarBase:(NSString *)avatarBase noavatar:(NSString *)avatarNO {

    BBSPrivateMessagePage *privateMessage = [[BBSPrivateMessagePage alloc] init];

    BBSPrivateMessageDetail *viewMessage = [[BBSPrivateMessageDetail alloc] init];


    IGHTMLDocument *document = [[IGHTMLDocument alloc] initWithHTMLString:html error:nil];
    IGXMLNode *infoBaseNode = [document queryNodeWithXPath:@"//*[@id=\"info_base\"]"];
    // pm ID
    NSString *pmId = [infoBaseNode.html stringWithRegular:@"(?<=mid=)\\d+"];
    viewMessage.pmID = pmId;

    // pm Title
    NSString *pmTitle = [[[infoBaseNode childAt:0] childAt:1] childAt:1].text.trim;
    viewMessage.pmTitle = pmTitle;

    NSString *pmTime = [[[infoBaseNode childAt:0] childAt:2] childAt:1].text.trim;
    viewMessage.pmTime = [CommonUtils timeForShort:pmTime withFormat:@"yyyy-MM-dd HH:mm"];

    NSString *pmContent = [[[infoBaseNode childAt:0] childAt:3] childAt:1].html;
    NSString *content = [NSString stringWithFormat:@"<div style=\"overflow-x: hidden;\">%@</div>", pmContent];
    viewMessage.pmContent = content;

    UserCount *pmAuthor = [[UserCount alloc] init];
    IGXMLNode *authorNode = [[[infoBaseNode childAt:0] childAt:0] childAt:1];
    pmAuthor.userName = authorNode.text.trim;
    pmAuthor.userID = [self userId:authorNode.html];

    viewMessage.pmUserInfo = pmAuthor;

    NSMutableArray *datas = [NSMutableArray array];
    [datas addObject:viewMessage];

    privateMessage.viewMessages = datas;
    return privateMessage;
}

- (CountProfile *)parserProfile:(NSString *)html userId:(NSString *)userId {
    CountProfile *profile = [[CountProfile alloc] init];
    // 用户名
    profile.profileName = [html stringWithRegular:@"(?<=<h1 class=\"u-h1\">)\\S+(?=</h1>)"];

    // 用户等级
    profile.profileRank = [html stringWithRegular:@"(?<=<td class=\"gray3\">等级</td><td>)\\S+(?=</td></tr>)"];

    // 注册日期
    profile.profileRegisterDate = [html stringWithRegular:@"(?<=<td>注册时间 </td> \t\t\t\t\t<th>)\\d+-\\d+-\\d+ \\d+:\\d+:\\d+(?=</th>)"];

    // 最近活动时间
    NSString *lastDay = [html stringWithRegular:@"(?<=<td>最后登录</td> \t\t\t\t\t<th>)\\d+-\\d+-\\d+ \\d+:\\d+:\\d+(?=</th>)"];
    profile.profileRecentLoginDate = lastDay;

    // 帖子总数
    NSString *postCount = [html stringWithRegular:@"(?<=<td>发帖</td> 					<th>)\\d+(?= </th>)"];
    profile.profileTotalPostCount = postCount;


    profile.profileUserId = userId;
    return profile;
}

- (NSArray<Forum *> *)parserForums:(NSString *)html forumHost:(NSString *)host {
    IGHTMLDocument *document = [[IGHTMLDocument alloc] initWithHTMLString:html error:nil];

    IGXMLNode *topNode = [document queryNodeWithClassName:@"contentwrap z"];

    NSMutableArray<Forum *> *forums = [NSMutableArray array];

    if (loginUser == nil) {
        NSString *url = localApi.currentForumHost;
        loginUser = [localApi getLoginUser:url];
    }
    BOOL special = [loginUser.userName isEqualToString:@"pobaby"];

    NSArray *blackList = @[@"口- 非凡AD区", @"电影资源区", @"口- 虚拟交易", @"剧集资源区", @"口- 谈股论金", @"≮交易交流区≯", @"≮体坛竞猜≯", @"口- 实物交易", @"口- 交易事务", @"口- 苹果专区", @"╃资源专区=-", @"╃交易理财=-", @"娱乐资源区", @"综艺纪录片资源区", @"游戏动漫资源区"];

    int replaceId = 10000;
    for (IGXMLNode *forumP in topNode.children) {
        Forum *parent = [[Forum alloc] init];

        NSString *parentName = [forumP childAt:0].html;
        NSLog(@"%@", parentName);

        IGXMLNode *nameTitleNode = [[[forumP childAt:0] childAt:0] childAt:0];
        NSString *name = [[nameTitleNode childAt:nameTitleNode.childrenCount - 1] childAt:0].text;
        if (special) {
            if ([blackList containsObject:name]) {
                continue;
            }
        }

        parent.forumName = name;
        parent.forumId = replaceId++;
        parent.forumHost = host;
        parent.parentForumId = -1;

        [forums addObject:parent];

        // 正式论坛

        for (IGXMLNode *forumNode in [[forumP childAt:0] childAt:2].children) {

            if ([[forumNode attribute:@"class"] isEqualToString:@"tr3 f_one"]) {
                Forum *forum = [[Forum alloc] init];
                IGXMLNode *tileNode = [[[forumNode childAt:1] childAt:0] firstChild];

                NSString *forumName = tileNode.text.trim;

                if (special) {
                    if ([blackList containsObject:forumName]) {
                        continue;
                    }
                }

                forum.forumName = forumName;
                forum.forumId = [[tileNode.html stringWithRegular:@"(?<=fn_)\\d+"] intValue];
                forum.forumHost = host;
                forum.parentForumId = parent.forumId;

                [forums addObject:forum];
                // 子论坛
                int count = [forumNode childAt:1].childrenCount;
                NSString *childHtml = [[forumNode childAt:1] childAt:count - 1].html;
                IGHTMLDocument *childForumDoc = [[IGHTMLDocument alloc] initWithHTMLString:childHtml error:nil];
                IGXMLNodeSet *childForumSet = [childForumDoc queryWithXPath:@"/html/body/div/span/a[position()>0]"];
                int c = childForumSet.count;
                for (IGXMLNode *childForumNode in childForumSet) {
                    Forum *childForum = [[Forum alloc] init];

                    NSString *childForumName = childForumNode.text.trim;
                    childForum.forumName = childForumName;
                    childForum.forumId = [[childForumNode.html stringWithRegular:@"(?<=fid=)\\d+"] intValue];
                    childForum.forumHost = host;
                    childForum.parentForumId = forum.forumId;

                    [forums addObject:childForum];
                }
            }
        }
    }

    return [forums copy];
}

- (NSMutableArray<Forum *> *)parseFavForumFromHtml:(NSString *)html {
    return nil;
}

- (PageNumber *)parserPageNumber:(NSString *)html {
    IGHTMLDocument *document = [[IGHTMLDocument alloc] initWithHTMLString:html error:nil];
    IGXMLNode *pageNode = [document queryNodeWithClassName:@"pagesone"];
    NSString *pageStr = [pageNode.text.trim stringByReplacingOccurrencesOfString:@" Go " withString:@""];
    PageNumber *pageNumber = [[PageNumber alloc] init];
    int currentPageNumber = [[pageStr componentsSeparatedByString:@"/"][0] intValue];
    int totalPageNumber = [[pageStr componentsSeparatedByString:@"/"][1] intValue];
    if (currentPageNumber == 0 || totalPageNumber == 0) {
        currentPageNumber = 1;
        totalPageNumber = 1;
    }

    pageNumber.currentPageNumber = currentPageNumber;
    pageNumber.totalPageNumber = totalPageNumber;

    return pageNumber;
}

- (NSString *)parseUserAvatar:(NSString *)html userId:(NSString *)userId {
    IGHTMLDocument *document = [[IGHTMLDocument alloc] initWithHTMLString:html error:nil];
    IGXMLNode *picNode = [document queryNodeWithClassName:@"pic"];
    NSString *src = [picNode attribute:@"src"];
    if (!src) {
        return nil;
    }
    if ([src hasPrefix:@"http"]) {
        return src;
    } else {
        return [@"http://bbs.crsky.com/" stringByAppendingString:src];
    }
}

- (NSString *)parseListMyThreadSearchId:(NSString *)html {
    NSString *sid = [html stringWithRegular:@"(?<=sid=)\\d+"];
    return sid;
}

- (NSString *)parseErrorMessage:(NSString *)html {
    if ([html containsString:@"<td class=\"h\" colspan=\"2\">霏凡论坛 - 非凡软件站 提示信息</td>"]) {
        IGHTMLDocument *document = [[IGHTMLDocument alloc] initWithHTMLString:html error:nil];
        IGXMLNode *messageNode = [document queryNodeWithClassName:@"f_one"];
        return messageNode.text.trim;
    }
    return @"未知错误";
}

// private
- (NSMutableArray<PostFloor *> *)parseShowThreadPosts:(IGHTMLDocument *)document {

    IGXMLNodeSet *postSetNode = [document queryWithClassName:@"t5 t2"];

    NSMutableArray *posts = [NSMutableArray array];

    for (IGXMLNode *postNode in postSetNode) {
        PostFloor *post = [[PostFloor alloc] init];
        // 1. postId
        NSString *pid = [postNode.html stringWithRegular:@"(?<=pid=)\\d+"];
        if (!pid) {
            pid = @"tpc";
        }
        post.postID = pid;

        //2. 楼层
        NSString *floor = [postNode.html stringWithRegular:@"(?<=title=\"复制此楼地址\">)\\d+"];
        if (!floor) {
            floor = @"楼主";
        }
        post.postLouCeng = floor;

        IGHTMLDocument *contentDoc = [[IGHTMLDocument alloc] initWithHTMLString:postNode.html error:nil];
        //3. time
        IGXMLNode *timeNode = [contentDoc queryNodeWithClassName:@"fl gray"];
        NSString *time = [timeNode.text.trim stringByReplacingOccurrencesOfString:@"发表于: " withString:@""];
        post.postTime = [CommonUtils timeForShort:time withFormat:@"yyyy-MM-dd HH:mm:ss"];

        //4. content
        IGXMLNodeSet *contentNodeSet = [contentDoc queryWithClassName:@"tpc_content"];

        int childCount = (int) contentNodeSet.count;
        if (childCount == 1) {
            post.postContent = contentNodeSet.firstObject.html;
        } else if (childCount > 1) {

            NSMutableString *content = [NSMutableString string];

            for (IGXMLNode *node in contentNodeSet) {
                if ([node.innerHtml containsString:@"<div class=\"tal s3\">本帖最近评分记录：</div>"]) {
                    continue;
                }
                [content appendString:node.innerHtml];
            }

            post.postContent = [NSString stringWithFormat:@"<div class=\"tpc_content\">%@</div>", [content copy]];
        } else {
            post.postContent = @"错误请联系开发者：pobaby";
        }



        //5. user
        UserCount *user = [[UserCount alloc] init];
        //1. userId
        user.userID = [self userId:postNode.html];

        //2. userName
        IGXMLNode *userNameNode = [contentDoc queryNodeWithClassName:@"fl"];
        NSString *uname = userNameNode.text.trim;
        user.userName = uname;

        //3. avatar
        IGXMLNode *userAvatarNode = [contentDoc queryNodeWithClassName:@"pic"];
        NSString *avatar = [userAvatarNode attribute:@"src"].trim;
        if (avatar) {
            if (![avatar hasPrefix:@"http"]) {
                avatar = [@"http://bbs.crsky.com/" stringByAppendingString:avatar];
            }
        }
        user.userAvatar = avatar;

        //4. rank
        //5. signDate
        //6. postCount
        //7.forumHost
        post.postUserInfo = user;

        [posts addObject:post];
    }

    return posts;
}

// private
- (NSString *)postMessages:(NSString *)html {
    IGHTMLDocument *document = [[IGHTMLDocument alloc] initWithHTMLString:html error:nil];
    IGXMLNodeSet *postMessages = [document queryWithClassName:@"t5 t2"];
    NSMutableString *messages = [NSMutableString string];

    for (IGXMLNode *node in postMessages) {
        [messages appendString:node.text];
    }
    return [messages copy];
}

- (NSString *)token:(NSString *)html {
    NSString *token = [html stringWithRegular:@"(?<=<input type=\"hidden\" name=\"verify\" value=\")\\S+(?=\" />)"];
    return token;
}

- (NSString *)parseSecurityToken:(NSString *)html {
    return [self token:html];
}

- (NSString *)parsePostHash:(NSString *)html {
    return nil;
}

- (NSString *)userId:(NSString *)html {
    NSString *uid = [html stringWithRegular:@"(?<=uid=)\\d+"].trim;
    if ([uid isEqualToString:@"0"]) {
        return @"-1";
    } else {
        return uid;
    }
}

- (void)ul2Forum:(IGXMLNode *)child parent:(Forum *)parent host:(NSString *)host parentId:(int)parentId {
    IGXMLNodeSet *set = child.children;
    NSMutableArray<Forum *> *childForms = [NSMutableArray array];

    Forum *currentForum = nil;
    for (IGXMLNode *node in set) {

        if ([node.html hasPrefix:@"<li>"]) {
            currentForum = [[Forum alloc] init];
            NSString *name = [node.text trim];
            currentForum.forumName = name;
            NSString *url = [[node childAt:0] attribute:@"href"];
            int forumId = [[url stringWithRegular:@"f\\d+" andChild:@"\\d+"] intValue];
            currentForum.forumId = forumId;

            currentForum.forumHost = host;
            currentForum.parentForumId = parentId;

            NSLog(@"parserForums>>>>>>>>>>>>>>>>>>>>>+++ \t%@", currentForum.forumName);
            [childForms addObject:currentForum];
        } else if ([node.html hasPrefix:@"<ul>"]) {
            [self ul2Forum:node parent:currentForum host:host parentId:currentForum.forumId];
        }
    }
    parent.childForums = childForms;
}

- (NSArray *)flatForm:(Forum *)form {
    NSMutableArray *resultArray = [NSMutableArray array];
    [resultArray addObject:form];
    for (Forum *childForm in form.childForums) {
        [resultArray addObjectsFromArray:[self flatForm:childForm]];
    }
    return resultArray;
}

@end
