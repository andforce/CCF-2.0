//
// Created by 迪远 王 on 2017/5/6.
// Copyright (c) 2017 andforce. All rights reserved.
//

#import "UIImageView+AFNetworking.h"
#import "CHHForumApi.h"
#import "AFHTTPSessionManager+SimpleAction.h"
#import "ForumParserDelegate.h"
#import "NSUserDefaults+Setting.h"

#import "IGHTMLDocument+QueryNode.h"
#import "CHHForumConfig.h"
#import "CHHForumHtmlParser.h"
#import "LocalForumApi.h"
#import "NSString+Extensions.h"
#import "IGXMLNode+Children.h"
#import "ViewMessage.h"

typedef void (^CallBack)(NSString *token, NSString *forumHash, NSString *posttime);

@implementation CHHForumApi {

    CHHForumConfig* forumConfig;
    CHHForumHtmlParser* forumParser;

    NSArray *toUploadImages;
    HandlerWithBool _handlerWithBool;
    NSString *_message;
    NSString *_subject;

    NSMutableArray *hasUploadImages;
}

- (instancetype)init {
    self = [super init];
    if (self){
        forumConfig = [[CHHForumConfig alloc] init];
        forumParser = [[CHHForumHtmlParser alloc]init];
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
    NSString *url = forumConfig.archive;
    [self GET:url requestCallback:^(BOOL isSuccess, NSString *html) {
        if (isSuccess) {
            NSArray<Forum *> *parserForums = [forumParser parserForums:html forumHost:forumConfig.forumURL.host];
            if (parserForums != nil && parserForums.count > 0) {
                handler(YES, parserForums);
            } else {
                handler(NO, html);
            }
        } else {
            handler(NO, html);
        }
    }];
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

            NSArray *categories = @[@"【分享】", @"【推荐】", @"【求助】", @"【注意】", @"【ＣＸ】", @"【高兴】", @"【难过】", @"【转帖】", @"【原创】", @"【讨论】"];
            callback(html, post_hash, forum_hash, posttime, seccodehash, nil, typeidDic);

        } else {
            callback(nil, nil, nil, nil, nil, nil, nil);
        }
    }];
}

- (void)unFavouriteForumWithId:(NSString *)forumId handler:(HandlerWithBool)handler {
    NSString *urlUnFav = @"https://www.chiphell.com/home.php?mod=space&do=favorite&view=me";

    [self GET:urlUnFav requestCallback:^(BOOL isSuccess, NSString *html) {
        if (isSuccess) {
            NSString *token = [forumParser parseSecurityToken:html];

            NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
            [parameters setValue:token forKey:@"formhash"];
            [parameters setValue:@"true" forKey:@"delfavorite"];
            [parameters setValue:@"" forKey:@"favorite[]"];

            NSString *url = [forumConfig unFavorThreadWithId:nil];
            [self.browser POSTWithURLString:url parameters:parameters charset:UTF_8 requestCallback:^(BOOL success, NSString *string) {
                handler(success, string);
            }];
        } else {
            handler(NO, nil);
        }
    }];
}



- (void)unFavoriteThreadWithId:(NSString *)threadPostId handler:(HandlerWithBool)handler {

    NSString *unFavUrl = @"https://www.chiphell.com/home.php?mod=space&do=favorite&view=me";
    [self GET:unFavUrl requestCallback:^(BOOL isSuccess, NSString *html) {
        if (isSuccess) {
            NSString *token = [forumParser parseSecurityToken:html];

            NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
            [parameters setValue:token forKey:@"formhash"];
            [parameters setValue:@"true" forKey:@"delfavorite"];
            [parameters setValue:@"" forKey:@"favorite[]"];

            NSString *url = [forumConfig unFavorThreadWithId:threadPostId];
            [self.browser POSTWithURLString:url parameters:parameters charset:UTF_8 requestCallback:^(BOOL success, NSString *string) {
                handler(success, string);
            }];
        } else {
            handler(NO, nil);
        }
    }];
}

- (void)listPrivateMessage:(int)page handler:(HandlerWithBool)handler{
    NSString *url = [forumConfig privateMessage:page];
    [self GET:url requestCallback:^(BOOL isSuccess, NSString *html) {
        if (isSuccess) {
            ViewForumPage *viewForumPage = [forumParser parsePrivateMessageFromHtml:html];
            handler(YES, viewForumPage);
        } else {
            handler(NO, html);
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
            handler(NO, html);
        }
    }];
}

- (void)showThreadWithPTid:(NSString *)ptid pid:(NSString *)pid handler:(HandlerWithBool)handler {
    NSString *url = [NSString stringWithFormat:@"https://www.chiphell.com/forum.php?mod=redirect&goto=findpost&pid=%@&ptid=%@", pid, ptid];

    [self GET:url requestCallback:^(BOOL isSuccess, NSString *html) {
        if (isSuccess) {
            ViewThreadPage *detail = [forumParser parseShowThreadWithHtml:html];
            handler(isSuccess, detail);
        } else {
            handler(NO, html);
        }
    }];
}


- (void)createNewThreadWithCategory:(NSString *)categoryName categoryValue:(NSString *)categoryValue withTitle:(NSString *)title
                         andMessage:(NSString *)message withImages:(NSArray *)images inPage:(ViewForumPage *)page postHash:(NSString *)posthash
                           formHash:(NSString *)formhash secCodeHash:(NSString *)seccodehash seccodeverify:(NSString *)seccodeverify
                           postTime:(NSString *)postTime handler:(HandlerWithBool)handler {

    // TODO 以后再重构
}

- (void)listFavoriteForums:(HandlerWithBool)handler {
    NSMutableArray * result = [NSMutableArray array];

    __block int page = 1;
    [self listFavoriteForums:page handler:^(BOOL isSuccess, id m) {
        if (isSuccess){
            NSMutableArray<Forum *> *favForms = [forumParser parseFavForumFromHtml:m];
            [result addObjectsFromArray:favForms];
            PageNumber * pageNumber = [forumParser parserPageNumber:m];

            if (pageNumber.totalPageNumber > page){
                for (int i = page + 1; i <= pageNumber.totalPageNumber; i++) {
                    [self listFavoriteForums:i handler:^(BOOL success, id html) {
                        if (success){
                            NSMutableArray<Forum *> *forums = [forumParser parseFavForumFromHtml:html];
                            [result addObjectsFromArray:forums];
                            page = i;
                            if (page >= pageNumber.totalPageNumber){

                                handler(YES, result);
                            }
                        } else{
                            handler(NO, html);
                        }
                    }];
                }
            } else{
                handler(YES, result);
            }
        } else{
            handler(NO, m);
        }
    }];
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
            handler(NO, html);
        }
    }];
}

- (void)listNewThreadWithPage:(int)page handler:(HandlerWithBool)handler {

    NSString *url = [forumConfig searchNewThread:page];
    [self GET:url requestCallback:^(BOOL isSuccess, NSString *html) {
        if (isSuccess) {
            ViewSearchForumPage *searchForumPage = [forumParser parseSearchPageFromHtml:html];
            handler(isSuccess, searchForumPage);
        } else {
            handler(NO, html);
        }
    }];
}

- (void)listMyAllThreadsWithPage:(int)page handler:(HandlerWithBool)handler {
    NSString *url = @"https://www.chiphell.com/forum.php?mod=guide&view=my";
    [self GET:url requestCallback:^(BOOL isSuccess, NSString *html) {
        if (isSuccess) {
            ViewForumPage *sarchPage = [forumParser parseSearchPageFromHtml:html];
            handler(isSuccess, sarchPage);
        } else {
            handler(NO, html);
        }
    }];
}

- (void)listAllUserThreads:(int)userId withPage:(int)page handler:(HandlerWithBool)handler {

    NSString *baseUrl = [forumConfig searchThreadWithUserId:[NSString stringWithFormat:@"%d", userId]];

    NSString * url = [baseUrl stringByAppendingFormat:@"%d", page];

    [self GET:url requestCallback:^(BOOL isSuccess, NSString *html) {
        if (isSuccess) {
            ViewForumPage *sarchPage = [forumParser parseSearchPageFromHtml:html];
            handler(isSuccess, sarchPage);
        } else {
            handler(NO, html);
        }
    }];
}

- (void)showThreadWithId:(int)threadId andPage:(int)page handler:(HandlerWithBool)handler {

    NSString *url = [forumConfig showThreadWithThreadId:[NSString stringWithFormat:@"%d", threadId] withPage:page];

    [self GET:url requestCallback:^(BOOL isSuccess, NSString *html) {
        if (isSuccess) {
            ViewThreadPage *detail = [forumParser parseShowThreadWithHtml:html];
            handler(isSuccess, detail);
        } else {
            handler(NO, html);
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
            handler(NO, html);
        }
    }];
}

- (void)getAvatarWithUserId:(NSString *)userId handler:(HandlerWithBool)handler {

    NSString *url = [forumConfig memberWithUserId:userId];

    [self GET:url requestCallback:^(BOOL isSuccess, NSString *html) {
        NSString *avatar = [forumParser parseUserAvatar:html userId:userId];
        if (avatar) {
            avatar = [forumConfig.avatarBase stringByAppendingString:avatar];
        } else {
            avatar = forumConfig.avatarNo;
        }
        handler(isSuccess, avatar);
    }];
}

- (void)showProfileWithUserId:(NSString *)userId handler:(HandlerWithBool)handler {
    NSString *url = [forumConfig memberWithUserId:userId];
    [self GET:url requestCallback:^(BOOL isSuccess, NSString *html) {
        if (isSuccess) {
            UserProfile *profile = [forumParser parserProfile:html userId:userId];
            handler(YES, profile);
        } else {
            handler(NO, @"未知错误");
        }
    }];
}

- (void)reportThreadPost:(int)postId andMessage:(NSString *)message handler:(HandlerWithBool)handler {
    handler(YES,@"");
}

- (BOOL)openUrlByClient:(ForumWebViewController *)controller request:(NSURLRequest *)request {
    return NO;
}

- (void)enterSeniorReplyPageFetchInfo:(int)forumId tid:(int)tid pid:(int)pid handler:(EnterNewThreadCallBack)callback {
    NSString *url = [NSString stringWithFormat:@"https://www.chiphell.com/forum.php?mod=post&action=reply&fid=%d&extra=&tid=%d&repquote=%d", forumId, tid, pid];
    if (pid == -1){
        url = [NSString stringWithFormat:@"https://www.chiphell.com/forum.php?mod=post&action=reply&fid=%d&tid=%d", forumId, tid];
    }

    [self GET:url requestCallback:^(BOOL isSuccess, NSString *html) {

        if (isSuccess) {

            NSString * post_hash = [html stringWithRegular:@"(?<=<input name=\"post_hash\" type=\"hidden\" value=\")\\w+(?=\" />)"];
            NSString * forum_hash = [html stringWithRegular:@"(?<=name=\"formhash\" id=\"formhash\" value=\")\\w+(?=\" />)"];
            NSString * posttime = [html stringWithRegular:@"(?<=name=\"posttime\" id=\"posttime\" value=\")\\d+(?=\" />)"];
            NSString * seccodehash = [html stringWithRegular:@"(?<=<span id=\"seccode_)\\w+(?=\">)"];

            IGHTMLDocument * document = [[IGHTMLDocument alloc] initWithHTMLString:html error:nil];
            IGXMLNode *typeidNode = [document queryNodeWithXPath:@"//*[@id=\"typeid\"]"];

            NSMutableDictionary *typeidDic = [NSMutableDictionary dictionary];

            for (int i = 0; i < typeidNode.childrenCount; ++i) {
                IGXMLNode *child = [typeidNode childAt:i];
                if (![[child attribute:@"value"] isEqualToString:@"0"]){
                    [typeidDic setValue:[child attribute:@"value"] forKey:[[child text] trim]];
                }
            }

            callback(html, post_hash, forum_hash, posttime, seccodehash, nil, typeidDic);

        } else {
            callback(nil, nil, nil, nil, nil, nil, nil);
        }
    }];
}

- (void)replyWithMessage:(NSString *)message withImages:(NSArray *)images toPostId:(NSString *)postId thread:(ViewThreadPage *)threadPage isQoute:(BOOL)quote
        handler:(HandlerWithBool)handler {

    NSString *msg = message;

    if ([NSUserDefaults standardUserDefaults].isSignatureEnabled) {
        msg = [message stringByAppendingString:[forumConfig signature]];
    }

    int replyPostId = [postId intValue];
    NSString *forumHash = threadPage.securityToken;
    int threadId = threadPage.threadID;
    int forumId = threadPage.forumId;

    if (images == nil || images.count == 0){
        [self doReply:handler msg:msg replyPostId:replyPostId token:forumHash threadId:threadId forumId:forumId];
    } else {
        [self enterSeniorReplyPageFetchInfo:forumId tid:threadId pid:replyPostId handler:^(NSString *responseHtml, NSString *post_hash,
                NSString *forum_hash, NSString *posttime, NSString *seccodehash, NSString *seccodeverify, NSDictionary *typeidList) {

            if (hasUploadImages == nil){
                hasUploadImages = [NSMutableArray array];
            } else{
                [hasUploadImages removeAllObjects];
            }

            // 解析出上传图片需要的参数
            NSString *uid = [responseHtml stringWithRegular:@"(?<=<input type=\"hidden\" name=\"uid\" value=\")\\d+(?=\">)"];
            NSString *uploadHash = [responseHtml stringWithRegular:@"(?<=<input type=\"hidden\" name=\"hash\" value=\")\\w+(?=\">)"];

            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(replyThreadUploadImages:) name:@"REPLYTHREADUPLOADIMAGES" object:nil];

            toUploadImages = images;
            _handlerWithBool = handler;
            _message = message;
            //_subject = subject;

            [[NSNotificationCenter defaultCenter] postNotificationName:@"REPLYTHREADUPLOADIMAGES" object:self
                                                              userInfo:@{@"uploadTime": posttime,
                                                                      @"fId": @(forumId),
                                                                      @"forumHash":forumHash,
                                                                      @"replyPostId" :@(replyPostId),
                                                                      @"threadId" :@(threadId),
                                                                      @"uid": uid,
                                                                      @"uploadHash": uploadHash,
                                                                      @"imageId": @(0)}];
        }];
    }
}

- (void)replyThreadUploadImages:(NSNotification *)notification {

    NSDictionary *dictionary = [notification userInfo];

    // Discuz postThread
    int forumId = [dictionary[@"fId"] intValue];
    NSString *posttime = [dictionary valueForKey:@"uploadTime"];
    NSString *forumHash = [dictionary valueForKey:@"forumHash"];

    int replyPostId = [dictionary[@"replyPostId"] intValue];
    int threadId = [dictionary[@"threadId"] intValue];

    // Discuz upload
    NSString *uid = [dictionary valueForKey:@"uid"];
    NSString *uploadHash = [dictionary valueForKey:@"uploadHash"];

    int imageId = [dictionary[@"imageId"] intValue];

    if (imageId < toUploadImages.count) {

        NSData *image = toUploadImages[(NSUInteger) imageId];

        NSURL *url = [NSURL URLWithString:forumConfig.newattachment];
        [self uploadImage:url uid:uid hash:uploadHash uploadImage:image callback:^(BOOL success, id html) {

            NSString *uploaded = [html stringWithRegular:@"\\d\\d\\d+"];
            [hasUploadImages addObject:uploaded];

            [NSThread sleepForTimeInterval:2.0f];

            [[NSNotificationCenter defaultCenter] postNotificationName:@"REPLYTHREADUPLOADIMAGES" object:self
                                                              userInfo:@{@"uploadTime": posttime,
                                                                      @"fId": @(forumId),
                                                                      @"forumHash":forumHash,
                                                                      @"replyPostId" :@(replyPostId),
                                                                      @"threadId" :@(threadId),
                                                                      @"uid": uid,
                                                                      @"uploadHash": uploadHash,
                                                                      @"imageId": @(imageId + 1)}];
        }];
    } else {

        [[NSNotificationCenter defaultCenter] removeObserver:self];

        [self doReply:_handlerWithBool msg:_message replyPostId:replyPostId token:forumHash threadId:threadId forumId:forumId];
    }
}

- (void)doReply:(HandlerWithBool)handler msg:(NSString *)message replyPostId:(int)replyPostId token:(NSString *)formhash threadId:(int)threadId forumId:(int)forumId {
    if (replyPostId != -1){     // 表示回复的某一个楼层

        NSString *preReplyUrl = [NSString stringWithFormat:@"https://www.chiphell.com/forum.php?mod=post&action=reply&fid=%d&extra=page%%3D1&tid=%d&repquote=%d", forumId, threadId, replyPostId];

        [self GET:preReplyUrl requestCallback:^(BOOL isSuccess, NSString *html) {
            if (isSuccess) {
                NSString *formHash = nil;
                NSString *posttime = nil;
                NSString *wysiwyg = nil;
                NSString *noticeauthor = nil;
                NSString *noticetrimstr = nil;
                NSString *noticeauthormsg = nil;
                NSString *reppid = nil;
                NSString *reppost = nil;

                IGHTMLDocument * document = [[IGHTMLDocument alloc] initWithXMLString:html error:nil];

                IGXMLNode *paramNode = [document queryNodeWithXPath:@"//*[@id='ct']"];
                for (IGXMLNode *node  in paramNode.children) {
                    NSString * nodeName = [node attribute:@"name"];

                    if ([nodeName isEqualToString:@"formhash"]) {
                        formHash = [node attribute:@"value"];
                    } else if ([nodeName isEqualToString:@"posttime"]) {
                        posttime = [node attribute:@"value"];
                    } else if ([nodeName isEqualToString:@"wysiwyg"]) {
                        wysiwyg = [node attribute:@"value"];
                    } else if([nodeName isEqualToString:@"noticeauthor"]){
                        noticeauthor = [node attribute:@"value"];
                    } else if ([nodeName isEqualToString:@"noticetrimstr"]){
                        noticetrimstr = [node attribute:@"value"];
                    } else if ([nodeName isEqualToString:@"noticeauthormsg"]){
                        noticeauthormsg = [node attribute:@"value"];
                    }else if ([nodeName isEqualToString:@"reppid"]){
                        reppid = [node attribute:@"value"];
                    }else if ([nodeName isEqualToString:@"reppost"]){
                        reppost = [node attribute:@"value"];
                    }

                    else {
                        continue;
                    }
                }

                // 开始回复
                NSString *url = [forumConfig replyWithThreadId:threadId forForumId:forumId replyPostId:replyPostId];

                NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
                [parameters setValue:formhash forKey:@"formhash"];

                [parameters setValue:posttime forKey:@"posttime"];
                [parameters setValue:@"1" forKey:@"wysiwyg"];
                [parameters setValue:noticeauthor forKey:@"noticeauthor"];
                [parameters setValue:noticetrimstr forKey:@"noticetrimstr"];
                [parameters setValue:noticeauthormsg forKey:@"noticeauthormsg"];

                [parameters setValue:reppid forKey:@"reppid"];
                [parameters setValue:reppost forKey:@"reppost"];
                [parameters setValue:@"" forKey:@"subject"];
                [parameters setValue:@"" forKey:@"save"];

                if (hasUploadImages != nil && hasUploadImages.count > 0){
                    NSMutableString * newMessage = [NSMutableString string];
                    [newMessage appendString:message];
                    for (NSString *image in hasUploadImages){
                        NSString *format = [NSString stringWithFormat:@"\r\n[attachimg]%@[/attachimg]", image];
                        [newMessage appendString:format];

                        [parameters setValue:@"" forKey:[NSString stringWithFormat:@"attachnew[%@][description]", image]];
                    }

                    [parameters setValue:newMessage forKey:@"message"];
                } else {
                    [parameters setValue:message forKey:@"message"];
                }

                [self.browser POSTWithURLString:url parameters:parameters charset:UTF_8 requestCallback:^(BOOL repsuccess, NSString *repHtml) {
                    ViewThreadPage *thread = [forumParser parseShowThreadWithHtml:repHtml];
                    if (thread.postList.count > 0) {
                        handler(YES, thread);
                    } else {
                        handler(NO, @"未知错误");
                    }
                }];

            } else {
                handler(NO, html);
            }
        }];

    } else {
        NSString *url = [forumConfig replyWithThreadId:threadId forForumId:forumId replyPostId:replyPostId];

        NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
        [parameters setValue:formhash forKey:@"formhash"];
        long time = (long) [[NSDate date] timeIntervalSince1970];
        [parameters setValue:[NSString stringWithFormat:@"%li", time] forKey:@"posttime"];
        [parameters setValue:@"" forKey:@"wysiwyg"];

        [parameters setValue:@"" forKey:@"noticeauthor"];
        [parameters setValue:@"" forKey:@"noticetrimstr"];

        [parameters setValue:@"" forKey:@"noticeauthormsg"];
        [parameters setValue:@"" forKey:@"subject"];
        [parameters setValue:@"0" forKey:@"save"];

        if (hasUploadImages != nil && hasUploadImages.count > 0){
            NSMutableString * newMessage = [NSMutableString string];
            [newMessage appendString:message];
            for (NSString *image in hasUploadImages){
                NSString *format = [NSString stringWithFormat:@"\r\n[attachimg]%@[/attachimg]", image];
                [newMessage appendString:format];

                [parameters setValue:@"" forKey:[NSString stringWithFormat:@"attachnew[%@][description]", image]];
            }

            [parameters setValue:newMessage forKey:@"message"];
        } else {
            [parameters setValue:message forKey:@"message"];
        }


        [self.browser POSTWithURLString:url parameters:parameters charset:UTF_8 requestCallback:^(BOOL isSuccess, NSString *html) {
            ViewThreadPage *thread = [forumParser parseShowThreadWithHtml:html];

            if (hasUploadImages != nil){
                [hasUploadImages removeAllObjects];
            }

            if (thread.postList.count > 0) {
                handler(YES, thread);
            } else {
                handler(NO, @"未知错误");
            }
        }];
    }
}

// private
- (NSString *)checkError:(NSString *)html {
    NSString *duplicate = @"<p><strong>此帖是您在最后 5 分钟发表的帖子的副本，您将返回该主题。</strong></p>";
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

// private f发表新的主题
- (void)doCreateNewThread:(int)fId withSubject:(NSString *)subject andMessage:(NSString *)message images:(NSArray *)images
                 withHash:(NSString *)forumHash postTime:(NSString *)postTime handler:(HandlerWithBool)handler {

    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];

    [parameters setValue:forumHash forKey:@"formhash"];
    [parameters setValue:postTime forKey:@"posttime"];
    [parameters setValue:@"1" forKey:@"wysiwyg"];
    [parameters setValue:subject forKey:@"subject"];
    [parameters setValue:@"1" forKey:@"allownoticeauthor"];
    [parameters setValue:@"" forKey:@"save"];

    if (images != nil && images.count > 0){
        NSMutableString * newMessage = [NSMutableString string];
        [newMessage appendString:message];
        for (NSString *image in images){
            NSString *format = [NSString stringWithFormat:@"\r\n[attachimg]%@[/attachimg]", image];
            [newMessage appendString:format];

            [parameters setValue:@"" forKey:[NSString stringWithFormat:@"attachnew[%@][description]", image]];
        }

        [parameters setValue:newMessage forKey:@"message"];
    } else {
        [parameters setValue:message forKey:@"message"];
    }

    NSString *forumId = [NSString stringWithFormat:@"%d", fId];
    NSString *url = [forumConfig createNewThreadWithForumId:forumId];

    [self.browser POSTWithURLString: url
                         parameters:parameters charset:UTF_8 requestCallback:^(BOOL isSuccess, NSString *html) {

                if (isSuccess) {
                    LocalForumApi *localForumApi = [[LocalForumApi alloc] init];
                    [localForumApi saveCookie];
                }
                handler(isSuccess, html);
            }];
}

- (void)createNewThreadWithCategory:(NSString *)category categoryIndex:(int)index withTitle:(NSString *)title
                         andMessage:(NSString *)message withImages:(NSArray *)images inPage:(ViewForumPage *)page
                            handler:(HandlerWithBool)handler {

    NSString * subject = [category stringByAppendingString:title];
    if ([category isEqualToString:@"[无分类]"]){
        subject = title;
    }

    if ([NSUserDefaults standardUserDefaults].isSignatureEnabled) {
        message = [message stringByAppendingString:[forumConfig signature]];

    }

    int fId = page.forumId;

    // 进入发帖页面，获取相关参数

    [self enterCreateThreadPageFetchInfo:fId :^(NSString *responseHtml, NSString *post_hash, NSString *forumHash, NSString *posttime,
            NSString *seccodehash, NSString *seccodeverify, NSDictionary *typeidList) {

        if (images == nil || images.count == 0) {
            // 没有图片，直接发送主题
            [self doCreateNewThread:fId withSubject:subject andMessage:message images:nil withHash:forumHash postTime:posttime handler:^(BOOL isSuccess, NSString *result) {
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
        } else {

            if (hasUploadImages == nil){
                hasUploadImages = [NSMutableArray array];
            } else{
                [hasUploadImages removeAllObjects];
            }

            // 解析出上传图片需要的参数
            NSString *uid = [responseHtml stringWithRegular:@"(?<=<input type=\"hidden\" name=\"uid\" value=\")\\d+(?=\">)"];
            NSString *uploadHash = [responseHtml stringWithRegular:@"(?<=<input type=\"hidden\" name=\"hash\" value=\")\\w+(?=\">)"];

            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(createThreadUploadImages:) name:@"CREATE_THREAD_UPLOAD_IMAGE" object:nil];

            toUploadImages = images;
            _handlerWithBool = handler;
            _message = message;
            _subject = subject;

            [[NSNotificationCenter defaultCenter] postNotificationName:@"CREATE_THREAD_UPLOAD_IMAGE" object:self
                                                              userInfo:@{@"uploadTime": posttime, @"fId": @(fId), @"forumHash":forumHash, @"uid": uid, @"uploadHash": uploadHash, @"imageId": @(0)}];
        }
    }];
}

- (void)createThreadUploadImages:(NSNotification *)notification {

    NSDictionary *dictionary = [notification userInfo];

    // Discuz postThread
    int fId = [dictionary[@"fId"] intValue];
    NSString *posttime = [dictionary valueForKey:@"uploadTime"];
    NSString *forumHash = [dictionary valueForKey:@"forumHash"];

    // Discuz upload
    NSString *uid = [dictionary valueForKey:@"uid"];
    NSString *uploadHash = [dictionary valueForKey:@"uploadHash"];

    int imageId = [dictionary[@"imageId"] intValue];

    if (imageId < toUploadImages.count) {

        NSData *image = toUploadImages[(NSUInteger) imageId];

        NSURL *url = [NSURL URLWithString:forumConfig.newattachment];
        [self uploadImage:url uid:uid hash:uploadHash uploadImage:image callback:^(BOOL success, id html) {

            NSString *uploaded = [html stringWithRegular:@"\\d\\d\\d+"];
            [hasUploadImages addObject:uploaded];

            [NSThread sleepForTimeInterval:2.0f];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"CREATE_THREAD_UPLOAD_IMAGE" object:self
                                                              userInfo:@{@"uploadTime": posttime, @"fId": @(fId), @"forumHash":forumHash,@"uid": uid, @"uploadHash": uploadHash, @"imageId": @(imageId + 1)}];
        }];
    } else {

        [[NSNotificationCenter defaultCenter] removeObserver:self];

        [self doCreateNewThread:fId withSubject:_subject andMessage:_message images:hasUploadImages withHash:forumHash postTime:posttime handler:^(BOOL postSuccess, id doPostResult) {

            if (postSuccess) {

                NSString *error = [self checkError:doPostResult];
                if (error != nil) {
                    _handlerWithBool(NO, error);
                } else {
                    ViewThreadPage *thread = [forumParser parseShowThreadWithHtml:doPostResult];
                    if (thread.postList.count > 0) {
                        _handlerWithBool(YES, thread);
                    } else {
                        _handlerWithBool(NO, @"未知错误");
                    }
                }
            } else {
                _handlerWithBool(NO, doPostResult);
            }
        }];
    }
}

// private
- (void)uploadImage:(NSURL *)url uid:(NSString *)uid hash:(NSString *)hash uploadImage:(NSData *)imageData callback:(HandlerWithBool)callback {


    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];

    NSString *boundary = [NSString stringWithFormat:@"----WebKitFormBoundary%@", [self uploadParamDivider]];

    [request setHTTPShouldHandleCookies:YES];
    [request setTimeoutInterval:60];
    [request setHTTPMethod:@"POST"];

    LocalForumApi *localForumApi = [[LocalForumApi alloc] init];

    // set Content-Type in HTTP header
    NSString *cookie = [localForumApi loadCookieString];
    [request setValue:cookie forHTTPHeaderField:@"cookie"];

    [request setValue:@"max-age=0" forHTTPHeaderField:@"cache-control"];
    //[request setValue:@"https://www.chiphell.com" forHTTPHeaderField:@"origin"];
    [request setValue:@"1" forHTTPHeaderField:@"upgrade-insecure-requests"];
    //[request setValue:@"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_13_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/66.0.3359.181 Safari/537.36" forHTTPHeaderField:@"user-agent"];
    [request setValue:@"text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8" forHTTPHeaderField:@"accept"];
    [request setValue:@"1" forHTTPHeaderField:@"dnt"];
    [request setValue:@"gzip, deflate, br" forHTTPHeaderField:@"accept-encoding"];
    [request setValue:@"zh-CN,zh;q=0.9,en;q=0.8" forHTTPHeaderField:@"accept-language"];
    //[request setValue:@"https://www.chiphell.com/forum.php?mod=post&action=newthread&fid=201" forHTTPHeaderField:@"referer"];


    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    [request setValue:contentType forHTTPHeaderField:@"content-Type"];

    // post body
    NSMutableData *body = [NSMutableData data];

    // add params (all params are strings)
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [parameters setValue:uid forKey:@"uid"];
    [parameters setValue:hash forKey:@"hash"];

    for (NSString *param in parameters) {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", param] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"%@\r\n", parameters[param]] dataUsingEncoding:NSUTF8StringEncoding]];
    }

    int inter = (int) [NSDate date].timeIntervalSince1970;
    NSString *name = [NSString stringWithFormat:@"Forum_Client_%d.jpg", inter];
    [parameters setValue:name forKey:@"Filedata[]"];
    // add image data
    if (imageData) {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", @"Filedata[]", name]dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"Content-Type: image/jpeg\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:imageData];
        [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    }

    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];

    // setting the body of the post to the request
    [request setHTTPBody:body];

    // set the content-length
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long) [body length]];
    [request setValue:postLength forHTTPHeaderField:@"content-length"];

    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue currentQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {

        if (data.length > 0) {
            //success
            NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            callback(YES, responseString);
        } else {
            callback(NO, @"failed");
        }
    }];
}

// private
- (NSString *)uploadParamDivider {
    static const NSString *kRandomAlphabet = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";

    NSMutableString *randomString = [NSMutableString stringWithCapacity:16];
    for (int i = 0; i < 16; i++) {
        [randomString appendFormat:@"%C", [kRandomAlphabet characterAtIndex:arc4random_uniform((u_int32_t) [kRandomAlphabet length])]];
    }
    return randomString;
}

- (void)searchWithKeyWord:(NSString *)keyWord forType:(int)type handler:(HandlerWithBool)handler {

    NSString* encodedString = [keyWord stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *searchUrl = nil;
    if (type == 0) {
        searchUrl = [NSString stringWithFormat:@"http://zhannei.baidu.com/cse/search?q=%@&s=13836577039777088209&area=1", encodedString];
    } else if (type == 1) {
        searchUrl = [NSString stringWithFormat:@"http://zhannei.baidu.com/cse/search?q=%@&s=13836577039777088209&area=2", encodedString];
    } else if (type == 2) {
        // TODO
    }

    [self GET:searchUrl requestCallback:^(BOOL isSuccess, NSString *html) {
        if (isSuccess) {
            ViewSearchForumPage *page = [forumParser parseZhanNeiSearchPageFromHtml:html type:type];
            handler(YES, page);
        } else {
            handler(NO, html);
        }
    }];
}

- (void)showPrivateMessageContentWithId:(int)pmId withType:(int)type handler:(HandlerWithBool)handler {
    NSString * url = [forumConfig privateShowWithMessageId:pmId withType:type];
    [self GET:url requestCallback:^(BOOL isSuccess, NSString *html) {
        if (isSuccess) {
            ViewMessagePage *content = [forumParser parsePrivateMessageContent:html avatarBase:forumConfig.avatarBase noavatar:forumConfig.avatarNo];
            ViewMessage * viewMessage = content.viewMessages.firstObject;

            if (![viewMessage.pmUserInfo.userID isEqualToString:@"-1"]){
                [self getAvatarWithUserId:viewMessage.pmUserInfo.userID handler:^(BOOL success, id message) {
                    viewMessage.pmUserInfo.userAvatar = message;
                    handler(YES, content);
                }];
            } else{
                viewMessage.pmUserInfo.userAvatar = forumConfig.avatarNo;
                handler(YES, content);
            }
        } else {
            handler(NO, [forumParser parseErrorMessage:html]);
        }
    }];
}


- (void)sendPrivateMessageTo:(User *)user andTitle:(NSString *)title andMessage:(NSString *)message handler:(HandlerWithBool)handler {
    NSString *url = [NSString stringWithFormat:@"https://www.chiphell.com/home.php?mod=spacecp&ac=pm&op=send&touid=%@&inajax=1", user.userID];

    [self GET:url requestCallback:^(BOOL isSuccess, NSString *html) {

        NSString *forumHash = [html stringWithRegular:@"(?<=<input type=\"hidden\" name=\"formhash\" value=\")\\w+(?=\" />)"];
        if (isSuccess){
            NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
            [parameters setValue:@"true" forKey:@"pmsubmit"];
            [parameters setValue:user.userID forKey:@"touid"];
            [parameters setValue:forumHash forKey:@"formhash"];
            [parameters setValue:@"showMsgBox" forKey:@"handlekey"];
            [parameters setValue:message forKey:@"message"];
            [parameters setValue:@"" forKey:@"messageappend"];

            [self.browser POSTWithURLString:url parameters:parameters charset:UTF_8 requestCallback:^(BOOL isSuccess, NSString *sendHtml) {
                handler(isSuccess, @"");
            }];
        } else {
           handler(NO, @"ERROR");
        }

    }];

}

- (void)replyPrivateMessage:(Message *)privateMessage andReplyContent:(NSString *)content handler:(HandlerWithBool)handler {
    NSString *url = [NSString stringWithFormat:@"https://www.chiphell.com/home.php?mod=spacecp&ac=pm&op=send&pmid=%@&daterange=0&handlekey=pmsend&pmsubmit=yes&inajax=1", privateMessage.pmID];

    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setValue:privateMessage.forumhash forKey:@"formhash"];
    [parameters setValue:content forKey:@"message"];
    [parameters setValue:privateMessage.pmAuthorId forKey:@"topmuid"];

    [self.browser POSTWithURLString:url parameters:parameters charset:UTF_8 requestCallback:^(BOOL isSuccess, NSString *html) {
        handler(isSuccess, @"");
    }];
}

- (void)favoriteForumWithId:(NSString *)forumId handler:(HandlerWithBool)handler {

    NSString * fetchForumHashUrl = [forumConfig forumDisplayWithId:forumId];
    [self GET:fetchForumHashUrl requestCallback:^(BOOL isSuccess, NSString *html) {
        if (isSuccess){
            NSString * forumHash = [forumParser parseSecurityToken:html];
            // fav forum with forumID & forumHash
            NSString *url = [forumConfig favForumWithId:forumId];
            NSMutableDictionary * dictionary = [NSMutableDictionary dictionary];
            [dictionary setValue:forumHash forKey:@"formhash"];
            [self GET:url parameters:dictionary requestCallback:^(BOOL isSuccess, NSString *favHtml) {
                BOOL isFavSuccess = [favHtml containsString:@"<p>信息收藏成功 <script"] || [favHtml containsString:@"<p>抱歉，您已收藏，请勿重复收藏</p>"];
                if (isFavSuccess){
                    handler(YES, @"");
                } else {
                    handler(NO, @"收藏失败");
                }
            }];
        } else {
            handler(NO, @"收藏失败");
        }
    }];

}

- (void)favoriteThreadWithId:(NSString *)threadPostId handler:(HandlerWithBool)handler {

    NSString * fetchForumHashUrl = [forumConfig showThreadWithThreadId:threadPostId withPage:1];
    [self GET:fetchForumHashUrl requestCallback:^(BOOL isSuccess, NSString *html) {
        if (isSuccess){
            NSString * forumHash = [forumParser parseSecurityToken:html];
            // fav forum with forumID & forumHash
            NSString *url = [forumConfig favThreadWithId:threadPostId];
            NSMutableDictionary * dictionary = [NSMutableDictionary dictionary];
            [dictionary setValue:forumHash forKey:@"formhash"];
            [self GET:url parameters:dictionary requestCallback:^(BOOL isSuccess, NSString *favHtml) {
                BOOL isFavSuccess = [favHtml containsString:@"<p>信息收藏成功 <script"] || [favHtml containsString:@"<p>抱歉，您已收藏，请勿重复收藏</p>"];
                if (isFavSuccess){
                    handler(YES, @"");
                } else {
                    handler(NO, @"收藏失败");
                }
            }];
        } else {
            handler(NO, @"收藏失败");
        }
    }];
}

- (void)deletePrivateMessage:(Message *)privateMessage withType:(int)type handler:(HandlerWithBool)handler {

    [self GET:[forumConfig privateMessage:1] requestCallback:^(BOOL isSuccess, NSString *html) {

        if (isSuccess){
            NSString *forumHash = [html stringWithRegular:@"(?<=<input type=\"hidden\" name=\"formhash\" value=\")\\w+(?=\" />)"];

            NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
            [parameters setValue:forumHash forKey:@"formhash"];
            [parameters setValue:@"true" forKey:@"deletesubmit"];
            [parameters setValue:@"true" forKey:@"deletepmsubmit_btn"];
            [parameters setValue:@"1" forKey:@"custompage"];
            [parameters setValue:privateMessage.pmAuthorId forKey:@"deletepm_deluid[]"];

            [self.browser POSTWithURLString:@"https://www.chiphell.com/home.php?mod=spacecp&ac=pm&op=delete&folder="
                                 parameters:parameters charset:UTF_8 requestCallback:^(BOOL isSuccess, NSString *html) {

                        if (isSuccess){
                            handler(isSuccess, html);
                        } else {
                            handler(NO, @"");
                        }
                    }];
        } else {
            handler(NO, @"");
        }

    }];

}

- (void)listSearchResultWithSearchId:(NSString *)searchId keyWord:(NSString *)keyWord andPage:(int)page type:(int)type handler:(HandlerWithBool)handler {
    NSString* encodedString = [keyWord stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *searchUrl = nil;
    if (type == 0) {
        searchUrl = [NSString stringWithFormat:@"http://zhannei.baidu.com/cse/search?q=%@&p=%d&s=13836577039777088209&area=1", encodedString, page];
    } else if (type == 1) {
        searchUrl = [NSString stringWithFormat:@"http://zhannei.baidu.com/cse/search?q=%@&p=%d&s=13836577039777088209&area=2", encodedString, page];
    } else if (type == 2) {
        // TODO
    }

    [self GET:searchUrl requestCallback:^(BOOL isSuccess, NSString *html) {
        if (isSuccess) {
            ViewSearchForumPage *viewSearchForumPage = [forumParser parseZhanNeiSearchPageFromHtml:html type:type];
            handler(YES, viewSearchForumPage);
        } else {
            handler(NO, html);
        }
    }];
}


@end
