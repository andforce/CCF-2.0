//
//  TForumLoginWebViewController.m
//  Forum
//
//  Created by 迪远 王 on 2018/4/29.
//  Copyright © 2018年 andforce. All rights reserved.
//

#import "TForumLoginWebViewController.h"
#import "ForumEntry+CoreDataClass.h"
#import "ForumCoreDataManager.h"
#import "UIStoryboard+Forum.h"
#import "LocalForumApi.h"

@interface TForumLoginWebViewController () <UIWebViewDelegate>

@end

@implementation TForumLoginWebViewController

- (void)viewDidLoad {
    [self.webView setScalesPageToFit:YES];
    self.webView.dataDetectorTypes = UIDataDetectorTypeNone;
    self.webView.scrollView.decelerationRate = UIScrollViewDecelerationRateNormal;
    self.webView.delegate = self;
    self.webView.scalesPageToFit = NO;
    self.webView.backgroundColor = [UIColor whiteColor];
    [self.webView setOpaque:NO];

    NSDictionary *dictionary = @{@"UserAgent": @"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/54.0.2840.71 Safari/537.36"};
    [[NSUserDefaults standardUserDefaults] registerDefaults:dictionary];

    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"https://account.smartisan.com/#/v2/login?return_url=http:%2F%2Fbbs.smartisan.com%2Fforum.php"]]];

    if ([self isNeedHideLeftMenu]) {
        self.navigationItem.leftBarButtonItem = nil;
    }
}

- (BOOL)isNeedHideLeftMenu {
    LocalForumApi *localForumApi = [[LocalForumApi alloc] init];
    NSString *bundleId = [localForumApi bundleIdentifier];
    return ![bundleId isEqualToString:@"com.andforce.forum"];
}

// private
- (void)saveUserName:(NSString *)name {
    LocalForumApi *localForumApi = [[LocalForumApi alloc] init];
    id <ForumConfigDelegate> config = [ForumApiHelper forumConfig:localForumApi.currentForumHost];
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

    NSLog(@"TForumLogin.webViewDidFinishLoad->%@", currentURL);

    // 使用JS注入获取用户输入的密码
    NSString *userName = [webView stringByEvaluatingJavaScriptFromString:@"document.getElementsByName('pwuser')[0].value"];
    NSLog(@"TForumLogin.userName->%@", userName);
    if (userName != nil && ![userName isEqualToString:@""]) {
        // 保存用户名
        [self saveUserName:userName];
    }

    NSLog(@"TForumLogin.webViewDidFinishLoad %@ ", html);


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
    NSLog(@"TForumLogin.webViewDidStartLoad %@ ", html);
}


- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {

    NSString *urlString = [[request URL] absoluteString];
    NSLog(@"TForumLogin.shouldStartLoadWithRequest %@ ", urlString);

    NSString * rUrl = request.URL.absoluteString;
    if ([rUrl isEqualToString:@"http://bbs.smartisan.com/forum.php"]) {
        LocalForumApi *localForumApi = [[LocalForumApi alloc] init];

        // 保存Cookie
        [localForumApi saveCookie];

        NSLog(@"TForumLogin.loadCookies: %@", [localForumApi loadCookie]);

        [self.forumApi fetchUserInfo:^(BOOL isSuccess, NSString *userName, NSString *userId) {
            if (isSuccess) {

                [localForumApi saveUserId:userId forHost:@"bbs.smartisan.com"];
                [localForumApi saveUserName:userName forHost:@"bbs.smartisan.com"];

                [self.forumApi listAllForums:^(BOOL success, id msg) {
                    if (success) {
                        NSMutableArray<Forum *> *needInsert = msg;
                        ForumCoreDataManager *formManager = [[ForumCoreDataManager alloc] initWithEntryType:EntryTypeForm];
                        // 需要先删除之前的老数据
                        [formManager deleteData:^NSPredicate * {
                            return [NSPredicate predicateWithFormat:@"forumHost = %@", self.currentForumHost];;
                        }];


                        [formManager insertData:needInsert operation:^(NSManagedObject *target, id src) {
                            ForumEntry *newsInfo = (ForumEntry *) target;
                            newsInfo.forumId = [src valueForKey:@"forumId"];
                            newsInfo.forumName = [src valueForKey:@"forumName"];
                            newsInfo.parentForumId = [src valueForKey:@"parentForumId"];
                            LocalForumApi *localeForumApi = [[LocalForumApi alloc] init];
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
    LocalForumApi *localForumApi = [[LocalForumApi alloc] init];
    NSString *bundleId = [localForumApi bundleIdentifier];
    if ([bundleId isEqualToString:@"com.andforce.forum"]) {
        [localForumApi clearCurrentForumURL];
        [[UIStoryboard mainStoryboard] changeRootViewControllerTo:@"ShowSupportForums" withAnim:UIViewAnimationOptionTransitionFlipFromTop];
    }
}

@end
