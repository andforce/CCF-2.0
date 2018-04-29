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

@implementation TForumHtmlParser
- (ViewThreadPage *)parseShowThreadWithHtml:(NSString *)html {
    return nil;
}

- (ViewForumPage *)parseThreadListFromHtml:(NSString *)html withThread:(int)threadId andContainsTop:(BOOL)containTop {
    return nil;
}

- (ViewForumPage *)parseFavorThreadListFromHtml:(NSString *)html {
    return nil;
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

    IGXMLNode *fourRowNode = [document queryWithCSS:@"body > div.main.forums-page.clearfix > div > div.section"][0];

    NSMutableArray<Forum *> *forums = [NSMutableArray array];
    int replaceId = 10000;
    for (IGXMLNode * child in fourRowNode.children) {

        Forum *parent = [[Forum alloc] init];
        for (int i = 0; i < child.childrenCount; ++i) {

            IGXMLNode *childNode = [child childAt:i];
            NSLog(@">>>>>>>> %@", childNode.html);

            if (i == 0){
                parent.forumName = [childNode.text trim];
                parent.forumId = replaceId ++;
                parent.forumHost = host;
                parent.parentForumId = -1;
                [forums addObject:parent];
            } else {

                for (int j = 0; j < [childNode childAt:0].childrenCount; ++j) {

                    IGXMLNode *liNode = [[childNode childAt:0] childAt:j];
                    NSLog(@">>>>>>>> %@", liNode.html);
                    IGXMLNode *nameNode = [[liNode childAt:1] childAt:0];
                    NSString *name = [nameNode.text trim];

                    NSString *forumIdStr = [nameNode.html stringWithRegular:@"(?<=fid=)\\d+"];

                    Forum *childForum = [[Forum alloc] init];
                    childForum.forumName = name;
                    childForum.forumId = [forumIdStr integerValue];
                    childForum.forumHost = host;
                    childForum.parentForumId = parent.forumId;

                    [forums addObject:childForum];
                }

            }

        }
    }

    return forums;
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
