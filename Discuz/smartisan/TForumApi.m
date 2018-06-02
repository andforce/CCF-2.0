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

#import "NSUserDefaults+Setting.h"
#import "IGHTMLDocument+QueryNode.h"
#import "IGXMLNode+Children.h"
#import "CommonUtils.h"

@implementation TForumApi{
    TForumConfig* forumConfig;
    TForumHtmlParser* forumParser;
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

// private 正式开始发送
- (void)doPostThread:(int)fId withSubject:(NSString *)subject andMessage:(NSString *)message postHash:(NSString *)posthash formHash:(NSString *)formhash
         secCodeHash:(NSString *)seccodehash seccodeverify:(NSString *)seccodeverify postTime:(NSString *)postTime typeid:(NSString *)typeid handler:(HandlerWithBool)handler {

    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];

    [parameters setValue:posthash forKey:@"post_hash"];              //dcc2334442ae357493f144de82be1cbf
    [parameters setValue:@"true" forKey:@"post_action"];
    [parameters setValue:formhash forKey:@"formhash"];
    [parameters setValue:postTime forKey:@"posttime"];
    [parameters setValue:@"1" forKey:@"wysiwyg"];
    [parameters setValue:typeid forKey:@"typeid"];
    [parameters setValue:subject forKey:@"subject"];                    //客户端帖子测试
    [parameters setValue:message forKey:@"message"];                    //看看能发图片么？
    [parameters setValue:@"1" forKey:@"allownoticeauthor"];
    [parameters setValue:@"forum::post" forKey:@"seccodemodid"];
    [parameters setValue:seccodehash forKey:@"seccodehash"];
    [parameters setValue:seccodeverify forKey:@"seccodeverify"];          // 验证码
    [parameters setValue:@"true" forKey:@"topicsubmit"];
    [parameters setValue:@"" forKey:@"save"];

    NSString *url = [forumConfig createNewThreadWithForumId:[NSString stringWithFormat:@"%d", fId]];
    [self.browser POSTWithURLString: url
                         parameters:parameters charset:UTF_8 requestCallback:^(BOOL isSuccess, NSString *html) {

                if (isSuccess) {
                    LocalForumApi *localForumApi = [[LocalForumApi alloc] init];
                    [localForumApi saveCookie];
                }
                handler(isSuccess, html);

            }];
}

- (void)createNewThreadWithCategory:(NSString *)categoryName categoryValue:(NSString *)categoryValue withTitle:(NSString *)title andMessage:(NSString *)message
                         withImages:(NSArray *)images inPage:(ViewForumPage *)page postHash:(NSString *)posthash
                           formHash:(NSString *)formhash secCodeHash:(NSString *)seccodehash seccodeverify:(NSString *)seccodeverify
                           postTime:(NSString *)postTime handler:(HandlerWithBool)handler {

    if ([NSUserDefaults standardUserDefaults].isSignatureEnabled) {
        //message = [message stringByAppendingString:[forumConfig signature]];

    }

    int fId = page.forumId;

    if (images == nil || images.count == 0) {
        [self doPostThread:fId withSubject:title andMessage:message postHash:posthash formHash:formhash
               secCodeHash:seccodehash seccodeverify:seccodeverify postTime:postTime
                    typeid:categoryValue handler:^(BOOL isSuccess, NSString * result) {
                    if (isSuccess) {
                        NSString *error = [self checkError:result];
                        if (error != nil) {
                            handler(NO, error);
                        } else {
                            ViewThreadPage *thread = [forumParser parseShowThreadWithHtml:result];
                            if (thread.postList.count > 0) {
                                handler(YES, thread);
                            } else {
                                handler(NO, @"未知错误");
                            }
                        }
                    } else {
                        handler(NO, result);
                    }
                }];
    }

    /*

     else {
        // 如果有图片，先传图片
        [self uploadImagePrepair:fId startPostTime:time postHash:hash :^(BOOL isSuccess, NSString *result) {

            if (isSuccess) {
                // 解析出上传图片需要的参数
                NSString *uploadToken = [forumParser parseSecurityToken:result];
                NSString *uploadTime = [[token componentsSeparatedByString:@"-"] firstObject];
                NSString *uploadHash = [forumParser parsePostHash:result];

                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(createThreadUploadImages:)
                                                             name:@"CREATE_THREAD_UPLOAD_IMAGE" object:nil];

                [[NSNotificationCenter defaultCenter] postNotificationName:@"CREATE_THREAD_UPLOAD_IMAGE" object:self
                                                                  userInfo:@{@"uploadToken": uploadToken, @"fId": @(fId),
                                                                          @"uploadTime": uploadTime, @"uploadHash": uploadHash, @"imageId": @(0)}];
            } else {
                handler(NO, result);
            }


        }];
    }

     */
}


// 获取发新帖子的post_hash、forum_hash、posttime、seccodehash、seccodeverify, typeid list

- (void)enterCreateThreadPageFetchInfo:(int)forumId :(EnterNewThreadCallBack)callback {

    NSString *url = [forumConfig enterCreateNewThreadWithForumId:[NSString stringWithFormat:@"%d", forumId]];

    [self GET:url requestCallback:^(BOOL isSuccess, NSString *html) {

        if (isSuccess) {

            NSString * post_hash = [html stringWithRegular:@"(?<=<input name=\"post_hash\" type=\"hidden\" value=\")\\w+(?=\" />)"];
            NSString * forum_hash = [html stringWithRegular:@"(?<=name=\"formhash\" id=\"formhash\" value=\")\\w+(?=\" />)"];
            NSString * posttime = [html stringWithRegular:@"(?<=name=\"posttime\" id=\"posttime\" value=\")\\d+(?=\" />)"];
            NSString * seccodehash = [html stringWithRegular:@"(?<=<span id=\"seccode_)\\w+(?=\">)"];

            IGHTMLDocument * document = [[IGHTMLDocument alloc] initWithHTMLString:html error:nil];
            IGXMLNode *typeidNode = [document queryNodeWithXPath:@"//*[@id=\"typeid\"]"];
            NSMutableDictionary *typeidDic = [NSMutableDictionary dictionary];

            for (int i = 0; i < typeidNode.childrenCount; i++) {
                IGXMLNode *child = [typeidNode childAt:i];
                if (![[child attribute:@"value"] isEqualToString:@"0"]){
                    [typeidDic setValue:[child attribute:@"value"] forKey:[[child text] trim]];
                }
            }

            NSString *secUrlTemple = @"http://bbs.smartisan.com/misc.php?mod=seccode&action=update&idhash=%@&%@&modid=forum::post";
            NSString *randomStr = [NSString stringWithFormat:@"0.%@", [CommonUtils randomNumber:17]];
            NSString *secUrl = [NSString stringWithFormat:secUrlTemple, seccodehash, randomStr];

            [self GET:secUrl parameters:nil requestCallback:^(BOOL success, NSString *resultHtml) {
                if (success){
                    NSString *update = [resultHtml stringWithRegular:@"(?<=update=)\\d+"];
                    NSString * seccodeverify = [NSString stringWithFormat:@"http://bbs.smartisan.com/misc.php?mod=seccode&update=%@&idhash=%@", update, seccodehash];
                    callback(post_hash, forum_hash, posttime, seccodehash, seccodeverify, typeidDic);
                } else {
                    callback(nil, nil, nil, nil, nil, nil);
                }
            }];

        } else {
            callback(nil, nil, nil, nil, nil, nil);
        }
    }];
}

// private 进入图片管理页面，准备上传图片
- (void)uploadImagePrepair:(int)forumId startPostTime:(NSString *)time postHash:(NSString *)hash :(HandlerWithBool)callback {

    NSString *url = [forumConfig newattachmentForForum:forumId time:time postHash:hash];

    [self GET:url requestCallback:^(BOOL isSuccess, NSString *html) {
        callback(isSuccess, html);
    }];
}

// private
- (NSString *)checkError:(NSString *)html {
    NSString *duplicate = @"<p><strong>此帖是您在最后 5 分钟发表的帖子的副本，您将返回该主题。</strong></p>";
    //NSString *tooShot = @"<ol><li>您输入的信息太短，您发布的信息至少为 5 个字符。</li></ol>";
    NSString *tooFast = @"<ol><li>本论坛允许的发表两个帖子的时间间隔必须大于 30 秒。请等待";

    NSString *searchFailed = @"<ol><li>对不起，没有匹配记录。请尝试采用其他条件查询。";
    NSString *searchTooFast = @"<ol><li>本论坛允许的进行两次搜索的时间间隔必须大于 30 秒";

    NSString *urlLost = @"<div style=\"margin: 10px\">没有指定 主题 。如果您来自一个有效链接，请通知<a href=\"sendmessage.php\">管理员</a></div>";
    NSString *permission = @"<li>您的账号可能没有足够的权限访问此页面或执行需要授权的操作。</li>";

    if ([html containsString:duplicate]) {
        return @"内容重复";
    } else if ([html containsString:tooFast]) {
        return @"30秒发帖限制";
    } else if ([html containsString:tooFast]) {
        return @"少于5个字";
    } else if ([html containsString:searchFailed]) {
        return @"未查到结果";
    } else if ([html containsString:searchTooFast]) {
        return @"30秒搜索限制";
    } else if ([html containsString:urlLost]) {
        return @"无效链接";
    } else if ([html containsString:permission]) {
        return @"无权查看";
    } else {
        return nil;
    }
}

- (void)replyWithMessage:(NSString *)message withImages:(NSArray *)images toPostId:(NSString *)postId thread:(ViewThreadPage *)threadPage isQoute:(BOOL)quote handler:(HandlerWithBool)handler {

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

- (void)listPrivateMessage:(int)page handler:(HandlerWithBool)handler {
    NSString *url = [forumConfig privateMessage:page];
    [self GET:url requestCallback:^(BOOL isSuccess, NSString *html) {
        if (isSuccess) {
            ViewForumPage *viewForumPage = [forumParser parsePrivateMessageFromHtml:html];
            handler(YES, viewForumPage);
        } else {
            handler(NO, [forumParser parseErrorMessage:html]);
        }
    }];
}

- (void)listNoticeMessage:(int)page handler:(HandlerWithBool)handler {
    NSString *url = [forumConfig noticeMessage:page];
    [self GET:url requestCallback:^(BOOL isSuccess, NSString *html) {
        if (isSuccess) {
            ViewForumPage *viewForumPage = [forumParser parseNoticeMessageFromHtml:html];
            handler(YES, viewForumPage);
        } else {
            handler(NO, [forumParser parseErrorMessage:html]);
        }
    }];
}

@end
