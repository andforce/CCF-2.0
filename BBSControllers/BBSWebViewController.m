//
//  Created by Diyuan Wang on 2019/11/21.
//  Copyright © 2019年 Diyuan Wang. All rights reserved.
//

#import "BBSWebViewController.h"
#import <MJRefresh.h>
#import <NYTPhotosViewController.h>
#import <NYTPhotoViewer/NYTPhoto.h>
#import "BBSPhoto.h"
#import "LCActionSheet.h"
#import "UIStoryboard+Forum.h"
#import "ActionSheetPicker.h"
#import "NSString+Extensions.h"
#import "BBSUserProfileTableViewController.h"
#import "AppDelegate.h"
#import "BBSLocalApi.h"
#import "ProgressDialog.h"
#import "NYTPhotoViewerArrayDataSource.h"
#import "NSURLProtocol+WKWebVIew.h"

#import <WebKit/WebKit.h>
#import <SDWebImage/SDImageCache.h>

@interface BBSWebViewController () <UIScrollViewDelegate, TranslateDataDelegate, CAAnimationDelegate, WKScriptMessageHandler, WKNavigationDelegate> {

    LCActionSheet *_itemActionSheet;
    ViewThreadPage *_currentShowThreadPage;
    NSMutableDictionary *_pageDic;
    int threadID;
    NSString *_threadAuthorName;
    int pId;
    // showNotice
    NSString *pid;
    NSString *_ptid;
    WKWebView *_wkWebView;
    WKUserContentController *_contentController;
    BOOL shouldScrollEnd;
}

@end

@implementation BBSWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [NSURLProtocol wk_registerScheme:@"http"];
    [NSURLProtocol wk_registerScheme:@"https"];

    _pageDic = [NSMutableDictionary dictionary];

    WKWebViewConfiguration *webViewConfiguration = [[WKWebViewConfiguration alloc] init];
    _contentController = [[WKUserContentController alloc] init];

    webViewConfiguration.userContentController = _contentController;


    CGFloat safeBottom = 0;
    if (@available(iOS 11.0, *)) {
        UIEdgeInsets edgeInsets = [[UIApplication sharedApplication] keyWindow].safeAreaInsets;
        safeBottom = edgeInsets.bottom;
    }


    CGFloat bottom = safeBottom + _bottomView.frame.size.height;

    CGRect f = self.view.frame;

    CGRect rectStatus = [[UIApplication sharedApplication] statusBarFrame];
    CGRect rectNav = self.navigationController.navigationBar.frame;

    _wkWebView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, f.size.width, f.size.height - rectStatus.size.height - rectNav.size.height - bottom) configuration:webViewConfiguration];

    _wkWebView.scrollView.decelerationRate = UIScrollViewDecelerationRateNormal;
    _wkWebView.backgroundColor = [UIColor whiteColor];
    _wkWebView.navigationDelegate = self;

    [self.view addSubview:_wkWebView];

    [self.view sendSubviewToBack:_wkWebView];

    [_wkWebView setOpaque:NO];

    // scrollView
    _wkWebView.scrollView.delegate = self;

    _wkWebView.scrollView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [self showPreviousPageOrRefresh];
    }];

    _wkWebView.scrollView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        // 当前页面 == 页面的最大数，只刷新当前页面就可以了
        [self showNextPageOrRefreshCurrentPage:_currentShowThreadPage.pageNumber.currentPageNumber forThreadId:threadID];
    }];

    [_wkWebView.scrollView.mj_header beginRefreshing];
}

- (void)transBundle:(TranslateData *)bundle {

    if ([bundle containsKey:@"Senior_Reply_Callback"]) {
        ViewThreadPage *threadPage = [bundle getObjectValue:@"Senior_Reply_Callback"];

        _currentShowThreadPage = threadPage;

        [self updatePageTitle];

        NSMutableArray<PostFloor *> *posts = threadPage.postList;

        NSString *postFloors = [self postFloors:posts];
        BOOL firstPage = threadPage.pageNumber.currentPageNumber <= 1;
        NSString *html = [self contentThreadPageHtml:firstPage title:threadPage.threadTitle postFloors:postFloors];

        NSString *cacheHtml = _pageDic[@(_currentShowThreadPage.pageNumber.currentPageNumber)];

        BBSLocalApi *localeForumApi = [[BBSLocalApi alloc] init];
        if (![cacheHtml isEqualToString:threadPage.originalHtml]) {
            [_wkWebView loadHTMLString:html baseURL:[NSURL URLWithString:localeForumApi.currentForumBaseUrl]];
            _pageDic[@(_currentShowThreadPage.pageNumber.currentPageNumber)] = html;
        }

        shouldScrollEnd = YES;

    } else if ([bundle containsKey:@"Simple_Reply_Callback"]) {
        ViewThreadPage *threadPage = [bundle getObjectValue:@"Simple_Reply_Callback"];

        _currentShowThreadPage = threadPage;


        [self updatePageTitle];

        NSMutableArray<PostFloor *> *posts = threadPage.postList;

        NSString *postFloors = [self postFloors:posts];
        BOOL firstPage = threadPage.pageNumber.currentPageNumber <= 1;
        NSString *html = [self contentThreadPageHtml:firstPage title:threadPage.threadTitle postFloors:postFloors];

        NSString *cacheHtml = _pageDic[@(_currentShowThreadPage.pageNumber.currentPageNumber)];
        if (![cacheHtml isEqualToString:threadPage.originalHtml]) {
            BBSLocalApi *localeForumApi = [[BBSLocalApi alloc] init];
            [_wkWebView loadHTMLString:html baseURL:[NSURL URLWithString:localeForumApi.currentForumBaseUrl]];
            _pageDic[@(_currentShowThreadPage.pageNumber.currentPageNumber)] = html;
        }

        shouldScrollEnd = YES;
    } else if ([bundle containsKey:@"show_for_notice"]) {

        _ptid = [bundle getStringValue:@"show_for_notice_ptid"];
        pid = [bundle getStringValue:@"show_for_notice_pid"];


    } else {
        threadID = [bundle getIntValue:@"threadID"];
        pId = [bundle getIntValue:@"pId"];

        _threadAuthorName = [bundle getStringValue:@"threadAuthorName"];

    }
}

- (NSString *)postFloors:(NSMutableArray<PostFloor *> *)posts {
    NSString *postFloors = @"";

    BBSLocalApi *localForumApi = [[BBSLocalApi alloc] init];
    id <BBSConfigDelegate> forumConfig = [BBSApiHelper forumConfig:localForumApi.currentForumHost];

    for (PostFloor *post in posts) {
        NSString *avatar = [forumConfig avatar:post.postUserInfo.userAvatar];
        NSString *floor = [post.postLouCeng stringWithRegular:@"\\d+"];
        NSString *postInfo = [NSString stringWithFormat:POST_MESSAGE, post.postID, post.postUserInfo.userName,
                                                        floor, post.postUserInfo.userID, avatar, post.postUserInfo.userName, post.postLouCeng, post.postTime, post.postContent];
        postFloors = [postFloors stringByAppendingString:postInfo];
    }
    return postFloors;
}

- (NSString *)contentThreadPageHtml:(BOOL)firstPage title:(NSString *)title postFloors:(NSString *)posts {
    NSString *titleHtml = @"        <li class=\"post-title\">\n"
                          "            <div class=\"title\">%@</div>\n"
                          "        </li>";
    NSString *titleFormat = firstPage ? [NSString stringWithFormat:titleHtml, title] : @"";
    NSString *html = [NSString stringWithFormat:THREAD_PAGE, titleFormat, posts, JS_FAST_CLICK_LIB, JS_HANDLE_CLICK];
    return html;
}

- (void)updatePageTitle {
    NSString *title = [NSString stringWithFormat:@"%lu-%lu", (unsigned long) _currentShowThreadPage.pageNumber.currentPageNumber, (unsigned long) _currentShowThreadPage.pageNumber.totalPageNumber];
    self.pageTitleTextView.text = title;
}

#pragma mark WKNavigationDelegate
- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation {
    NSLog(@"onImageClicked %@",@"didFinishNavigation");
    if (shouldScrollEnd){
        CGPoint scrollPoint = CGPointMake(0, _wkWebView.scrollView.contentSize.height);
        NSString *js = [NSString stringWithFormat:@"window.scrollTo(0,%f)",scrollPoint.y];
        [_wkWebView evaluateJavaScript:js completionHandler:nil];
        shouldScrollEnd = NO;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [_wkWebView.configuration.userContentController addScriptMessageHandler:self name:@"onImageClicked"];
    [_wkWebView.configuration.userContentController addScriptMessageHandler:self name:@"onPostMessageClicked"];
    [_wkWebView.configuration.userContentController addScriptMessageHandler:self name:@"onAvatarClicked"];
    [_wkWebView.configuration.userContentController addScriptMessageHandler:self name:@"onLinkClicked"];
    [_wkWebView.configuration.userContentController addScriptMessageHandler:self name:@"onDebug"];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    [_wkWebView.configuration.userContentController removeScriptMessageHandlerForName:@"onImageClicked"];
    [_wkWebView.configuration.userContentController removeScriptMessageHandlerForName:@"onPostMessageClicked"];
    [_wkWebView.configuration.userContentController removeScriptMessageHandlerForName:@"onAvatarClicked"];
    [_wkWebView.configuration.userContentController removeScriptMessageHandlerForName:@"onLinkClicked"];
    [_wkWebView.configuration.userContentController removeScriptMessageHandlerForName:@"onDebug"];
}

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    if ([message.name isEqualToString:@"onImageClicked"]) {
        NSLog(@"onImageClicked %@", message.body);

        NSString *src = message.body;

        UIImage *memCachedImage = [[SDImageCache sharedImageCache] imageFromMemoryCacheForKey:src];
        if (!memCachedImage) {
            memCachedImage = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:src];
        }

        NYTPhotoViewerArrayDataSource *ds = [self.class newTimesBuildingDataSource:@[memCachedImage]];

        NYTPhotosViewController *photosViewController = [[NYTPhotosViewController alloc] initWithDataSource:ds initialPhoto:nil delegate:nil];

        [self presentViewController:photosViewController animated:YES completion:nil];

    } else if ([message.name isEqualToString:@"onPostMessageClicked"]) {
        NSURL *url = [NSURL URLWithString:message.body];
        NSLog(@"onPostMessageClicked %@", url);

        NSData *data = [message.body dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *query = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        NSString *userName = [[query valueForKey:@"postuser"] replaceUnicode];
        int postId = [[query valueForKey:@"postid"] intValue];
        int floor = [[query valueForKey:@"postlouceng"] intValue];

        _itemActionSheet = [LCActionSheet sheetWithTitle:userName cancelButtonTitle:@"取消" clicked:^(LCActionSheet *_Nonnull actionSheet, NSInteger buttonIndex) {

            NSLog(@"LCActionSheet click index %ld", (long) buttonIndex);

            if (buttonIndex == 1) {

                UIStoryboard *storyBoard = [UIStoryboard mainStoryboard];

                UINavigationController *controller = [storyBoard instantiateViewControllerWithIdentifier:@"SeniorReplySomeOne"];

                TranslateData *bundle = [[TranslateData alloc] init];

                [bundle putIntValue:_currentShowThreadPage.forumId forKey:@"FORM_ID"];
                [bundle putIntValue:threadID forKey:@"THREAD_ID"];
                [bundle putIntValue:postId forKey:@"POST_ID"];
                NSString *token = _currentShowThreadPage.securityToken;
                [bundle putStringValue:token forKey:@"SECURITY_TOKEN"];
                [bundle putStringValue:_currentShowThreadPage.ajaxLastPost forKey:@"AJAX_LAST_POST"];
                [bundle putStringValue:userName forKey:@"USER_NAME"];
                [bundle putIntValue:1 forKey:@"IS_QUOTE_REPLY"];

                [bundle putObjectValue:_currentShowThreadPage forKey:@"QUICK_REPLY_THREAD"];

                [self presentViewController:controller withBundle:bundle forRootController:YES animated:YES completion:^{

                }];

            } else if (buttonIndex == 2) {

                BBSLocalApi *localForumApi = [[BBSLocalApi alloc] init];
                id <BBSConfigDelegate> forumConfig = [BBSApiHelper forumConfig:localForumApi.currentForumHost];

                NSString *postUrl = [forumConfig copyThreadUrl:[NSString stringWithFormat:@"%d", threadID] withPostId:[NSString stringWithFormat:@"%d", postId] withPostCout:floor];
                UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
                pasteboard.string = postUrl;
                [ProgressDialog showSuccess:@"复制成功"];
            } else if (buttonIndex == 3) {
                [self reportThreadPost:postId userName:userName];
            }
        }                          otherButtonTitleArray:@[@"引用此楼回复", @"复制此楼链接", @"举报此楼"]];

        [_itemActionSheet show];

    } else if ([message.name isEqualToString:@"onAvatarClicked"]) {
        NSLog(@"onAvatarClicked %@", message.body);

        NSURL *url = [NSURL URLWithString:message.body];
        NSDictionary *query = [self dictionaryFromQuery:url.query usingEncoding:NSUTF8StringEncoding];

        NSString *userid = [query valueForKey:@"userid"];


        UIStoryboard *storyboard = [UIStoryboard mainStoryboard];
        BBSUserProfileTableViewController *showThreadController = [storyboard instantiateViewControllerWithIdentifier:@"ShowUserProfile"];

        TranslateData *bundle = [[TranslateData alloc] init];
        [bundle putIntValue:[userid intValue] forKey:@"UserId"];
        [self transBundle:bundle forController:showThreadController];

        [self.navigationController pushViewController:showThreadController animated:YES];

    } else if ([message.name isEqualToString:@"onLinkClicked"]) {

        NSURL *url = [NSURL URLWithString:message.body];

        NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];

        if ([self.forumApi openUrlByClient:self request:request]) {

        } else {
            [[UIApplication sharedApplication] openURL:request.URL options:@{} completionHandler:nil];
        }
    } else {
        NSLog(@"didReceiveScriptMessage() >>>:%@, body:%@", message.name, message.body);
    }

}

- (void)showPreviousPageOrRefresh {

    if (pid && _ptid) {
        [self.forumApi showThreadWithPTid:_ptid pid:pid handler:^(BOOL isSuccess, id message) {
            if (!isSuccess) {
                [self showFailedMessage:message];
                return;
            }

            [self showMessage:message];
        }];
    } else {
        if (threadID == -1) {
            [self.forumApi showThreadWithP:[NSString stringWithFormat:@"%d", pId] handler:^(BOOL isSuccess, id message) {

                if (!isSuccess) {
                    [self showFailedMessage:message];
                    return;
                }
                [self showMessage:message];
            }];
        } else {
            if (_currentShowThreadPage == nil) {
                [self prePage:threadID page:1 withAnim:NO];
            } else if (_currentShowThreadPage.pageNumber.currentPageNumber == 1) {
                [self prePage:threadID page:1 withAnim:NO];
            } else {
                int page = _currentShowThreadPage.pageNumber.currentPageNumber - 1;
                if (page <= 1) {
                    page = 1;
                }
                [self prePage:threadID page:page withAnim:YES];
            }
        }
    }

}

- (void)showMessage:(id)message {
    ViewThreadPage *threadPage = message;
    _currentShowThreadPage = threadPage;
    threadID = threadPage.threadID;

    [self updatePageTitle];

    NSMutableArray<PostFloor *> *posts = threadPage.postList;


    NSString *postFloors = [self postFloors:posts];

    //NSString *html = [NSString stringWithFormat:THREAD_PAGE, threadPage.threadTitle, postFloors, JS_FAST_CLICK_LIB, JS_HANDLE_CLICK];

    NSString *html = [self contentThreadPageHtml:YES title:threadPage.threadTitle postFloors:postFloors];

    // 缓存当前页面
    _pageDic[@(_currentShowThreadPage.pageNumber.currentPageNumber)] = threadPage.originalHtml;

    BBSLocalApi *localeForumApi = [[BBSLocalApi alloc] init];
    [_wkWebView loadHTMLString:html baseURL:[NSURL URLWithString:localeForumApi.currentForumBaseUrl]];

    [_wkWebView.scrollView.mj_header endRefreshing];


    CABasicAnimation *stretchAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale.y"];
    [stretchAnimation setToValue:@1.02F];
    [stretchAnimation setRemovedOnCompletion:YES];
    [stretchAnimation setFillMode:kCAFillModeRemoved];
    [stretchAnimation setAutoreverses:YES];
    [stretchAnimation setDuration:0.15];
    [stretchAnimation setDelegate:self];
    [stretchAnimation setBeginTime:CACurrentMediaTime() + 0.35];
    [stretchAnimation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [_wkWebView.layer addAnimation:stretchAnimation forKey:@"stretchAnimation"];
    CATransition *animation = [CATransition animation];
    [animation setType:kCATransitionPush];
    [animation setSubtype:kCATransitionFromBottom];
    [animation setDuration:0.5f];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [[_wkWebView layer] addAnimation:animation forKey:nil];
}

- (void)showFailedMessage:(id)message {
    [_wkWebView.scrollView.mj_header endRefreshing];

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"错误" message:message preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self.navigationController popViewControllerAnimated:YES];
    }];

    [alert addAction:cancel];

    [self presentViewController:alert animated:YES completion:^{

    }];
}

- (void)prePage:(int)threadId page:(int)page withAnim:(BOOL)anim {

    [self.forumApi showThreadWithId:threadId andPage:page handler:^(BOOL isSuccess, id message) {

        if (!isSuccess) {
            [self showFailedMessage:message];
            return;
        }

        ViewThreadPage *threadPage = message;

        if (threadPage.threadTitle == nil) {

            [_wkWebView.scrollView.mj_header endRefreshing];

            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"错误" message:@"\n此帖包含乱码无法正确解析，使用浏览器打开？" preferredStyle:UIAlertControllerStyleAlert];

            UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                [self.navigationController popViewControllerAnimated:YES];

                BBSLocalApi *localForumApi = [[BBSLocalApi alloc] init];
                id <BBSConfigDelegate> forumConfig = [BBSApiHelper forumConfig:localForumApi.currentForumHost];

                NSURL *nsurl = [NSURL URLWithString:[forumConfig showThreadWithThreadId:[NSString stringWithFormat:@"%d", threadId] withPage:page]];
                [[UIApplication sharedApplication] openURL:nsurl options:@{} completionHandler:nil];
            }];

            UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                [self.navigationController popViewControllerAnimated:YES];
            }];

            [alert addAction:action];
            [alert addAction:cancel];

            [self presentViewController:alert animated:YES completion:^{

            }];
            return;
        }
        _currentShowThreadPage = threadPage;


        [self updatePageTitle];

        NSMutableArray<PostFloor *> *posts = threadPage.postList;

        NSString *postFloors = [self postFloors:posts];
        BOOL firstPage = threadPage.pageNumber.currentPageNumber <= 1;
        NSString *html = [self contentThreadPageHtml:firstPage title:threadPage.threadTitle postFloors:postFloors];


        _pageDic[@(_currentShowThreadPage.pageNumber.currentPageNumber)] = threadPage.originalHtml;

        BBSLocalApi *localeForumApi = [[BBSLocalApi alloc] init];
        [_wkWebView loadHTMLString:html baseURL:[NSURL URLWithString:localeForumApi.currentForumBaseUrl]];

        [_wkWebView.scrollView.mj_header endRefreshing];


        if (anim) {
            CABasicAnimation *stretchAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale.y"];
            [stretchAnimation setToValue:@1.02F];
            [stretchAnimation setRemovedOnCompletion:YES];
            [stretchAnimation setFillMode:kCAFillModeRemoved];
            [stretchAnimation setAutoreverses:YES];
            [stretchAnimation setDuration:0.15];
            [stretchAnimation setDelegate:self];

            [stretchAnimation setBeginTime:CACurrentMediaTime() + 0.35];

            [stretchAnimation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
            //[_webView setAnchorPoint:CGPointMake(0.0, 1) forView:_webView];
            [_wkWebView.layer addAnimation:stretchAnimation forKey:@"stretchAnimation"];

            CATransition *animation = [CATransition animation];
            [animation setType:kCATransitionPush];
            [animation setSubtype:kCATransitionFromBottom];
            [animation setDuration:0.5f];
            [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
            [[_wkWebView layer] addAnimation:animation forKey:nil];
        }

    }];
}

- (void)showNextPageOrRefreshCurrentPage:(int)currentPage forThreadId:(int)threadId {

    if (currentPage < _currentShowThreadPage.pageNumber.totalPageNumber) {
        [self showThread:threadId page:currentPage + 1 withAnim:YES];
    } else {
        [self.forumApi showThreadWithId:threadId andPage:currentPage handler:^(BOOL isSuccess, id message) {

            if (!isSuccess) {
                [self showFailedMessage:message];
                return;
            }

            ViewThreadPage *threadPage = message;
            if (_currentShowThreadPage.postList.count < threadPage.postList.count) {

                NSMutableArray *posts = threadPage.postList;

                BBSLocalApi *localForumApi = [[BBSLocalApi alloc] init];
                id <BBSConfigDelegate> forumConfig = [BBSApiHelper forumConfig:localForumApi.currentForumHost];

                for (NSInteger i = _currentShowThreadPage.postList.count; i < posts.count; i++) {
                    PostFloor *post = posts[(NSUInteger) i];
                    NSString *avatar = [forumConfig avatar:post.postUserInfo.userAvatar];
                    NSString *floor = [post.postLouCeng stringWithRegular:@"\\d+"];

                    [self addPostByJSElement:post avatar:avatar louceng:floor];

                }

                _currentShowThreadPage = threadPage;
            }
            [_wkWebView.scrollView.mj_footer endRefreshing];
        }];
    }
}

- (void)showThread:(int)threadId page:(int)page withAnim:(BOOL)anim {


    NSString *cacheHtml = _pageDic[@(page)];

    [self.forumApi showThreadWithId:threadId andPage:page handler:^(BOOL isSuccess, ViewThreadPage *threadPage) {


        [ProgressDialog dismiss];

        if (!isSuccess) {
            [self showFailedMessage:threadPage];
            return;
        }

        _currentShowThreadPage = threadPage;

        [self updatePageTitle];

        NSMutableArray<PostFloor *> *posts = threadPage.postList;

        NSString *postFloors = [self postFloors:posts];
        BOOL firstPage = threadPage.pageNumber.currentPageNumber <= 1;
        NSString *html = [self contentThreadPageHtml:firstPage title:threadPage.threadTitle postFloors:postFloors];

        if (![cacheHtml isEqualToString:threadPage.originalHtml]) {
            _pageDic[@(page)] = html;
        }

        BBSLocalApi *localeForumApi = [[BBSLocalApi alloc] init];
        [_wkWebView loadHTMLString:html baseURL:[NSURL URLWithString:localeForumApi.currentForumBaseUrl]];

        if (anim) {
            CABasicAnimation *stretchAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale.y"];
            [stretchAnimation setToValue:@1.02F];
            [stretchAnimation setRemovedOnCompletion:YES];
            [stretchAnimation setFillMode:kCAFillModeRemoved];
            [stretchAnimation setAutoreverses:YES];
            [stretchAnimation setDuration:0.15];
            [stretchAnimation setDelegate:self];

            [stretchAnimation setBeginTime:CACurrentMediaTime() + 0.35];

            [stretchAnimation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
            [_wkWebView.layer addAnimation:stretchAnimation forKey:@"stretchAnimation"];

            CATransition *animation = [CATransition animation];
            [animation setType:kCATransitionPush];
            [animation setSubtype:kCATransitionFromTop];
            [animation setDuration:0.5f];
            [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
            [[_wkWebView layer] addAnimation:animation forKey:nil];
        }

        [_wkWebView.scrollView.mj_footer endRefreshing];

    }];
}

- (void)addPostByJSElement:(PostFloor *)post avatar:(NSString *)avatar louceng:(NSString *)floor {
    NSString *pattern = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"append_post" ofType:@"js"] encoding:NSUTF8StringEncoding error:nil];
    NSString *contentPattern = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"append_post_content" ofType:@"html"] encoding:NSUTF8StringEncoding error:nil];
    NSString *content = [NSString stringWithFormat:contentPattern, post.postUserInfo.userID, avatar, post.postUserInfo.userName, post.postLouCeng, post.postTime, post.postContent];
    NSString *deleteEnter = [content stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    NSString *deleteT = [deleteEnter stringByReplacingOccurrencesOfString:@"\t" withString:@""];
    NSString *deleteR = [deleteT stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    NSString *deleteLine = [deleteR stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];

    NSString *js = [NSString stringWithFormat:pattern, post.postID, post.postID, post.postUserInfo.userName, floor, deleteLine];
    [_wkWebView evaluateJavaScript:js completionHandler:nil];
}


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

- (void)reportThreadPost:(int)postId userName:(NSString *)userName {
    UIStoryboard *storyboard = [UIStoryboard mainStoryboard];

    UINavigationController *simpleReplyController = [storyboard instantiateViewControllerWithIdentifier:@"ReportThreadPost"];

    TranslateData *bundle = [[TranslateData alloc] init];
    [bundle putIntValue:postId forKey:@"POST_ID"];
    [bundle putStringValue:userName forKey:@"POST_USER"];

    [self presentViewController:simpleReplyController withBundle:bundle forRootController:YES animated:YES completion:^{

    }];
}

- (void)showChangePageActionSheet:(UIBarButtonItem *)sender {

    if (_currentShowThreadPage.pageNumber.totalPageNumber <= 1) {
        return;
    }

    NSMutableArray<NSString *> *pages = [NSMutableArray array];
    for (int i = 0; i < _currentShowThreadPage.pageNumber.totalPageNumber; i++) {
        NSString *page = [NSString stringWithFormat:@"第 %d 页", i + 1];
        [pages addObject:page];
    }

    ActionSheetStringPicker *picker = [[ActionSheetStringPicker alloc] initWithTitle:@"选择页面" rows:pages
                                                                    initialSelection:_currentShowThreadPage.pageNumber.currentPageNumber - 1 doneBlock:
                    ^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {

        int selectPage = (int) selectedIndex + 1;

        if (selectPage != _currentShowThreadPage.pageNumber.currentPageNumber) {

            [ProgressDialog showStatus:@"正在切换"];
            [self showThread:threadID page:selectPage withAnim:YES];
        }


    }                                                                    cancelBlock:^(ActionSheetStringPicker *picker) {


    }                                                                         origin:sender];

    UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] init];
    cancelItem.title = @"取消";
    [picker setCancelButton:cancelItem];

    UIBarButtonItem *queding = [[UIBarButtonItem alloc] init];
    queding.title = @"确定";
    [picker setDoneButton:queding];


    [picker showActionSheetPicker];
}


- (IBAction)back:(UIBarButtonItem *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)changeNumber:(id)sender {
    [self showChangePageActionSheet:sender];

}

- (IBAction)showMoreAction:(UIBarButtonItem *)sender {

    BBSLocalApi *localForumApi = [[BBSLocalApi alloc] init];
    id <BBSConfigDelegate> forumConfig = [BBSApiHelper forumConfig:localForumApi.currentForumHost];

    _itemActionSheet = [LCActionSheet sheetWithTitle:nil cancelButtonTitle:nil clicked:^(LCActionSheet *_Nonnull actionSheet, NSInteger buttonIndex) {
        if (buttonIndex == 1) {
            // 复制贴链接
            UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];

            pasteboard.string = [forumConfig showThreadWithThreadId:[NSString stringWithFormat:@"%d", threadID] withPage:0];

            [ProgressDialog showSuccess:@"复制成功"];

        } else if (buttonIndex == 2) {
            // 在浏览器种查看
            NSURL *url = [NSURL URLWithString:[forumConfig showThreadWithThreadId:[NSString stringWithFormat:@"%d", threadID] withPage:1]];
            [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
        } else if (buttonIndex == 3) {
            [self reportThreadPost:nil userName:nil];
        }

    } otherButtonTitleArray:@[@"复制帖子链接", @"在浏览器中查看", @"举报此主题"]];

    [_itemActionSheet show];
}

- (IBAction)reply:(id)sender {

    UIStoryboard *storyBoard = [UIStoryboard mainStoryboard];
    UINavigationController *controller = [storyBoard instantiateViewControllerWithIdentifier:@"SeniorReplySomeOne"];

    TranslateData *bundle = [[TranslateData alloc] init];
    [bundle putIntValue:_currentShowThreadPage.forumId forKey:@"FORM_ID"];
    [bundle putIntValue:threadID forKey:@"THREAD_ID"];
    [bundle putIntValue:-1 forKey:@"POST_ID"];

    NSString *token = _currentShowThreadPage.securityToken;
    [bundle putStringValue:token forKey:@"SECURITY_TOKEN"];
    [bundle putStringValue:_threadAuthorName forKey:@"POST_USER"];
    [bundle putObjectValue:_currentShowThreadPage forKey:@"QUICK_REPLY_THREAD"];

    [self presentViewController:controller withBundle:bundle forRootController:YES animated:YES completion:^{
        NSLog(@"");
    }];
}

- (void)killScroll {
    CGPoint offset = _wkWebView.scrollView.contentOffset;
    offset.y -= 1.0;
    [_wkWebView.scrollView setContentOffset:offset animated:NO];
}

- (IBAction)firstPage:(id)sender {
    [self killScroll];

    if (1 == _currentShowThreadPage.pageNumber.currentPageNumber) {
        [_wkWebView.scrollView.mj_header beginRefreshing];
        return;
    }

    [ProgressDialog showStatus:@"正在切换"];
    [self showThread:threadID page:1 withAnim:YES];
}

- (IBAction)lastPage:(id)sender {
    [self killScroll];

    if (_currentShowThreadPage.pageNumber.totalPageNumber == _currentShowThreadPage.pageNumber.currentPageNumber) {
        [_wkWebView.scrollView.mj_footer beginRefreshing];
        return;
    }
    [ProgressDialog showStatus:@"正在切换"];
    [self showThread:threadID page:_currentShowThreadPage.pageNumber.totalPageNumber withAnim:YES];
}

- (IBAction)previousPage:(id)sender {
    [self killScroll];

    [_wkWebView.scrollView.mj_header beginRefreshing];
}

- (IBAction)nextPage:(id)sender {
    [self killScroll];

    [_wkWebView.scrollView.mj_footer beginRefreshing];
}

+ (NYTPhotoViewerArrayDataSource *)newTimesBuildingDataSource:(NSArray *)images {
    NSMutableArray *photos = [NSMutableArray array];

    for (UIImage *image in images) {
        BBSPhoto *photo = [[BBSPhoto alloc] init];
        photo.attributedCaptionTitle = [[NSAttributedString alloc] initWithString:@"1" attributes:nil];
        photo.image = image;
        [photos addObject:photo];
    }

    return [NYTPhotoViewerArrayDataSource dataSourceWithPhotos:photos];
}
@end
