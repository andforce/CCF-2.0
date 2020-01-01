//  DRL
//
//  Created by Diyuan Wang on 2019/11/21.
//  Copyright © 2019年 Diyuan Wang. All rights reserved.
//

#import "BBSTabBarController.h"
#import "SlideDrawerView.h"
#import "BBSLocalApi.h"
#import "UIStoryboard+Forum.h"
#import "BBSNavigationViewController.h"

@interface BBSTabBarController () {
    SlideDrawerView *_leftDrawerView;
}

@end

@implementation BBSTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];

    if (![self isNeedHideLeftMenu]) {
        _leftDrawerView = [[SlideDrawerView alloc] initWithDrawerType:DrawerViewTypeLeft andXib:@"SlideDrawerView"];
        [self.view addSubview:_leftDrawerView];
    }

    BBSLocalApi *localForumApi = [[BBSLocalApi alloc] init];
    if ([localForumApi.currentForumHost isEqualToString:@"bbs.smartisan.com"] || [localForumApi.currentForumHost containsString:@"chiphell.com"]) {
        [self changeMessageUITabController:Discuz];
    } else {
        [self changeMessageUITabController:vBulletin];
    }
}

- (void)changeMessageUITabController:(ForumType)forumType {

    UIStoryboard *storyboard = [UIStoryboard mainStoryboard];
    BBSNavigationViewController *controller = (BBSNavigationViewController *)
            (forumType == Discuz ? [storyboard finControllerById:@"DiscuzNavID"] : [storyboard finControllerById:@"vBulletinNavID"]);

    NSMutableArray *withDiscuzControllers = [NSMutableArray new];

    NSArray *currentControllers = self.viewControllers;

    if (currentControllers.count == 5){
        for (NSUInteger i = 0; i < currentControllers.count; i++) {
            if (i == 3) {
                [withDiscuzControllers addObject:controller];
            } else {
                [withDiscuzControllers addObject:currentControllers[i]];
            }
        }
    } else {
        for (NSUInteger i = 0; i < currentControllers.count; i++) {
            if (forumType == Discuz){
                if (i == 0 || i == 1 || i == 2 || i == 4 || i == 5){
                    [withDiscuzControllers addObject:currentControllers[i]];
                }
            } else {
                if (i == 0 || i == 1 || i == 2 || i == 3 || i == 5){
                    [withDiscuzControllers addObject:currentControllers[i]];
                }
            }
        }
    }

    self.viewControllers = [withDiscuzControllers copy];
}

- (BOOL)isNeedHideLeftMenu {
    BBSLocalApi *localForumApi = [[BBSLocalApi alloc] init];
    NSString *bundleId = [localForumApi bundleIdentifier];
    return NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)showLeftDrawer {
    [_leftDrawerView openLeftDrawer];
}

- (void)bringLeftDrawerToFront {
    if (![self isNeedHideLeftMenu]) {
        [_leftDrawerView bringDrawerToFront];
    }
}
@end
