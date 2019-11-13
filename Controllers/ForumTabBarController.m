//
//  ForumTabBarController.m
//  DRL
//
//  Created by 迪远 王 on 16/5/21.
//  Copyright © 2016年 andforce. All rights reserved.
//

#import "ForumTabBarController.h"
#import "DrawerView.h"
#import "LocalForumApi.h"
#import "UIStoryboard+Forum.h"
#import "ForumNavigationViewController.h"

@interface ForumTabBarController () {
    DrawerView *_leftDrawerView;
}

@end

@implementation ForumTabBarController

- (void)changeMessageUITabController:(ForumType) forumType {

    UIStoryboard * storyboard  = [UIStoryboard mainStoryboard];
    ForumNavigationViewController * controller = (ForumNavigationViewController *)
            (forumType == Discuz ? [storyboard finControllerById:@"DiscuzNavID"]: [storyboard finControllerById:@"vBulletinNavID"]);

    NSMutableArray *withDiscuzControllers = [NSMutableArray new];

    NSArray * currentControllers = self.viewControllers;

    for (NSUInteger i = 0; i < currentControllers.count; i++){
        if (i == 3){
            [withDiscuzControllers addObject:controller];
        } else {
            [withDiscuzControllers addObject:currentControllers[i]];
        }
    }

    self.viewControllers = [withDiscuzControllers copy];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    if (![self isNeedHideLeftMenu]){
        _leftDrawerView = [[DrawerView alloc] initWithDrawerType:DrawerViewTypeLeft andXib:@"DrawerView"];
        [self.view addSubview:_leftDrawerView];
    }

    LocalForumApi *localForumApi = [[LocalForumApi alloc] init];
    if ([localForumApi.currentForumHost isEqualToString:@"bbs.smartisan.com"] || [localForumApi.currentForumHost containsString:@"chiphell.com"]){
        [self changeMessageUITabController:Discuz];
    } else {
        [self changeMessageUITabController:vBulletin];
    }
}

- (BOOL)isNeedHideLeftMenu {
    LocalForumApi *localForumApi = [[LocalForumApi alloc] init];
    NSString *bundleId = [localForumApi bundleIdentifier];
    return ![bundleId isEqualToString:@"com.andforce.forums"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)showLeftDrawer{
    [_leftDrawerView openLeftDrawer];
}

- (void)bringLeftDrawerToFront {
    if (![self isNeedHideLeftMenu]){
        [_leftDrawerView bringDrawerToFront];
    }
}
@end
