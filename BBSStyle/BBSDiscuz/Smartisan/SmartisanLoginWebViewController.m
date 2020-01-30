//
//  SmartisanLoginWebViewController.m
//  Created by Diyuan Wang on 2019/11/21.
//  Copyright © 2019年 Diyuan Wang. All rights reserved.
//

#import "SmartisanLoginWebViewController.h"
#import "ForumEntry+CoreDataClass.h"
#import "BBSCoreDataManager.h"
#import "UIStoryboard+Forum.h"
#import "BBSLocalApi.h"

#import "AssertReader.h"

#import "Forum.pch"

@interface SmartisanLoginWebViewController () <WKNavigationDelegate>

@end

@implementation SmartisanLoginWebViewController

- (void)viewDidLoad {
    self.webView.scrollView.decelerationRate = UIScrollViewDecelerationRateNormal;
    self.webView.navigationDelegate = self;

    self.webView.backgroundColor = [UIColor whiteColor];
    [self.webView setOpaque:NO];

    NSDictionary *dictionary = @{@"UserAgent": ForumUserAgent};
    [[NSUserDefaults standardUserDefaults] registerDefaults:dictionary];

    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"https://account.smartisan.com/#/v2/login?return_url=http:%2F%2Fbbs.smartisan.com%2Fforum.php"]]];

    if ([self isNeedHideLeftMenu]) {
        self.navigationItem.leftBarButtonItem = nil;
    }
}

- (BOOL)isNeedHideLeftMenu {
    BBSLocalApi *localForumApi = [[BBSLocalApi alloc] init];
    NSString *bundleId = [localForumApi bundleIdentifier];
    return NO;
}

// private
- (void)saveUserName:(NSString *)name {
    BBSLocalApi *localForumApi = [[BBSLocalApi alloc] init];
    id <BBSConfigDelegate> config = [BBSApiHelper forumConfig:localForumApi.currentForumHost];
    [localForumApi saveUserName:name forHost:config.forumURL.host];
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
    NSLog(@"TForumLogin.webViewDidFinishLoad->%@", currentURL);

    // 使用JS注入获取用户输入的密码
    [webView evaluateJavaScript:@"document.getElementsByName('pwuser')[0].value" completionHandler:^(id o, NSError *error) {
        NSString *userName = o;

        NSLog(@"TForumLogin.userName->%@", userName);
        if (userName != nil && ![userName isEqualToString:@""]) {
            // 保存用户名
            [self saveUserName:userName];
        }
    }];

    // 改变样式
    NSString *js = [AssertReader js_change_web_login_style];

    [webView evaluateJavaScript:js completionHandler:nil];

    [self performSelector:@selector(hideMaskView) withObject:nil/*可传任意类型参数*/ afterDelay:1.0];
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    NSString *rUrl = navigationAction.request.URL.absoluteString;
    if ([rUrl isEqualToString:@"http://bbs.smartisan.com/forum.php"]) {
        BBSLocalApi *localForumApi = [[BBSLocalApi alloc] init];

        // 保存Cookie
        [localForumApi saveCookie];

        NSLog(@"TForumLogin.loadCookies: %@", [localForumApi loadCookieString]);

        [self.forumApi fetchUserInfo:^(BOOL isSuccess, NSString *userName, NSString *userId) {
            if (isSuccess) {

                [localForumApi saveUserId:userId forHost:@"bbs.smartisan.com"];
                [localForumApi saveUserName:userName forHost:@"bbs.smartisan.com"];

                [self.forumApi listAllForums:^(BOOL success, id msg) {
                    if (success) {
                        NSMutableArray<Forum *> *needInsert = msg;
                        BBSCoreDataManager *formManager = [[BBSCoreDataManager alloc] initWithEntryType:EntryTypeForm];
                        // 需要先删除之前的老数据
                        [formManager deleteData:^NSPredicate * {
                            return [NSPredicate predicateWithFormat:@"forumHost = %@", self.currentForumHost];;
                        }];


                        [formManager insertData:needInsert operation:^(NSManagedObject *target, id src) {
                            ForumEntry *newsInfo = (ForumEntry *) target;
                            newsInfo.forumId = [src valueForKey:@"forumId"];
                            newsInfo.forumName = [src valueForKey:@"forumName"];
                            newsInfo.parentForumId = [src valueForKey:@"parentForumId"];
                            BBSLocalApi *localeForumApi = [[BBSLocalApi alloc] init];
                            newsInfo.forumHost = localeForumApi.currentForumHost;

                        }];

                        UIStoryboard *stortboard = [UIStoryboard mainStoryboard];
                        [stortboard changeRootViewControllerTo:kForumTabBarControllerId];

                    }
                }];

            }
        }];

        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
    decisionHandler(WKNavigationActionPolicyAllow);
}

- (IBAction)cancelLogin:(id)sender {
    BBSLocalApi *localForumApi = [[BBSLocalApi alloc] init];

    [localForumApi clearCurrentForumURL];
    [[UIStoryboard mainStoryboard] changeRootViewControllerTo:@"ShowSupportForums" withAnim:UIViewAnimationOptionTransitionFlipFromTop];
}

@end
