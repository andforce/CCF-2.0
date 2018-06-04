//
// Created by 迪远 王 on 2017/5/6.
// Copyright (c) 2017 andforce. All rights reserved.
//

#import "CHHForumHtmlParser.h"

#import "ForumEntry+CoreDataClass.h"

#import "ForumCoreDataManager.h"
#import "NSString+Extensions.h"

#import "IGHTMLDocument+QueryNode.h"
#import "IGXMLNode+Children.h"
#import "AppDelegate.h"
#import "LocalForumApi.h"
#import "Message.h"
#import "CommonUtils.h"
#import "ViewMessage.h"

@implementation CHHForumHtmlParser {

}
- (ViewThreadPage *)parseShowThreadWithHtml:(NSString *)html {
    NSString * fixImagesHtml = html;
    NSString *newImagePattern = @"<img src=\"%@\" />";
    NSArray *orgImages = [fixImagesHtml arrayWithRegular:@"<img id=\"aimg_\\d+\" aid=\"\\d+\" src=\".*\" zoomfile=\".*\" file=\".*\" class=\"zoom\" onclick=\".*\" width=\".*\" .*"];
    for (NSString *img in orgImages) {

        IGXMLDocument *igxmlDocument = [[IGXMLDocument alloc] initWithXMLString:img error:nil];
        NSString * file = [igxmlDocument attribute:@"file"];
        NSString * newImage = [NSString stringWithFormat:newImagePattern, file];
        NSLog(@"parseShowThreadWithHtml orgimage: %@ %@", img, newImage);

        fixImagesHtml = [fixImagesHtml stringByReplacingOccurrencesOfString:img withString:newImage];
    }

    IGHTMLDocument * document = [[IGHTMLDocument alloc] initWithHTMLString:fixImagesHtml error:nil];

    ViewThreadPage *showThreadPage = [[ViewThreadPage alloc] init];
    // threadId
    IGXMLNode * threadIdNode = [document queryNodeWithXPath:@"//*[@id=\"postlist\"]/table[1]/tr/td[2]/span/a"];
    NSString * threadId = [[threadIdNode attribute:@"href"] componentsSeparatedByString:@"-"][1];
    // threadTitle
    IGXMLNode * threadTitleNode = [document queryNodeWithXPath:@"//*[@id=\"thread_subject\"]"];
    NSString * threadTitle = [[threadTitleNode text] trim];
    // forumId
    IGXMLNode * forumIdNode = [document queryNodeWithXPath:@"//*[@id=\"pt\"]/div/a[4]"];
    NSString * forumId = [[forumIdNode attribute:@"href"] componentsSeparatedByString:@"-"][1];
    // origin html
    NSString * originHtml = [document queryNodeWithXPath:@"//*[@id=\"postlist\"]"].html;


    // pageNumber
    PageNumber *pageNumber = [self parserPageNumber:fixImagesHtml];

    showThreadPage.threadID = [threadId intValue];
    showThreadPage.threadTitle = threadTitle;
    showThreadPage.forumId= [forumId intValue];
    showThreadPage.originalHtml = originHtml;

    showThreadPage.pageNumber = pageNumber;


    // 回帖列表
    NSMutableArray<Post *> *postList = [NSMutableArray array];

    IGXMLNode * postListNode = [document queryNodeWithXPath:@"//*[@id=\"postlist\"]"];
    for (IGXMLNode * node in postListNode.children){
        NSString * nodeHtml = node.html.trim;
        if ([nodeHtml hasPrefix:@"<div id=\"post_"]){
            Post * post = [[Post alloc] init];
            NSString *postId = [[node attribute:@"id"] componentsSeparatedByString:@"_"][1];
            NSString * loucengQuery = [NSString stringWithFormat: @"//*[@id=\"postnum%@\"]/em", postId];
            IGXMLNode * postLouCengNode = [document queryNodeWithXPath:loucengQuery];
            NSString *postLouCeng = [[postLouCengNode text] trim];
            // 发表时间
            NSString *postTimeQuery = [NSString stringWithFormat:@"//*[@id=\"authorposton%@\"]", postId];
            NSString *postTime = [[document queryNodeWithXPath:postTimeQuery] text];//[[[document queryNodeWithXPath:postTimeQuery] text] stringWithRegular:@"\\d+-\\d+\\d+ \\d+:\\d+"];
            // 发表内容


            NSString *contentQuery = [NSString stringWithFormat:@"//*[@id=\"pid%@\"]/tr[1]/td[2]/div[2]/div/div[1]", postId];
            NSString *postContent = [document queryNodeWithXPath:contentQuery].html;
            // User Info
            User * user = [[User alloc] init];
            // UserId
            //NSString * userQuery = [NSString stringWithFormat:@"//*[@id=\"favatar%@\"]", postId];
            //IGXMLNode * userNode = [document queryNodeWithXPath:userQuery];
            NSString * idNameQuery = [NSString stringWithFormat:@"//*[@id=\"favatar%@\"]/div[1]/div/a", postId];
            IGXMLNode *idNameNode = [document queryNodeWithXPath:idNameQuery];
            NSString *userId = [[idNameNode attribute:@"href"] stringWithRegular:@"\\d+"];
            NSString * userName = [[idNameNode text] trim];

            NSString * avatarQuery = [NSString stringWithFormat:@"//*[@id=\"favatar%@\"]/div[3]/div/a/img", postId];
            IGXMLNode * avatarNode = [document queryNodeWithXPath:avatarQuery];
            NSString * avatar = [avatarNode attribute:@"src"];

            NSString * rankQuery = [NSString stringWithFormat:@"//*[@id=\"favatar%@\"]/p[1]/em/a", postId];
            IGXMLNode *rankNode = [document queryNodeWithXPath:rankQuery];
            NSString *rank = [[rankNode text] trim];

            // 注册日期
            NSString * signQuery = [NSString stringWithFormat:@"//*[@id=\"favatar%@\"]/dl[1]/dd[4]", postId];
            IGXMLNode * signNode = [document queryNodeWithXPath:signQuery];
            NSString * signDate = [signNode text];
            user.userAvatar = avatar;
            user.userID = userId;
            user.userName = userName;
            user.userRank = rank;
            user.userSignDate = signDate;

            post.postContent = postContent;
            post.postID = postId;
            post.postLouCeng = postLouCeng;
            post.postTime = postTime;
            post.postUserInfo = user;

            [postList addObject:post];

        }
    }

    showThreadPage.postList = postList;

    NSString * forumHash = [self parseSecurityToken:html];
    showThreadPage.securityToken = forumHash;

    return showThreadPage;
}

- (ViewForumPage *)parseThreadListFromHtml:(NSString *)html withThread:(int)threadId andContainsTop:(BOOL)containTop {
    ViewForumPage *page = [[ViewForumPage alloc] init];

    NSMutableArray<Thread *> *threadList = [NSMutableArray<Thread *> array];


    IGHTMLDocument *document = [[IGHTMLDocument alloc] initWithHTMLString:html error:nil];
    IGXMLNode *contents = [document queryNodeWithXPath:@"//*[@id='threadlisttableid']"];
    int childCount = contents.childrenCount;

    for (int i = 0; i < childCount; ++i) {
        IGXMLNode * threadNode = [contents childAt:i];
        if (threadNode.childrenCount == 1 && threadNode.firstChild.childrenCount == 5){
            NSString * threadNodeHtml = threadNode.html;
            NSLog(@"%@", threadNodeHtml);

            Thread *thread = [[Thread alloc] init];
            // threadId
            NSString * idAttr = [threadNode attribute:@"id"];
            if (idAttr == nil || ![idAttr containsString:@"_"]) {
                continue;
            }
            NSString * tId = [idAttr componentsSeparatedByString:@"_"][1];
            // thread Title
            IGXMLNode * titleNode = [threadNode.firstChild childAt:1];
            NSString * titleHtml = titleNode.html;

            NSString *threadTitle = [titleHtml stringWithRegular:@"(?<=class=\"s xst\">).*(?=</a>)"];
            if (threadTitle == nil || [threadTitle isEqualToString:@""]){
                continue;
            }
            // 作者
            IGXMLNode * authorNode = [threadNode.firstChild childAt:2];
            if (authorNode.childrenCount < 2){
                continue;
            }
            NSString *threadAuthor = [[[authorNode childAt:0] text] trim];
            // 作者ID
            NSString *threadAuthorId = [authorNode.innerHtml stringWithRegular:@"space-uid-\\d+" andChild:@"\\d+"];
            //最后发表时间
            IGXMLNode * lastAuthorNode = [threadNode.firstChild childAt:4];
            if (lastAuthorNode.childrenCount < 2){
                continue;
            }
            NSString *lastPostTime = [[lastAuthorNode childAt:1].text trim];
            // 是否是精华
            // 都不是
            // 是否包含图片
            BOOL isHaveImage = [threadNode.html containsString:@"<img src=\"static/image/filetype/image_s.gif\" alt=\"attach_img\" title=\"图片附件\" align=\"absmiddle\">"];

            // 回复数量
            IGXMLNode * numberNode = [threadNode.firstChild childAt:3];
            NSString * huitieShu = numberNode.firstChild.text.trim;
            // 查看数量
            NSString * chakanShu = [[[numberNode childAt:1] text] trim];

            // 最后发表的人
            NSString *lastAuthorName = [[lastAuthorNode childAt:0].text trim];

            // 帖子回帖页数
            int totalPage = 1;
            if ([titleNode.html containsString:@"<span class=\"tps\">"]){
                IGXMLNode * pageNode = [titleNode childAt:titleNode.childrenCount - 1];
                if ([[pageNode text] isEqualToString:@"New"]) {
                    pageNode = [titleNode childAt:titleNode.childrenCount - 2];
                }
                int pageNodeChildCount = pageNode.childrenCount;
                IGXMLNode * realPageNode = [pageNode childAt:pageNodeChildCount - 1];
                totalPage = [[realPageNode text] intValue];
            }

            // 是否是置顶
            IGXMLNode * iconNode = [threadNode.firstChild childAt:0];
            BOOL isPin = [iconNode.html containsString:@"<img src=\"static/image/common/pin"];
            if (!isPin) {
                isPin = [iconNode.html containsString:@"static/image/common/folder_lock.gif"];
            }

            thread.threadID = tId;
            thread.threadTitle = threadTitle;
            thread.threadAuthorName = threadAuthor;
            thread.threadAuthorID = threadAuthorId;
            thread.lastPostTime = lastPostTime;
            thread.isGoodNess = NO;
            thread.isContainsImage = isHaveImage;
            thread.postCount = huitieShu;
            thread.openCount = chakanShu;
            thread.lastPostAuthorName = lastAuthorName;
            thread.totalPostPageCount = totalPage;
            thread.isTopThread = isPin;

            [threadList addObject:thread];
        }
    }

    page.dataList = threadList;

    //<input type="hidden" name="srhfid" value="201" />
    int fid = [[html stringWithRegular:@"(?<=<input type=\"hidden\" name=\"srhfid\" value=\")\\d+(?=\" />)"] intValue];
    page.forumId = fid;
    // 总页数

    PageNumber *pageNumber = [self parserPageNumber:html];
    page.pageNumber = pageNumber;


    return page;
}

- (ViewForumPage *)parseFavorThreadListFromHtml:(NSString *)html {
    ViewForumPage *page = [[ViewForumPage alloc] init];
    IGHTMLDocument *document = [[IGHTMLDocument alloc] initWithHTMLString:html error:nil];

    IGXMLNode * favNode = [document queryNodeWithXPath:@"//*[@id=\"favorite_ul\"]"];
    if (favNode != nil){
        NSMutableArray<Thread *> *threadList = [NSMutableArray<Thread *> array];
        for (IGXMLNode * fav in favNode.children){
            Thread *thread = [[Thread alloc] init];
            IGXMLNode *titleNode = [fav queryWithXPath:@"a[2]"].firstObject;
            NSString * title = [titleNode text];
            NSString *thradId = [[titleNode attribute:@"href"] componentsSeparatedByString:@"-"][1];

            //*[@id="fav_1010109"]/span
            NSString *favTime = [[fav queryWithXPath:@"span"].firstObject text];

            thread.threadTitle = title;
            thread.threadID = thradId;
            thread.lastPostTime = favTime;

            [threadList addObject:thread];
        }
        page.dataList = threadList;
    }

    PageNumber *pageNumber = [self parserPageNumber:html];
    page.pageNumber = pageNumber;
    return page;
}

- (ViewSearchForumPage *)parseSearchPageFromHtml:(NSString *)html {
    ViewSearchForumPage *page = [[ViewSearchForumPage alloc] init];

    NSMutableArray<Thread *> *threadList = [NSMutableArray<Thread *> array];


    IGHTMLDocument *document = [[IGHTMLDocument alloc] initWithHTMLString:html error:nil];
    //*[@id="threadlist"]/div[2]/table
    IGXMLNode *contents = [document queryNodeWithXPath:@"//*[@id=\"threadlist\"]/div[2]/table"];
    int childCount = contents.childrenCount;

    for (int i = 0; i < childCount; ++i) {
        IGXMLNode * threadNode = [contents childAt:i];
        if (threadNode.childrenCount == 1 && threadNode.firstChild.childrenCount == 6){
            NSString * threadNodeHtml = threadNode.html;
            NSLog(@"%@", threadNodeHtml);

            Thread *thread = [[Thread alloc] init];
            // threadId
            NSString * idAttr = [threadNode attribute:@"id"];
            if (idAttr == nil || ![idAttr containsString:@"_"]) {
                continue;
            }
            NSString * tId = [idAttr componentsSeparatedByString:@"_"][1];
            // thread Title
            IGXMLNode * titleNode = [threadNode.firstChild childAt:1];

            int titleIndex = 0;
            NSString *threadTitle = [titleNode childAt:titleIndex].text;
            // 作者
            IGXMLNode * authorNode = [threadNode.firstChild childAt:3];
            NSString *threadAuthor = [[[authorNode childAt:0] text] trim];
            // 作者ID
            NSString *threadAuthorId = [authorNode.innerHtml stringWithRegular:@"space-uid-\\d+" andChild:@"\\d+"];
            //最后发表时间
            IGXMLNode * lastAuthorNode = [threadNode.firstChild childAt:5];
            NSString *lastPostTime = [[lastAuthorNode childAt:1].text trim];
            // 是否是精华
            // 都不是
            // 是否包含图片
            BOOL isHaveImage = [threadNode.html containsString:@"<img src=\"static/image/filetype/image_s.gif\" alt=\"attach_img\" title=\"图片附件\" align=\"absmiddle\">"];

            // 回复数量
            IGXMLNode * numberNode = [threadNode.firstChild childAt:4];
            NSString * huitieShu = numberNode.firstChild.text.trim;
            // 查看数量
            NSString * chakanShu = [[[numberNode childAt:1] text] trim];

            // 最后发表的人
            NSString *lastAuthorName = [[lastAuthorNode childAt:0].text trim];

            // 帖子回帖页数
            int totalPage = 1;
            if ([titleNode.html containsString:@"<span class=\"tps\">"]){
                IGXMLNode * pageNode = [titleNode childAt:titleNode.childrenCount - 1];
                if ([[pageNode text] isEqualToString:@"New"]) {
                    pageNode = [titleNode childAt:titleNode.childrenCount - 2];
                }
                int pageNodeChildCount = pageNode.childrenCount;
                IGXMLNode * realPageNode = [pageNode childAt:pageNodeChildCount - 1];
                totalPage = [[realPageNode text] intValue];
            }

            thread.threadID = tId;
            thread.threadTitle = threadTitle;
            thread.threadAuthorName = threadAuthor;
            thread.threadAuthorID = threadAuthorId;
            thread.lastPostTime = lastPostTime;
            thread.isGoodNess = NO;
            thread.isContainsImage = isHaveImage;
            thread.postCount = huitieShu;
            thread.openCount = chakanShu;
            thread.lastPostAuthorName = lastAuthorName;
            thread.totalPostPageCount = totalPage;

            [threadList addObject:thread];
        }
    }

    page.dataList = threadList;

    // 总页数
    PageNumber *pageNumber = [self parserPageNumber:html];
    page.pageNumber = pageNumber;


    return page;
}

- (ViewSearchForumPage *)parseZhanNeiSearchPageFromHtml:(NSString *)html type:(int)type {
    ViewSearchForumPage *page = [[ViewSearchForumPage alloc] init];

    NSMutableArray<Thread *> *threadList = [NSMutableArray<Thread *> array];

    IGHTMLDocument *document = [[IGHTMLDocument alloc] initWithHTMLString:html error:nil];

    NSString * xpath = @"result f s0";
    if (type == 1){
        xpath = @"result f s3";
    }
    IGXMLNodeSet *contents = [document queryWithClassName:xpath];
    int childCount = contents.count;

    for (int i = 0; i < childCount; ++i) {
        IGXMLNode *node = contents[(NSUInteger) i];
        IGXMLNode *titleNode = [[node childAt:0] childAt:0];
        NSString *href = [titleNode attribute:@"href"];
        if (![href containsString:@"/thread-"]){
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
    NSString * totalCount = [[document queryNodeWithXPath:@"//*[@id=\"results\"]/span"].text stringWithRegular:@"\\d+"];
    int tInt = [totalCount intValue];
    if (tInt % 10 == 0){
        pageNumber.totalPageNumber = [totalCount intValue] / 10;
    } else {
        pageNumber.totalPageNumber = [totalCount intValue] / 10 + 1;
    }

    page.pageNumber = pageNumber;


    return page;
}

- (ViewMessagePage *)parsePrivateMessageContent:(NSString *)html avatarBase:(NSString *)avatarBase noavatar:(NSString *)avatarNO {

    IGHTMLDocument *document = [[IGHTMLDocument alloc] initWithHTMLString:html error:nil];

    IGXMLNodeSet *pmUlSet = [document queryNodeWithXPath:@"//*[@id=\"pm_ul\"]"].children;

    ViewMessagePage *privateMessage = [[ViewMessagePage alloc] init];
    NSMutableArray *datas = [NSMutableArray array];
    privateMessage.viewMessages = datas;
    for (IGXMLNode *node in pmUlSet) {
        ViewMessage * viewMessage = [[ViewMessage alloc] init];

        if (![node.tag isEqualToString:@"dl"]){
            continue;
        }
        
        viewMessage.pmContent = [[node childAt:2] html];
        // 回帖时间
        NSString *timeLong = [[[node childAt:2] html] stringWithRegular:@"(?<=<span class=\"xg1\">)\\d+-\\d+-\\d+ \\d+:\\d+(?=</span>)"];
        viewMessage.pmTime = [CommonUtils timeForShort:timeLong withFormat:@"yyyy-MM-dd, HH:mm:ss"];
        // PM ID
        NSString *pmId = [[node attribute:@"id"] stringWithRegular:@"\\d+"];
        viewMessage.pmID = pmId;

        // PM Title
        viewMessage.pmTitle = @"NULL";

        // User Info
        User *pmAuthor = [[User alloc] init];
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

- (UserProfile *)parserProfile:(NSString *)html userId:(NSString *)userId {
    IGHTMLDocument *document = [[IGHTMLDocument alloc] initWithHTMLString:html error:nil];

    UserProfile *profile = [[UserProfile alloc] init];
    NSString *profileUserId = userId;
    NSString *profileRank = [[document queryNodeWithXPath:@"//*[@id=\"ct\"]/div/div[2]/div/div[1]/div[2]/ul[1]/li/span/a"] text];
    NSString *profileName = [[[document queryNodeWithXPath:@"//*[@id=\"uhd\"]/div/h2"] text] trim];
    NSString *profileRegisterDate = [[[document queryNodeWithXPath:@"//*[@id=\"pbbs\"]/li[2]/text()"] text] trim];
    NSString *profileRecentLoginDate = [[[document queryNodeWithXPath:@"//*[@id=\"pbbs\"]/li[3]/text()"] text] trim];
    NSString *profileTotalPostCount = [[[document queryNodeWithXPath:@"//*[@id=\"ct\"]/div/div[2]/div/div[1]/div[1]/ul[3]/li/a[3]"] text] trim];

    profile.profileUserId = profileUserId;
    profile.profileRank = profileRank;
    profile.profileName = profileName;
    profile.profileRegisterDate = profileRegisterDate;
    profile.profileRecentLoginDate = profileRecentLoginDate;
    profile.profileTotalPostCount = profileTotalPostCount;
    return profile;
}

- (NSArray<Forum *> *)parserForums:(NSString *)html forumHost:(NSString *)host {
    IGHTMLDocument *document = [[IGHTMLDocument alloc] initWithHTMLString:html error:nil];

    NSMutableArray<Forum *> *forms = [NSMutableArray array];

    NSString *xPath = @"//*[@id='content']";

    IGXMLNode *contents = [document queryNodeWithXPath:xPath];
    int size = contents.childrenCount;

    int replaceId = 10000;
    Forum * current;
    for (int i = 0; i < size; i++) {
        IGXMLNode * child = [contents childAt:i];

        if (child.childrenCount == 0){
            Forum *parent = [[Forum alloc] init];
            NSString * name = child.text;
            parent.forumName = name;
            parent.forumId = replaceId;
            replaceId ++;
            parent.forumHost = host;
            parent.parentForumId = -1;

            current = parent;
            [forms addObject:parent];
        } else{
            NSMutableArray<Forum *> *childForms = [NSMutableArray array];
            IGXMLNodeSet * set = child.children;
            for(IGXMLNode * node in set){

                Forum *childForum = [[Forum alloc] init];
                NSString * name = node.text;
                childForum.forumName = name;

                NSString *url = [[node childAt:0] attribute:@"href"];
                int forumId = [[url stringWithRegular:@"fid-\\d+" andChild:@"\\d+"] intValue];
                childForum.forumId = forumId;
                childForum.forumHost = host;
                childForum.parentForumId = current.forumId;

                [childForms addObject:childForum];
            }

            current.childForums = childForms;

        }

    }

    NSMutableArray<Forum *> *needInsert = [NSMutableArray array];

    for (Forum *forum in forms) {
        [needInsert addObjectsFromArray:[self flatForm:forum]];
    }

    return [needInsert copy];
}

- (NSMutableArray<Forum *> *)parseFavForumFromHtml:(NSString *)html {
    IGHTMLDocument *document = [[IGHTMLDocument alloc] initWithHTMLString:html error:nil];
    //*[@id="favorite_ul"]
    IGXMLNode * favoriteUl = [document queryNodeWithXPath:@"//*[@id=\"favorite_ul\"]"];
    IGXMLNodeSet * favoriteLis = favoriteUl.children;

    NSMutableArray *ids = [NSMutableArray array];

    for (IGXMLNode *favLi in favoriteLis){
        IGXMLNode * forumIdNode = [favLi childAt:2];
        NSString * forumIdNodeHtml = forumIdNode.html;
        //<a href="forum-196-1.html" target="_blank">GALAX</a>
        NSString *idsStr = [forumIdNodeHtml stringWithRegular:@"forum-\\d+" andChild:@"\\d+"];
        [ids addObject:@(idsStr.intValue)];
        NSLog(@"%@", forumIdNodeHtml);
    }

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
    PageNumber *pageNumber = [[PageNumber alloc] init];

    IGHTMLDocument *document = [[IGHTMLDocument alloc] initWithHTMLString:html error:nil];

    IGXMLNode * pageNode = [document queryNodeWithClassName:@"pg"];

    NSString * nodeHtml = pageNode.html;
    pageNumber.currentPageNumber = [[nodeHtml stringWithRegular:@"(?<=<strong>)\\d+(?=</strong>)"] intValue];
    pageNumber.totalPageNumber = [[nodeHtml stringWithRegular:@"(?<=<span title=\"共 )\\d+(?= 页\">)"] intValue];

    if (pageNumber.currentPageNumber == 0 || pageNumber.totalPageNumber == 0){
        pageNumber.currentPageNumber = 1;
        pageNumber.totalPageNumber = 1;
    }
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

    NSMutableArray<Message *> *messagesList = [NSMutableArray array];
    for (IGXMLNode *pmNode in pmRootNode.children){
        Message *message = [[Message alloc] init];
        NSString *newPm = [pmNode attribute:@"class"];
        BOOL isReaded = ![newPm isEqualToString:@"bbda cur1 cl newpm"];
        NSString *pmId = [[pmNode attribute:@"id"] componentsSeparatedByString:@"_"].lastObject;

        //*[@id="pmlist_973711"]/dd[2]/text()[1]
        IGXMLNodeSet *dd = [pmNode queryWithXPath:@"dd[2]/text()"];
        NSString * title = [[[dd[4] text] trim] stringByReplacingOccurrencesOfString:@"\n" withString:@" "];

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

    IGXMLNode *pmRootNode = [document queryNodeWithXPath:@"//*[@id=\"ct\"]/div[1]/div/div/div"];

    NSMutableArray<Message *> *messagesList = [NSMutableArray array];
    for (IGXMLNode *pmNode in pmRootNode.children){
        Message *message = [[Message alloc] init];

        BOOL isReaded = NO;

        // Title
        IGXMLNodeSet *actionNode = [pmNode queryWithXPath:@"dd[2]/text()"];
        NSString * action = [[actionNode[1] text] trim];
        IGXMLNode *actionTitleNode = [pmNode queryWithXPath:@"dd[2]/a[2]"].firstObject;
        NSString *pmId = [actionTitleNode attribute:@"href"];
        NSString *actionTitle = [[actionTitleNode text] trim];
        NSString * title = [NSString stringWithFormat:@"%@ %@", action, actionTitle];

        // 作者
        IGXMLNode *authorNode = [pmNode queryWithXPath:@"dd[2]/a[1]"].firstObject;
        NSString *authorName = [[authorNode text] trim];
        NSString *authorId = [[authorNode attribute:@"href"] stringWithRegular:@"\\d+"];

        // 时间
        IGXMLNode *timeNode = [pmNode queryWithXPath:@"dt/span"].firstObject;
        NSString *time = [timeNode text];

        message.isReaded = isReaded;
        message.pmID = pmId;
        message.pmAuthor = authorName;
        message.pmAuthorId = authorId;
        message.pmTime = time;
        message.pmTitle = title;

        IGXMLNode * node = [[pmNode childAt:2] childAt:1];

        message.pid = [[node html] stringWithRegular:@"(?<=;pid=)\\d+"];
        message.ptid = [[node html] stringWithRegular:@"(?<=;ptid=)\\d+"];

        [messagesList addObject:message];

    }

    page.dataList = messagesList;
    PageNumber *pageNumber = [self parserPageNumber:html];
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
