//
//
//  Created by Diyuan Wang on 2019/11/21.
//  Copyright © 2019年 Diyuan Wang. All rights reserved.
//

#import "BBSNavigationViewController.h"
#import "BBSApiDelegate.h"
#import "BBSApiHelper.h"
#import "BBSLocalApi.h"

@interface BBSNavigationViewController ()

@end

@implementation BBSNavigationViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    BBSLocalApi *localForumApi = [[BBSLocalApi alloc] init];
    id <BBSConfigDelegate> forumConfig = [BBSApiHelper forumConfig:localForumApi.currentForumHost];
    UIColor *dyColor = nil;

//    if (@available(iOS 13.0, *)) {
//        dyColor = [UIColor colorWithDynamicProvider:^UIColor *_Nonnull(UITraitCollection *_Nonnull trainCollection) {
//            if ([trainCollection userInterfaceStyle] == UIUserInterfaceStyleLight) {
//                return forumConfig.themeColor;
//            } else {
//                return nil;
//            }
//        }];
//    } else {
//        dyColor = forumConfig.themeColor;
//    }
//
//
//    self.navigationBar.barTintColor = dyColor;//forumConfig.themeColor;

//    if (@available(iOS 13.0, *)) {
//        if (self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleLight){
//            BBSLocalApi *localForumApi = [[BBSLocalApi alloc] init];
//            id <BBSConfigDelegate> forumConfig = [BBSApiHelper forumConfig:localForumApi.currentForumHost];
//            self.navigationBar.barTintColor = forumConfig.themeColor;
//        } else {
//            self.navigationBar.barTintColor = nil;
//        }
//    } else {
//        BBSLocalApi *localForumApi = [[BBSLocalApi alloc] init];
//        id <BBSConfigDelegate> forumConfig = [BBSApiHelper forumConfig:localForumApi.currentForumHost];
//        self.navigationBar.barTintColor = forumConfig.themeColor;
//    }
}

- (void)traitCollectionDidChange:(nullable UITraitCollection *)previousTraitCollection {
//    if (@available(iOS 13.0, *)) {
//        if (previousTraitCollection.userInterfaceStyle == UIUserInterfaceStyleDark){
//            BBSLocalApi *localForumApi = [[BBSLocalApi alloc] init];
//            id <BBSConfigDelegate> forumConfig = [BBSApiHelper forumConfig:localForumApi.currentForumHost];
//            self.navigationBar.barTintColor = forumConfig.themeColor;
//        } else {
//            self.navigationBar.barTintColor = nil;
//        }
//    } else {
//        BBSLocalApi *localForumApi = [[BBSLocalApi alloc] init];
//        id <BBSConfigDelegate> forumConfig = [BBSApiHelper forumConfig:localForumApi.currentForumHost];
//        self.navigationBar.barTintColor = forumConfig.themeColor;
//    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (UIViewController *)childViewControllerForStatusBarStyle {
    return self.topViewController;
}

@end
