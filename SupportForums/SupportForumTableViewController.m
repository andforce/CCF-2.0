//  DRL
//
//  Created by Diyuan Wang on 2019/11/21.
//  Copyright © 2019年 Diyuan Wang. All rights reserved.
//

#import "SupportForumTableViewController.h"
#import "BBSThreadListTableViewController.h"
#import "BBSTabBarController.h"
#import "UIStoryboard+Forum.h"
#import "SupportForums.h"
#import "AppDelegate.h"
#import "BBSLocalApi.h"
#import "BBSPayManager.h"
#import "BBSSupportNavigationController.h"

@interface SupportForumTableViewController () <CAAnimationDelegate> {
    BBSLocalApi *localForumApi;
}

@end

@implementation SupportForumTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    localForumApi = [[BBSLocalApi alloc] init];
    self.forumApi = [BBSApiHelper forumApi:localForumApi.currentForumHost];


    [self.dataList removeAllObjects];

    [self.dataList addObjectsFromArray:localForumApi.supportForums];

    [self.tableView reloadData];


    if ([localForumApi isHaveLoginForum]) {
        if (self.canBack) {
            self.navigationItem.leftBarButtonItem.image = [UIImage imageNamed:@"ic_arrow_back_18pt"];
        } else {
            UIWindow *window = [UIApplication sharedApplication].keyWindow;
            UIViewController *rootViewController = window.rootViewController;
            if ([rootViewController isKindOfClass:[BBSSupportNavigationController class]]) {
                self.navigationItem.leftBarButtonItem.image = nil;
                self.navigationItem.leftBarButtonItem.title = @"";
            } else {
                self.navigationItem.leftBarButtonItem.image = [UIImage imageNamed:@"ic_close_18pt"];
            }

        }
    } else {
        self.navigationItem.leftBarButtonItem.image = nil;
        self.navigationItem.leftBarButtonItem.title = @"";
    }

}

- (BOOL)canBack {
    return self.presentingViewController != nil;
}

- (BOOL)setPullRefresh:(BOOL)enable {
    return NO;
}

- (BOOL)setLoadMore:(BOOL)enable {
    return NO;
}

- (BOOL)autoPullfresh {
    return NO;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = (UITableViewCell *) [tableView dequeueReusableCellWithIdentifier:@"SupportForum"];


    Forums *forums = self.dataList[(NSUInteger) indexPath.row];

    cell.textLabel.text = forums.name;

    NSString *login = [localForumApi isHaveLogin:forums.host] ? @"已登录" : @"未登录";
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@\t~\t%@", forums.host.uppercaseString, login];
    forums.host;

    UIEdgeInsets edgeInsets = UIEdgeInsetsMake(0, 16, 0, 16);
    [cell setSeparatorInset:edgeInsets];
    [cell setLayoutMargins:UIEdgeInsetsZero];
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 54;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ShowThreadList"]) {
        BBSThreadListTableViewController *controller = segue.destinationViewController;

        NSIndexPath *path = [self.tableView indexPathForSelectedRow];
        Forum *select = self.dataList[(NSUInteger) path.section];
        Forum *child = select.childForums[(NSUInteger) path.row];

        TranslateData *bundle = [[TranslateData alloc] init];
        [bundle putObjectValue:child forKey:@"TransForm"];
        [self transBundle:bundle forController:controller];

    }
}

- (BOOL)isUserHasLogin:(NSString *)host {
    // 判断是否登录
    return [[[BBSLocalApi alloc] init] isHaveLogin:host];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    [tableView deselectRowAtIndexPath:indexPath animated:NO];


    if (YES) {
        Forums *forums = self.dataList[(NSUInteger) indexPath.row];

        NSURL *url = [NSURL URLWithString:forums.url];

        BBSLocalApi *localForumApi = [[BBSLocalApi alloc] init];
        [localForumApi saveCurrentForumURL:forums.url];

        if ([self isUserHasLogin:url.host]) {

            UIStoryboard *mainStoryboard = [UIStoryboard mainStoryboard];
            [mainStoryboard changeRootViewControllerTo:@"ForumTabBarControllerId"];

        } else {

            id <BBSConfigDelegate> forumConfig = [BBSApiHelper forumConfig:localForumApi.currentForumHost];

            NSString *cId = forumConfig.loginControllerId;
            [[UIStoryboard mainStoryboard] changeRootViewControllerTo:cId withAnim:UIViewAnimationOptionTransitionFlipFromTop];
        }
    }
}


- (IBAction)showLeftDrawer:(id)sender {
    BBSTabBarController *controller = (BBSTabBarController *) self.tabBarController;

    [controller showLeftDrawer];
}

- (IBAction)cancel:(id)sender {

    BBSLocalApi *localForumApi = [[BBSLocalApi alloc] init];

    if (![localForumApi isHaveLogin:localForumApi.currentForumHost]) {
        NSArray<Forums *> *loginForums = localForumApi.loginedSupportForums;
        if (loginForums != nil && loginForums.count > 0) {
            [localForumApi saveCurrentForumURL:loginForums.firstObject.url];
        }
    }

    if ([localForumApi isHaveLoginForum]) {
        if (self.canBack) {
            [self.navigationController popViewControllerAnimated:YES];
        } else {
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    } else {
        //[self exitApplication];
    }
}

- (void)exitApplication {
    AppDelegate *app = (AppDelegate *) [UIApplication sharedApplication].delegate;
    UIWindow *window = app.window;

    CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.x"];
    rotationAnimation.delegate = self;

    rotationAnimation.fillMode = kCAFillModeForwards;

    rotationAnimation.removedOnCompletion = NO;
    //旋转角度
    rotationAnimation.toValue = @((float) (M_PI / 2));
    //每次旋转的时间（单位秒）
    rotationAnimation.duration = 0.5;
    rotationAnimation.cumulative = YES;
    //重复旋转的次数，如果你想要无数次，那么设置成MAXFLOAT
    rotationAnimation.repeatCount = 0;
    [window.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    exit(0);
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}

@end



