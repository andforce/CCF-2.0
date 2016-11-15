//
//  ForumWebViewController.m
//  CCF
//
//  Created by 迪远 王 on 16/5/26.
//  Copyright © 2016年 andforce. All rights reserved.
//

#import "ForumWebViewController.h"
#import <MJRefresh.h>
#import "SDImageCache+URLCache.h"

#import <NYTPhotosViewController.h>
#import <NYTPhotoViewer/NYTPhoto.h>
#import "NYTExamplePhoto.h"
#import "LCActionSheet.h"

#import "SVProgressHUD.h"
#import "UIStoryboard+CCF.h"
#import "ActionSheetPicker.h"
#import "ForumReplyNavigationController.h"
#import "NSString+Extensions.h"
#import "ForumUserProfileTableViewController.h"
#import "ForumConfig.h"

#import "TransBundleDelegate.h"

@interface ForumWebViewController () <UIWebViewDelegate, UIScrollViewDelegate, TransBundleDelegate, CAAnimationDelegate> {

    LCActionSheet *itemActionSheet;

    ShowThreadPage *currentShowThreadPage;

    NSMutableDictionary *pageDic;

    int threadID;
    NSString *threadAuthorName;

    int p;

    BOOL shouldScrollEnd;
}

@end

@implementation ForumWebViewController

- (void)transBundle:(TransBundle *)bundle {

    if ([bundle containsKey:@"Senior_Reply_Callback"]) {
        ShowThreadPage *threadPage = [bundle getObjectValue:@"Senior_Reply_Callback"];

        currentShowThreadPage = threadPage;


        NSString *title = [NSString stringWithFormat:@"%lu/%lu", (unsigned long) currentShowThreadPage.currentPage, (unsigned long) currentShowThreadPage.totalPageCount];
        self.pageNumber.title = title;

        NSMutableArray<Post *> *posts = threadPage.dataList;

        NSString *lis = @"";

        for (Post *post in posts) {

            NSString *avatar = BBS_AVATAR(post.postUserInfo.userAvatar);
            NSString *louceng = [post.postLouCeng stringWithRegular:@"\\d+"];
            NSString *postInfo = [NSString stringWithFormat:POST_MESSAGE, post.postID, post.postID, post.postUserInfo.userName, louceng, post.postUserInfo.userID, avatar, post.postUserInfo.userName, post.postLouCeng, post.postTime, post.postContent];

            lis = [lis stringByAppendingString:postInfo];

            //[self addPostByJSElement:post avatar:avatar louceng:louceng];

        }

        NSString *html = nil;

        if (threadPage.currentPage <= 1) {
            html = [NSString stringWithFormat:THREAD_PAGE, threadPage.threadTitle, lis];
        } else {
            html = [NSString stringWithFormat:THREAD_PAGE_NOTITLE, lis];
        }

        NSString *cacheHtml = pageDic[@(currentShowThreadPage.currentPage)];
        if (![cacheHtml isEqualToString:threadPage.originalHtml]) {
            [self.webView loadHTMLString:html baseURL:[NSURL URLWithString:BBS_URL]];
            pageDic[@(currentShowThreadPage.currentPage)] = html;
        }

        shouldScrollEnd = YES;

    } else if ([bundle containsKey:@"Simple_Reply_Callback"]) {
        ShowThreadPage *threadPage = [bundle getObjectValue:@"Simple_Reply_Callback"];

        currentShowThreadPage = threadPage;


        NSString *title = [NSString stringWithFormat:@"%lu/%lu", (unsigned long) currentShowThreadPage.currentPage, (unsigned long) currentShowThreadPage.totalPageCount];
        self.pageNumber.title = title;

        NSMutableArray<Post *> *posts = threadPage.dataList;

        NSString *lis = @"";

        for (Post *post in posts) {

            NSString *avatar = BBS_AVATAR(post.postUserInfo.userAvatar);
            NSString *louceng = [post.postLouCeng stringWithRegular:@"\\d+"];
            NSString *postInfo = [NSString stringWithFormat:POST_MESSAGE, post.postID, post.postID, post.postUserInfo.userName, louceng, post.postUserInfo.userID, avatar, post.postUserInfo.userName, post.postLouCeng, post.postTime, post.postContent];

            lis = [lis stringByAppendingString:postInfo];

            //[self addPostByJSElement:post avatar:avatar louceng:louceng];

        }

        NSString *html = nil;

        if (threadPage.currentPage <= 1) {
            html = [NSString stringWithFormat:THREAD_PAGE, threadPage.threadTitle, lis];
        } else {
            html = [NSString stringWithFormat:THREAD_PAGE_NOTITLE, lis];
        }

        NSString *cacheHtml = pageDic[@(currentShowThreadPage.currentPage)];
        if (![cacheHtml isEqualToString:threadPage.originalHtml]) {
            [self.webView loadHTMLString:html baseURL:[NSURL URLWithString:BBS_URL]];
            pageDic[@(currentShowThreadPage.currentPage)] = html;
        }

        shouldScrollEnd = YES;
    } else {
        threadID = [bundle getIntValue:@"threadID"];
        p = [bundle getIntValue:@"p"];

        threadAuthorName = [bundle getStringValue:@"threadAuthorName"];

    }
}


- (void)viewDidLoad {
    [super viewDidLoad];

    pageDic = [NSMutableDictionary dictionary];

    [self.webView setScalesPageToFit:YES];
    self.webView.dataDetectorTypes = UIDataDetectorTypeNone;
    self.webView.scrollView.decelerationRate = UIScrollViewDecelerationRateNormal;
    self.webView.delegate = self;
    self.webView.backgroundColor = [UIColor whiteColor];

    for (UIView *view in [[[self.webView subviews] objectAtIndex:0] subviews]) {
        if ([view isKindOfClass:[UIImageView class]]) {
            view.hidden = YES;
        }
    }
    [self.webView setOpaque:NO];

    // scrollView
    self.webView.scrollView.delegate = self;

    self.webView.scrollView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{

        if (threadID == -1) {
            [self showThreadWithP:[NSString stringWithFormat:@"%d", p]];
        } else {
            if (currentShowThreadPage == nil) {
                [self prePage:threadID page:1 withAnim:NO];
            } else if (currentShowThreadPage.currentPage == 1) {
                [self prePage:threadID page:1 withAnim:NO];
            } else {
                int page = currentShowThreadPage.currentPage - 1;
                if (page <= 1) {
                    page = 1;
                }
                [self prePage:threadID page:page withAnim:YES];
            }
        }
    }];


    self.webView.scrollView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{

        // 当前页面 == 页面的最大数，只刷新当前页面就可以了

        [self showNextPageOrRefreshCurrentPage:currentShowThreadPage.currentPage forThreadId:threadID];

    }];

    [self.webView.scrollView.mj_header beginRefreshing];
}

-(void) showFailedMessage:(id) message{
    [self.webView.scrollView.mj_header endRefreshing];

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"错误" message:message preferredStyle:UIAlertControllerStyleAlert];


    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self.navigationController popViewControllerAnimated:YES];
    }];

    [alert addAction:cancel];

    [self presentViewController:alert animated:YES completion:^{

    }];
}

- (void)showThreadWithP:(NSString *)pID {
    [self.ccfForumApi showThreadWithP:pID handler:^(BOOL isSuccess, id message) {

        if (!isSuccess){
            [self showFailedMessage:message];
            return;
        }

        ShowThreadPage *threadPage = message;
        currentShowThreadPage = threadPage;
        threadID = [threadPage.threadID intValue];

        NSString *title = [NSString stringWithFormat:@"%d/%d", currentShowThreadPage.currentPage, currentShowThreadPage.totalPageCount];
        self.pageNumber.title = title;

        NSMutableArray<Post *> *posts = threadPage.dataList;


        NSString *lis = @"";

        for (Post *post in posts) {
            NSString *avatar = BBS_AVATAR(post.postUserInfo.userAvatar);
            NSString *louceng = [post.postLouCeng stringWithRegular:@"\\d+"];
            NSString *postInfo = [NSString stringWithFormat:POST_MESSAGE, post.postID, post.postID, post.postUserInfo.userName, louceng, post.postUserInfo.userID, avatar, post.postUserInfo.userName, post.postLouCeng, post.postTime, post.postContent];
            lis = [lis stringByAppendingString:postInfo];
        }

        NSString *html = [NSString stringWithFormat:THREAD_PAGE, threadPage.threadTitle, lis];


        // 缓存当前页面
        pageDic[@(currentShowThreadPage.currentPage)] = threadPage.originalHtml;

        [self.webView loadHTMLString:html baseURL:[NSURL URLWithString:BBS_URL]];

        [self.webView.scrollView.mj_header endRefreshing];


        CABasicAnimation *stretchAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale.y"];
        [stretchAnimation setToValue:@1.02F];
        [stretchAnimation setRemovedOnCompletion:YES];
        [stretchAnimation setFillMode:kCAFillModeRemoved];
        [stretchAnimation setAutoreverses:YES];
        [stretchAnimation setDuration:0.15];
        [stretchAnimation setDelegate:self];
        [stretchAnimation setBeginTime:CACurrentMediaTime() + 0.35];
        [stretchAnimation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
        [self.view.layer addAnimation:stretchAnimation forKey:@"stretchAnimation"];
        CATransition *animation = [CATransition animation];
        [animation setType:kCATransitionPush];
        [animation setSubtype:kCATransitionFromBottom];
        [animation setDuration:0.5f];
        [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
        [[self.webView layer] addAnimation:animation forKey:nil];
    }];
}

- (void)prePage:(int)threadId page:(int)page withAnim:(BOOL)anim {


    [self.ccfForumApi showThreadWithId:threadId andPage:page handler:^(BOOL isSuccess, id message) {

        if (!isSuccess){
            [self showFailedMessage:message];
            return;
        }

        ShowThreadPage *threadPage = message;

        if (threadPage.threadTitle == nil) {

            [self.webView.scrollView.mj_header endRefreshing];

            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"错误" message:@"\n此帖包含乱码无法正确解析，使用浏览器打开？" preferredStyle:UIAlertControllerStyleAlert];

            UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                [self.navigationController popViewControllerAnimated:YES];
                NSURL *nsurl = [NSURL URLWithString:BBS_SHOWTHREAD_PAGE(threadId, page)];
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


        NSString *title = [NSString stringWithFormat:@"%lu/%lu", (unsigned long) currentShowThreadPage.currentPage, (unsigned long) currentShowThreadPage.totalPageCount];
        self.pageNumber.title = title;

        NSMutableArray<Post *> *posts = threadPage.dataList;


        NSString *lis = @"";

        for (Post *post in posts) {
            NSString *avatar = BBS_AVATAR(post.postUserInfo.userAvatar);
            NSString *louceng = [post.postLouCeng stringWithRegular:@"\\d+"];
            NSString *postInfo = [NSString stringWithFormat:POST_MESSAGE, post.postID, post.postID, post.postUserInfo.userName, louceng, post.postUserInfo.userID, avatar, post.postUserInfo.userName, post.postLouCeng, post.postTime, post.postContent];
            lis = [lis stringByAppendingString:postInfo];
        }

        NSString *html = nil;

        if (page <= 1) {
            html = [NSString stringWithFormat:THREAD_PAGE, threadPage.threadTitle, lis];
        } else {
            html = [NSString stringWithFormat:THREAD_PAGE_NOTITLE, lis];
        }


        pageDic[@(currentShowThreadPage.currentPage)] = threadPage.originalHtml;

        [self.webView loadHTMLString:html baseURL:[NSURL URLWithString:BBS_URL]];

        [self.webView.scrollView.mj_header endRefreshing];


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
            //[self.webView setAnchorPoint:CGPointMake(0.0, 1) forView:self.webView];
            [self.view.layer addAnimation:stretchAnimation forKey:@"stretchAnimation"];

            CATransition *animation = [CATransition animation];
            [animation setType:kCATransitionPush];
            [animation setSubtype:kCATransitionFromBottom];
            [animation setDuration:0.5f];
            [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
            [[self.webView layer] addAnimation:animation forKey:nil];
        }

    }];
}

- (void)showNextPageOrRefreshCurrentPage:(NSUInteger)currentPage forThreadId:(int)threadId {

    if (currentPage < currentShowThreadPage.totalPageCount) {
        [self showThread:threadId page:currentPage + 1 withAnim:YES];
    } else {
        [self.ccfForumApi showThreadWithId:threadId andPage:currentPage handler:^(BOOL isSuccess, id message) {

            if (!isSuccess){
                [self showFailedMessage:message];
                return;
            }

            ShowThreadPage *threadPage = message;
            if (currentShowThreadPage.dataList.count < threadPage.dataList.count) {

                NSMutableArray *posts = threadPage.dataList;

                for (int i = currentShowThreadPage.dataList.count; i < posts.count; i++) {
                    Post *post = posts[i];
                    NSString *avatar = BBS_AVATAR(post.postUserInfo.userAvatar);
                    NSString *louceng = [post.postLouCeng stringWithRegular:@"\\d+"];

                    [self addPostByJSElement:post avatar:avatar louceng:louceng];

                }

                currentShowThreadPage = threadPage;
            }
            [self.webView.scrollView.mj_footer endRefreshing];
        }];
    }
}

- (void)showThread:(int)threadId page:(int)page withAnim:(BOOL)anim {


    NSString *cacheHtml = pageDic[@(page)];

    [self.ccfForumApi showThreadWithId:threadId andPage:page handler:^(BOOL isSuccess, id message) {

        
        [SVProgressHUD dismiss];
        
        if (!isSuccess){
            [self showFailedMessage:message];
            return;
        }

        ShowThreadPage *threadPage = message;

        currentShowThreadPage = threadPage;


        NSString *title = [NSString stringWithFormat:@"%lu/%lu", (unsigned long)currentShowThreadPage.currentPage, (unsigned long)currentShowThreadPage.totalPageCount];
        self.pageNumber.title = title;

        NSMutableArray<Post *> *posts = threadPage.dataList;

        NSString *lis = @"";

        for (Post *post in posts) {

            NSString *avatar = BBS_AVATAR(post.postUserInfo.userAvatar);
            NSString *louceng = [post.postLouCeng stringWithRegular:@"\\d+"];
            NSString *postInfo = [NSString stringWithFormat:POST_MESSAGE, post.postID, post.postID, post.postUserInfo.userName, louceng, post.postUserInfo.userID, avatar, post.postUserInfo.userName, post.postLouCeng, post.postTime, post.postContent];

            lis = [lis stringByAppendingString:postInfo];

            //[self addPostByJSElement:post avatar:avatar louceng:louceng];

        }

        NSString *html = nil;

        if (page <= 1) {
            html = [NSString stringWithFormat:THREAD_PAGE, threadPage.threadTitle, lis];
        } else {
            html = [NSString stringWithFormat:THREAD_PAGE_NOTITLE, lis];
        }

        if (![cacheHtml isEqualToString:threadPage.originalHtml]) {
            [self.webView loadHTMLString:html baseURL:[NSURL URLWithString:BBS_URL]];
            pageDic[@(page)] = html;
        }

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
            //[self.webView setAnchorPoint:CGPointMake(0.0, 1) forView:self.webView];
            [self.view.layer addAnimation:stretchAnimation forKey:@"stretchAnimation"];

            CATransition *animation = [CATransition animation];
            [animation setType:kCATransitionPush];
            [animation setSubtype:kCATransitionFromTop];
            [animation setDuration:0.5f];
            [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
            [[self.webView layer] addAnimation:animation forKey:nil];
        }

        [self.webView.scrollView.mj_footer endRefreshing];

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

    [self.webView stringByEvaluatingJavaScriptFromString:js];
}

- (void)showMoreAction {

//    itemActionSheet = [LCActionSheet sheetWithTitle:nil cancelButtonTitle:nil clicked:^(LCActionSheet *actionSheet, NSInteger buttonIndex) {
//
//    } otherButtonTitles:@"复制帖子链接", @"在浏览器中查看",@"高级回帖" , nil];

    itemActionSheet = [LCActionSheet sheetWithTitle:nil buttonTitles:@[@"复制帖子链接", @"在浏览器中查看", @"高级回帖"] redButtonIndex:2 clicked:^(NSInteger buttonIndex) {


    }];

    [itemActionSheet show];
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
            NSString *key = [[kvPair objectAtIndex:0] stringByReplacingPercentEscapesUsingEncoding:encoding];
            NSString *value = [[kvPair objectAtIndex:1] stringByReplacingPercentEscapesUsingEncoding:encoding];
            [pairs setObject:value forKey:key];
        }
    }

    return [NSDictionary dictionaryWithDictionary:pairs];
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

    NSString *urlString = [[request URL] absoluteString];

    if ([request.URL.scheme isEqualToString:@"postid"]) {
        NSDictionary *query = [self dictionaryFromQuery:request.URL.query usingEncoding:NSUTF8StringEncoding];

        NSString *userName = [[query valueForKey:@"postuser"] replaceUnicode];
        int postId = [[query valueForKey:@"postid"] intValue];
        NSString *louCeng = [query valueForKey:@"postlouceng"];

        itemActionSheet = [LCActionSheet sheetWithTitle:userName buttonTitles:@[@"快速回复", @"高级回复", @"复制链接", @"举报此帖"] redButtonIndex:-1 clicked:^(NSInteger buttonIndex) {
            if (buttonIndex == 0) {
                UIStoryboard *storyboard = [UIStoryboard mainStoryboard];

                ForumReplyNavigationController *simpleReplyController = [storyboard instantiateViewControllerWithIdentifier:@"QuickReplySomeOne"];

                TransBundle *bundle = [[TransBundle alloc] init];

                [bundle putIntValue:threadID forKey:@"THREAD_ID"];
                [bundle putIntValue:postId forKey:@"POST_ID"];

                NSString *token = currentShowThreadPage.securityToken;
                [bundle putStringValue:token forKey:@"SECYRITY_TOKEN"];
                [bundle putStringValue:currentShowThreadPage.ajaxLastPost forKey:@"AJAX_LAST_POST"];
                [bundle putStringValue:userName forKey:@"POST_USER"];

                [self presentViewController:simpleReplyController withBundle:bundle forRootController:YES animated:YES completion:^{

                }];

            } else if (buttonIndex == 1) {

                UIStoryboard *storyBoard = [UIStoryboard mainStoryboard];

                ForumReplyNavigationController *controller = [storyBoard instantiateViewControllerWithIdentifier:@"SeniorReplySomeOne"];


                TransBundle *bundle = [[TransBundle alloc] init];

                [bundle putIntValue:threadID forKey:@"THREAD_ID"];


                [bundle putIntValue:postId forKey:@"POST_ID"];

                NSString *token = currentShowThreadPage.securityToken;


                [bundle putStringValue:token forKey:@"SECYRITY_TOKEN"];

                [bundle putStringValue:currentShowThreadPage.ajaxLastPost forKey:@"AJAX_LAST_POST"];

                [bundle putStringValue:userName forKey:@"USER_NAME"];

                [self presentViewController:controller withBundle:bundle forRootController:YES animated:YES completion:^{

                }];

            } else if (buttonIndex == 2) {
                NSString *postUrl = BBS_SHOWTHREAD_POSTCOUNT(postId, louCeng);
                UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
                pasteboard.string = postUrl;
                [SVProgressHUD showSuccessWithStatus:@"复制成功" maskType:SVProgressHUDMaskTypeBlack];
            } else if (buttonIndex == 3){
                UIStoryboard *storyboard = [UIStoryboard mainStoryboard];

                UINavigationController *simpleReplyController = [storyboard instantiateViewControllerWithIdentifier:@"ReportThreadPost"];

                TransBundle *bundle = [[TransBundle alloc] init];
                [bundle putIntValue:postId forKey:@"POST_ID"];
                [bundle putStringValue:userName forKey:@"POST_USER"];

                [self presentViewController:simpleReplyController withBundle:bundle forRootController:YES animated:YES completion:^{

                }];
            }
        }];

        [itemActionSheet show];
        return NO;

    }

    if ([request.URL.scheme isEqualToString:@"image"]) {

        NSString *absUrl = request.URL.absoluteString;


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

        NSMutableArray *array = [NSMutableArray array];

        NYTExamplePhoto *photo1 = [[NYTExamplePhoto alloc] init];

        photo1.attributedCaptionTitle = [[NSAttributedString alloc] initWithString:@"1" attributes:nil];
        photo1.image = memCachedImage;
        [array addObject:photo1];
        NYTPhotosViewController *photosViewController = [[NYTPhotosViewController alloc] initWithPhotos:array];
        [self presentViewController:photosViewController animated:YES completion:nil];

        return NO;
    }

    if ([request.URL.scheme isEqualToString:@"avatar"]) {
        NSDictionary *query = [self dictionaryFromQuery:request.URL.query usingEncoding:NSUTF8StringEncoding];

        NSString *userid = [query valueForKey:@"userid"];


        UIStoryboard *storyboard = [UIStoryboard mainStoryboard];
        ForumUserProfileTableViewController *showThreadController = [storyboard instantiateViewControllerWithIdentifier:@"ShowUserProfile"];

        TransBundle *bundle = [[TransBundle alloc] init];
        [bundle putIntValue:[userid intValue] forKey:@"UserId"];
        [self transBundle:bundle forController:showThreadController];

        [self.navigationController pushViewController:showThreadController animated:YES];

        return NO;
    }

    if (navigationType == UIWebViewNavigationTypeLinkClicked && ([request.URL.scheme isEqualToString:@"http"] || [request.URL.scheme isEqualToString:@"https"])) {


        NSString *path = request.URL.path;
        if ([path rangeOfString:@"showthread.php"].location != NSNotFound) {
            // 显示帖子
            NSDictionary *query = [self dictionaryFromQuery:request.URL.query usingEncoding:NSUTF8StringEncoding];

            NSString *threadIdStr = [query valueForKey:@"t"];


            UIStoryboard *storyboard = [UIStoryboard mainStoryboard];
            ForumWebViewController *showThreadController = [storyboard instantiateViewControllerWithIdentifier:@"ShowThreadDetail"];

            TransBundle *bundle = [[TransBundle alloc] init];
            [bundle putIntValue:[threadIdStr intValue] forKey:@"threadID"];

            [self transBundle:bundle forController:showThreadController];

            [self.navigationController pushViewController:showThreadController animated:YES];

            return NO;
        } else {
            [[UIApplication sharedApplication] openURL:request.URL];

            return NO;
        }
    }
    return YES;
}

- (void)showChangePageActionSheet:(UIBarButtonItem *)sender {
    NSMutableArray<NSString *> *pages = [NSMutableArray array];
    for (int i = 0; i < currentShowThreadPage.totalPageCount; i++) {
        NSString *page = [NSString stringWithFormat:@"第 %d 页", i + 1];
        [pages addObject:page];
    }


    ActionSheetStringPicker *picker = [[ActionSheetStringPicker alloc] initWithTitle:@"选择页面" rows:pages initialSelection:currentShowThreadPage.currentPage - 1 doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {

        int selectPage = (int) selectedIndex + 1;

        if (selectPage != currentShowThreadPage.currentPage) {

            [SVProgressHUD showWithStatus:@"正在切换" maskType:SVProgressHUDMaskTypeBlack];
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



//    NSString * currentHtml = [self.webView stringByEvaluatingJavaScriptFromString:@"document.getElementById('list').innerHTML;"];
//
//    [self.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"document.getElementById('list').innerHTML +='%@';", @"<li class=\"post-title\">\n            <div class=\"title\">\n\t 9999999 \n</div>\n        </li>"]];



//    NSString *injectSrc = @"var i = document.createElement('div'); i.innerHTML = '%@';document.documentElement.appendChild(i);";
//    NSString *runToInject = [NSString stringWithFormat:injectSrc, @"Hello World"];
//    [self.webView stringByEvaluatingJavaScriptFromString:runToInject];
}

- (IBAction)changeNumber:(id)sender {
    [self showChangePageActionSheet:sender];

}

- (IBAction)showMoreAction:(UIBarButtonItem *)sender {

    itemActionSheet = [LCActionSheet sheetWithTitle:nil buttonTitles:@[@"复制帖子链接", @"在浏览器中查看", @"高级回帖"] redButtonIndex:4 clicked:^(NSInteger buttonIndex) {
        if (buttonIndex == 0) {
            // 复制贴链接
            UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
            pasteboard.string = BBS_SHOWTHREAD_PAGE(threadID, 0);

            [SVProgressHUD showSuccessWithStatus:@"复制成功" maskType:SVProgressHUDMaskTypeBlack];

        } else if (buttonIndex == 1) {
            // 在浏览器种查看
            NSURL *url = [NSURL URLWithString:BBS_SHOWTHREAD_PAGE(threadID, 1)];
            [[UIApplication sharedApplication] openURL:url];
        } else if (buttonIndex == 2) {
            [self reply:self];

        }
    }];

    [itemActionSheet show];
}

- (IBAction)reply:(id)sender {

    UIStoryboard *storyBoard = [UIStoryboard mainStoryboard];
    ForumReplyNavigationController *controller = [storyBoard instantiateViewControllerWithIdentifier:@"SeniorReplySomeOne"];

    TransBundle *bundle = [[TransBundle alloc] init];
    [bundle putIntValue:threadID forKey:@"THREAD_ID"];
    NSString *token = currentShowThreadPage.securityToken;
    [bundle putStringValue:token forKey:@"SECYRITY_TOKEN"];
    [bundle putStringValue:threadAuthorName forKey:@"POST_USER"];
    [bundle putStringValue:currentShowThreadPage.formId forKey:@"FORM_ID"];

    [self presentViewController:controller withBundle:bundle forRootController:YES animated:YES completion:^{

    }];
}
@end
