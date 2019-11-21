//
// Created by Diyuan Wang on 2019/11/12
// Copyright (c) 2016 andforce. All rights reserved.
//

#import "DreamLandHtmlParser.h"

#import "IGXMLNode+Children.h"

#import "ForumEntry+CoreDataClass.h"
#import "ForumCoreDataManager.h"
#import "NSString+Extensions.h"

#import "IGHTMLDocument+QueryNode.h"
#import "AppDelegate.h"
#import "BBSLocalApi.h"
#import "CommonUtils.h"
#import "Message.h"
#import "ViewMessage.h"
#import "LoginUser.h"

@implementation DreamLandHtmlParser {
    BBSLocalApi *localApi;
    LoginUser *loginUser;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        localApi = [[BBSLocalApi alloc] init];
    }
    return self;
}

- (ViewThreadPage *)parseShowThreadWithHtml:(NSString *)html {
    NSString *fixedImage = [self fixedImage:html];

    NSString *fixFontSizeHTML = [self fixedFontSize:fixedImage];
    NSString *fixedCodeBlock = [self fixedCodeBlodk:fixFontSizeHTML];

    NSString *fixedQuoteHeight = [self fixedQuote:fixedCodeBlock];
    NSString *fixedHtml = [self fixedLink:fixedQuoteHeight];


    IGHTMLDocument *document = [[IGHTMLDocument alloc] initWithHTMLString:fixedHtml error:nil];

    ViewThreadPage *showThreadPage = [[ViewThreadPage alloc] init];
    // origin html
    showThreadPage.originalHtml = [self postMessages:fixedHtml];

    // forum Id
    NSString *forumId = [[fixedHtml stringWithRegular:@"<option value=\"\\d+\" class=\".*\" selected=\"selected\">" andChild:@"value=\"\\d+\""] stringWithRegular:@"\\d+"];
    showThreadPage.forumId = [forumId intValue];

    // token 【失败】
    NSString *securityToken = [self parseSecurityToken:html];
    showThreadPage.securityToken = securityToken;

    // ajax  【失败】
    NSString *ajaxLastPost = [self parseAjaxLastPost:html];
    showThreadPage.ajaxLastPost = ajaxLastPost;

    // all posts
    showThreadPage.postList = [self parseShowThreadPosts:document];

    // title
    IGXMLNode *titleNode = [document queryWithXPath:@"//*[@id='table1']/tr/td[1]/div/strong"].firstObject;

    if (titleNode != nil) {
        NSString *fixedTitle = [titleNode.text trim];
        if ([fixedTitle hasPrefix:@"【"]) {
            fixedTitle = [fixedTitle stringByReplacingOccurrencesOfString:@"【" withString:@"["];
            fixedTitle = [fixedTitle stringByReplacingOccurrencesOfString:@"】" withString:@"]"];
        } else {
            fixedTitle = [@"讨论" stringByAppendingString:fixedTitle];
        }
        showThreadPage.threadTitle = fixedTitle;
    }

    NSString *threadID = [html stringWithRegular:@"(?<=<input type=\"hidden\" name=\"searchthreadid\" value=\")\\d+"];
    showThreadPage.threadID = [threadID intValue];

    // page number

    PageNumber *pageNumber = [self pageNumber:html];

    showThreadPage.pageNumber = pageNumber;

    return showThreadPage;
}

- (ViewForumPage *)parseThreadListFromHtml:(NSString *)html withThread:(int)threadId andContainsTop:(BOOL)containTop {
    ViewForumPage *forumDisplayPage = [[ViewForumPage alloc] init];

    NSString *path = @"/html/body/table/tr/td/div[*]/div/div/table[*]/tr[position()>1]";

    NSMutableArray<Thread *> *threadList = [NSMutableArray<Thread *> array];

    IGHTMLDocument *document = [[IGHTMLDocument alloc] initWithHTMLString:html error:nil];

    IGXMLNodeSet *contents = [document queryWithXPath:path];

    for (int i = 0; i < contents.count; i++) {
        IGXMLNode *normallThreadNode = contents[(NSUInteger) i];

        if (normallThreadNode.children.count >= 8) { // 要>=8的原因是：过滤已经被删除的帖子 以及 被移动的帖子

            Thread *normalThread = [[Thread alloc] init];

            // 由于各个论坛的帖子格式可能不一样，因此此处的标题等所在的列也会发生变化
            // 需要根据不同的论坛计算不同的位置

            NSInteger childColumnCount = normallThreadNode.children.count;

            int titlePosition = 2;

            if (childColumnCount == 8) {
                titlePosition = 2;
            } else if (childColumnCount == 7) {
                titlePosition = 1;
            }

            // title Node
            IGXMLNode *threadTitleNode = [normallThreadNode childAt:titlePosition];

            // title all html
            NSString *titleHtml = [threadTitleNode html];

            // title inner html
            NSString *titleInnerHtml = [threadTitleNode innerHtml];

            // 判断是不是置顶主题
            normalThread.isTopThread = [self isStickyThread:titleHtml];

            // 判断是不是精华帖子
            normalThread.isGoodNess = [self isGoodnessThread:titleHtml];

            // 是否包含小别针
            normalThread.isContainsImage = [self isContainsImagesThread:titleHtml];

            // 主题和分类
            NSString *titleAndCategory = [self parseTitle:titleInnerHtml];
            IGHTMLDocument *titleTemp = [[IGHTMLDocument alloc] initWithXMLString:titleAndCategory error:nil];

            NSString *titleText = [titleTemp text];

            if ([titleText hasPrefix:@"【"]) {
                titleText = [titleText stringByReplacingOccurrencesOfString:@"【" withString:@"["];
                titleText = [titleText stringByReplacingOccurrencesOfString:@"】" withString:@"]"];
            } else {
                titleText = [@"[讨论]" stringByAppendingString:titleText];
            }

            // 分离出主题
            normalThread.threadTitle = titleText;

            //[@"showthread.php?t=" length]    17的由来
            normalThread.threadID = [[titleTemp attribute:@"href"] substringFromIndex:17];

            // 作者相关
            int authorNodePosition = 3;
            if (childColumnCount == 7) {
                authorNodePosition = 2;
            }
            IGXMLNode *authorNode = [normallThreadNode childAt:authorNodePosition];
            NSString *authorIdStr = [authorNode innerHtml];
            normalThread.threadAuthorID = [authorIdStr stringWithRegular:@"\\d+"];
            normalThread.threadAuthorName = [[authorNode text] trim];

            // 最后回帖时间
            int lastPostTimePosition = 4;
            if (childColumnCount == 7) {
                lastPostTimePosition = 3;
            }
            IGXMLNode *lastPostTime = [normallThreadNode childAt:lastPostTimePosition];
            normalThread.lastPostTime = [CommonUtils timeForShort:[[lastPostTime text] trim] withFormat:@"MM-dd-yyyy HH:mm"];

            // 回帖数量
            int commentCountPosition = 5;
            if (childColumnCount == 7) {
                commentCountPosition = 4;
            }
            IGXMLNode *commentCountNode = [normallThreadNode childAt:commentCountPosition];
            normalThread.postCount = [commentCountNode text];

            // 查看数量
            int openCountNodePosition = 6;
            if (childColumnCount == 7) {
                openCountNodePosition = 5;
            }
            IGXMLNode *openCountNode = [normallThreadNode childAt:openCountNodePosition];
            normalThread.openCount = [openCountNode text];

            [threadList addObject:normalThread];
        }
    }
    forumDisplayPage.dataList = threadList;

    //forumID
    int fid = [[html stringWithRegular:@"(?<=newthread&amp;f=)\\d+"] intValue];
    forumDisplayPage.forumId = fid;

    forumDisplayPage.token = [self parseSecurityToken:html];

    // 总页数
    PageNumber *pageNumber = [self pageNumber:html];

    forumDisplayPage.pageNumber = pageNumber;

    return forumDisplayPage;
}

- (ViewForumPage *)parseFavorThreadListFromHtml:(NSString *)html {
    ViewForumPage *page = [[ViewForumPage alloc] init];

    NSString *path = @"/html/body/table/tr/td/div[2]/div/div/table[2]/tr/td[3]/form[2]/table/tr[position()>2]";

    //*[@id="threadbits_forum_147"]/tr[1]

    NSMutableArray<Thread *> *threadList = [NSMutableArray<Thread *> array];

    IGHTMLDocument *document = [[IGHTMLDocument alloc] initWithHTMLString:html error:nil];
    IGXMLNodeSet *contents = [document queryWithXPath:path];

    // NSInteger totaleListCount = -1;


    for (int i = 0; i < contents.count; i++) {
        IGXMLNode *threadListNode = contents[(NSUInteger) i];

        if (threadListNode.children.count >= 6) {

            Thread *simpleThread = [[Thread alloc] init];

            // Title
            IGXMLNode *threadTitleNode = threadListNode.children[2];
            NSString *titleText = [[[threadTitleNode text] trim] componentsSeparatedByString:@"\n"].firstObject;

            if (!([titleText hasPrefix:@"["] && [titleText containsString:@"]"])) {
                if ([titleText hasPrefix:@"【"]) {
                    titleText = [titleText stringByReplacingOccurrencesOfString:@"【" withString:@"["];
                    titleText = [titleText stringByReplacingOccurrencesOfString:@"】" withString:@"]"];
                } else {
                    titleText = [@"[讨论]" stringByAppendingString:titleText];
                }
            }
            simpleThread.threadTitle = titleText;

            // Thread Id
            NSString *threadStrig = [[threadTitleNode attribute:@"id"] stringWithRegular:@"\\d+"];
            simpleThread.threadID = threadStrig;

            //  Author
            IGXMLNode *authorNode = threadListNode.children[3];

            NSString *authorIdStr = [authorNode innerHtml];
            simpleThread.threadAuthorID = [authorIdStr stringWithRegular:@"\\d+"];

            simpleThread.threadAuthorName = [[authorNode text] trim];

            IGXMLNode *timeNode = threadListNode.children[4];
            NSString *time = [[timeNode text] trim];

            simpleThread.lastPostTime = time;

            [threadList addObject:simpleThread];
        }
    }
    page.dataList = threadList;

    // 总页数
    PageNumber *pageNumber = [self pageNumber:html];
    page.pageNumber = pageNumber;

    return page;
}

- (ViewForumPage *)parsePrivateMessageFromHtml:(NSString *)html forType:(int)type {
    return [self parsePrivateMessageFromHtml:html];
}

- (ViewSearchForumPage *)parseSearchPageFromHtml:(NSString *)html {
    IGHTMLDocument *document = [[IGHTMLDocument alloc] initWithHTMLString:html error:nil];


    IGXMLNodeSet *searchNodeSet = [document queryWithXPath:@"/html/body/table/tr/td/div[*]/div/div/table[*]/tr[position()>1]"];

    if (searchNodeSet == nil || searchNodeSet.count == 0) {
        return nil;
    }


    ViewSearchForumPage *resultPage = [[ViewSearchForumPage alloc] init];


    // 总页数 和 当前页数
    PageNumber *pageNumber = [self pageNumber:html];

    resultPage.pageNumber = pageNumber;

    NSMutableArray<Thread *> *post = [NSMutableArray array];

    for (IGXMLNode *node in searchNodeSet) {

        if (node.children.count == 9) {
            // 9个节点是正确的输出结果
            Thread *searchThread = [[Thread alloc] init];

            IGXMLNode *postForNode = [node childAt:2];

            NSString *postIdNode = [postForNode html];
            NSString *postId = [postIdNode stringWithRegular:@"t=\\d+" andChild:@"\\d+"];

            NSString *postTitle = @"[标题解析错误请联系@马小甲]";

            IGXMLNodeSet *realNodeSet = postForNode.firstChild.children;
            for (IGXMLNode *realNode in realNodeSet) {
                if ([realNode.tag isEqualToString:@"a"] && [[realNode attribute:@"href"] hasPrefix:@"showthread.php?t="]) {
                    postTitle = realNode.text.trim;
                }
            }

            NSString *postAuthor = [[[node childAt:3] text] trim];
            NSString *postAuthorId = [[node.children[3] html] stringWithRegular:@"=\\d+" andChild:@"\\d+"];
            NSString *postTime = [[node.children[4] text] trim];
            NSString *postBelongForm = [node.children[8] text];

            searchThread.threadID = postId;

            NSString *titleText = [postTitle trim];

            if ([titleText hasPrefix:@"【"]) {
                titleText = [titleText stringByReplacingOccurrencesOfString:@"【" withString:@"["];
                titleText = [titleText stringByReplacingOccurrencesOfString:@"】" withString:@"]"];
            } else {
                titleText = [@"[讨论]" stringByAppendingString:titleText];
            }

            searchThread.threadTitle = titleText;
            searchThread.threadAuthorName = postAuthor;
            searchThread.threadAuthorID = postAuthorId;
            searchThread.lastPostTime = [postTime trim];
            searchThread.fromFormName = postBelongForm;

            if ([self isSpecial]) {
                NSArray *blackList = [self blackList];
                if ([blackList containsObject:postBelongForm]) {
                    continue;
                }
            }
            [post addObject:searchThread];
        }
    }

    resultPage.dataList = post;

    return resultPage;
}

- (ViewSearchForumPage *)parseZhanNeiSearchPageFromHtml:(NSString *)html type:(int)type {
    return nil;
}

- (ViewMessagePage *)parsePrivateMessageContent:(NSString *)html avatarBase:(NSString *)avatarBase noavatar:(NSString *)avatarNO {
    IGHTMLDocument *document = [[IGHTMLDocument alloc] initWithHTMLString:html error:nil];

    ViewMessagePage *privateMessage = [[ViewMessagePage alloc] init];

    ViewMessage *viewMessage = [[ViewMessage alloc] init];
    // ===== message content =====

    // PM Title
    IGXMLNode *pmTitleNode = [document queryWithXPath:@"/html/body/table/tr/td/div[2]/div/div/table[2]/tr/td[3]/form/table[1]/tr/td"].firstObject;
    NSString *pmTitle = [[pmTitleNode text] trim];
    viewMessage.pmTitle = pmTitle;

    // PM Content
    IGXMLNode *contentNode = [document queryWithXPath:@"/html/body/table/tr/td/div[2]/div/div/table[2]/tr/td[3]/form/table[2]/tr[2]/td[2]/div"].firstObject;
    viewMessage.pmContent = [contentNode html];

    // 回帖时间
    IGXMLNode *timeNode = [document queryWithXPath:@"/html/body/table/tr/td/div[2]/div/div/table[2]/tr/td[3]/form/table[2]/tr[1]/td[1]/text()"].firstObject;
    viewMessage.pmTime = [timeNode.text trim];

    // PM ID
    IGXMLNode *idNode = [document queryWithXPath:@"/html/body/table/tr/td/div[2]/div/div/table[2]/tr/td[3]/form/table[2]/tr[4]/td/a[2]"].firstObject;
    NSString *pmId = [[idNode attribute:@"href"] stringWithRegular:@"\\d+"];
    viewMessage.pmID = pmId;

    // ===== User Info =====
    User *pmAuthor = [[User alloc] init];

    // 用户名
    IGXMLNode *userInfoNode = [document queryNodeWithXPath:@"//*[@id='postmenu_']/a"];
    NSString *name = [[userInfoNode text] trim];
    pmAuthor.userName = name;
    // 用户ID
    NSString *userId = [[userInfoNode attribute:@"href"] stringWithRegular:@"\\d+"];
    pmAuthor.userID = userId;

    // 用户头像
    IGXMLNode *userAvatarNode = [document queryNodeWithXPath:@"/html/body/table/tr/td/div[2]/div/div/table[2]/tr/td[3]/form/table[2]/tr[2]/td[1]/div[2]/a/img"];
    NSString *userAvatar = [userAvatarNode attribute:@"src"];//[[userAvatarNode attribute:@"src"] componentsSeparatedByString:@"customavatars"].lastObject;
    if (userAvatar == nil) {
        userAvatar = avatarNO;
    }
    pmAuthor.userAvatar = userAvatar;

    // 用户等级
    NSString *userRank = [document queryNodeWithXPath:@"/html/body/table/tr/td/div[2]/div/div/table[2]/tr/td[3]/form/table[2]/tr[2]/td[1]/div[3]"].text;
    pmAuthor.userRank = userRank;
    // 注册日期
    NSString *userSignDate = [[document queryNodeWithXPath:@"/html/body/table/tr/td/div[2]/div/div/table[2]/tr/td[3]/form/table[2]/tr[2]/td[1]/div[5]/fieldset/div[1]"].text componentsSeparatedByString:@": "].lastObject;
    pmAuthor.userSignDate = userSignDate;
    // 帖子数量
    NSString *postCount = [[[[document queryNodeWithXPath:@"/html/body/table/tr/td/div[2]/div/div/table[2]/tr/td[3]/form/table[2]/tr[2]/td[1]/div[5]/fieldset/div[2]/text()"] text] trim] componentsSeparatedByString:@": "].lastObject;
    pmAuthor.userPostCount = postCount;

    viewMessage.pmUserInfo = pmAuthor;

    NSMutableArray *datas = [NSMutableArray array];
    [datas addObject:viewMessage];

    privateMessage.viewMessages = datas;

    return privateMessage;
}

- (UserProfile *)parserProfile:(NSString *)html userId:(NSString *)userId {
    IGHTMLDocument *document = [[IGHTMLDocument alloc] initWithHTMLString:html error:nil];
    UserProfile *profile = [[UserProfile alloc] init];
    // 用户名
    NSString *userNameXPath = @"/html/body/table/tr/td/div[2]/div/div/table[2]/tr[2]/td/table/tr[1]/td/div[2]";
    profile.profileName = [[[document queryWithXPath:userNameXPath].firstObject text] trim];

    // 用户等级
    NSString *rankXPath = @"/html/body/table/tr/td/div[2]/div/div/table[2]/tr[2]/td/table/tr[1]/td/div[3]";
    profile.profileRank = [self queryText:document withXPath:rankXPath];

    // 注册日期                    /html/body/table/tr/td/div[2]/div/div/table[5]/tr[2]/td[1]/div/div/div/div
    NSString *signDatePattern = @"/html/body/table/tr/td/div[2]/div/div/table[*]/tr[2]/td[1]/div/div/div/div";

    profile.profileRegisterDate = [[[[[document queryWithXPath:signDatePattern].firstObject text] trim] componentsSeparatedByString:@": "] lastObject];

    // 最近活动时间
    NSString *lastLoginDayXPath = @"/html/body/table/tr/td/div[2]/div/div/table[2]/tr[2]/td/table/tr[2]/td[2]/div[1]";
    NSString *lastDay = [[[self queryText:document withXPath:lastLoginDayXPath] trim] componentsSeparatedByString:@": "].lastObject;

    if (lastDay == nil) {
        profile.profileRecentLoginDate = @"隐私";
    } else {
        profile.profileRecentLoginDate = lastDay;
    }


    // 帖子总数                   /html/body/table/tr/td/div[2]/div/div/table[5]/tr[2]/td[1]/div/div/fieldset/table/tr[1]/td
    NSString *postCountXPath = @"/html/body/table/tr/td/div[2]/div/div/table[*]/tr[2]/td[1]/div/div/fieldset/table/tr[1]/td";
    NSString *postCount = [[[document queryWithXPath:postCountXPath].firstObject text] componentsSeparatedByString:@": "].lastObject;
    profile.profileTotalPostCount = postCount;

    profile.profileUserId = userId;
    return profile;
}

- (NSArray<Forum *> *)parserForums:(NSString *)html forumHost:(NSString *)host {
    IGHTMLDocument *document = [[IGHTMLDocument alloc] initWithHTMLString:html error:nil];

    NSString *xPath = @"/html/body/table/tr/td/div[*]/div/div/table[5]/tr/td[2]/div/form/select/optgroup[2]";

    IGXMLNode *contents = [document queryNodeWithXPath:xPath];

    NSMutableArray<Forum *> *needInsert = [NSMutableArray array];

    int parentForumIDForTH1 = -1;
    int parentForumIDForTH2 = -1;
    for (IGXMLNode *child in contents.children) {

        Forum *forum = [[Forum alloc] init];

        NSString *classType = [child attribute:@"class"];
        int forumID = [[child attribute:@"value"] intValue];
        NSString *forumName = [[child text] trim];


        if ([classType isEqualToString:@"fjsel"] || [classType isEqualToString:@"fjdpth0"]) {
            parentForumIDForTH1 = forumID;
            forum.parentForumId = -1;
        } else if ([classType isEqualToString:@"fjdpth1"]) {
            forum.parentForumId = parentForumIDForTH1;
            parentForumIDForTH2 = forumID;

        } else if ([classType isEqualToString:@"fjdpth2"]) {
            forum.parentForumId = parentForumIDForTH2;
        }

        forum.forumId = forumID;
        forum.forumName = forumName;
        forum.forumHost = host;

        [needInsert addObject:forum];
    }

    if ([self isSpecial]) {
        NSMutableArray<Forum *> *realMeedInsert = [NSMutableArray array];
        for (Forum *forum in needInsert) {
            NSArray *blackList = [self blackList];
            if ([blackList containsObject:forum.forumName]) {
                continue;
            } else {
                [realMeedInsert addObject:forum];
            }
        }

        return [realMeedInsert copy];
    } else {
        return [needInsert copy];
    }
}

- (NSMutableArray<Forum *> *)parseFavForumFromHtml:(NSString *)html {
    IGHTMLDocument *document = [[IGHTMLDocument alloc] initWithHTMLString:html error:nil];
    IGXMLNodeSet *favFormNodeSet = [document queryWithXPath:@"//*[@id='collapseobj_usercp_forums']/tr[*]/td[2]/div[1]/a"];


    NSMutableArray *ids = [NSMutableArray array];

    //<a href="forumdisplay.php?f=158">『手机◇移动数码』</a>
    for (IGXMLNode *node in favFormNodeSet) {
        NSString *idsStr = [node.html stringWithRegular:@"f=\\d+" andChild:@"\\d+"];
        [ids addObject:@([idsStr intValue])];
    }

    BBSLocalApi *localForumApi = [[BBSLocalApi alloc] init];
    [localForumApi saveFavFormIds:ids];

    // 通过ids 过滤出Form
    ForumCoreDataManager *manager = [[ForumCoreDataManager alloc] initWithEntryType:EntryTypeForm];
    NSArray *result = [manager selectData:^NSPredicate * {
        NSString *host = localForumApi.currentForumHost;
        return [NSPredicate predicateWithFormat:@"forumHost = %@ AND forumId IN %@", host, ids];
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
    PageNumber *pageNumber = [[PageNumber alloc] init];

    IGHTMLDocument *document = [[IGHTMLDocument alloc] initWithHTMLString:html error:nil];

    IGXMLNode *pageNode = [document queryNodeWithClassName:@"pg"];

    if (pageNode == nil) {
        pageNumber.currentPageNumber = 1;
        pageNumber.totalPageNumber = 1;
    } else {
        NSString *text = [pageNode text];
        NSLog(@"%@", text);
    }
    return pageNumber;
}

- (NSString *)parseQuickReplyQuoteContent:(NSString *)html {
    IGHTMLDocument *document = [[IGHTMLDocument alloc] initWithHTMLString:html error:nil];
    IGXMLNodeSet *nodeSet = [document queryWithXPath:@"//*[@id='vB_Editor_QR_textarea']"];
    NSString *node = [[nodeSet firstObject] text];
    return node;
}

- (NSString *)parseQuickReplyTitle:(NSString *)html {
    IGHTMLDocument *document = [[IGHTMLDocument alloc] initWithHTMLString:html error:nil];
    IGXMLNodeSet *nodeSet = [document queryWithXPath:@"//*[@id='message_form']/div[1]/div/div/div[3]/input[9]"];

    NSString *node = [[nodeSet firstObject] attribute:@"value"];
    return node;
}

- (NSString *)parseQuickReplyTo:(NSString *)html {
    IGHTMLDocument *document = [[IGHTMLDocument alloc] initWithHTMLString:html error:nil];
    IGXMLNodeSet *nodeSet = [document queryWithXPath:@"//*[@id='message_form']/div[1]/div/div/div[3]/input[10]"];
    NSString *node = [[nodeSet firstObject] attribute:@"value"];
    return node;
}

- (NSString *)parseUserAvatar:(NSString *)html userId:(NSString *)userId {
    NSString *regular = [NSString stringWithFormat:@"/avatar%@_(\\d+).gif", userId];
    NSString *avatar = [html stringWithRegular:regular];
    if (avatar == nil) {
        avatar = @"/no_avatar.gif";
    }
    //NSLog(@"avatarLink  >> %@", avatar);
    return avatar;
}

- (NSString *)parseListMyThreadSearchId:(NSString *)html {
    NSString *searchid = [html stringWithRegular:@"/search.php\\?searchid=\\d+" andChild:@"\\d+"];
    return searchid;
}

- (NSString *)parseErrorMessage:(NSString *)html {
    return nil;
}

// private
- (NSString *)postMessages:(NSString *)html {
    IGHTMLDocument *document = [[IGHTMLDocument alloc] initWithHTMLString:html error:nil];

    IGXMLNodeSet *postMessages = [document queryWithXPath:@"//*[@id='posts']/div[*]/div/div/div/table/tr[2]/td[2]/div"];
    if (postMessages.count == 0) {
        postMessages = [document queryWithXPath:@"//*[@id='posts']/div/div/div/table/tr[2]/td[2]/div"];
    }
    NSMutableString *messages = [NSMutableString string];

    for (IGXMLNode *node in postMessages) {
        [messages appendString:node.text];
    }
    return [messages copy];
}


// private
- (NSString *)parseAjaxLastPost:(NSString *)html {
    NSString *searchText = [html stringWithRegular:@"var ajax_last_post = \\d+;" andChild:@"\\d+"];
    return searchText;
}


// private
- (NSMutableArray<Post *> *)parseShowThreadPosts:(IGHTMLDocument *)document {

    NSMutableArray<Post *> *posts = [NSMutableArray array];

    // 发帖的整个楼层 包含UserInfo 和 发帖内容
    IGXMLNodeSet *postMessages = [document queryWithXPath:@"//*[@id='posts']/div[*]"];

    for (IGXMLNode *node in postMessages) {

        // 重新构建Document 方便再次使用xPath 查询
        IGXMLDocument *postDocument = [[IGHTMLDocument alloc] initWithHTMLString:node.html error:nil];

        //======= Post Conent======//
        Post *post = [[Post alloc] init];

        // postId
        IGXMLNode *postIdNode = [postDocument queryWithXPath:@"/html/body/div/div/div/div/table/tr[2]/td[1]/div[1]"].firstObject;
        if (postIdNode == nil) {
            // 很蛋疼，DRL最后一楼，xPath跟前面的楼层不一样
            postIdNode = [postDocument queryWithXPath:@"/html/body/div/div/div/table/tr[2]/td[1]/div[1]"].firstObject;
        }

        NSString *postId = [[[postIdNode attribute:@"id"] componentsSeparatedByString:@"postmenu_"] lastObject];
        post.postID = postId;

        // post Time
        IGXMLNode *timeNode = [postDocument queryWithXPath:@"/html/body/div/div/div/div/table/tr[1]/td[1]"].firstObject;
        if (timeNode == nil || timeNode.html.length < 50) {
            // 很蛋疼，DRL最后一楼，xPath跟前面的楼层不一样
            timeNode = [postDocument queryWithXPath:@"/html/body/div/div/div/table/tr[1]/td[1]"].firstObject;
        }
        NSString *time = [[timeNode text] trim];
        post.postTime = [CommonUtils timeForShort:time withFormat:@"MM-dd-yyyy, HH:mm"];
        //post.postTime = time;

        // post Louceng
        IGXMLNode *loucengNode = [postDocument queryWithXPath:@"/html/body/div/div/div/div/table/tr[1]/td[2]"].firstObject;
        if (loucengNode == nil) {
            // 很蛋疼，DRL最后一楼，xPath跟前面的楼层不一样
            loucengNode = [postDocument queryWithXPath:@"/html/body/div/div/div/table/tr[1]/td[2]"].firstObject;
        }
        NSString *louceng = [[loucengNode text] trim];
        post.postLouCeng = louceng;


        // post Content
        // 帖子内容 有三部分组成 1、message 2、attachments 3、edit note
        IGXMLNode *messageNode = [postDocument queryWithXPath:@"/html/body/div/div/div/div/table/tr[2]/td[2]/div[1]"].firstObject;
        if (messageNode == nil) {
            // 很蛋疼，DRL最后一楼，xPath跟前面的楼层不一样
            messageNode = [postDocument queryWithXPath:@"/html/body/div/div/div/table/tr[2]/td[2]/div"].firstObject;
        }
        NSString *message = [messageNode html];

        IGXMLNode *attchmentsNode = [postDocument queryWithXPath:@"/html/body/div/div/div/div/table/tr[2]/td[2]/div[2]"].firstObject;
        if (attchmentsNode == nil) {
            // 很蛋疼，DRL最后一楼，xPath跟前面的楼层不一样
            attchmentsNode = [postDocument queryWithXPath:@"/html/body/div/div/div/table/tr[2]/td[2]/div[2]"].firstObject;
        }
        NSString *attchments = [attchmentsNode html];

        IGXMLNode *editNoteNode = [postDocument queryWithXPath:@"/html/body/div/div/div/div/table/tr[2]/td[2]/div[3]"].firstObject;
        if (editNoteNode == nil) {
            // 很蛋疼，DRL最后一楼，xPath跟前面的楼层不一样
            editNoteNode = [postDocument queryWithXPath:@"/html/body/div/div/div/table/tr[2]/td[2]/div[3]"].firstObject;
        }
        NSString *editNote = [editNoteNode html];
        NSString *postContent = message;
        if (attchments != nil) {
            postContent = [postContent stringByAppendingString:attchments];
        }
        if (editNote != nil) {
            postContent = [postContent stringByAppendingString:editNote];
        }
        post.postContent = postContent;

        //=======User Info======//
        User *userInfo = [[User alloc] init];

        // user name
        NSString *userNameXPath = [NSString stringWithFormat:@"//*[@id='postmenu_%@']/a", postId];
        IGXMLNode *userNameNode = [postDocument queryWithXPath:userNameXPath].firstObject;
        NSString *userName = [[userNameNode text] trim];
        userInfo.userName = userName;

        // user id
        NSString *userId = [[userNameNode attribute:@"href"] stringWithRegular:@"\\d+"];
        userInfo.userID = userId;

        //*[@id="posts"]/div[*]/div/div/div/table/tr[2]/td[1]/div[4]/a/img
        //*[@id="posts"]/div[*]/div/div/div/table/tr[2]/td[1]/div[4]/a/img
        // user avatar                                          /html/body/div/div/div/table/tr[2]/td[1]/div[4]/a/img

        IGXMLNode *avatarNode = [postDocument queryWithXPath:@"/html/body/div/div/div/div/table/tr[2]/td[1]/div[2]/a/img"].firstObject;
        if (avatarNode == nil) {
            // /html/body/div/div/div/table/tr[2]/td[1]/div[2]/a/img
            avatarNode = [postDocument queryWithXPath:@"/html/body/div/div/div/table/tr[2]/td[1]/div[*]/a/img"].firstObject;
        }
        if (avatarNode == nil) {
            userInfo.userAvatar = @"/no_avatar.gif";;
        } else {
            NSString *avatar = [avatarNode attribute:@"src"];
            userInfo.userAvatar = [avatar componentsSeparatedByString:@"customavatars"].lastObject;
        }

        post.postUserInfo = userInfo;

        // 添加数据
        [posts addObject:post];
    }

    return posts;
}

// private 修改字体大小统一为2
- (NSString *)fixedFontSize:(NSString *)html {
    NSArray *fontSetString = [html arrayWithRegular:@"<font size=\"\\d+\">"];

    NSString *fixFontSizeHTML = html;
    for (NSString *tmp in fontSetString) {
        fixFontSizeHTML = [fixFontSizeHTML stringByReplacingOccurrencesOfString:tmp withString:@"<font size=\"\2\">"];
    }
    return fixFontSizeHTML;
}

// private 修改链接
- (NSString *)fixedLink:(NSString *)html {
    // 去掉_http hxxp
    NSString *fuxkHttp = html;
    NSArray *httpArray = [html arrayWithRegular:@"(_http|hxxp|_https|hxxps)://[\\w\\-_]+(\\.[\\w\\-_]+)+([\\w\\-\\.,@?^=%&amp;:/~\\+#]*[\\w\\-\\@?^=%&amp;/~\\+#])?"];
    NSString *httpPattern = @"<a href=\"%@\" target=\"_blank\">%@</a>";
    for (NSString *http in httpArray) {
        NSString *fixedHttp = [http stringByReplacingOccurrencesOfString:@"_http://" withString:@"http://"];
        fixedHttp = [fixedHttp stringByReplacingOccurrencesOfString:@"hxxp://" withString:@"http://"];
        fixedHttp = [fixedHttp stringByReplacingOccurrencesOfString:@"hxxps://" withString:@"https://"];
        fixedHttp = [fixedHttp stringByReplacingOccurrencesOfString:@"_https://" withString:@"https://"];

        NSString *patterned = [NSString stringWithFormat:httpPattern, fixedHttp, fixedHttp];
        fuxkHttp = [fuxkHttp stringByReplacingOccurrencesOfString:http withString:patterned];

    }
    return fuxkHttp;
}

// private
- (NSString *)fixedCodeBlodk:(NSString *)html {

    NSString *fixed = [html stringByReplacingOccurrencesOfString:@"<div style=\"margin:20px; margin-top:5px\">" withString:@"<div style=\"overflow-x: hidden\"><div style=\"margin:20px; margin-top:5px\">"];
    return fixed;
}

// private
- (NSString *)fixedImage:(NSString *)html {

    NSString *fixedImage = html;

    NSArray *images = [html arrayWithRegular:@"<a href=\"attachment.php\\?attachmentid=\\d+&amp;stc=1\" target=\"_blank\"><img class=\"attach\" src=\"attachment.php\\?attachmentid=\\d+&amp;stc=1\" border=\"0\" alt=\"\" /></a>"];

    for (NSString *image in images) {
        NSString *imageSrc = [image stringWithRegular:@"<img class=\"attach\" src=\"attachment.php\\?attachmentid=\\d+&amp;stc=1\" border=\"0\" alt=\"\" />"];
        fixedImage = [fixedImage stringByReplacingOccurrencesOfString:image withString:imageSrc];
    }
    return fixedImage;
}

// private
- (NSString *)fixedQuote:(NSString *)html {

    NSString *result = [html stringByReplacingOccurrencesOfString:@"<div style=\"overflow: auto; height: 100px; padding: 2px;\" id=\"quote_d\">" withString:@"<div id=\"quote_d\">"];
    return result;
}

- (PageNumber *)pageNumber:(NSString *)html {
    NSString *pageStr = [html stringWithRegular:@"(?<=/> -->)第\\d+页 共\\d+页(?=</td>)"];
    PageNumber *pageNumber = [[PageNumber alloc] init];
    int currentPageNumber = [[[pageStr componentsSeparatedByString:@" "][0] stringWithRegular:@"\\d+"] intValue];
    int totalPageNumber = [[[pageStr componentsSeparatedByString:@" "][1] stringWithRegular:@"\\d+"] intValue];
    if (currentPageNumber == 0 || totalPageNumber == 0) {
        currentPageNumber = 1;
        totalPageNumber = 1;
    }
    pageNumber.currentPageNumber = currentPageNumber;
    pageNumber.totalPageNumber = totalPageNumber;

    return pageNumber;
}

// private 判断是不是置顶帖子
- (BOOL)isStickyThread:(NSString *)postTitleHtml {
    return [postTitleHtml containsString:@"images/drl2/misc/sticky.gif"];
}

// private 判断是不是精华帖子
- (BOOL)isGoodnessThread:(NSString *)postTitleHtml {
    return [postTitleHtml containsString:@"images/drl2/misc/elite_posticon.gif"];
}

// private 判断是否包含图片
- (BOOL)isContainsImagesThread:(NSString *)postTitlehtml {
    return [postTitlehtml containsString:@"images/drl2/misc/paperclip.gif"];
}

// private 获取回帖的页数
- (int)threadPostPageCount:(NSString *)postTitlehtml {
    NSArray *postPages = [postTitlehtml arrayWithRegular:@"page=\\d+"];
    if (postPages == nil || postPages.count == 0) {
        return 1;
    } else {
        NSString *countStr = [postPages.lastObject stringWithRegular:@"\\d+"];
        return [countStr intValue];
    }
}

// private
- (NSString *)parseTitle:(NSString *)html {
    NSString *searchText = html;

    NSString *pattern = @"<a href=\"showthread.php\\?t.*";

    NSRange range = [searchText rangeOfString:pattern options:NSRegularExpressionSearch];

    if (range.location != NSNotFound) {
        //NSLog(@"%@", [searchText substringWithRange:range]);
        return [searchText substringWithRange:range];
    }
    return nil;
}

- (NSString *)parseSecurityToken:(NSString *)html {
    NSString *searchText = html;

    NSRange range = [searchText rangeOfString:@"\\d{10}-\\S{40}" options:NSRegularExpressionSearch];

    if (range.location != NSNotFound) {
        NSLog(@"parseSecurityToken   %@", [searchText substringWithRange:range]);
        return [searchText substringWithRange:range];
    }
    return nil;
}

- (NSString *)parsePostHash:(NSString *)html {
    NSString *hash = [html stringWithRegular:@"<input type=\"hidden\" name=\"posthash\" value=\"\\w{32}\" />" andChild:@"\\w{32}"];

    return hash;
}

// for drl
- (NSString *)parserPostStartTime:(NSString *)html {
    NSString *startTime = [html stringWithRegular:@"<input type=\"hidden\" name=\"poststarttime\" value=\"\\d+\" />" andChild:@"\\d+"];
    return startTime;
}

- (NSString *)parseLoginErrorMessage:(NSString *)html {
    IGHTMLDocument *document = [[IGHTMLDocument alloc] initWithHTMLString:html error:nil];
    IGXMLNodeSet *contents = [document queryWithXPath:@"/html/body/div[2]/div/div/table[3]/tr[2]/td/div/div/div"];

    return contents.firstObject.text;
}

- (NSString *)parseQuote:(NSString *)html {
    IGHTMLDocument *document = [[IGHTMLDocument alloc] initWithHTMLString:html error:nil];
    IGXMLNodeSet *contents = [document queryWithXPath:@"//*[@id='vBulletin_editor']/table/tr[2]/td[1]/textarea"];
    return contents.firstObject.text;
}

// for drl
- (ViewForumPage *)parsePrivateMessageFromHtml:(NSString *)html {
    ViewForumPage *page = [[ViewForumPage alloc] init];

    IGHTMLDocument *document = [[IGHTMLDocument alloc] initWithHTMLString:html error:nil];


    PageNumber *pageNumber = [self pageNumber:html];

    page.pageNumber = pageNumber;


    NSMutableArray<Message *> *messagesList = [NSMutableArray array];
    IGXMLNodeSet *messages = [document queryWithXPath:@"/html/body/table/tr/td/div[2]/div/div/table[2]/tr/td[3]/form[2]/table/tbody[*]/tr"];
    for (IGXMLNode *node in messages) {
        long childCount = (long) [[node children] count];
        if (childCount == 4) {
            // 有4个节点说明是正常的站内短信
            Message *message = [[Message alloc] init];

            IGXMLNodeSet *children = [node children];
            // 1. 是不是未读短信
            IGXMLNode *unreadFlag = children[0];
            message.isReaded = ![[unreadFlag html] containsString:@"pm_new.gif"];

            // 2. 标题
            IGXMLNode *title = [children[2] children][0];
            NSString *titleStr = [[title children][1] text];
            message.pmTitle = titleStr;

            NSString *messageLink = [[[title children][1] attribute:@"href"] stringWithRegular:@"\\d+"];
            message.pmID = messageLink;


            NSString *timeDay = [[title children][0] text];

            // 3. 发送PM作者
            IGXMLNode *author = [children[2] children][1];
            NSString *authorText = [[author children][1] text];
            message.pmAuthor = [authorText trim];

            // 4. 发送者ID
            NSString *authorId;
            if (message.isReaded) {
                authorId = [[author children][1] attribute:@"onclick"];
                authorId = [authorId stringWithRegular:@"\\d+"];
            } else {
                IGXMLNode *strongNode = [author children][1];
                strongNode = [strongNode children][0];
                authorId = [strongNode attribute:@"onclick"];
                authorId = [authorId stringWithRegular:@"\\d+"];
            }
            message.pmAuthorId = authorId;

            // 5. 时间
            NSString *timeHour = [[author children][0] text];
            message.pmTime = [[timeDay stringByAppendingString:@" "] stringByAppendingString:timeHour];

            [messagesList addObject:message];

        }
    }

    page.dataList = messagesList;

    return page;
}

// private
- (NSString *)queryText:(IGHTMLDocument *)document withXPath:(NSString *)xpath {
    IGXMLNodeSet *nodeSet = [document queryWithXPath:xpath];
    NSString *text = [nodeSet.firstObject text];
    return text;
}

// private
- (Forum *)node2Form:(IGXMLNode *)node parentFormId:(int)parentFormId replaceId:(int)replaceId {
    Forum *parent = [[Forum alloc] init];
    NSString *name = [[node childAt:0] text];
    NSString *url = [[node childAt:0] html];
    int forumId = [[url stringWithRegular:@"f-\\d+" andChild:@"\\d+"] intValue];
    int fixForumId = forumId == 0 ? replaceId : forumId;
    parent.forumId = fixForumId;
    parent.parentForumId = parentFormId;
    parent.forumName = name;

    if (node.childrenCount == 2) {
        IGXMLNodeSet *childSet = [node childAt:1].children;
        NSMutableArray<Forum *> *childForms = [NSMutableArray array];

        for (IGXMLNode *childNode in childSet) {
            [childForms addObject:[self node2Form:childNode parentFormId:fixForumId replaceId:replaceId]];
        }
        parent.childForums = childForms;
    }

    return parent;
}

// private
- (NSArray *)flatForm:(Forum *)form {
    NSMutableArray *resultArray = [NSMutableArray array];
    [resultArray addObject:form];
    for (Forum *childForm in form.childForums) {
        [resultArray addObjectsFromArray:[self flatForm:childForm]];
    }
    return resultArray;
}

- (BOOL)isSpecial {
    if (loginUser == nil) {
        NSString *url = localApi.currentForumHost;
        loginUser = [localApi getLoginUser:url];
    }
    return [loginUser.userName isEqualToString:@"马小甲"];
}

- (NSArray *)blackList {
    return @[@"〖软件会员区〗", @"软件会员区精华", @"〖影视会员区〗", @"DVDR 介绍区", @"连续剧介绍区", @"动漫介绍区", @"影视讨论精华区", @"高清影视", @"〖交易信息〗", @"团购及商业性交易", @"优惠快讯版", @"身份备案", @"Archive", @"争议协调", @"DRL-X 讨论", @"0day warez介绍", @"〖杰出会员评选〗", @"〖羊毛〗", @"〖补档交流区〗", @"Archive", @"〖FTP资源〗", @"DRL-X", @"【论坛工作区】"];
}

@end
