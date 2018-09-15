//
//  ForumWebViewController.m
//
//  Created by 迪远 王 on 16/5/26.
//  Copyright © 2016年 andforce. All rights reserved.
//

#import "ForumWebViewController.h"
#import <MJRefresh.h>
#import "SDImageCache+URLCache.h"
#import <NYTPhotosViewController.h>
#import <NYTPhotoViewer/NYTPhoto.h>
#import <SVProgressHUD/SVProgressHUD.h>
#import "NYTExamplePhoto.h"
#import "LCActionSheet.h"
#import "UIStoryboard+Forum.h"
#import "ActionSheetPicker.h"
#import "NSString+Extensions.h"
#import "ForumUserProfileTableViewController.h"
#import "AppDelegate.h"
#import "LocalForumApi.h"
#import "ProgressDialog.h"
#import "NYTPhotoViewerArrayDataSource.h"

#import <WebKit/WebKit.h>

@interface ForumWebViewController () <UIWebViewDelegate, UIScrollViewDelegate, TransBundleDelegate, CAAnimationDelegate, WKScriptMessageHandler> {

    LCActionSheet *itemActionSheet;

    ViewThreadPage *currentShowThreadPage;

    NSMutableDictionary *pageDic;

    int threadID;
    NSString *threadAuthorName;

    int pId;

    BOOL shouldScrollEnd;

    // showNotice
    NSString *pid;
    NSString *ptid;

    WKWebView *_webView;
}

@end

@implementation ForumWebViewController

- (void)transBundle:(TransBundle *)bundle {

    if ([bundle containsKey:@"Senior_Reply_Callback"]) {
        ViewThreadPage *threadPage = [bundle getObjectValue:@"Senior_Reply_Callback"];

        currentShowThreadPage = threadPage;

        [self updatePageTitle];

        NSMutableArray<Post *> *posts = threadPage.postList;

        NSString *lis = @"";

        LocalForumApi *localForumApi = [[LocalForumApi alloc] init];
        id<ForumConfigDelegate> forumConfig = [ForumApiHelper forumConfig:localForumApi.currentForumHost];

        for (Post *post in posts) {

            NSString *avatar = [forumConfig avatar:post.postUserInfo.userAvatar];
            NSString *louceng = [post.postLouCeng stringWithRegular:@"\\d+"];
            NSString *postInfo = [NSString stringWithFormat:POST_MESSAGE, post.postID, post.postID, post.postUserInfo.userName,
                            louceng, post.postUserInfo.userID, avatar, post.postUserInfo.userName, post.postLouCeng, post.postTime, post.postContent];

            lis = [lis stringByAppendingString:postInfo];

            //[self addPostByJSElement:post avatar:avatar louceng:louceng];

        }

        NSString *html = nil;

        if (threadPage.pageNumber.currentPageNumber <= 1) {
            html = [NSString stringWithFormat:THREAD_PAGE, threadPage.threadTitle, lis, JS_FAST_CLICK_LIB, JS_HANDLE_CLICK];
        } else {
            html = [NSString stringWithFormat:THREAD_PAGE_NOTITLE, lis, JS_FAST_CLICK_LIB, JS_HANDLE_CLICK];
        }

        NSString *cacheHtml = pageDic[@(currentShowThreadPage.pageNumber.currentPageNumber)];

        LocalForumApi * localeForumApi = [[LocalForumApi alloc] init];
        if (![cacheHtml isEqualToString:threadPage.originalHtml]) {
            [_webView loadHTMLString:html baseURL:[NSURL URLWithString:localeForumApi.currentForumBaseUrl]];
            pageDic[@(currentShowThreadPage.pageNumber.currentPageNumber)] = html;
        }

        shouldScrollEnd = YES;

    } else if ([bundle containsKey:@"Simple_Reply_Callback"]) {
        ViewThreadPage *threadPage = [bundle getObjectValue:@"Simple_Reply_Callback"];

        currentShowThreadPage = threadPage;


        [self updatePageTitle];

        NSMutableArray<Post *> *posts = threadPage.postList;

        NSString *lis = @"";

        LocalForumApi *localForumApi = [[LocalForumApi alloc] init];
        id<ForumConfigDelegate> forumConfig = [ForumApiHelper forumConfig:localForumApi.currentForumHost];
        for (Post *post in posts) {
            NSString *avatar = [forumConfig avatar:post.postUserInfo.userAvatar];
            NSString *louceng = [post.postLouCeng stringWithRegular:@"\\d+"];
            NSString *postInfo = [NSString stringWithFormat:POST_MESSAGE, post.postID, post.postID, post.postUserInfo.userName,
                            louceng, post.postUserInfo.userID, avatar, post.postUserInfo.userName, post.postLouCeng, post.postTime, post.postContent];

            lis = [lis stringByAppendingString:postInfo];

            //[self addPostByJSElement:post avatar:avatar louceng:louceng];

        }

        NSString *html = nil;

        if (threadPage.pageNumber.currentPageNumber <= 1) {
            html = [NSString stringWithFormat:THREAD_PAGE, threadPage.threadTitle, lis, JS_FAST_CLICK_LIB, JS_HANDLE_CLICK];
        } else {
            html = [NSString stringWithFormat:THREAD_PAGE_NOTITLE, lis, JS_FAST_CLICK_LIB, JS_HANDLE_CLICK];
        }

        NSString *cacheHtml = pageDic[@(currentShowThreadPage.pageNumber.currentPageNumber)];
        if (![cacheHtml isEqualToString:threadPage.originalHtml]) {
            LocalForumApi * localeForumApi = [[LocalForumApi alloc] init];
            [_webView loadHTMLString:html baseURL:[NSURL URLWithString:localeForumApi.currentForumBaseUrl]];
            pageDic[@(currentShowThreadPage.pageNumber.currentPageNumber)] = html;
        }

        shouldScrollEnd = YES;
    } else if ([bundle containsKey:@"show_for_notice"]){

        ptid = [bundle getStringValue:@"show_for_notice_ptid"];
        pid = [bundle getStringValue:@"show_for_notice_pid"];


    } else {
        threadID = [bundle getIntValue:@"threadID"];
        pId = [bundle getIntValue:@"pId"];

        threadAuthorName = [bundle getStringValue:@"threadAuthorName"];

    }
}

- (void) updatePageTitle{
    NSString *title = [NSString stringWithFormat:@"%lu-%lu", (unsigned long) currentShowThreadPage.pageNumber.currentPageNumber, (unsigned long) currentShowThreadPage.pageNumber.totalPageNumber];
    self.pageTitleTextView.text = title;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    pageDic = [NSMutableDictionary dictionary];

    WKWebViewConfiguration *webViewConfiguration = [[WKWebViewConfiguration alloc] init];
    WKUserContentController *contentController = [[WKUserContentController alloc] init];
    [contentController addScriptMessageHandler:self name:@"onImageClicked"];
    [contentController addScriptMessageHandler:self name:@"onPostMessageClicked"];
    [contentController addScriptMessageHandler:self name:@"onAvatarClicked"];
    [contentController addScriptMessageHandler:self name:@"onLinkClicked"];
    [contentController addScriptMessageHandler:self name:@"onDebug"];

    webViewConfiguration.userContentController = contentController;


    CGFloat safeBottom = 0;
    if (@available(iOS 11.0,*)){
        UIEdgeInsets edgeInsets = [[UIApplication sharedApplication] keyWindow].safeAreaInsets;
        safeBottom = edgeInsets.bottom;
    }


    CGFloat bottom = safeBottom + _bottomView.frame.size.height;

    CGRect f = self.view.frame;

    CGRect rectStatus = [[UIApplication sharedApplication] statusBarFrame];
    CGRect rectNav = self.navigationController.navigationBar.frame;

    _webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, f.size.width, f.size.height - rectStatus.size.height - rectNav.size.height - bottom) configuration:webViewConfiguration];

    _webView.scrollView.decelerationRate = UIScrollViewDecelerationRateNormal;
    _webView.backgroundColor = [UIColor whiteColor];

    [self.view addSubview:_webView];

    [self.view sendSubviewToBack:_webView];


//    [_webView setScalesPageToFit:YES];
//    _webView.dataDetectorTypes = UIDataDetectorTypeNone;
//    _webView.delegate = self;

    for (UIView *view in [[_webView subviews][0] subviews]) {
        if ([view isKindOfClass:[UIImageView class]]) {
            view.hidden = YES;
        }
    }
    [_webView setOpaque:NO];

    // scrollView
    _webView.scrollView.delegate = self;

    _webView.scrollView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{

        [self showPreviousPageOrRefresh];

    }];


    _webView.scrollView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{

        // 当前页面 == 页面的最大数，只刷新当前页面就可以了
        [self showNextPageOrRefreshCurrentPage:currentShowThreadPage.pageNumber.currentPageNumber forThreadId:threadID];

    }];

    [_webView.scrollView.mj_header beginRefreshing];
}

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    if ([message.name isEqualToString:@"onImageClicked"]){
        NSLog(@"onImageClicked %@", message.body);

        NSURL *url = [NSURL URLWithString:message.body];

        NSString *absUrl = url.absoluteString;


        NSString *src = [absUrl stringByReplacingOccurrencesOfString:@"image://https//" withString:@"https://"];
        if ([absUrl hasPrefix:@"image://http//"]) {
            src = [absUrl stringByReplacingOccurrencesOfString:@"image://http//" withString:@"http://"];
        }

        UIImage *memCachedImage = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:src];
        NSData *data = nil;
        if (memCachedImage) {
            if (!memCachedImage.images) {
                data = UIImageJPEGRepresentation(memCachedImage, 1.f);
            }
        } else {
            data = [[SDImageCache sharedImageCache] hp_imageDataFromDiskCacheForKey:src];
            memCachedImage = [UIImage imageWithData:data];
        }

        NYTPhotoViewerArrayDataSource * ds = [self.class newTimesBuildingDataSource:@[memCachedImage]];

        NYTPhotosViewController *photosViewController = [[NYTPhotosViewController alloc] initWithDataSource:ds initialPhoto:nil delegate:nil];

        [self presentViewController:photosViewController animated:YES completion:nil];

    } else if ([message.name isEqualToString:@"onPostMessageClicked"]){
        NSLog(@"onPostMessageClicked %@", message.body);

        NSURL *url = [NSURL URLWithString:message.body];

        NSDictionary *query = [self dictionaryFromQuery:url.query usingEncoding:NSUTF8StringEncoding];

        NSString *userName = [[query valueForKey:@"postuser"] replaceUnicode];
        int postId = [[query valueForKey:@"postid"] intValue];
        int louCeng = [[query valueForKey:@"postlouceng"] intValue];

        itemActionSheet = [LCActionSheet sheetWithTitle:userName cancelButtonTitle:@"取消" clicked:^(LCActionSheet * _Nonnull actionSheet, NSInteger buttonIndex) {

            NSLog(@"LCActionSheet click index %ld", (long) buttonIndex);

            if (buttonIndex == 1) {

                UIStoryboard *storyBoard = [UIStoryboard mainStoryboard];

                UINavigationController *controller = [storyBoard instantiateViewControllerWithIdentifier:@"SeniorReplySomeOne"];

                TransBundle *bundle = [[TransBundle alloc] init];

                [bundle putIntValue:currentShowThreadPage.forumId forKey:@"FORM_ID"];
                [bundle putIntValue:threadID forKey:@"THREAD_ID"];
                [bundle putIntValue:postId forKey:@"POST_ID"];
                NSString *token = currentShowThreadPage.securityToken;
                [bundle putStringValue:token forKey:@"SECURITY_TOKEN"];
                [bundle putStringValue:currentShowThreadPage.ajaxLastPost forKey:@"AJAX_LAST_POST"];
                [bundle putStringValue:userName forKey:@"USER_NAME"];
                [bundle putIntValue:1 forKey:@"IS_QUOTE_REPLY"];

                [bundle putObjectValue:currentShowThreadPage forKey:@"QUICK_REPLY_THREAD"];

                [self presentViewController:controller withBundle:bundle forRootController:YES animated:YES completion:^{

                }];

            } else if (buttonIndex == 2) {

                LocalForumApi *localForumApi = [[LocalForumApi alloc] init];
                id<ForumConfigDelegate> forumConfig = [ForumApiHelper forumConfig:localForumApi.currentForumHost];

                NSString *postUrl = [forumConfig copyThreadUrl:[NSString stringWithFormat:@"%d", threadID] withPostId:[NSString stringWithFormat:@"%d", postId] withPostCout:louCeng];
                UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
                pasteboard.string = postUrl;
                [ProgressDialog showSuccess:@"复制成功"];
            } else if (buttonIndex == 3){
                [self reportThreadPost:postId userName:userName];
            }
        } otherButtonTitleArray:@[@"引用此楼回复", @"复制此楼链接", @"举报此楼"]];

        [itemActionSheet show];

    }else if ([message.name isEqualToString:@"onAvatarClicked"]){
        NSLog(@"onAvatarClicked %@", message.body);

        NSURL *url = [NSURL URLWithString:message.body];
        NSDictionary *query = [self dictionaryFromQuery:url.query usingEncoding:NSUTF8StringEncoding];

        NSString *userid = [query valueForKey:@"userid"];


        UIStoryboard *storyboard = [UIStoryboard mainStoryboard];
        ForumUserProfileTableViewController *showThreadController = [storyboard instantiateViewControllerWithIdentifier:@"ShowUserProfile"];

        TransBundle *bundle = [[TransBundle alloc] init];
        [bundle putIntValue:[userid intValue] forKey:@"UserId"];
        [self transBundle:bundle forController:showThreadController];

        [self.navigationController pushViewController:showThreadController animated:YES];

    }else if ([message.name isEqualToString:@"onLinkClicked"]){

        NSURL *url = [NSURL URLWithString:message.body];

        NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];

        if ([self.forumApi openUrlByClient:self request:request]){

        } else {
            [[UIApplication sharedApplication] openURL:url];
        }
    }

    else{
        NSLog(@"didReceiveScriptMessage() >>>:%@, body:%@", message.name, message.body);
    }

}

- (void) showPreviousPageOrRefresh{

    if (pid && ptid){
        [self.forumApi showThreadWithPTid:ptid pid:pid handler:^(BOOL isSuccess, id message) {
            if (!isSuccess){
                [self showFailedMessage:message];
                return;
            }

            [self showMessage:message];
        }];
    } else {
        if (threadID == -1) {
            [self.forumApi showThreadWithP:[NSString stringWithFormat:@"%d", pId] handler:^(BOOL isSuccess, id message) {

                if (!isSuccess){
                    [self showFailedMessage:message];
                    return;
                }

                [self showMessage:message];


            }];
        } else {
            if (currentShowThreadPage == nil) {
                [self prePage:threadID page:1 withAnim:NO];
            } else if (currentShowThreadPage.pageNumber.currentPageNumber == 1) {
                [self prePage:threadID page:1 withAnim:NO];
            } else {
                int page = currentShowThreadPage.pageNumber.currentPageNumber - 1;
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
    currentShowThreadPage = threadPage;
    threadID = threadPage.threadID;

    [self updatePageTitle];

    NSMutableArray<Post *> *posts = threadPage.postList;


    NSString *lis = @"";

    LocalForumApi *localForumApi = [[LocalForumApi alloc] init];
    id<ForumConfigDelegate> forumConfig = [ForumApiHelper forumConfig:localForumApi.currentForumHost];

    for (Post *post in posts) {

                    NSString *avatar = [forumConfig avatar:post.postUserInfo.userAvatar];
                    NSString *louceng = [post.postLouCeng stringWithRegular:@"\\d+"];
                    NSString *postInfo = [NSString stringWithFormat:POST_MESSAGE, post.postID, post.postID, post.postUserInfo.userName,
                                                                    louceng, post.postUserInfo.userID, avatar, post.postUserInfo.userName, post.postLouCeng, post.postTime, post.postContent];
                    lis = [lis stringByAppendingString:postInfo];
                }

    NSString *html = [NSString stringWithFormat:THREAD_PAGE, threadPage.threadTitle, lis, JS_FAST_CLICK_LIB, JS_HANDLE_CLICK];


    // 缓存当前页面
    pageDic[@(currentShowThreadPage.pageNumber.currentPageNumber)] = threadPage.originalHtml;

    LocalForumApi * localeForumApi = [[LocalForumApi alloc] init];
    [_webView loadHTMLString:html baseURL:[NSURL URLWithString:localeForumApi.currentForumBaseUrl]];

    [_webView.scrollView.mj_header endRefreshing];


    CABasicAnimation *stretchAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale.y"];
    [stretchAnimation setToValue:@1.02F];
    [stretchAnimation setRemovedOnCompletion:YES];
    [stretchAnimation setFillMode:kCAFillModeRemoved];
    [stretchAnimation setAutoreverses:YES];
    [stretchAnimation setDuration:0.15];
    [stretchAnimation setDelegate:self];
    [stretchAnimation setBeginTime:CACurrentMediaTime() + 0.35];
    [stretchAnimation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [_webView.layer addAnimation:stretchAnimation forKey:@"stretchAnimation"];
    CATransition *animation = [CATransition animation];
    [animation setType:kCATransitionPush];
    [animation setSubtype:kCATransitionFromBottom];
    [animation setDuration:0.5f];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [[_webView layer] addAnimation:animation forKey:nil];
}

-(void) showFailedMessage:(id) message{
    [_webView.scrollView.mj_header endRefreshing];

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

        if (!isSuccess){
            [self showFailedMessage:message];
            return;
        }

        ViewThreadPage *threadPage = message;

        if (threadPage.threadTitle == nil) {

            [_webView.scrollView.mj_header endRefreshing];

            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"错误" message:@"\n此帖包含乱码无法正确解析，使用浏览器打开？" preferredStyle:UIAlertControllerStyleAlert];

            UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                [self.navigationController popViewControllerAnimated:YES];

                LocalForumApi *localForumApi = [[LocalForumApi alloc] init];
                id<ForumConfigDelegate> forumConfig = [ForumApiHelper forumConfig:localForumApi.currentForumHost];

                NSURL *nsurl = [NSURL URLWithString:[forumConfig showThreadWithThreadId:[NSString stringWithFormat:@"%d", threadId] withPage:page]];
                [[UIApplication sharedApplication] openURL:nsurl];
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
        currentShowThreadPage = threadPage;


        [self updatePageTitle];

        NSMutableArray<Post *> *posts = threadPage.postList;


        NSString *lis = @"";

        LocalForumApi *localForumApi = [[LocalForumApi alloc] init];
        id<ForumConfigDelegate> forumConfig = [ForumApiHelper forumConfig:localForumApi.currentForumHost];

        for (Post *post in posts) {
            NSString *avatar = [forumConfig avatar:post.postUserInfo.userAvatar];
            NSString *louceng = [post.postLouCeng stringWithRegular:@"\\d+"];
            NSString *postInfo = [NSString stringWithFormat:POST_MESSAGE, post.postID, post.postID, post.postUserInfo.userName, louceng, post.postUserInfo.userID, avatar, post.postUserInfo.userName, post.postLouCeng, post.postTime, post.postContent];
            lis = [lis stringByAppendingString:postInfo];
        }

        NSString *html = nil;

        if (page <= 1) {
            NSString * lib = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"fastclick_lib" ofType:@"js"] encoding:NSUTF8StringEncoding error:nil];
            [lib length];
            
            html = [NSString stringWithFormat:THREAD_PAGE, threadPage.threadTitle, lis, JS_FAST_CLICK_LIB, JS_HANDLE_CLICK];
        } else {
            html = [NSString stringWithFormat:THREAD_PAGE_NOTITLE, lis, JS_FAST_CLICK_LIB, JS_HANDLE_CLICK];
        }


        pageDic[@(currentShowThreadPage.pageNumber.currentPageNumber)] = threadPage.originalHtml;

        LocalForumApi * localeForumApi = [[LocalForumApi alloc] init];
        [_webView loadHTMLString:html baseURL:[NSURL URLWithString:localeForumApi.currentForumBaseUrl]];

        [_webView.scrollView.mj_header endRefreshing];


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
            [_webView.layer addAnimation:stretchAnimation forKey:@"stretchAnimation"];

            CATransition *animation = [CATransition animation];
            [animation setType:kCATransitionPush];
            [animation setSubtype:kCATransitionFromBottom];
            [animation setDuration:0.5f];
            [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
            [[_webView layer] addAnimation:animation forKey:nil];
        }

    }];
}

- (void)showNextPageOrRefreshCurrentPage:(int)currentPage forThreadId:(int)threadId {

    if (currentPage < currentShowThreadPage.pageNumber.totalPageNumber) {
        [self showThread:threadId page:currentPage + 1 withAnim:YES];
    } else {
        [self.forumApi showThreadWithId:threadId andPage:currentPage handler:^(BOOL isSuccess, id message) {

            if (!isSuccess){
                [self showFailedMessage:message];
                return;
            }

            ViewThreadPage *threadPage = message;
            if (currentShowThreadPage.postList.count < threadPage.postList.count) {

                NSMutableArray *posts = threadPage.postList;

                LocalForumApi *localForumApi = [[LocalForumApi alloc] init];
                id<ForumConfigDelegate> forumConfig = [ForumApiHelper forumConfig:localForumApi.currentForumHost];

                for (NSInteger i = currentShowThreadPage.postList.count; i < posts.count; i++) {
                    Post *post = posts[(NSUInteger) i];
                    NSString *avatar = [forumConfig avatar:post.postUserInfo.userAvatar];
                    NSString *louceng = [post.postLouCeng stringWithRegular:@"\\d+"];

                    [self addPostByJSElement:post avatar:avatar louceng:louceng];

                }

                currentShowThreadPage = threadPage;
            }
            [_webView.scrollView.mj_footer endRefreshing];
        }];
    }
}

- (void)showThread:(int)threadId page:(int)page withAnim:(BOOL)anim {


    NSString *cacheHtml = pageDic[@(page)];

    [self.forumApi showThreadWithId:threadId andPage:page handler:^(BOOL isSuccess, ViewThreadPage *threadPage) {


        [ProgressDialog dismiss];
        
        if (!isSuccess){
            [self showFailedMessage:threadPage];
            return;
        }

        currentShowThreadPage = threadPage;

        [self updatePageTitle];

        NSMutableArray<Post *> *posts = threadPage.postList;

        NSString *lis = @"";

        LocalForumApi *localForumApi = [[LocalForumApi alloc] init];
        id<ForumConfigDelegate> forumConfig = [ForumApiHelper forumConfig:localForumApi.currentForumHost];

        for (Post *post in posts) {

            NSString *avatar = [forumConfig avatar:post.postUserInfo.userAvatar];
            NSString *louceng = [post.postLouCeng stringWithRegular:@"\\d+"];
            NSString *postInfo = [NSString stringWithFormat:POST_MESSAGE, post.postID, post.postID, post.postUserInfo.userName,
                    louceng, post.postUserInfo.userID, avatar, post.postUserInfo.userName, post.postLouCeng, post.postTime, post.postContent];

            lis = [lis stringByAppendingString:postInfo];

            //[self addPostByJSElement:post avatar:avatar louceng:louceng];

        }

        NSString *html = nil;

        if (page <= 1) {
            html = [NSString stringWithFormat:THREAD_PAGE, threadPage.threadTitle, lis, JS_FAST_CLICK_LIB, JS_HANDLE_CLICK];
        } else {
            html = [NSString stringWithFormat:THREAD_PAGE_NOTITLE, lis, JS_FAST_CLICK_LIB, JS_HANDLE_CLICK];
        }

        if (![cacheHtml isEqualToString:threadPage.originalHtml]) {
            pageDic[@(page)] = html;
        }
        
        LocalForumApi * localeForumApi = [[LocalForumApi alloc] init];
        [_webView loadHTMLString:html baseURL:[NSURL URLWithString:localeForumApi.currentForumBaseUrl]];

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
            [_webView.layer addAnimation:stretchAnimation forKey:@"stretchAnimation"];

            CATransition *animation = [CATransition animation];
            [animation setType:kCATransitionPush];
            [animation setSubtype:kCATransitionFromTop];
            [animation setDuration:0.5f];
            [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
            [[_webView layer] addAnimation:animation forKey:nil];
        }

        [_webView.scrollView.mj_footer endRefreshing];

    }];
}

- (void)addPostByJSElement:(Post *)post avatar:(NSString *)avatar louceng:(NSString *)louceng {
    NSString *pattern = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"append_post" ofType:@"js"] encoding:NSUTF8StringEncoding error:nil];
    NSString *contentPattern = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"append_post_content" ofType:@"html"] encoding:NSUTF8StringEncoding error:nil];
    NSString *content = [NSString stringWithFormat:contentPattern, post.postUserInfo.userID, avatar, post.postUserInfo.userName, post.postLouCeng, post.postTime, post.postContent];
    NSString *deleteEnter = [content stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    NSString *deleteT = [deleteEnter stringByReplacingOccurrencesOfString:@"\t" withString:@""];
    NSString *deleteR = [deleteT stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    NSString *deleteLine = [deleteR stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];


    NSString *js = [NSString stringWithFormat:pattern, post.postID, post.postID, post.postUserInfo.userName, louceng, deleteLine];

//    [_webView stringByEvaluatingJavaScriptFromString:js];

    [_webView evaluateJavaScript:js completionHandler:nil];
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

                TransBundle *bundle = [[TransBundle alloc] init];
                [bundle putIntValue:postId forKey:@"POST_ID"];
                [bundle putStringValue:userName forKey:@"POST_USER"];

                [self presentViewController:simpleReplyController withBundle:bundle forRootController:YES animated:YES completion:^{

                }];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    if (shouldScrollEnd) {
        NSInteger height = [[webView stringByEvaluatingJavaScriptFromString:@"document.body.offsetHeight;"] intValue];
        NSString *javascript = [NSString stringWithFormat:@"window.scrollBy(0, %ld);", (long) height];
        [webView stringByEvaluatingJavaScriptFromString:javascript];
        shouldScrollEnd = NO;
    }

}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {

    //NSString *urlString = [[request URL] absoluteString];




    if (navigationType == UIWebViewNavigationTypeLinkClicked && ([request.URL.scheme isEqualToString:@"http"] || [request.URL.scheme isEqualToString:@"https"])) {


        if ([self.forumApi openUrlByClient:self request:request]){
            return NO;
        } else {
            [[UIApplication sharedApplication] openURL:request.URL];

            return NO;
        }
    }
    return YES;
}

- (void)showChangePageActionSheet:(UIBarButtonItem *)sender {

    if (currentShowThreadPage.pageNumber.totalPageNumber <= 1){
        return;
    }

    NSMutableArray<NSString *> *pages = [NSMutableArray array];
    for (int i = 0; i < currentShowThreadPage.pageNumber.totalPageNumber; i++) {
        NSString *page = [NSString stringWithFormat:@"第 %d 页", i + 1];
        [pages addObject:page];
    }


    ActionSheetStringPicker *picker = [[ActionSheetStringPicker alloc] initWithTitle:@"选择页面" rows:pages initialSelection:currentShowThreadPage.pageNumber.currentPageNumber - 1 doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {

        int selectPage = (int) selectedIndex + 1;

        if (selectPage != currentShowThreadPage.pageNumber.currentPageNumber) {

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

    LocalForumApi *localForumApi = [[LocalForumApi alloc] init];
    id<ForumConfigDelegate> forumConfig = [ForumApiHelper forumConfig:localForumApi.currentForumHost];

    itemActionSheet = [LCActionSheet sheetWithTitle:nil cancelButtonTitle:nil clicked:^(LCActionSheet * _Nonnull actionSheet, NSInteger buttonIndex) {
        if (buttonIndex == 1) {
            // 复制贴链接
            UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
            
            pasteboard.string = [forumConfig showThreadWithThreadId:[NSString stringWithFormat:@"%d", threadID] withPage:0];

            [ProgressDialog showSuccess:@"复制成功"];
            
        } else if (buttonIndex == 2) {
            // 在浏览器种查看
            NSURL *url = [NSURL URLWithString:[forumConfig showThreadWithThreadId:[NSString stringWithFormat:@"%d", threadID] withPage:1]];
            [[UIApplication sharedApplication] openURL:url];
        } else if (buttonIndex == 3) {
            [self reportThreadPost:nil userName:nil];
        }
        
    } otherButtonTitleArray:@[@"复制帖子链接", @"在浏览器中查看", @"举报此主题"]];

    [itemActionSheet show];
}

- (IBAction)reply:(id)sender {

    UIStoryboard *storyBoard = [UIStoryboard mainStoryboard];
    UINavigationController *controller = [storyBoard instantiateViewControllerWithIdentifier:@"SeniorReplySomeOne"];

    TransBundle *bundle = [[TransBundle alloc] init];
    [bundle putIntValue:currentShowThreadPage.forumId forKey:@"FORM_ID"];
    [bundle putIntValue:threadID forKey:@"THREAD_ID"];
    [bundle putIntValue:-1 forKey:@"POST_ID"];

    NSString *token = currentShowThreadPage.securityToken;
    [bundle putStringValue:token forKey:@"SECURITY_TOKEN"];
    [bundle putStringValue:threadAuthorName forKey:@"POST_USER"];
    [bundle putObjectValue:currentShowThreadPage forKey:@"QUICK_REPLY_THREAD"];

    [self presentViewController:controller withBundle:bundle forRootController:YES animated:YES completion:^{

    }];
}
- (IBAction)firstPage:(id)sender {
    if (1 == currentShowThreadPage.pageNumber.currentPageNumber){
        [_webView.scrollView.mj_header beginRefreshing];
        return;
    }

    [ProgressDialog showStatus:@"正在切换"];
    [self showThread:threadID page:1 withAnim:YES];
}

- (IBAction)lastPage:(id)sender {
    if (currentShowThreadPage.pageNumber.totalPageNumber == currentShowThreadPage.pageNumber.currentPageNumber){
        [_webView.scrollView.mj_footer beginRefreshing];
        return;
    }
    [ProgressDialog showStatus:@"正在切换"];
    [self showThread:threadID page:currentShowThreadPage.pageNumber.totalPageNumber withAnim:YES];
}

- (IBAction)previousPage:(id)sender {
    [_webView.scrollView.mj_header beginRefreshing];
}

- (IBAction)nextPage:(id)sender {
    [_webView.scrollView.mj_footer beginRefreshing];
}

+ (NYTPhotoViewerArrayDataSource *)newTimesBuildingDataSource:(NSArray *)images {
    NSMutableArray *photos = [NSMutableArray array];
    
    for (UIImage * image in images) {
        NYTExamplePhoto *photo = [[NYTExamplePhoto alloc] init];
        photo.attributedCaptionTitle = [[NSAttributedString alloc] initWithString:@"1" attributes:nil];
        photo.image = image;
        [photos addObject:photo];
    }
    
    return [NYTPhotoViewerArrayDataSource dataSourceWithPhotos:photos];
}
@end
