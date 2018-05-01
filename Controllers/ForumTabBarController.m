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

- (void)changeMessageUITabController:(int)type {

    UIStoryboard * storyboard  = [UIStoryboard mainStoryboard];
    ForumNavigationViewController * navigationController1 = nil;

    if (type == 0){
        navigationController1 = (ForumNavigationViewController *) [storyboard finControllerById:@"DiscuzNavID"];
    } else {
        navigationController1 = (ForumNavigationViewController *) [storyboard finControllerById:@"vBulletinNavID"];
    }

    NSMutableArray *withDiscuzControllers = [NSMutableArray new];

    NSArray * currentControllers = self.viewControllers;

    for (NSUInteger i = 0; i < currentControllers.count; i++){
        if (i == 3){
            [withDiscuzControllers addObject:navigationController1];
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

    [self changeMessageUITabController:0];
}

- (BOOL)isNeedHideLeftMenu {
    LocalForumApi *localForumApi = [[LocalForumApi alloc] init];
    NSString *bundleId = [localForumApi bundleIdentifier];
    return ![bundleId isEqualToString:@"com.andforce.forum"];
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
