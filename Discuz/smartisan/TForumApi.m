//
//  TForumApi.m
//  Forum
//
//  Created by 迪远 王 on 2018/4/29.
//  Copyright © 2018年 andforce. All rights reserved.
//

#import "TForumApi.h"
#import "TForumConfig.h"
#import "ForumParserDelegate.h"
#import "TForumHtmlParser.h"

#import "AFHTTPSessionManager+SimpleAction.h"
#import "ForumCoreDataManager.h"
#import "NSString+Extensions.h"
#import "IGHTMLDocument.h"
#import "ForumWebViewController.h"


@implementation TForumApi{
    id <ForumConfigDelegate> forumConfig;
    id <ForumParserDelegate> forumParser;
}


- (instancetype)init {
    self = [super init];
    if (self){
        forumConfig = [[TForumConfig alloc] init];
        forumParser = [[TForumHtmlParser alloc]init];
    }
    return self;
}

- (void)GET:(NSString *)url parameters:(NSDictionary *)parameters requestCallback:(RequestCallback)callback{
    NSMutableDictionary *defParameters = [NSMutableDictionary dictionary];
    [defParameters setValue:@"2" forKey:@"styleid"];
    [defParameters setValue:@"1" forKey:@"langid"];

    if (parameters){
        [defParameters addEntriesFromDictionary:parameters];
    }

    [self.browser GETWithURLString:url parameters:defParameters charset:UTF_8 requestCallback:callback];
}

- (void)GET:(NSString *)url requestCallback:(RequestCallback)callback{
    [self GET:url parameters:nil requestCallback:callback];
}

- (void)listAllForums:(HandlerWithBool)handler {
    NSString * url = forumConfig.archive;
    [self GET:url requestCallback:^(BOOL isSuccess, NSString *html) {
        if (isSuccess) {
            NSString * host = forumConfig.forumURL.host;
            NSArray<Forum *> *parserForums = [forumParser parserForums:html forumHost:host];
            if (parserForums != nil && parserForums.count > 0) {
                handler(YES, parserForums);
            } else {
                handler(NO, [forumParser parseErrorMessage:html]);
            }
        } else {
            handler(NO, [forumParser parseErrorMessage:html]);
        }
    }];
}

- (void)listThreadCategory:(NSString *)fid handler:(HandlerWithBool)handler {

}

- (void)createNewThreadWithCategory:(NSString *)category categoryIndex:(int)index withTitle:(NSString *)title andMessage:(NSString *)message withImages:(NSArray *)images inPage:(ViewForumPage *)page handler:(HandlerWithBool)handler {

}

- (void)seniorReplyPostWithMessage:(NSString *)message withImages:(NSArray *)images toPostId:(NSString *)postId thread:(ViewThreadPage *)threadPage handler:(HandlerWithBool)handler {

}

- (void)quoteReplyPostWithMessage:(NSString *)message withImages:(NSArray *)images toPostId:(NSString *)postId thread:(ViewThreadPage *)threadPage handler:(HandlerWithBool)handler {

}

- (void)searchWithKeyWord:(NSString *)keyWord forType:(int)type handler:(HandlerWithBool)handler {

}

- (void)showPrivateMessageContentWithId:(int)pmId withType:(int)type handler:(HandlerWithBool)handler {

}

- (void)sendPrivateMessageToUserName:(NSString *)name andTitle:(NSString *)title andMessage:(NSString *)message handler:(HandlerWithBool)handler {

}

- (void)replyPrivateMessage:(Message *)privateMessage andReplyContent:(NSString *)content handler:(HandlerWithBool)handler {

}

- (void)favoriteForumWithId:(NSString *)forumId handler:(HandlerWithBool)handler {

}

- (void)unFavouriteForumWithId:(NSString *)forumId handler:(HandlerWithBool)handler {

}

- (void)favoriteThreadWithId:(NSString *)threadPostId handler:(HandlerWithBool)handler {

}

- (void)unFavoriteThreadWithId:(NSString *)threadPostId handler:(HandlerWithBool)handler {

}

- (void)listPrivateMessageWithType:(int)type andPage:(int)page handler:(HandlerWithBool)handler {

}

- (void)deletePrivateMessage:(Message *)privateMessage withType:(int)type handler:(HandlerWithBool)handler {

}

- (void)listFavoriteForums:(HandlerWithBool)handler {

}

- (void)listFavoriteThreads:(int)userId withPage:(int)page handler:(HandlerWithBool)handler {

}

- (void)listNewThreadWithPage:(int)page handler:(HandlerWithBool)handler {
    NSDate *date = [NSDate date];
    NSInteger timeStamp = (NSInteger) [date timeIntervalSince1970];

    NSString *url = [forumConfig searchNewThread:page];
    [self GET:url requestCallback:^(BOOL isSuccess, NSString *html) {
        if (isSuccess) {
            ViewSearchForumPage *sarchPage = [forumParser parseSearchPageFromHtml:html];
            handler(isSuccess, sarchPage);
        } else {
            handler(NO, [forumParser parseErrorMessage:html]);
        }
    }];
}

- (void)listMyAllThreadsWithPage:(int)page handler:(HandlerWithBool)handler {

}

- (void)listAllUserThreads:(int)userId withPage:(int)page handler:(HandlerWithBool)handler {

}

- (void)showThreadWithId:(int)threadId andPage:(int)page handler:(HandlerWithBool)handler {

}

- (void)forumDisplayWithId:(int)forumId andPage:(int)page handler:(HandlerWithBool)handler {
    NSString *url = [forumConfig forumDisplayWithId:[NSString stringWithFormat:@"%d", forumId] withPage:page];

    [self GET:url requestCallback:^(BOOL isSuccess, NSString *html) {
        if (isSuccess) {
            ViewForumPage *viewForumPage = [forumParser parseThreadListFromHtml:html withThread:forumId andContainsTop:YES];
            handler(isSuccess, viewForumPage);
        } else {
            handler(NO, [forumParser parseErrorMessage:html]);
        }
    }];
}

- (void)getAvatarWithUserId:(NSString *)userId handler:(HandlerWithBool)handler {
    handler(YES, [NSString stringWithFormat:@"http://bbs.smartisan.com/uc_server/avatar.php?uid=%@&size=middle", userId]);
}

- (void)listSearchResultWithSearchId:(NSString *)searchId keyWord:(NSString *)keyWord andPage:(int)page type:(int)type handler:(HandlerWithBool)handler {

}

- (void)showProfileWithUserId:(NSString *)userId handler:(HandlerWithBool)handler {
    NSString *url = [forumConfig memberWithUserId:userId];
    [self GET:url requestCallback:^(BOOL isSuccess, NSString *html) {
        if (isSuccess) {
            UserProfile *profile = [forumParser parserProfile:html userId:userId];
            handler(YES, profile);
        } else {
            handler(NO, [forumParser parseErrorMessage:html]);
        }
    }];
}

- (void)reportThreadPost:(int)postId andMessage:(NSString *)message handler:(HandlerWithBool)handler {

}

- (BOOL)openUrlByClient:(ForumWebViewController *)controller request:(NSURLRequest *)request {
    return NO;
}

- (void)fetchUserInfo:(UserInfoHandler)handler {
    NSString * url = forumConfig.forumURL.absoluteString;

    [self GET:url requestCallback:^(BOOL isSuccess, NSString *html) {
        if (isSuccess) {

            IGHTMLDocument *document = [[IGHTMLDocument alloc] initWithHTMLString:html error:nil];

            IGXMLNode * uidNode = [document queryWithCSS:@"#um > div.ui-login-toggle > span.user-avatar"][0];
            NSString *uid = [uidNode.html stringWithRegular:@"(?<=uid=)\\d+"];
            
            IGXMLNode *nameNode = [document queryWithCSS:@"#um > div.ui-login-toggle > span.user-name.hide-row"][0];
            
            NSString *name = [nameNode.text trim];
            
            handler(isSuccess, name, uid);
        } else {
            handler(NO, @"", [forumParser parseErrorMessage:html]);
        }
    }];
}

@end
