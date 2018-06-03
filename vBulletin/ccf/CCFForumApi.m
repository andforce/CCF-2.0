//
// Created by WDY on 2016/12/8.
// Copyright (c) 2016 andforce. All rights reserved.
//

#import <IGHTMLQuery/IGHTMLDocument.h>
#import "CCFForumApi.h"

#import "NSString+Extensions.h"
#import "NSUserDefaults+Setting.h"
#import "AFHTTPSessionManager+SimpleAction.h"
#import "UIImageView+AFNetworking.h"
#import "ForumParserDelegate.h"
#import "CCFForumConfig.h"
#import "CCFForumHtmlParser.h"
#import "LocalForumApi.h"
#import "ForumWebViewController.h"
#import "UIStoryboard+Forum.h"
#import "IGHTMLDocument+QueryNode.h"
#import "IGXMLNode+Children.h"

#define kSecurityToken @"securitytoken"

typedef void (^CallBack)(NSString *token, NSString *hash, NSString *time);

@implementation CCFForumApi {
    NSString *listMyThreadSearchId;

    NSMutableDictionary *listUserThreadRedirectUrlDictionary;

    // senior post
    NSArray *toUploadImages;
    HandlerWithBool _handlerWithBool;
    NSString *_message;
    NSString *_subject;

    CCFForumConfig * forumConfig;
    CCFForumHtmlParser * forumParser;
}

- (instancetype)init {
    self = [super init];
    if (self){
        forumConfig =  [[CCFForumConfig alloc] init];
        forumParser = [[CCFForumHtmlParser alloc]init];
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

- (void)loginWithName:(NSString *)name andPassWord:(NSString *)passWord withCode:(NSString *)code question:(NSString *)q answer:(NSString *)a handler:(HandlerWithBool)handler {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setValue:name forKey:@"vb_login_username"];
    [parameters setValue:@"" forKey:@"vb_login_password"];
    [parameters setValue:@"1" forKey:@"cookieuser"];
    [parameters setValue:@"" forKey:@"vcode"];
    [parameters setValue:@"" forKey:@"s"];
    [parameters setValue:@"guest" forKey:@"securitytoken"];
    [parameters setValue:@"login" forKey:@"do"];

    NSString *md5pwd = [passWord md5HexDigest];
    [parameters setValue:md5pwd forKey:@"vb_login_md5password"];
    [parameters setValue:md5pwd forKey:@"vb_login_md5password_utf"];

    [self.browser POSTWithURLString:forumConfig.login parameters:parameters charset:UTF_8 requestCallback:^(BOOL isSuccess, NSString *html) {
        if (isSuccess) {

            NSString *userName = [html stringWithRegular:@"(?<=<p><strong>感谢您登录，).*(?=。</strong></p>)"];

            if (userName) {
                LocalForumApi *localForumApi = [[LocalForumApi alloc] init];
                // 保存Cookie
                [localForumApi saveCookie];
                // 保存用户名
                [localForumApi saveUserName:userName forHost:forumConfig.forumURL.host];
                handler(YES, @"登录成功");
            } else {
                handler(NO, [forumParser parseLoginErrorMessage:html]);
            }

        } else {
            handler(NO, [forumParser parseLoginErrorMessage:html]);
        }
    }];
}

- (void)refreshVCodeToUIImageView:(UIImageView *)vCodeImageView {
    NSString *url = forumConfig.loginvCode;

    AFImageDownloader *downloader = [[vCodeImageView class] sharedImageDownloader];
    id <AFImageRequestCache> imageCache = downloader.imageCache;
    [imageCache removeImageWithIdentifier:url];

    NSURL *URL = [NSURL URLWithString:url];

    NSURLRequest *request = [NSURLRequest requestWithURL:URL];

    UIImageView *view = vCodeImageView;

    [vCodeImageView setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *_Nonnull urlRequest, NSHTTPURLResponse *_Nullable response, UIImage *_Nonnull image) {
        [view setImage:image];
    }                              failure:^(NSURLRequest *_Nonnull urlRequest, NSHTTPURLResponse *_Nullable response, NSError *_Nonnull error) {
        NSLog(@"refreshDoor failed");
    }];
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

- (void)enterCreateThreadPageFetchInfo:(int)forumId :(EnterNewThreadCallBack)callback {
    NSString *url = [forumConfig enterCreateNewThreadWithForumId:[NSString stringWithFormat:@"%d", forumId]];

    [self GET:url requestCallback:^(BOOL isSuccess, NSString *html) {

        if (isSuccess) {

            NSString * post_hash = [html stringWithRegular:@"(?<=<input name=\"post_hash\" type=\"hidden\" value=\")\\w+(?=\" />)"];
            NSString * forum_hash = [html stringWithRegular:@"(?<=name=\"formhash\" id=\"formhash\" value=\")\\w+(?=\" />)"];
            NSString * posttime = [html stringWithRegular:@"(?<=name=\"posttime\" id=\"posttime\" value=\")\\d+(?=\" />)"];
            NSString * seccodehash = [html stringWithRegular:@"(?<=<span id=\"seccode_)\\w+(?=\">)"];

            IGHTMLDocument * document = [[IGHTMLDocument alloc] initWithHTMLString:html error:nil];
            IGXMLNodeSet *typeidNodeSet = [document queryWithClassName:@"bginput"];

            NSMutableDictionary *typeidDic = [NSMutableDictionary dictionary];

            for (IGXMLNode * node in typeidNodeSet) {
                if ([node.tag isEqualToString:@"select"]){

                    for (int i = 1; i < node.childrenCount; i++) {
                        IGXMLNode *child = [node childAt:i];
                        [typeidDic setValue:[child attribute:@"value"] forKey:[[child text] trim]];
                    }
                    break;
                }
            }

            callback(html, post_hash, forum_hash, posttime, seccodehash, nil, typeidDic);

        } else {
            callback(nil, nil, nil, nil, nil, nil, nil);
        }
    }];
}

- (void)createNewThreadWithCategory:(NSString *)category categoryIndex:(int)index withTitle:(NSString *)title
                         andMessage:(NSString *)message withImages:(NSArray *)images inPage:(ViewForumPage *)page handler:(HandlerWithBool)handler {
    NSString * subject = [category stringByAppendingString:title];
    [self createNewThreadWithForumId:page.forumId withSubject:subject andMessage:message withImages:images handler:handler];
}

// private 正式开始发送
- (void)doPostThread:(int)fId withSubject:(NSString *)subject andMessage:(NSString *)message withToken:(NSString *)token withHash:(NSString *)hash postTime:(NSString *)time handler:(HandlerWithBool)handler {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setValue:subject forKey:@"subject"];
    [parameters setValue:message forKey:@"message"];
    [parameters setValue:@"0" forKey:@"wysiwyg"];
    [parameters setValue:@"0" forKey:@"iconid"];
    [parameters setValue:@"" forKey:@"s"];
    [parameters setValue:token forKey:@"securitytoken"];
    NSString *forumId = [NSString stringWithFormat:@"%d", fId];
    [parameters setValue:forumId forKey:@"f"];
    [parameters setValue:@"postthread" forKey:@"do"];
    [parameters setValue:hash forKey:@"posthash"];


    [parameters setValue:time forKey:@"poststarttime"];

    LocalForumApi *forumApi = [[LocalForumApi alloc] init];
    LoginUser *user = [forumApi getLoginUser:forumConfig.forumURL.host];
    [parameters setValue:user.userID forKey:@"loggedinuser"];
    [parameters setValue:@"发表主题" forKey:@"sbutton"];
    [parameters setValue:@"1" forKey:@"parseurl"];
    [parameters setValue:@"9999" forKey:@"emailupdate"];
    [parameters setValue:@"4" forKey:@"polloptions"];


    [self.browser POSTWithURLString:[forumConfig createNewThreadWithForumId:[NSString stringWithFormat:@"%d", fId]] parameters:parameters charset:UTF_8 requestCallback:^(BOOL isSuccess, NSString *html) {
        if (isSuccess) {
            LocalForumApi *localForumApi = [[LocalForumApi alloc] init];
            [localForumApi saveCookie];
        }
        handler(isSuccess, html);

    }];
}

// private 进入图片管理页面，准备上传图片
- (void)uploadImagePrepare:(int)forumId startPostTime:(NSString *)time postHash:(NSString *)hash :(HandlerWithBool)callback {

    NSString *url = [forumConfig newattachmentForForum:forumId time:time postHash:hash];

    [self GET:url requestCallback:^(BOOL isSuccess, NSString *html) {
        callback(isSuccess, html);
    }];
}

// private
- (void)uploadImagePrepareFormSeniorReply:(int)threadId startPostTime:(NSString *)time postHash:(NSString *)hash :(HandlerWithBool)callback {
    NSString *url = [forumConfig newattachmentForThread:threadId time:time postHash:hash];

    [self GET:url requestCallback:^(BOOL isSuccess, NSString *html) {
        callback(isSuccess, html);
    }];
}

// private
- (void)uploadImage:(NSURL *)url :(NSString *)token fId:(int)fId postTime:(NSString *)postTime hash:(NSString *)hash uploadImage:(NSData *)imageData callback:(HandlerWithBool)callback {


    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];

    [request setHTTPShouldHandleCookies:YES];
    [request setTimeoutInterval:60];
    [request setHTTPMethod:@"POST"];

    LocalForumApi *localForumApi = [[LocalForumApi alloc] init];

    NSString *cookie = [localForumApi loadCookieString];
    [request setValue:cookie forHTTPHeaderField:@"Cookie"];

    NSString *boundary = [NSString stringWithFormat:@"----WebKitFormBoundary%@", [self uploadParamDivider]];

    // set Content-Type in HTTP header
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    [request setValue:contentType forHTTPHeaderField:@"Content-Type"];

    [request setValue:token forHTTPHeaderField:@"securitytoken"];

    // post body
    NSMutableData *body = [NSMutableData data];

    // add params (all params are strings)
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [parameters setValue:@"" forKey:@"s"];
    [parameters setValue:token forKey:@"securitytoken"];
    [parameters setValue:@"manageattach" forKey:@"do"];
    [parameters setValue:@"" forKey:@"t"];
    NSString *forumId = [NSString stringWithFormat:@"%d", fId];
    [parameters setValue:forumId forKey:@"f"];
    [parameters setValue:@"" forKey:@"p"];
    [parameters setValue:postTime forKey:@"poststarttime"];
    [parameters setValue:@"0" forKey:@"editpost"];
    [parameters setValue:hash forKey:@"posthash"];
    [parameters setValue:@"16777216" forKey:@"MAX_FILE_SIZE"];
    [parameters setValue:@"上传" forKey:@"upload"];


    NSString *name = [NSString stringWithFormat:@"Forum_Client_%f.jpg", [[NSDate date] timeIntervalSince1970]];

    [parameters setValue:name forKey:@"attachment[]"];

    [parameters setValue:name forKey:@"attachmenturl[]"];


    for (NSString *param in parameters) {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", param] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"%@\r\n", parameters[param]] dataUsingEncoding:NSUTF8StringEncoding]];
    }



    // add image data
    if (imageData) {

        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", @"attachment[]", name] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"Content-Type: image/jpeg\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:imageData];
        [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    }

    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];

    // setting the body of the post to the reqeust
    [request setHTTPBody:body];

    // set the content-length
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long) [body length]];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];


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

//private  获取发新帖子的Posttime hash 和token
- (void)enterCreateThreadPage:(int)forumId :(CallBack)callback {

    NSString *url = [forumConfig enterCreateNewThreadWithForumId:[NSString stringWithFormat:@"%d", forumId]];
    [self GET:url requestCallback:^(BOOL isSuccess, NSString *html) {
        if (isSuccess) {
            NSString *token = [forumParser parseSecurityToken:html];
            NSString *postTime = [[token componentsSeparatedByString:@"-"] firstObject];
            NSString *hash = [forumParser parsePostHash:html];

            callback(token, hash, postTime);
        } else {
            callback(nil, nil, nil);
        }
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

- (void)createNewThreadWithForumId:(int)fId withSubject:(NSString *)subject andMessage:(NSString *)message withImages:(NSArray *)images handler:(HandlerWithBool)handler {
    if ([NSUserDefaults standardUserDefaults].isSignatureEnabled) {
        message = [message stringByAppendingString:[forumConfig signature]];

    }

    // 准备发帖
    [self enterCreateThreadPage:fId :^(NSString *token, NSString *hash, NSString *time) {

        if (images == nil || images.count == 0) {
            // 没有图片，直接发送主题
            [self doPostThread:fId withSubject:subject andMessage:message withToken:token withHash:hash postTime:time handler:^(BOOL isSuccess, NSString *result) {
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
            // 如果有图片，先传图片
            [self uploadImagePrepare:fId startPostTime:time postHash:hash :^(BOOL isSuccess, NSString *result) {

                if (isSuccess) {
                    // 解析出上传图片需要的参数
                    NSString *uploadToken = [forumParser parseSecurityToken:result];
                    NSString *uploadTime = [[token componentsSeparatedByString:@"-"] firstObject];
                    NSString *uploadHash = [forumParser parsePostHash:result];

                    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(createThreadUploadImages:) name:@"CREATE_THREAD_UPLOAD_IMAGE" object:nil];

                    toUploadImages = images;
                    _handlerWithBool = handler;
                    _message = message;
                    _subject = subject;

                    [[NSNotificationCenter defaultCenter] postNotificationName:@"CREATE_THREAD_UPLOAD_IMAGE" object:self userInfo:@{@"uploadToken": uploadToken, @"fId": @(fId), @"uploadTime": uploadTime, @"uploadHash": uploadHash, @"imageId": @(0)}];
                } else {
                    handler(NO, result);
                }


            }];
        }

    }];
}

- (void)createThreadUploadImages:(NSNotification *)notification {

    NSDictionary *dictionary = [notification userInfo];
    NSString *uploadToken = [dictionary valueForKey:@"uploadToken"];
    int fId = [dictionary[@"fId"] intValue];
    NSString *uploadTime = [dictionary valueForKey:@"uploadTime"];
    NSString *uploadHash = [dictionary valueForKey:@"uploadHash"];

    int imageId = [dictionary[@"imageId"] intValue];

    if (imageId < toUploadImages.count) {
        NSData *image = toUploadImages[(NSUInteger) imageId];
        [self uploadImage:[NSURL URLWithString:forumConfig.newattachment] :uploadToken fId:fId postTime:uploadTime hash:uploadHash uploadImage:image callback:^(BOOL success, id html) {
            [NSThread sleepForTimeInterval:2.0f];

            [[NSNotificationCenter defaultCenter] postNotificationName:@"CREATE_THREAD_UPLOAD_IMAGE" object:self userInfo:@{@"uploadToken": uploadToken, @"fId": @(fId), @"uploadTime": uploadTime, @"uploadHash": uploadHash, @"imageId": @(imageId + 1)}];

        }];
    } else {
        [self doPostThread:fId withSubject:_subject andMessage:_message withToken:uploadToken withHash:uploadHash postTime:uploadTime handler:^(BOOL postSuccess, id doPostResult) {

            [[NSNotificationCenter defaultCenter] removeObserver:self];
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
- (NSString *)readSecurityToken {
    return [[NSUserDefaults standardUserDefaults] valueForKey:kSecurityToken];
}


- (void)reply:(NSString *)message withImages:(NSArray *)images toPostId:(NSString *)postId thread:(ViewThreadPage *)threadPage handler:(HandlerWithBool)handler {

    int threadId = threadPage.threadID;
    NSString *token = threadPage.securityToken;
    NSString *url = [forumConfig replyWithThreadId:threadId forForumId:-1 replyPostId:-1];
    int forumId = threadPage.forumId;

    NSMutableDictionary *preParameters = [NSMutableDictionary dictionary];
    [preParameters setValue:@"" forKey:@"message"];
    [preParameters setValue:@"0" forKey:@"wysiwyg"];
    [preParameters setValue:@"2" forKey:@"styleid"];
    [preParameters setValue:@"1" forKey:@"signature"];
    [preParameters setValue:@"1" forKey:@"fromquickreply"];
    [preParameters setValue:@"" forKey:@"s"];
    [preParameters setValue:token forKey:@"securitytoken"];
    [preParameters setValue:@"postreply" forKey:@"do"];
    [preParameters setValue:[NSString stringWithFormat:@"%d", threadId] forKey:@"t"];
    [preParameters setValue:@"who cares" forKey:@"p"];
    [preParameters setValue:@"0" forKey:@"specifiedpost"];
    [preParameters setValue:@"1" forKey:@"parseurl"];

    LocalForumApi *forumApi = [[LocalForumApi alloc] init];
    LoginUser *user = [forumApi getLoginUser:forumConfig.forumURL.host];
    [preParameters setValue:user.userID forKey:@"loggedinuser"];
    [preParameters setValue:@"进入高级模式" forKey:@"preview"];

    [self.browser POSTWithURLString:url parameters:preParameters charset:UTF_8 requestCallback:^(BOOL isSuccess, NSString *html) {
        if (isSuccess) {

            NSString *securityToken = [forumParser parseSecurityToken:html];
            NSString *postHash = [forumParser parsePostHash:html];
            NSString *postStartTime = [forumParser parserPostStartTime:html];

            if (images == nil || [images count] == 0) {
                [self seniorReplyWithThreadId:threadId andMessage:message securitytoken:securityToken posthash:postHash poststarttime:postStartTime handler:^(BOOL success, id result) {
                    if (success) {

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
                        handler(NO, html);
                    }
                }];

            } else {

                __block NSString *uploadImageToken = @"";
                // 如果有图片，先传图片
                [self uploadImagePrepareFormSeniorReply:threadId startPostTime:postStartTime postHash:postHash :^(BOOL success, id result) {

                    if (success) {
                        // 解析出上传图片需要的参数
                        uploadImageToken = [forumParser parseSecurityToken:result];
                        NSString *uploadTime = [[securityToken componentsSeparatedByString:@"-"] firstObject];
                        NSString *uploadHash = [forumParser parsePostHash:result];

                        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(seniorReplyUploadImage:) name:@"SENIOR_REPLY_UPLOAD_IMAGE" object:nil];

                        toUploadImages = images;
                        _handlerWithBool = handler;
                        _message = message;

                        [[NSNotificationCenter defaultCenter] postNotificationName:@"SENIOR_REPLY_UPLOAD_IMAGE" object:self userInfo:@{@"uploadImageToken": uploadImageToken, @"forumId": @(forumId),
                                @"threadId": @(threadId), @"uploadTime": uploadTime, @"uploadHash": uploadHash, @"imageId": @(0)}];
                    } else {
                        handler(NO, result);
                    }


                }];
            }
        } else {
            handler(NO, @"回复失败");
        }
    }];
}

- (void)replyWithMessage:(NSString *)message withImages:(NSArray *)images toPostId:(NSString *)postId thread:(ViewThreadPage *)threadPage isQoute:(BOOL)quote handler:(HandlerWithBool)handler {

    NSString *replyUrl = nil;
    if (quote){
        replyUrl = [forumConfig quoteReply:threadPage.forumId threadId:threadPage.threadID postId:[postId intValue]];
    } else {
        replyUrl = [forumConfig replyWithThreadId:threadPage.threadID forForumId:threadPage.forumId replyPostId:[postId intValue]];
    }
    [self GET:replyUrl requestCallback:^(BOOL isSuccess, NSString *html) {
        if (isSuccess) {

            NSString * quoteString = [forumParser parseQuote:html];

            NSString * replyContent = [NSString stringWithFormat:@"%@ %@", quoteString, message];
            [self reply:replyContent withImages:images toPostId:postId thread:threadPage handler:handler];

        } else {
            handler(NO, html);
        }
    }];

}


// private
- (void)seniorReplyWithThreadId:(int)threadId andMessage:(NSString *)message securitytoken:(NSString *)token posthash:(NSString *)posthash poststarttime:(NSString *)poststarttime handler:(HandlerWithBool)handler {

    NSString *url = [forumConfig replyWithThreadId:threadId forForumId:-1 replyPostId:-1];

    if ([NSUserDefaults standardUserDefaults].isSignatureEnabled) {
        message = [message stringByAppendingString:[forumConfig signature]];
    }


    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setValue:message forKey:@"message"];
    [parameters setValue:@"0" forKey:@"wysiwyg"];
    [parameters setValue:@"0" forKey:@"iconid"];
    [parameters setValue:@"" forKey:@"s"];
    [parameters setValue:token forKey:@"securitytoken"];
    [parameters setValue:@"postreply" forKey:@"do"];
    [parameters setValue:[NSString stringWithFormat:@"%d", threadId] forKey:@"t"];
    [parameters setValue:@"" forKey:@"p"];
    [parameters setValue:@"0" forKey:@"specifiedpost"];
    [parameters setValue:posthash forKey:@"posthash"];
    [parameters setValue:poststarttime forKey:@"poststarttime"];

    LocalForumApi *forumApi = [[LocalForumApi alloc] init];
    LoginUser *user = [forumApi getLoginUser:forumConfig.forumURL.host];
    [parameters setValue:user.userID forKey:@"loggedinuser"];
    [parameters setValue:@"" forKey:@"multiquoteempty"];
    [parameters setValue:@"提交回复" forKey:@"sbutton"];
    [parameters setValue:@"1" forKey:@"signature"];

    [parameters setValue:@"1" forKey:@"parseurl"];
    [parameters setValue:@"9999" forKey:@"emailupdate"];

    [self.browser POSTWithURLString:url parameters:parameters charset:UTF_8 requestCallback:^(BOOL isSuccess, NSString *html) {
        handler(isSuccess, html);
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

// private
- (void)uploadImageForSeniorReply:(NSURL *)url :(NSString *)token fId:(int)fId threadId:(int)threadId postTime:(NSString *)postTime hash:(NSString *)hash :(NSData *)imageData callback:(HandlerWithBool)callback {


    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];

    [request setHTTPShouldHandleCookies:YES];
    [request setTimeoutInterval:60];
    [request setHTTPMethod:@"POST"];

    LocalForumApi *localForumApi = [[LocalForumApi alloc] init];
    NSString *cookie = [localForumApi loadCookieString];
    [request setValue:cookie forHTTPHeaderField:@"Cookie"];

    NSString *boundary = [NSString stringWithFormat:@"----WebKitFormBoundary%@", [self uploadParamDivider]];

    // set Content-Type in HTTP header
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    [request setValue:contentType forHTTPHeaderField:@"Content-Type"];

    [request setValue:token forHTTPHeaderField:@"securitytoken"];



    // post body
    NSMutableData *body = [NSMutableData data];



    // add params (all params are strings)
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [parameters setValue:@"" forKey:@"s"];
    [parameters setValue:token forKey:@"securitytoken"];
    [parameters setValue:@"manageattach" forKey:@"do"];
    [parameters setValue:[NSString stringWithFormat:@"%d", threadId] forKey:@"t"];
    NSString *forumId = [NSString stringWithFormat:@"%d", fId];
    [parameters setValue:forumId forKey:@"f"];
    [parameters setValue:@"" forKey:@"p"];
    [parameters setValue:postTime forKey:@"poststarttime"];

    [parameters setValue:@"0" forKey:@"editpost"];
    [parameters setValue:hash forKey:@"posthash"];

    [parameters setValue:@"16777216" forKey:@"MAX_FILE_SIZE"];
    [parameters setValue:@"上传" forKey:@"upload"];

    NSString *name = [NSString stringWithFormat:@"Forum_Client_%f.jpg", [[NSDate date] timeIntervalSince1970]];

    [parameters setValue:name forKey:@"attachment[]"];

    [parameters setValue:@"" forKey:@"attachmenturl[]"];


    for (NSString *param in parameters) {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", param] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"%@\r\n", parameters[param]] dataUsingEncoding:NSUTF8StringEncoding]];
    }

    // add image data
    if (imageData) {

        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", @"attachment[]", name] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"Content-Type: image/jpeg\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:imageData];
        [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    }

    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];

    // setting the body of the post to the reqeust
    [request setHTTPBody:body];

    // set the content-length
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long) [body length]];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];

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
- (void)seniorReplyUploadImage:(NSNotification *)notification {
    NSDictionary *dictionary = [notification userInfo];
    NSString *uploadImageToken = [dictionary valueForKey:@"uploadImageToken"];
    int forumId = [dictionary[@"forumId"] intValue];
    int threadId = [dictionary[@"threadId"] intValue];
    NSString *uploadTime = [dictionary valueForKey:@"uploadTime"];
    NSString *uploadHash = [dictionary valueForKey:@"uploadHash"];

    int imageId = [dictionary[@"imageId"] intValue];

    if (imageId < toUploadImages.count) {
        NSData *image = toUploadImages[(NSUInteger) imageId];
        [NSThread sleepForTimeInterval:2.0f];

        [self uploadImageForSeniorReply:[NSURL URLWithString:forumConfig.newattachment] :uploadImageToken fId:forumId threadId:threadId postTime:uploadTime hash:uploadHash :image callback:^(BOOL isSuccess, id uploadResultHtml) {

            // 更新token
            NSString *newUploadImageToken = [forumParser parseSecurityToken:uploadResultHtml];

            NSLog(@" 上传第 %d 张图片", imageId);

            [[NSNotificationCenter defaultCenter] postNotificationName:@"SENIOR_REPLY_UPLOAD_IMAGE" object:self userInfo:@{@"uploadImageToken": newUploadImageToken, @"forumId": @(forumId),
                    @"threadId": @(threadId), @"uploadTime": uploadTime, @"uploadHash": uploadHash, @"imageId": @(imageId + 1)}];

        }];

    } else {

        [[NSNotificationCenter defaultCenter] removeObserver:self];

        [self seniorReplyWithThreadId:threadId andMessage:_message securitytoken:uploadImageToken posthash:uploadHash poststarttime:uploadTime handler:^(BOOL isSuccess, id result) {

            if (isSuccess) {

                NSString *error = [self checkError:result];
                if (error != nil) {
                    _handlerWithBool(NO, error);
                } else {
                    ViewThreadPage *thread = [forumParser parseShowThreadWithHtml:result];
                    if (thread.postList.count > 0) {
                        _handlerWithBool(YES, thread);
                    } else {
                        _handlerWithBool(NO, @"未知错误");
                    }
                }
            } else {
                _handlerWithBool(NO, result);
            }

        }];
    }
}

// private
- (void)saveSecurityToken:(NSString *)token {
    [[NSUserDefaults standardUserDefaults] setValue:token forKey:kSecurityToken];
}

- (void)searchWithKeyWord:(NSString *)keyWord forType:(int)type handler:(HandlerWithBool)handler {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];


    [parameters setValue:@"" forKey:@"s"];
    [parameters setValue:@"process" forKey:@"do"];
    [parameters setValue:@"" forKey:@"searchthreadid"];

    if (type == 0) {
        [parameters setValue:keyWord forKey:@"query"];
        [parameters setValue:@"1" forKey:@"titleonly"];
        [parameters setValue:@"" forKey:@"searchuser"];
        [parameters setValue:@"0" forKey:@"starteronly"];
    } else if (type == 1) {
        [parameters setValue:keyWord forKey:@"query"];
        [parameters setValue:@"0" forKey:@"titleonly"];
        [parameters setValue:@"" forKey:@"searchuser"];
        [parameters setValue:@"0" forKey:@"starteronly"];
    } else if (type == 2) {
        [parameters setValue:@"1" forKey:@"starteronly"];
        [parameters setValue:@"" forKey:@"query"];
        [parameters setValue:@"1" forKey:@"titleonly"];
        [parameters setValue:keyWord forKey:@"searchuser"];
    }

    [parameters setValue:@"1" forKey:@"exactname"];
    [parameters setValue:@"0" forKey:@"replyless"];
    [parameters setValue:@"0" forKey:@"replylimit"];
    [parameters setValue:@"0" forKey:@"searchdate"];
    [parameters setValue:@"after" forKey:@"beforeafter"];
    [parameters setValue:@"lastpost" forKey:@"sortby"];
    [parameters setValue:@"descending" forKey:@"order"];
    [parameters setValue:@"0" forKey:@"showposts"];
    [parameters setValue:@"" forKey:@"tag"];
    [parameters setValue:@"0" forKey:@"forumchoice[]"];
    [parameters setValue:@"1" forKey:@"childforums"];
    [parameters setValue:@"1" forKey:@"saveprefs"];

    NSString *searchUrl = forumConfig.search;
    [self GET:searchUrl requestCallback:^(BOOL isSuccess, NSString *html) {
        if (isSuccess) {
            NSString *token = [forumParser parseSecurityToken:html];
            if (token != nil) {
                [self saveSecurityToken:token];
            }

            NSString *securitytoken = [self readSecurityToken];
            [parameters setValue:securitytoken forKey:@"securitytoken"];

            [self.browser POSTWithURLString:forumConfig.search parameters:parameters charset:UTF_8 requestCallback:^(BOOL searchSuccess, NSString *searchResult) {

                if (searchSuccess) {
                    NSString *error = [self checkError:searchResult];
                    if (error != nil) {
                        handler(NO, error);
                    } else {
                        ViewSearchForumPage *page = [forumParser parseSearchPageFromHtml:searchResult];
                        LocalForumApi *localForumApi = [[LocalForumApi alloc] init];
                        [localForumApi saveCookie];

                        if (page != nil && page.dataList != nil && page.dataList.count > 0) {
                            handler(YES, page);
                        } else {
                            handler(NO, @"未知错误");
                        }
                    }
                } else {
                    handler(NO, searchResult);
                }

            }];
        } else {
            handler(NO, html);
        }
    }];
}

- (void)showPrivateMessageContentWithId:(int)pmId withType:(int)type handler:(HandlerWithBool)handler {

    NSString *url = [forumConfig privateShowWithMessageId:pmId withType:0];
    [self GET:url requestCallback:^(BOOL isSuccess, NSString *html) {
        if (isSuccess) {
            ViewMessagePage *content = [forumParser parsePrivateMessageContent:html avatarBase:forumConfig.avatarBase noavatar:forumConfig.avatarNo];
            handler(YES, content);
        } else {
            handler(NO, html);
        }
    }];
}

- (void)sendPrivateMessageToUserName:(NSString *)name andTitle:(NSString *)title andMessage:(NSString *)message handler:(HandlerWithBool)handler {

    NSString *url = forumConfig.privateNewPre;
    [self GET:url requestCallback:^(BOOL isSuccess, NSString *html) {
        if (isSuccess) {
            NSString *token = [forumParser parseSecurityToken:html];

            NSMutableDictionary *pars = [NSMutableDictionary dictionary];
            [pars setValue:message forKey:@"message"];
            [pars setValue:title forKey:@"title"];
            [pars setValue:@"0" forKey:@"pmid"];
            [pars setValue:name forKey:@"recipients"];
            [pars setValue:@"0" forKey:@"wysiwyg"];
            [pars setValue:@"" forKey:@"s"];
            [pars setValue:token forKey:@"securitytoken"];
            [pars setValue:@"0" forKey:@"forward"];
            [pars setValue:@"1" forKey:@"savecopy"];
            [pars setValue:@"提交信息" forKey:@"sbutton"];
            [pars setValue:@"1" forKey:@"parseurl"];
            [pars setValue:@"insertpm" forKey:@"do"];
            [pars setValue:@"" forKey:@"bccrecipients"];
            [pars setValue:@"0" forKey:@"iconid"];

            [self.browser POSTWithURLString:forumConfig.privateReplyWithMessage parameters:pars charset:UTF_8 requestCallback:^(BOOL success, NSString *result) {
                if (success) {
                    if ([result containsString:@"信息提交时发生如下错误:"]) {
                        handler(NO, @"收件人未找到或者未填写标题");
                    } else {
                        handler(YES, @"");
                    }
                } else {
                    handler(NO, result);
                }
            }];
        } else {
            handler(NO, nil);
        }
    }];
}

- (void)replyPrivateMessage:(Message *)privateMessage andReplyContent:(NSString *)content handler:(HandlerWithBool)handler {

    int pmId = [privateMessage.pmID intValue];
    NSString *url = [forumConfig privateShowWithMessageId:pmId withType:0];
    [self GET:url requestCallback:^(BOOL isSuccess, NSString *html) {
        if (isSuccess) {
            NSString *token = [forumParser parseSecurityToken:html];

            NSString *quote = [forumParser parseQuickReplyQuoteContent:html];

            NSString *title = [forumParser parseQuickReplyTitle:html];
            NSString *name = [forumParser parseQuickReplyTo:html];

            NSMutableDictionary *parameters = [NSMutableDictionary dictionary];

            NSString *realMessage = [[quote stringByAppendingString:@"\n"] stringByAppendingString:content];

            [parameters setValue:realMessage forKey:@"message"];
            [parameters setValue:@"0" forKey:@"wysiwyg"];
            [parameters setValue:@"6" forKey:@"styleid"];
            [parameters setValue:@"1" forKey:@"fromquickreply"];
            [parameters setValue:@"" forKey:@"s"];
            [parameters setValue:token forKey:@"securitytoken"];
            [parameters setValue:@"insertpm" forKey:@"do"];
            [parameters setValue:[NSString stringWithFormat:@"%d", pmId] forKey:@"pmid"];
            //[parameters setValue:@"0" forKey:@"loggedinuser"]; 经过测试，这个参数不写也行
            [parameters setValue:@"1" forKey:@"parseurl"];
            [parameters setValue:@"1" forKey:@"signature"];
            [parameters setValue:title forKey:@"title"];
            [parameters setValue:name forKey:@"recipients"];

            [parameters setValue:@"0" forKey:@"forward"];
            [parameters setValue:@"1" forKey:@"savecopy"];
            [parameters setValue:@"提交信息" forKey:@"sbutton"];

            [self.browser POSTWithURLString:[forumConfig privateReplyWithMessageIdPre:pmId] parameters:parameters charset:UTF_8 requestCallback:^(BOOL success, NSString *result) {
                handler(success, result);
            }];

        } else {
            handler(NO, nil);
        }
    }];
}

- (void)favoriteForumWithId:(NSString *)forumId handler:(HandlerWithBool)handler {
    NSString *preUrl = [forumConfig favForumWithId:forumId];
    [self GET:preUrl requestCallback:^(BOOL isSuccess, NSString *html) {
        if (!isSuccess) {
            handler(NO, html);
        } else {
            NSString *token = [forumParser parseSecurityToken:html];

            NSString *url = [forumConfig favForumWithIdParam:forumId];
            NSMutableDictionary *parameters = [NSMutableDictionary dictionary];

            NSString *paramUrl = [forumConfig forumDisplayWithId:forumId];

            [parameters setValue:@"" forKey:@"s"];
            [parameters setValue:token forKey:@"securitytoken"];
            [parameters setValue:@"doaddsubscription" forKey:@"do"];
            [parameters setValue:forumId forKey:@"forumid"];
            [parameters setValue:paramUrl forKey:@"url"];
            [parameters setValue:@"0" forKey:@"emailupdate"];


            [self.browser POSTWithURLString:url parameters:parameters charset:UTF_8 requestCallback:^(BOOL success, NSString *result) {
                handler(success, result);
            }];

        }
    }];
}

- (void)unFavouriteForumWithId:(NSString *)forumId handler:(HandlerWithBool)handler {
    NSString *url = [forumConfig unfavForumWithId:forumId];

    [self GET:url requestCallback:^(BOOL isSuccess, NSString *html) {
        handler(isSuccess, html);
    }];
}

- (void)favoriteThreadWithId:(NSString *)threadPostId handler:(HandlerWithBool)handler {
    NSString *preUrl = [forumConfig favThreadWithIdPre:threadPostId];

    [self GET:preUrl requestCallback:^(BOOL isSuccess, NSString *html) {
        if (!isSuccess) {
            handler(NO, html);
        } else {
            NSString *token = [forumParser parseSecurityToken:html];

            NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
            [parameters setValue:@"" forKey:@"s"];
            [parameters setValue:token forKey:@"securitytoken"];
            [parameters setValue:@"doaddsubscription" forKey:@"do"];
            [parameters setValue:threadPostId forKey:@"threadid"];
            NSString *urlPram = [forumConfig showThreadWithThreadId:threadPostId withPage:-1];

            [parameters setValue:urlPram forKey:@"url"];
            [parameters setValue:@"0" forKey:@"emailupdate"];
            [parameters setValue:@"0" forKey:@"folderid"];

            NSString *fav = [forumConfig favThreadWithId:threadPostId];
            [self.browser POSTWithURLString:fav parameters:parameters charset:UTF_8 requestCallback:^(BOOL success, NSString *result) {
                handler(success, result);
            }];
        }
    }];
}

- (void)unFavoriteThreadWithId:(NSString *)threadPostId handler:(HandlerWithBool)handler {
    NSString *url = [forumConfig unFavorThreadWithId:threadPostId];

    [self GET:url requestCallback:^(BOOL isSuccess, NSString *html) {
        handler(isSuccess, html);
    }];
}

- (void)listPrivateMessageWithType:(int)type andPage:(int)page handler:(HandlerWithBool)handler {

    NSString * url = [forumConfig privateWithType:type withPage:page];
    [self GET:url requestCallback:^(BOOL isSuccess, NSString *html) {
        if (isSuccess) {
            ViewForumPage *viewForumPage = [forumParser parsePrivateMessageFromHtml:html forType:type];
            handler(YES, viewForumPage);
        } else {
            handler(NO, html);
        }
    }];
}

- (void)deletePrivateMessage:(Message *)privateMessage withType:(int)type handler:(HandlerWithBool)handler {
    NSString * url = [forumConfig deletePrivateWithType:type];
    [self GET:url requestCallback:^(BOOL isSuccess, NSString *html) {
        if (isSuccess) {
            NSString *token = [forumParser parseSecurityToken:html];
            NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
            [parameters setValue:@"" forKey:@"s"];
            [parameters setValue:token forKey:@"securitytoken"];
            [parameters setValue:@"managepm" forKey:@"do"];
            [parameters setValue:[NSString stringWithFormat:@"%d", type] forKey:@"folderid"];
            [parameters setValue:@"0" forKey:[NSString stringWithFormat:@"pm[%@]", privateMessage.pmID]];
            [parameters setValue:@"delete" forKey:@"dowhat"];

            [self.browser POSTWithURLString:url parameters:parameters charset:UTF_8 requestCallback:^(BOOL success, NSString *result) {
                handler(success, result);
            }];

        } else {
            handler(NO, nil);
        }
    }];
}

- (void)listFavoriteForums:(HandlerWithBool)handler {

    NSString *url = forumConfig.favoriteForums;
    [self GET:url requestCallback:^(BOOL isSuccess, NSString *html) {
        if (isSuccess) {
            NSMutableArray<Forum *> *favForms = [forumParser parseFavForumFromHtml:html];
            handler(YES, favForms);
        } else {
            handler(NO, html);
        }
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
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];

    NSDate *date = [NSDate date];
    NSInteger timeStamp = (NSInteger) [date timeIntervalSince1970];

    NSInteger searchId = [userDefault integerForKey:[forumConfig.forumURL.host stringByAppendingString:@"-search_id"]];
    NSInteger lastTimeStamp = [userDefault integerForKey:[forumConfig.forumURL.host stringByAppendingString:@"-search_time"]];

    long spaceTime = timeStamp - lastTimeStamp;

    if (page == 1 && (searchId == 0 || spaceTime > 60 * 10)) {

        [self GET:[forumConfig searchNewThread:page] requestCallback:^(BOOL isSuccess, NSString *html) {
            if (isSuccess) {
                NSUInteger newThreadPostSearchId = (NSUInteger) [[forumParser parseListMyThreadSearchId:html] integerValue];
                [userDefault setInteger:timeStamp forKey:[forumConfig.forumURL.host stringByAppendingString:@"-search_time"]];
                [userDefault setInteger:newThreadPostSearchId forKey:[forumConfig.forumURL.host stringByAppendingString:@"-search_id"]];
            }
            if (isSuccess) {
                ViewForumPage *sarchPage = [forumParser parseSearchPageFromHtml:html];
                handler(isSuccess, sarchPage);
            } else {
                handler(NO, html);
            }
        }];
    } else {
        NSString *searchIdStr = [NSString stringWithFormat:@"%ld", (long) searchId];
        NSString *url = [forumConfig searchWithSearchId:searchIdStr withPage:page];

        [self GET:url requestCallback:^(BOOL isSuccess, NSString *html) {
            if (isSuccess) {
                ViewForumPage *sarchPage = [forumParser parseSearchPageFromHtml:html];
                handler(isSuccess, sarchPage);
            } else {
                handler(NO, html);
            }
        }];
    }
}

- (void)listMyAllThreadsWithPage:(int)page handler:(HandlerWithBool)handler {
    LocalForumApi *forumApi = [[LocalForumApi alloc] init];
    LoginUser *user = [forumApi getLoginUser:forumConfig.forumURL.host];
    if (user == nil || user.userID == nil) {
        handler(NO, @"未登录");
        return;
    }

    if (listMyThreadSearchId == nil) {

        NSString *encodeName = [user.userName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

        NSString *url = [forumConfig searchMyThreadWithUserName:encodeName];
        [self GET:url requestCallback:^(BOOL isSuccess, NSString *html) {
            if (listMyThreadSearchId == nil) {
                listMyThreadSearchId = [forumParser parseListMyThreadSearchId:html];
            }

            if (isSuccess) {
                ViewForumPage *sarchPage = [forumParser parseSearchPageFromHtml:html];
                handler(isSuccess, sarchPage);
            } else {
                handler(NO, html);
            }
        }];
    } else {
        NSString *url = [forumConfig searchWithSearchId:listMyThreadSearchId withPage:page];

        [self GET:url requestCallback:^(BOOL isSuccess, NSString *html) {
            if (isSuccess) {
                ViewForumPage *sarchPage = [forumParser parseSearchPageFromHtml:html];
                handler(isSuccess, sarchPage);
            } else {
                handler(NO, html);
            }
        }];
    }
}

- (void)listAllUserThreads:(int)userId withPage:(int)page handler:(HandlerWithBool)handler {


    if (listUserThreadRedirectUrlDictionary == nil || listUserThreadRedirectUrlDictionary[@(userId)] == nil) {
        NSString *baseUrl = [forumConfig searchThreadWithUserId:[NSString stringWithFormat:@"%d", userId]];
        [self GET:baseUrl requestCallback:^(BOOL isSuccess, NSString *html) {
            if (listUserThreadRedirectUrlDictionary == nil) {
                listUserThreadRedirectUrlDictionary = [NSMutableDictionary dictionary];
            }

            NSString *searchId = [forumParser parseListMyThreadSearchId:html];

            listUserThreadRedirectUrlDictionary[@(userId)] = searchId;

            if (isSuccess) {
                ViewForumPage *sarchPage = [forumParser parseSearchPageFromHtml:html];
                handler(isSuccess, sarchPage);
            } else {
                handler(NO, html);
            }
        }];

    } else {
        NSString *searchId = listUserThreadRedirectUrlDictionary[@(userId)];
        NSString *url = [forumConfig searchWithSearchId:searchId withPage:page];

        [self GET:url requestCallback:^(BOOL isSuccess, NSString *html) {
            if (isSuccess) {
                ViewForumPage *sarchPage = [forumParser parseSearchPageFromHtml:html];
                handler(isSuccess, sarchPage);
            } else {
                handler(NO, html);
            }
        }];
    }
}

- (void)showThreadWithId:(int)threadId andPage:(int)page handler:(HandlerWithBool)handler {

    NSString *url = [forumConfig showThreadWithThreadId:[NSString stringWithFormat:@"%d", threadId] withPage:page];
    [self GET:url requestCallback:^(BOOL isSuccess, NSString *html) {
        if (isSuccess) {
            NSString *error = [self checkError:html];
            if (error != nil) {
                handler(NO, error);
            } else {
                ViewThreadPage *detail = [forumParser parseShowThreadWithHtml:html];
                handler(isSuccess, detail);
            }
        } else {
            handler(NO, html);
        }
    }];
}

- (void)showThreadWithP:(NSString *)p handler:(HandlerWithBool)handler {
    NSString *url = [forumConfig showThreadWithP:p];

    [self GET:url requestCallback:^(BOOL isSuccess, NSString *html) {
        if (isSuccess) {
            NSString *error = [self checkError:html];
            if (error != nil) {
                handler(NO, error);
            } else {
                ViewThreadPage *detail = [forumParser parseShowThreadWithHtml:html];
                handler(isSuccess, detail);
            }
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

- (void)listSearchResultWithSearchId:(NSString *)searchId keyWord:(NSString *)keyWord andPage:(int)page type:(int)type handler:(HandlerWithBool)handler {
    NSString *searchedUrl = [forumConfig searchWithSearchId:searchId withPage:page];

    [self GET:searchedUrl requestCallback:^(BOOL isSuccess, NSString *html) {
        if (isSuccess) {

            NSString *error = [self checkError:html];
            if (error != nil) {
                handler(NO, error);
            } else {
                ViewSearchForumPage *viewSearchForumPage = [forumParser parseSearchPageFromHtml:html];

                if (viewSearchForumPage != nil && viewSearchForumPage.dataList != nil && viewSearchForumPage.dataList.count > 0) {
                    handler(YES, viewSearchForumPage);
                } else {
                    handler(NO, @"未知错误");
                }
            }

        } else {
            handler(NO, html);
        }
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
    NSString *url = [forumConfig reportWithPostId:postId];
    [self GET:url requestCallback:^(BOOL isSuccess, NSString *html) {
        if (isSuccess) {

            NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
            [parameters setValue:@"" forKey:@"s"];
            NSString *token = [forumParser parseSecurityToken:html];
            [parameters setValue:token forKey:@"securitytoken"];
            [parameters setValue:message forKey:@"reason"];
            [parameters setValue:[NSString stringWithFormat:@"%d", postId] forKey:@"postid"];
            [parameters setValue:@"sendemail" forKey:@"do"];
            [parameters setValue:[NSString stringWithFormat:@"showthread.php?p=%d#post%d", postId, postId] forKey:@"url"];

            [self.browser POSTWithURLString:forumConfig.report parameters:parameters charset:UTF_8 requestCallback:^(BOOL success, NSString *string) {
                handler(success, string);
            }];
        } else {
            handler(NO, html);
        }
    }];
}

- (BOOL)openUrlByClient:(ForumWebViewController *)controller request:(NSURLRequest *)request {
    NSString *path = request.URL.path;
    if ([path rangeOfString:@"showthread.php"].location != NSNotFound) {
        // 显示帖子
        NSDictionary *query = [self dictionaryFromQuery:request.URL.query usingEncoding:NSUTF8StringEncoding];

        NSString *threadIdStr = [query valueForKey:@"t"];

        UIStoryboard *storyboard = [UIStoryboard mainStoryboard];
        ForumWebViewController *showThreadController = [storyboard instantiateViewControllerWithIdentifier:@"ShowThreadDetail"];

        TransBundle *bundle = [[TransBundle alloc] init];
        [bundle putIntValue:[threadIdStr intValue] forKey:@"threadID"];

        [controller transBundle:bundle forController:showThreadController];

        [controller.navigationController pushViewController:showThreadController animated:YES];

        return YES;
    }
    return NO;
}

#pragma private
- (NSDictionary *)dictionaryFromQuery:(NSString *)query usingEncoding:(NSStringEncoding)encoding {
    NSCharacterSet *delimiterSet = [NSCharacterSet characterSetWithCharactersInString:@"&;"];
    NSMutableDictionary *pairs = [NSMutableDictionary dictionary];
    NSScanner *scanner = [[NSScanner alloc] initWithString:query];
    while (![scanner isAtEnd]) {
        NSString *pairString = nil;
        [scanner scanUpToCharactersFromSet:delimiterSet intoString:&pairString];
        [scanner scanCharactersFromSet:delimiterSet intoString:NULL];
        NSArray *kvPair = [pairString componentsSeparatedByString:@"="];
        if (kvPair.count == 2) {
            NSString *key = [kvPair[0] stringByReplacingPercentEscapesUsingEncoding:encoding];
            NSString *value = [kvPair[1] stringByReplacingPercentEscapesUsingEncoding:encoding];
            pairs[key] = value;
        }
    }

    return [NSDictionary dictionaryWithDictionary:pairs];
}

@end
