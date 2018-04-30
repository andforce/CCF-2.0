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
#import "LocalForumApi.h"


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

- (void)favoriteForumWithId:(NSString *)forumId handler:(HandlerWithBool)handler {
    NSString *key = [forumConfig.forumURL.host stringByAppendingString:@"-favForums"];

    NSUbiquitousKeyValueStore * store = [NSUbiquitousKeyValueStore defaultStore];

    NSString * data = [store stringForKey:key];

    LocalForumApi *localForumApi = [[LocalForumApi alloc] init];

    if (data){
        NSArray * favForumIds = [data componentsSeparatedByString:@","];
        NSLog(@"favoriteForumsWithId \t%@", favForumIds);
        if (![favForumIds containsObject:forumId]){
            NSMutableArray * array = [favForumIds mutableCopy];
            [array addObject:forumId];

            // 存到云端
            NSString * newForums = [array componentsJoinedByString:@","];
            [store setString:newForums forKey:key];
            [store synchronize];

            // 存到本地
            NSMutableArray * ids = [NSMutableArray array];
            for (NSString *fid in favForumIds){
                [ids addObject:@([fid intValue])];
            }
            [localForumApi saveFavFormIds:ids];
        }
    } else {
        NSMutableArray * array = [NSMutableArray array];
        [array addObject:forumId];

        // 存到云端
        NSString * newForums = [array componentsJoinedByString:@","];
        [store setString:newForums forKey:key];
        [store synchronize];

        // 存到本地
        NSMutableArray * ids = [NSMutableArray array];

        [ids addObject:@([forumId intValue])];
        [localForumApi saveFavFormIds:ids];
    }

    handler(YES, @"SUCCESS");
}

- (void)unFavouriteForumWithId:(NSString *)forumId handler:(HandlerWithBool)handler {
    NSString *key = [forumConfig.forumURL.host stringByAppendingString:@"-favForums"];

    NSUbiquitousKeyValueStore * store = [NSUbiquitousKeyValueStore defaultStore];

    NSString * data = [store stringForKey:key];
    NSArray * favForumIds = [data componentsSeparatedByString:@","];
    NSLog(@"favoriteForumsWithId \t%@", favForumIds);
    if ([favForumIds containsObject:forumId]){
        NSMutableArray * array = [favForumIds mutableCopy];
        [array removeObject:forumId];

        // 存到云端
        NSString * newForums = [array componentsJoinedByString:@","];
        [store setString:newForums forKey:key];
        [store synchronize];

        // 存到本地
        NSMutableArray * ids = [NSMutableArray array];
        for (NSString *fid in favForumIds){
            [ids addObject:@([fid intValue])];
        }
        LocalForumApi *localForumApi = [[LocalForumApi alloc] init];
        [localForumApi saveFavFormIds:ids];
    }

    handler(YES, @"SUCCESS");
}

- (void)favoriteThreadWithId:(NSString *)threadPostId handler:(HandlerWithBool)handler {

}

- (void)unFavoriteThreadWithId:(NSString *)threadPostId handler:(HandlerWithBool)handler {

}

- (void)listFavoriteForums:(HandlerWithBool)handler {
    NSString *key = [forumConfig.forumURL.host stringByAppendingString:@"-favForums"];

    NSUbiquitousKeyValueStore * store = [NSUbiquitousKeyValueStore defaultStore];

    NSString * data = [store stringForKey:key];
    NSArray * favForumIds = [data componentsSeparatedByString:@","];
    NSMutableArray * ids = [NSMutableArray array];
    for (NSString *forumId in favForumIds){
        [ids addObject:@([forumId intValue])];
    }
    LocalForumApi *localForumApi = [[LocalForumApi alloc] init];
    [localForumApi saveFavFormIds:ids];

    ForumCoreDataManager *manager = [[ForumCoreDataManager alloc] initWithEntryType:EntryTypeForm];
    NSArray *forms = [[manager selectFavForums:ids] mutableCopy];

    handler(YES, forms);
}

// private
- (void)listFavoriteForums:(int ) page handler:(HandlerWithBool)handler {
    NSString * baseUrl = forumConfig.favoriteForums;
    NSString * favForumsURL = [NSString stringWithFormat:@"%@&page=%d",baseUrl,page];

    [self GET:favForumsURL requestCallback:^(BOOL isSuccess, NSString *html) {
        handler(isSuccess, html);
    }];
}

- (void)listFavoriteThreads:(int)userId withPage:(int)page handler:(HandlerWithBool)handler {
    NSString *url = [forumConfig listFavorThreads:userId withPage:page];
    [self GET:url requestCallback:^(BOOL isSuccess, NSString *html) {
        if (isSuccess) {
            ViewForumPage *viewForumPage = [forumParser parseFavorThreadListFromHtml:html];
            handler(isSuccess, viewForumPage);
        } else {
            handler(NO, [forumParser parseErrorMessage:html]);
        }
    }];
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
    NSString * url = [forumConfig showThreadWithThreadId:[NSString stringWithFormat:@"%d", threadId] withPage:page];
    [self GET:url requestCallback:^(BOOL isSuccess, NSString *html) {
        if (isSuccess) {
            ViewThreadPage *detail = [forumParser parseShowThreadWithHtml:html];
            handler(isSuccess, detail);
        } else {
            handler(NO, [forumParser parseErrorMessage:html]);
        }
    }];
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
