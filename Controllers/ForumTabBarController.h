//
//  ForumTabBarController.h
//  DRL
//
//  Created by 迪远 王 on 16/5/21.
//  Copyright © 2016年 andforce. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, ForumType) {
    vBulletin = 0,
    Discuz
};

@interface ForumTabBarController : UITabBarController

- (void)showLeftDrawer;

- (void)bringLeftDrawerToFront;

- (void)changeMessageUITabController:(ForumType)forumType;

@end
