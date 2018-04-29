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
#import "IGHTMLDocument+QueryNode.h"
#import "IGXMLNode+Children.h"
#import "NSString+Extensions.h"

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

@end
