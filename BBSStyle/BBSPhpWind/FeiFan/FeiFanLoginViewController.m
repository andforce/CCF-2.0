//
//  CrskyLoginViewController.m
//  Created by Diyuan Wang on 2019/11/21.
//  Copyright © 2019年 Diyuan Wang. All rights reserved.
//

#import "FeiFanLoginViewController.h"
#import "ForumEntry+CoreDataClass.h"
#import "BBSCoreDataManager.h"
#import "UIStoryboard+Forum.h"
#import "BBSLocalApi.h"

#import "Forum.pch"
@interface FeiFanLoginViewController () <WKNavigationDelegate> {

}

@end

@implementation FeiFanLoginViewController


- (void)viewDidLoad {
    self.webView.scrollView.decelerationRate = UIScrollViewDecelerationRateNormal;
    self.webView.navigationDelegate = self;
    self.webView.backgroundColor = [UIColor whiteColor];
    [self.webView setOpaque:NO];

    NSDictionary *userAgent = @{@"UserAgent": ForumUserAgent};
    [[NSUserDefaults standardUserDefaults] registerDefaults:userAgent];


    __weak typeof(self) weakSelf = self;
    [self.webView evaluateJavaScript:@"navigator.userAgent" completionHandler:^(id _Nullable agent, NSError *_Nullable error) {
        NSString *oldAgent = agent;
        // 给User-Agent添加额外的信息
        weakSelf.webView.customUserAgent = ForumUserAgent;
        NSLog(@"WKNavigationDelegate evaluateJavaScript -> %@", oldAgent);

    }];



    BBSLocalApi *localForumApi = [[BBSLocalApi alloc] init];
    NSString *loginUrl = [localForumApi.currentForumURL stringByAppendingString:@"login.php"];
    NSURL *url = [NSURL URLWithString:loginUrl];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];

    [request setValue:@"" forHTTPHeaderField:@"Cookie"];
    [self.webView loadRequest:request];

    if ([self isNeedHideLeftMenu]) {
        self.navigationItem.leftBarButtonItem = nil;
    }
}

- (BOOL)isNeedHideLeftMenu {
    //BBSLocalApi *localForumApi = [[BBSLocalApi alloc] init];
    //NSString *bundleId = [localForumApi bundleIdentifier];
    return NO;
}

// private
- (void)saveUserName:(NSString *)name {
    BBSLocalApi *localForumApi = [[BBSLocalApi alloc] init];
    id <BBSConfigDelegate> config = [BBSApiHelper forumConfig:localForumApi.currentForumHost];
    [localForumApi saveUserName:name forHost:config.forumURL.host];
}

- (void)hideMaskView {
    self.maskLoadingView.hidden = YES;
}

#pragma mark - WKNavigationDelegate

- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation {

    NSLog(@"WKNavigationDelegate -> %@", @"didFinishNavigation");

    // 保存Cookie
    BBSLocalApi *localForumApi = [[BBSLocalApi alloc] init];
    [localForumApi saveCookie];

    NSString *currentURL = webView.URL.absoluteString;
    NSLog(@"TForumLogin.webViewDidFinishLoad->%@", currentURL);
    
    NSString *urlString = webView.URL.absoluteString;

    NSString *index = [localForumApi.currentForumURL stringByAppendingString:@"index.php"];
    if ([currentURL isEqualToString:index]) {

        NSLog(@"CrskyLogin.shouldStartLoadWithRequest, Enter index.php %@ ", urlString);
        // 保存Cookie
        [localForumApi saveCookie];
        
        //[NSThread sleepForTimeInterval:2.0];
        
        [webView evaluateJavaScript:@"document.documentElement.innerHTML" completionHandler:^(id o, NSError *error) {
            NSString *html = o;
            NSLog(@"TForumLogin.userName->%@", html);

            [self.forumApi fetchUserInfo:html handler:^(BOOL isSuccess, id userName, id userId) {

                [localForumApi saveUserId:userId forHost:@"crskybbs.org"];
                [localForumApi saveUserName:userName forHost:@"crskybbs.org"];

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
            }];
        }];

//        [self.forumApi fetchUserInfo:^(BOOL isSuccess, NSString *userName, NSString *userId) {
//
//            NSLog(@"CrskyLogin.shouldStartLoadWithRequest, fetchUserInfo %@ ", urlString);
//
//            if (isSuccess) {
//
//
//
//            }
//        }];
    } else {
//        // 使用JS注入获取用户输入的密码
//        [webView evaluateJavaScript:@"document.getElementsByName('pwuser')[0].value" completionHandler:^(id o, NSError *error) {
//            NSString *userName = o;
//
//            NSLog(@"TForumLogin.userName->%@", userName);
//            if (userName != nil && ![userName isEqualToString:@""]) {
//                // 保存用户名
//                [self saveUserName:userName];
//            }
//        }];
//
//        // 改变样式
//        NSString *js = [AssertReader js_change_web_login_style];
//
//        [webView evaluateJavaScript:js completionHandler:nil];
    }
    



    [self performSelector:@selector(hideMaskView) withObject:nil/*可传任意类型参数*/ afterDelay:1.0];
}


- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    //NSString *rUrl = navigationAction.request.URL.absoluteString;
    NSLog(@"WKNavigationDelegate -> %@", @"decidePolicyForNavigationAction");
    NSURLRequest * request = navigationAction.request;

    NSString *urlString = [[request URL] absoluteString];
    NSLog(@"CrskyLogin.shouldStartLoadWithRequest %@ ", urlString);

    if ([request.URL.host containsString:@"baidu.com"]) {
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }

    decisionHandler(WKNavigationActionPolicyAllow);
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
    //NSString *bundleId = [localForumApi bundleIdentifier];

    [localForumApi clearCurrentForumURL];
    [[UIStoryboard mainStoryboard] changeRootViewControllerTo:@"ShowSupportForums" withAnim:UIViewAnimationOptionTransitionFlipFromTop];
}
@end
