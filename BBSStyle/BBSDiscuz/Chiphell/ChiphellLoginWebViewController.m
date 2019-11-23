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
#import "AssertReader.h"

#define LOG_IN_URL @"https://www.chiphell.com/member.php?mod=logging&action=login&mobile=no&referer=https://www.chiphell.com/forum.php"

@interface ChiphellLoginWebViewController () <WKNavigationDelegate> {

}

@end

@implementation ChiphellLoginWebViewController {

    NSString *REFERER;

}

- (void)viewDidLoad {
//    NSString *oldAgent = [self.webView stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"];
//    NSLog(@"old agent :%@", oldAgent);
//
//    //add my info to the new agent
//    NSString *newAgent = @"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_13_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/67.0.3396.99 Safari/537.36";
//    NSLog(@"new agent :%@", newAgent);
//
//    //regist the new agent
//    NSDictionary *dictionary = @{@"UserAgent": newAgent};
//    [[NSUserDefaults standardUserDefaults] registerDefaults:dictionary];


    self.webView.scrollView.decelerationRate = UIScrollViewDecelerationRateNormal;
    self.webView.navigationDelegate = self;
    self.webView.backgroundColor = [UIColor whiteColor];

    [self.webView setOpaque:NO];

    REFERER = [LOG_IN_URL stringWithRegular:@"(?<=referer=).*"];
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:LOG_IN_URL]]];

    if ([self isNeedHideLeftMenu]) {
        self.navigationItem.leftBarButtonItem = nil;
    }
}

- (BOOL)isNeedHideLeftMenu {
    BBSLocalApi *localForumApi = [[BBSLocalApi alloc] init];
    NSString *bundleId = [localForumApi bundleIdentifier];
    return ![bundleId isEqualToString:@"com.andforce.forums"];
}

- (void)getResponseHTML:(WKWebView *)webView handle:(void (^)(NSString *html))success{
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
        NSString *js = [AssertReader js_chiphell_login];
        [webView evaluateJavaScript:js completionHandler:nil];

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

- (IBAction)cancelLogin:(id)sender {

    BBSLocalApi *localForumApi = [[BBSLocalApi alloc] init];
    NSString *bundleId = [localForumApi bundleIdentifier];
    if ([bundleId isEqualToString:@"com.andforce.forums"]) {
        [localForumApi clearCurrentForumURL];
        [[UIStoryboard mainStoryboard] changeRootViewControllerTo:@"ShowSupportForums" withAnim:UIViewAnimationOptionTransitionFlipFromTop];
    }
}

@end
