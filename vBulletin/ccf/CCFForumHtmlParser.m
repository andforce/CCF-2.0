//
// Created by WDY on 2016/12/8.
// Copyright (c) 2016 andforce. All rights reserved.
//

#import "CCFForumHtmlParser.h"

#import "IGXMLNode+Children.h"

#import "ForumEntry+CoreDataClass.h"
#import "ForumCoreDataManager.h"
#import "NSString+Extensions.h"

#import "IGHTMLDocument+QueryNode.h"
#import "AppDelegate.h"
#import "LocalForumApi.h"
#import "CommonUtils.h"

@implementation CCFForumHtmlParser {

}
- (ViewThreadPage *)parseShowThreadWithHtml:(NSString *)html {
    // 查找设置了字体的回帖
    NSArray *fontSetString = [html arrayWithRegular:@"<font size=\"\\d+\">"];

    NSString *fixFontSizeHTML = html;

    for (NSString *tmp in fontSetString) {
        fixFontSizeHTML = [fixFontSizeHTML stringByReplacingOccurrencesOfString:tmp withString:@"<font size=\"\2\">"];
    }
    // 去掉_http hxxp
    NSString *fuxkHttp = fixFontSizeHTML;
    NSArray *httpArray = [fixFontSizeHTML arrayWithRegular:@"(_http|hxxp|_https|hxxps)://[\\w\\-_]+(\\.[\\w\\-_]+)+([\\w\\-\\.,@?^=%&amp;:/~\\+#]*[\\w\\-\\@?^=%&amp;/~\\+#])?"];
    NSString *httpPattern = @"<a href=\"%@\" target=\"_blank\">%@</a>";
    for (NSString *http in httpArray) {
        NSString *fixedHttp = [http stringByReplacingOccurrencesOfString:@"_http://" withString:@"http://"];
        fixedHttp = [fixedHttp stringByReplacingOccurrencesOfString:@"hxxp://" withString:@"http://"];
        fixedHttp = [fixedHttp stringByReplacingOccurrencesOfString:@"hxxps://" withString:@"https://"];
        fixedHttp = [fixedHttp stringByReplacingOccurrencesOfString:@"_https://" withString:@"https://"];

        NSString *patterned = [NSString stringWithFormat:httpPattern, fixedHttp, fixedHttp];
        fuxkHttp = [fuxkHttp stringByReplacingOccurrencesOfString:http withString:patterned];

    }


    IGHTMLDocument *document = [[IGHTMLDocument alloc] initWithHTMLString:fuxkHttp error:nil];


    NSString *forumId = [fuxkHttp stringWithRegular:@"(?<=newthread.php\\?do=newthread&amp;f=)\\d+"];

    ViewThreadPage *showThreadPage = [[ViewThreadPage alloc] init];
    showThreadPage.originalHtml = [self postMessages:fuxkHttp];

    showThreadPage.forumId = [forumId intValue];

    NSString *securityToken = [self parseSecurityToken:html];
    showThreadPage.securityToken = securityToken;

    NSString *ajaxLastPost = [self parseAjaxLastPost:html];
    showThreadPage.ajaxLastPost = ajaxLastPost;

    showThreadPage.postList = [self parseShowThreadPosts:document];


    IGXMLNode *titleNode = [document queryWithXPath:@"/html/body/div[2]/div/div/table[2]/tr/td[1]/table/tr[2]/td/strong"].firstObject;
    NSString *fixedTitle = [titleNode.text trim];
    if ([fixedTitle hasPrefix:@"【"]) {
        fixedTitle = [fixedTitle stringByReplacingOccurrencesOfString:@"【" withString:@"["];
        fixedTitle = [fixedTitle stringByReplacingOccurrencesOfString:@"】" withString:@"]"];
    } else {
        fixedTitle = [@"讨论" stringByAppendingString:fixedTitle];
    }

    showThreadPage.threadTitle = fixedTitle;

    NSString *threadID = [html stringWithRegular:@"(?<=<input type=\"hidden\" name=\"searchthreadid\" value=\")\\d+"];
    showThreadPage.threadID = [threadID intValue];

    PageNumber *pageNumber = [self parserPageNumber:html];
    showThreadPage.pageNumber = pageNumber;

    return showThreadPage;
}

- (ViewForumPage *)parseThreadListFromHtml:(NSString *)html withThread:(int)threadId andContainsTop:(BOOL)containTop {
    ViewForumPage *page = [[ViewForumPage alloc] init];

    NSString *path = [NSString stringWithFormat:@"//*[@id='threadbits_forum_%d']/tr", threadId];

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

            // 回帖页数
            normalThread.totalPostPageCount = [self threadPostPageCount:titleHtml];

            // title inner html
            NSString *titleInnerHtml = [threadTitleNode innerHtml];

            // 判断是不是置顶主题
            normalThread.isTopThread = [self isStickyThread:titleHtml];

            // 判断是不是精华帖子
            normalThread.isGoodNess = [self isGoodNessThread:titleHtml];

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
            normalThread.threadAuthorName = [authorNode text];

            // 最后回帖时间
            int lastPostTimePosition = 4;
            if (childColumnCount == 7) {
                lastPostTimePosition = 3;
            }
            IGXMLNode *lastPostTime = [normallThreadNode childAt:lastPostTimePosition];
            normalThread.lastPostTime = [CommonUtils timeForShort:[[lastPostTime text] trim] withFormat:@"yyyy-MM-dd HH:mm:ss"];

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
    page.dataList = threadList;

    //forumID
    int fid = [[html stringWithRegular:@"(?<=newthread&amp;f=)\\d+"] intValue];
    page.forumId = fid;

    page.token = [self parseSecurityToken:html];

    // 总页数
    PageNumber *pageNumber = [self parserPageNumber:html];
    page.pageNumber = pageNumber;

    return page;
}

- (ViewForumPage *)parseFavorThreadListFromHtml:(NSString *)html {
    ViewForumPage *page = [[ViewForumPage alloc] init];

    NSString *path = @"/html/body/div[2]/div/div/table[3]/tr/td[3]/form[2]/table/tr[position()>2]";

    //*[@id="threadbits_forum_147"]/tr[1]

    NSMutableArray<Thread *> *threadList = [NSMutableArray<Thread *> array];

    IGHTMLDocument *document = [[IGHTMLDocument alloc] initWithHTMLString:html error:nil];
    IGXMLNodeSet *contents = [document queryWithXPath:path];

    for (int i = 0; i < contents.count; i++) {
        IGXMLNode *threadListNode = contents[(NSUInteger) i];

        if (threadListNode.children.count >= 7) { // 要大于7的原因是：过滤已经被删除的帖子 和已经被移动的帖子

            Thread *simpleThread = [[Thread alloc] init];

            // title
            IGXMLNode *threadTitleNode = threadListNode.children[2];
            NSString *titleText = [[[threadTitleNode text] trim] componentsSeparatedByString:@"\n"].firstObject;

            if ([titleText hasPrefix:@"【"]) {
                titleText = [titleText stringByReplacingOccurrencesOfString:@"【" withString:@"["];
                titleText = [titleText stringByReplacingOccurrencesOfString:@"】" withString:@"]"];
            } else {
                titleText = [@"[讨论]" stringByAppendingString:titleText];
            }

            //分离出Title
            simpleThread.threadTitle = titleText;

            NSString *timeHtml = [self parseTitle:[[threadTitleNode innerHtml] trim]];
            IGHTMLDocument *titleTemp = [[IGHTMLDocument alloc] initWithXMLString:timeHtml error:nil];

            //[@"showthread.php?t=" length]    17的由来
            simpleThread.threadID = [[titleTemp attribute:@"href"] substringFromIndex:17];


            IGXMLNode *authorNode = threadListNode.children[3];

            NSString *authorIdStr = [authorNode innerHtml];
            simpleThread.threadAuthorID = [authorIdStr stringWithRegular:@"\\d+"];

            simpleThread.threadAuthorName = [authorNode text];

            IGXMLNode *timeNode = threadListNode.children[4];
            NSString *time = [[timeNode text] trim];

            simpleThread.lastPostTime = time;

            [threadList addObject:simpleThread];
        }
    }
    page.dataList = threadList;

    // 总页数
    PageNumber *pageNumber = [self parserPageNumber:html];

    page.pageNumber = pageNumber;

    return page;
}

- (ViewForumPage *)parsePrivateMessageFromHtml:(NSString *)html forType:(int)type {
    return [self parsePrivateMessageFromHtml:html];
}

- (ViewSearchForumPage *)parseSearchPageFromHtml:(NSString *)html {
    IGHTMLDocument *document = [[IGHTMLDocument alloc] initWithHTMLString:html error:nil];
    IGXMLNodeSet *searchNodeSet = [document queryWithXPath:@"//*[@id='threadslist']/tr[*]"];

    if (searchNodeSet == nil || searchNodeSet.count == 0) {
        return nil;
    }


    ViewSearchForumPage *resultPage = [[ViewSearchForumPage alloc] init];

    // 1. 结果总条数
    PageNumber *pageNumber = [self parserPageNumber:html];

    resultPage.pageNumber = pageNumber;

    NSMutableArray<Thread *> *post = [NSMutableArray array];

    for (IGXMLNode *node in searchNodeSet) {

        if (node.children.count == 9) {
            // 9个节点是正确的输出结果
            Thread *searchThread = [[Thread alloc] init];

            IGXMLNode *postForNode = [node childAt:2];

            //NSLog(@"--------------------- %ld title: %@", (long) [postForNode children].count, [[postForNode text] trim]);

            NSString *postIdNode = [postForNode html];
            NSString *postId = [postIdNode stringWithRegular:@"(?<=id=\"thread_title_)\\d+(?=\")"];


            NSString *titleAndCategory = [self parseTitle:[postForNode html]];
            IGHTMLDocument *titleTemp = [[IGHTMLDocument alloc] initWithXMLString:titleAndCategory error:nil];
            NSString *titleText = [titleTemp text];

            //NSString *postTitle = [[[postForNode text] trim] componentsSeparatedByString:@"\n"].firstObject;
            NSString *postAuthor = [[node childAt:3] text];
            NSString *postAuthorId = [[node.children[3] html] stringWithRegular:@"(?<==)\\d+"];
            NSString *postTime = [node.children[4] text];

            NSString *postBelongForm = [node.children[8] text];

            searchThread.threadID = postId;

            if ([titleText hasPrefix:@"【"]) {
                titleText = [titleText stringByReplacingOccurrencesOfString:@"【" withString:@"["];
                titleText = [titleText stringByReplacingOccurrencesOfString:@"】" withString:@"]"];
            } else {
                titleText = [@"[讨论]" stringByAppendingString:titleText];
            }

            searchThread.threadTitle = titleText;

            searchThread.threadAuthorName = postAuthor;
            searchThread.threadAuthorID = postAuthorId;
            searchThread.lastPostTime = [CommonUtils timeForShort:[postTime trim] withFormat:@"yyyy-MM-dd HH:mm:ss"];
            searchThread.fromFormName = postBelongForm;


            [post addObject:searchThread];
        }
    }

    resultPage.searchid = [self parseListMyThreadSearchId:html];
    resultPage.dataList = post;

    return resultPage;
}

- (ViewSearchForumPage *)parseZhanNeiSearchPageFromHtml:(NSString *)html type:(int)type {
    return nil;
}

- (ViewMessagePage *)parsePrivateMessageContent:(NSString *)html avatarBase:(NSString *)avatarBase noavatar:(NSString *)avatarNO {
    // 去掉引用inline 的样式设定
    html = [html stringByReplacingOccurrencesOfString:@"<div class=\"smallfont\" style=\"margin-bottom:2px\">引用:</div>" withString:@""];
    html = [html stringByReplacingOccurrencesOfString:@"style=\"margin:20px; margin-top:5px; \"" withString:@"class=\"post-quote\""];
    html = [html stringByReplacingOccurrencesOfString:@"<td class=\"alt2\" style=\"border:1px inset\">" withString:@"<td class=\"alt2\">"];


    IGHTMLDocument *document = [[IGHTMLDocument alloc] initWithHTMLString:html error:nil];

    // message content
    ViewMessagePage *privateMessage = [[ViewMessagePage alloc] init];
    IGXMLNodeSet *contentNodeSet = [document queryWithXPath:@"//*[@id='post_message_']"];
    privateMessage.pmContent = [[contentNodeSet firstObject] html];
    // 回帖时间
    IGXMLNodeSet *privateSendTimeSet = [document queryWithXPath:@"//*[@id='table1']/tr/td[1]/div/text()"];
    NSString *timeLong = [[privateSendTimeSet[2] text] trim];
    privateMessage.pmTime = [CommonUtils timeForShort:timeLong withFormat:@"yyyy-MM-dd, HH:mm:ss"];
    // PM ID
    IGXMLNodeSet *privateMessageIdSet = [document queryWithXPath:@"/html/body/div[2]/div/div/table[2]/tr/td[1]/table/tr[2]/td/a"];
    NSString *pmId = [[[privateMessageIdSet firstObject] attribute:@"href"] stringWithRegular:@"\\d+"];
    privateMessage.pmID = pmId;

    // PM Title
    IGXMLNodeSet *pmTitleSet = [document queryWithXPath:@"/html/body/div[2]/div/div/table[2]/tr/td[1]/table/tr[2]/td/strong"];
    NSString *pmTitle = [[[pmTitleSet firstObject] text] trim];
    privateMessage.pmTitle = pmTitle;


    // User Info
    User *pmAuthor = [[User alloc] init];
    IGXMLNode *userInfoNode = [document queryNodeWithXPath:@"//*[@id='post']/tr[1]/td[1]"];
    // 用户名
    NSString *name = [[[userInfoNode childAt:0] childAt:0] text];
    pmAuthor.userName = name;
    // 用户ID
    NSString *userId = [[[[userInfoNode childAt:0] childAt:0] attribute:@"href"] stringWithRegular:@"\\d+"];
    pmAuthor.userID = userId;

    // 用户头像
    NSString *userAvatar = [[[[[[userInfoNode childAt:1] childAt:1] childAt:0] attribute:@"src"] componentsSeparatedByString:@"/"] lastObject];
    if (userAvatar) {
        NSString *avatarPattern = @"%@/%@";
        userAvatar = [NSString stringWithFormat:avatarPattern, avatarBase, userAvatar];
    } else {
        userAvatar = avatarNO;
    }
    pmAuthor.userAvatar = userAvatar;

    // 用户等级
    NSString *userRank = [[userInfoNode childAt:3] text];
    pmAuthor.userRank = userRank;
    // 注册日期
    NSString *userSignDate = [[[[[[userInfoNode childAt:4] childAt:1] childAt:1] text] componentsSeparatedByString:@": "] lastObject];
    pmAuthor.userSignDate = userSignDate;
    // 帖子数量
    NSString *postCount = [[[[[[[userInfoNode childAt:4] childAt:1] childAt:2] text] trim] componentsSeparatedByString:@": "] lastObject];
    pmAuthor.userPostCount = postCount;

    privateMessage.pmUserInfo = pmAuthor;
    return privateMessage;
}

- (UserProfile *)parserProfile:(NSString *)html userId:(NSString *)userId {
    IGHTMLDocument *document = [[IGHTMLDocument alloc] initWithHTMLString:html error:nil];
    UserProfile *profile = [[UserProfile alloc] init];
    // 用户名
    NSString *userNameXPath = @"//*[@id='username_box']/h1/text()";
    profile.profileName = [[self queryText:document withXPath:userNameXPath] trim];

    // 用户等级
    NSString *rankXPath = @"//*[@id='username_box']/h2";
    profile.profileRank = [self queryText:document withXPath:rankXPath];

    // 注册日期
    profile.profileRegisterDate = [html stringWithRegular:@"(?<=<li><span class=\"shade\">注册日期:</span> )\\d{4}-\\d{2}-\\d{2}(?=</li>)"];

    // 最近活动时间
    NSString *lastLoginDayXPath = @"//*[@id='collapseobj_stats']/div/fieldset[2]/ul/li[1]/text()";
    NSString *lastDay = [[self queryText:document withXPath:lastLoginDayXPath] trim];

    NSString *lastLoginTimeXPath = @"//*[@id='collapseobj_stats']/div/fieldset[2]/ul/li[1]/span[2]";
    NSString *lastTime = [[self queryText:document withXPath:lastLoginTimeXPath] trim];
    if (lastTime == nil) {
        lastTime = @"隐私";
        profile.profileRecentLoginDate = lastTime;
    } else {
        profile.profileRecentLoginDate = [NSString stringWithFormat:@"%@ %@", lastDay, lastTime];
    }


    // 帖子总数
    NSString *postCount = [html stringWithRegular:@"(?<=<li><span class=\"shade\">帖子总数:</span> )([0-9][,]?)+(?=</li>)"];
    profile.profileTotalPostCount = postCount;

    profile.profileUserId = userId;
    return profile;
}

- (NSArray<Forum *> *)parserForums:(NSString *)html forumHost:(NSString *)host {
    IGHTMLDocument *document = [[IGHTMLDocument alloc] initWithHTMLString:html error:nil];

    NSMutableArray<Forum *> *forms = [NSMutableArray array];

    //*[@id="content"]/ul

    NSString *xPath = @"//*[@id='content']/ul/li[position()>0]";

    IGXMLNodeSet *contents = [document query:xPath];

    int replaceId = 10000;
    for (IGXMLNode *child in contents) {
        [forms addObject:[self node2Form:child forumHost: host parentFormId:-1 replaceId:replaceId++]];

    }

    NSMutableArray<Forum *> *needInsert = [NSMutableArray array];

    for (Forum *forum in forms) {
        [needInsert addObjectsFromArray:[self flatForm:forum]];
    }

    return [needInsert copy];
}

- (NSMutableArray<Forum *> *)parseFavForumFromHtml:(NSString *)html {
    IGHTMLDocument *document = [[IGHTMLDocument alloc] initWithHTMLString:html error:nil];
    IGXMLNodeSet *favFormNodeSet = [document queryWithXPath:@"//*[@id='collapseobj_usercp_forums']/tr[*]/td[2]/div[1]/a"];


    NSMutableArray *ids = [NSMutableArray array];

    //<a href="forumdisplay.php?f=158">『手机◇移动数码』</a>
    for (IGXMLNode *node in favFormNodeSet) {
        NSString *idsStr = [node.html stringWithRegular:@"(?<=f=)\\d+"];
        [ids addObject:@(idsStr.intValue)];
    }

    LocalForumApi *localForumApi = [[LocalForumApi alloc] init];
    [localForumApi saveFavFormIds:ids];


    // 通过ids 过滤出Form
    ForumCoreDataManager *manager = [[ForumCoreDataManager alloc] initWithEntryType:EntryTypeForm];
    LocalForumApi * localeForumApi = [[LocalForumApi alloc] init];
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
    NSString *pageStr = [html stringWithRegular:@"(?<=<td class=\"vbmenu_control\" style=\"font-weight:normal\">)第 \\d+ 页，共 \\d+ 页(?=</td>)"];
    PageNumber * pageNumber = [[PageNumber alloc] init];
    int currentPageNumber = [[[pageStr componentsSeparatedByString:@"，"][0] stringWithRegular:@"\\d+"] intValue];
    int totalPageNumber = [[[pageStr componentsSeparatedByString:@"，"][1] stringWithRegular:@"\\d+"] intValue];
    if (currentPageNumber == 0 || totalPageNumber == 0){
        currentPageNumber = 1;
        totalPageNumber = 1;
    }
    pageNumber.currentPageNumber = currentPageNumber;
    pageNumber.totalPageNumber = totalPageNumber;
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
    NSString *xPath = @"/html/body/div[2]/div/div/table[2]/tr/td[1]/table/tr[2]/td/a";
    IGHTMLDocument *document = [[IGHTMLDocument alloc] initWithHTMLString:html error:nil];
    IGXMLNodeSet *nodeSet = [document queryWithXPath:xPath];

    return [[nodeSet.firstObject attribute:@"href"] stringWithRegular:@"\\d+"];
}

- (NSString *)parseErrorMessage:(NSString *)html {
    return nil;
}


// private
- (NSString *)postMessages:(NSString *)html {
    IGHTMLDocument *document = [[IGHTMLDocument alloc] initWithHTMLString:html error:nil];
    IGXMLNodeSet *postMessages = [document queryWithXPath:@"//*[@id='posts']/div[*]/div/div/div/table/tr[1]/td[2]"];
    NSMutableString *messages = [NSMutableString string];

    for (IGXMLNode *node in postMessages) {
        [messages appendString:node.text];
    }
    return [messages copy];
}


// private
- (NSString *)parseAjaxLastPost:(NSString *)html {
    NSString *searchText = [html stringWithRegular:@"(?<=var ajax_last_post = )\\d+(?=;)"];
    return searchText;
}


// private
- (NSMutableArray<Post *> *)parseShowThreadPosts:(IGHTMLDocument *)document {

    NSMutableArray<Post *> *posts = [NSMutableArray array];

    // 发帖内容的 table -> td
    IGXMLNodeSet *postMessages = [document queryWithXPath:@"//*[@id='posts']/div[*]/div/div/div/table/tr[1]/td[2]"];

    // 发帖时间
    NSString *xPathTime = @"//*[@id='table1']/tr/td[1]/div";


    for (IGXMLNode *node in postMessages) {

        Post *post = [[Post alloc] init];


        NSString *postId = [[[node attribute:@"id"] componentsSeparatedByString:@"td_post_"] lastObject];


        IGXMLDocument *postDocument = [[IGHTMLDocument alloc] initWithHTMLString:node.html error:nil];

        IGXMLNode *time = [postDocument queryWithXPath:xPathTime].firstObject;


        NSString *xPathMessage = [NSString stringWithFormat:@"//*[@id='post_message_%@']", postId];
        IGXMLNode *message = [postDocument queryWithXPath:xPathMessage].firstObject;

        post.postContent = message.html;
        // 去掉引用inline 的样式设定
        post.postContent = [post.postContent stringByReplacingOccurrencesOfString:@"<div class=\"smallfont\" style=\"margin-bottom:2px\">引用:</div>" withString:@""];
        post.postContent = [post.postContent stringByReplacingOccurrencesOfString:@"style=\"margin:20px; margin-top:5px; \"" withString:@"class=\"post-quote\""];
        post.postContent = [post.postContent stringByReplacingOccurrencesOfString:@"<td class=\"alt2\" style=\"border:1px inset\">" withString:@"<td class=\"alt2\">"];


        NSString *xPathAttImage = [NSString stringWithFormat:@"//*[@id='td_post_%@']/div[2]", postId];
        IGXMLNode *attImage = [postDocument queryWithXPath:xPathAttImage].firstObject;

        if (attImage) {
            
            NSString *attImageHtml = [attImage html];
            
            //<a href="attachment.php?attachmentid=725161&amp;stc=1" target="_blank">
            //<img class="attach" src="attachment.php?attachmentid=725161&amp;stc=1&amp;d=1261896941" onload="if(this.width>screen.width*0.7) {this.width=screen.width*0.7;}" border="0" alt="">
            //</a>
            
            // 上传的图片，外面包了一层，影响点击事件，
            // 因此要替换成<img src="attachment.php?attachmentid=725161&amp;stc=1" /> 这种形式
            IGHTMLDocument *attImageDocument = [[IGHTMLDocument alloc] initWithHTMLString:attImageHtml error:nil];
            
            IGXMLNodeSet *attImageSet = [attImageDocument queryWithXPath:@"/html/body/div/fieldset/div/a[*]"];
            
            
            NSString *newImagePattern = @"<img src=\"%@\" />";
            for (IGXMLNode *nodeImage in attImageSet) {
                NSString *href = [nodeImage attribute:@"href"];
                NSString *newImage = [NSString stringWithFormat:newImagePattern, href];
                
                attImageHtml = [attImageHtml stringByReplacingOccurrencesOfString:nodeImage.html withString:newImage];
            }
            
            post.postContent = [post.postContent stringByAppendingString:attImageHtml];
        }


        NSRange louCengRange = [time.text rangeOfString:@"#\\d+" options:NSRegularExpressionSearch];

        if (louCengRange.location != NSNotFound) {
            post.postLouCeng = [time.text substringWithRange:louCengRange];
        }


        NSRange timeRange = [time.text rangeOfString:@"\\d{4}-\\d{2}-\\d{2}, \\d{2}:\\d{2}:\\d{2}" options:NSRegularExpressionSearch];

        if (timeRange.location != NSNotFound) {
            NSString *fixTime = [[time.text substringWithRange:timeRange] stringByReplacingOccurrencesOfString:@", " withString:@" "];
            post.postTime = [CommonUtils timeForShort:fixTime withFormat:@"yyyy-MM-dd HH:mm:ss"];
        }
        // 保存数据
        post.postID = postId;

        // 添加数据
        [posts addObject:post];


    }


    // 发帖账户信息 table -> td
    //*[@id='posts']/div[1]/div/div/div/table/tr[1]/td[1]
    IGXMLNodeSet *postUserInfo = [document queryWithXPath:@"//*[@id='posts']/div[*]/div/div/div/table/tr[1]/td[1]"];
    //*[@id="post"]/tbody/tr[1]/td[1]

    int postPointer = 0;
    for (IGXMLNode *userInfoNode in postUserInfo) {

        if (userInfoNode.children.count < 5) {
            continue;
        }
        IGXMLNode *nameNode = userInfoNode.firstChild.firstChild;

        User *user = [[User alloc] init];

        NSString *name = nameNode.innerHtml;
        user.userName = name;
        NSString *nameLink = [nameNode attribute:@"href"];
        user.userID = [nameLink stringWithRegular:@"\\d+"];
        //avatar
        IGXMLNode *avatarNode = userInfoNode.children[1];
        NSString *avatarLink = [[[avatarNode children][1] firstChild] attribute:@"src"];

        avatarLink = [avatarLink stringWithRegular:@"/avatar(\\d+)_(\\d+).gif"];
        if (avatarLink == nil) {
            avatarLink = @"/no_avatar.gif";
        }

        //avatarLink = [[avatarLink componentsSeparatedByString:@"/"]lastObject];

        user.userAvatar = avatarLink;

        //rank
        IGXMLNode *rankNode = userInfoNode.children[3];
        user.userRank = rankNode.text;
        // 资料div
        IGXMLNode *subInfoNode = userInfoNode.children[4];
        // 注册日期
        IGXMLNode *signDateNode = [[subInfoNode children][1] children][1];
        user.userSignDate = signDateNode.text;
        // 帖子数量html
        IGXMLNode *postCountNode = [[subInfoNode children][1] children][2];
        user.userPostCount = postCountNode.text;
        // 精华 解答 暂时先不处理
        //IGXMLNode * solveCountNode = subInfoNode;


        posts[(NSUInteger) postPointer].postUserInfo = user;

        Post *newPost = posts[(NSUInteger) postPointer];
        newPost.postUserInfo = user;
        [posts removeObjectAtIndex:(NSUInteger) postPointer];
        [posts insertObject:newPost atIndex:(NSUInteger) postPointer];

        postPointer++;
    }

    return posts;
}

// private 判断是不是置顶帖子
- (BOOL)isStickyThread:(NSString *)postTitleHtml {
    return [postTitleHtml containsString:@"images/CCFStyle/misc/sticky.gif"];
}

// private 判断是不是精华帖子
- (BOOL)isGoodNessThread:(NSString *)postTitleHtml {
    return [postTitleHtml containsString:@"images/CCFStyle/misc/goodnees.gif"];
}

// private 判断是否包含图片
- (BOOL)isContainsImagesThread:(NSString *)postTitlehtml {
    return [postTitlehtml containsString:@"images/CCFStyle/misc/paperclip.gif"];
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
    NSString *hash = [html stringWithRegular:@"(?<=<input type=\"hidden\" name=\"posthash\" value=\")\\w{32}(?=\" />)"];

    return hash;
}

- (NSString *)parserPostStartTime:(NSString *)html {
    NSString *result = [html stringWithRegular:@"(?<=poststarttime=)\\d+"];
    return result;
}

- (NSString *)parseLoginErrorMessage:(NSString *)html {
    IGHTMLDocument *document = [[IGHTMLDocument alloc] initWithHTMLString:html error:nil];
    IGXMLNodeSet *contents = [document queryWithXPath:@"/html/body/div[2]/div/div/table[3]/tr[2]/td/div/div/div"];

    return contents.firstObject.text;
}

- (NSString *)parseQuote:(NSString *)html {
    IGHTMLDocument *document = [[IGHTMLDocument alloc] initWithHTMLString:html error:nil];
    IGXMLNodeSet *contents = [document queryWithXPath:@"//*[@id=\"vB_Editor_001_textarea\"]/text()"];
    if (contents.firstObject.text == nil) {
        return @"";
    }
    return contents.firstObject.text;
}

- (ViewForumPage *)parsePrivateMessageFromHtml:(NSString *)html {
    ViewForumPage *page = [[ViewForumPage alloc] init];

    IGHTMLDocument *document = [[IGHTMLDocument alloc] initWithHTMLString:html error:nil];

    NSMutableArray<Message *> *messagesList = [NSMutableArray array];

    IGXMLNodeSet *messages = [document queryWithXPath:@"//*[@id='pmform']/table[*]/tbody[*]/tr"];
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
            message.pmAuthor = authorText;

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

    page.pageNumber = [self parserPageNumber:html];
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
- (Forum *)node2Form:(IGXMLNode *)node forumHost:(NSString *) host parentFormId:(int)parentFormId replaceId:(int)replaceId {
    Forum *parent = [[Forum alloc] init];
    NSString *name = [[node childAt:0] text];
    NSString *url = [[node childAt:0] html];
    int forumId = [[url stringWithRegular:@"(?<=f-)\\d+"] intValue];
    int fixForumId = forumId == 0 ? replaceId : forumId;
    parent.forumId = fixForumId;
    parent.parentForumId = parentFormId;
    parent.forumName = name;
    parent.forumHost = host;

    if (node.childrenCount == 2) {
        IGXMLNodeSet *childSet = [node childAt:1].children;
        NSMutableArray<Forum *> *childForms = [NSMutableArray array];

        for (IGXMLNode *childNode in childSet) {
            [childForms addObject:[self node2Form:childNode forumHost: host parentFormId:fixForumId replaceId:replaceId]];
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

@end
