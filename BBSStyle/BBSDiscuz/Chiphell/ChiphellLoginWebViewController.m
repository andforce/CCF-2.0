//
// Created by Diyuan Wang on 2019/11/12
// Copyright (c) 2017 None. All rights reserved.
//

#import "ChiphellLoginWebViewController.h"
#import "IGXMLNode+Children.h"

#import "ForumEntry+CoreDataClass.h"
#import "BBSCoreDataManager.h"
#import "NSString+Extensions.h"

#import "IGHTMLDocument+QueryNode.h"
#import "UIStoryboard+Forum.h"
#import "BBSLocalApi.h"

#import "Forum.pch"

#define LOG_IN_URL @"https://www.chiphell.com/member.php?mod=logging&action=login&mobile=no&referer=https://www.chiphell.com/forum.php"

@interface ChiphellLoginWebViewController () <WKNavigationDelegate> {

}

@end

@implementation ChiphellLoginWebViewController {

    NSString *REFERER;

}

- (void)viewDidLoad {

    self.webView.scrollView.decelerationRate = UIScrollViewDecelerationRateNormal;
    self.webView.navigationDelegate = self;
    self.webView.backgroundColor = [UIColor whiteColor];

    [self.webView setOpaque:NO];

    __weak typeof(self) weakSelf = self;
    [self.webView evaluateJavaScript:@"navigator.userAgent" completionHandler:^(id _Nullable agent, NSError *_Nullable error) {
        // 给User-Agent添加额外的信息
        weakSelf.webView.customUserAgent = ForumUserAgent;

        NSLog(@"WKNavigationDelegate evaluateJavaScript -> %@", agent);

    }];

    REFERER = [LOG_IN_URL stringWithRegular:@"(?<=referer=).*"];

    NSURL *url = [NSURL URLWithString:LOG_IN_URL];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
    [request setValue:@"" forHTTPHeaderField:@"Cookie"];
    [self.webView loadRequest:request];

    if ([self isNeedHideLeftMenu]) {
        self.navigationItem.leftBarButtonItem = nil;
    }
}

- (BOOL)isNeedHideLeftMenu {
    BBSLocalApi *localForumApi = [[BBSLocalApi alloc] init];
    NSString *bundleId = [localForumApi bundleIdentifier];
    return NO;
}

- (void)getResponseHTML:(WKWebView *)webView handle:(void (^)(NSString *html))success {
    NSString *lJs = @"document.documentElement.outerHTML";
    [webView evaluateJavaScript:lJs completionHandler:^(id o, NSError *error) {
        NSString *tmpHtml = o;
        success(tmpHtml);
    }];
}

- (void)hideMaskView {
    self.maskLoadingView.hidden = YES;
}

#pragma mark - WKNavigationDelegate

- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation {

    NSString *currentURL = webView.URL.absoluteString;

    if ([currentURL isEqualToString:LOG_IN_URL]) {
        // 改变样式
//        NSString *js = [AssertReader js_chiphell_login];
//        [webView evaluateJavaScript:js completionHandler:nil];

        [self performSelector:@selector(hideMaskView) withObject:nil/*可传任意类型参数*/ afterDelay:1.0];

    } else if ([currentURL isEqualToString:REFERER]) {

        [self getResponseHTML:webView handle:^(NSString *html) {
            NSLog(@">>>>>>>>>>>>>%@", html);

            IGHTMLDocument *document = [[IGHTMLDocument alloc] initWithHTMLString:html error:nil];

            IGXMLNode *logined = [document queryNodeWithXPath:@"//*[@id=\"um\"]/p[1]/strong"];
            NSString *userName = [[logined text] trim];

            BBSLocalApi *localForumApi = [[BBSLocalApi alloc] init];
            id <BBSConfigDelegate> forumConfig = [BBSApiHelper forumConfig:localForumApi.currentForumHost];
            if (userName != nil && ![userName isEqualToString:@""]) {
                // 保存Cookie
                [localForumApi saveCookie];
                // 保存用户名
                [localForumApi saveUserName:userName forHost:forumConfig.forumURL.host];
            }

            [self.forumApi listAllForums:^(BOOL isSuccess, id msg) {
                if (isSuccess) {
                    NSMutableArray<Forum *> *needInsert = msg;
                    BBSCoreDataManager *formManager = [[BBSCoreDataManager alloc] initWithEntryType:EntryTypeForm];
                    // 需要先删除之前的老数据
                    [formManager deleteData:^NSPredicate * {
                        return [NSPredicate predicateWithFormat:@"forumHost = %@", self.currentForumHost];;
                    }];

                    BBSLocalApi *localeForumApi = [[BBSLocalApi alloc] init];

                    [formManager insertData:needInsert operation:^(NSManagedObject *target, id src) {
                        ForumEntry *newsInfo = (ForumEntry *) target;
                        newsInfo.forumId = [src valueForKey:@"forumId"];
                        newsInfo.forumName = [src valueForKey:@"forumName"];
                        newsInfo.parentForumId = [src valueForKey:@"parentForumId"];
                        newsInfo.forumHost = localeForumApi.currentForumHost;

                    }];

                    UIStoryboard *stortboard = [UIStoryboard mainStoryboard];
                    [stortboard changeRootViewControllerTo:kForumTabBarControllerId];

                }
            }];

        }];
    }
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler {
    NSLog(@"WKNavigationDelegate -> %@", @"decidePolicyForNavigationResponse");

    // 保存Cookie
    BBSLocalApi *localForumApi = [[BBSLocalApi alloc] init];
    [localForumApi saveCookiesForResponse:(NSHTTPURLResponse *) navigationResponse.response];

    decisionHandler(WKNavigationResponsePolicyAllow);
}

- (IBAction)cancelLogin:(id)sender {

    BBSLocalApi *localForumApi = [[BBSLocalApi alloc] init];
    NSString *bundleId = [localForumApi bundleIdentifier];

    [localForumApi clearCurrentForumURL];
    [[UIStoryboard mainStoryboard] changeRootViewControllerTo:@"ShowSupportForums" withAnim:UIViewAnimationOptionTransitionFlipFromTop];
}

@end
