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

@interface FeiFanLoginViewController () <UIWebViewDelegate> {

}

@end

@implementation FeiFanLoginViewController


- (void)viewDidLoad {
    [self.webView setScalesPageToFit:YES];
    self.webView.dataDetectorTypes = UIDataDetectorTypeNone;
    self.webView.scrollView.decelerationRate = UIScrollViewDecelerationRateNormal;
    self.webView.delegate = self;
    self.webView.scalesPageToFit = NO;
    self.webView.backgroundColor = [UIColor whiteColor];
    [self.webView setOpaque:NO];

    NSDictionary *dictionnary = @{@"UserAgent": @"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_13_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/67.0.3396.99 Safari/537.36"};
    [[NSUserDefaults standardUserDefaults] registerDefaults:dictionnary];

    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://bbs.crsky.com/login.php"]]];

    if ([self isNeedHideLeftMenu]) {
        self.navigationItem.leftBarButtonItem = nil;
    }
}

- (BOOL)isNeedHideLeftMenu {
    BBSLocalApi *localForumApi = [[BBSLocalApi alloc] init];
    NSString *bundleId = [localForumApi bundleIdentifier];
    return ![bundleId isEqualToString:@"com.andforce.forums"];
}

// private
- (void)saveUserName:(NSString *)name {
    BBSLocalApi *localForumApi = [[BBSLocalApi alloc] init];
    id <BBSConfigDelegate> config = [BBSApiHelper forumConfig:localForumApi.currentForumHost];
    [localForumApi saveUserName:name forHost:config.forumURL.host];
}

// private
- (NSString *)getResponseHTML:(UIWebView *)webView {
    NSString *lJs = @"document.documentElement.outerHTML";
    NSString *html = [webView stringByEvaluatingJavaScriptFromString:lJs];
    return html;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {

    NSString *html = [self getResponseHTML:webView];

    NSString *currentURL = [webView stringByEvaluatingJavaScriptFromString:@"document.location.href"];

    NSLog(@"CrskyLogin.webViewDidFinishLoad->%@", currentURL);

    // 使用JS注入获取用户输入的密码
    NSString *userName = [webView stringByEvaluatingJavaScriptFromString:@"document.getElementsByName('pwuser')[0].value"];
    NSLog(@"CrskyLogin.userName->%@", userName);
    if (userName != nil && ![userName isEqualToString:@""]) {
        // 保存用户名
        [self saveUserName:userName];
    }

    // 改变样式
    NSString *js = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"changeLoginStyle" ofType:@"js"] encoding:NSUTF8StringEncoding error:nil];

    [webView stringByEvaluatingJavaScriptFromString:js];

    [self performSelector:@selector(hideMaskView) withObject:nil/*可传任意类型参数*/ afterDelay:1.0];
}

- (void)hideMaskView {
    self.maskLoadingView.hidden = YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {

    NSString *html = [self getResponseHTML:webView];
}


- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {

    NSString *urlString = [[request URL] absoluteString];
    NSLog(@"CrskyLogin.shouldStartLoadWithRequest %@ ", urlString);

    if ([request.URL.host containsString:@"baidu.com"]) {
        return NO;
    }

    if ([request.URL.absoluteString isEqualToString:@"http://bbs.crsky.com/index.php"]) {
        BBSLocalApi *localForumApi = [[BBSLocalApi alloc] init];

        NSLog(@"CrskyLogin.shouldStartLoadWithRequest, Enter index.php %@ ", urlString);
        // 保存Cookie
        [localForumApi saveCookie];

        [self.forumApi fetchUserInfo:^(BOOL isSuccess, NSString *userName, NSString *userId) {

            NSLog(@"CrskyLogin.shouldStartLoadWithRequest, fetchUserInfo %@ ", urlString);

            if (isSuccess) {

                [localForumApi saveUserId:userId forHost:@"bbs.crsky.com"];
                [localForumApi saveUserName:userName forHost:@"bbs.crsky.com"];

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

        return NO;
    }


    return YES;
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
