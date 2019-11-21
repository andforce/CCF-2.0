//  DRL
//
//  Created by Diyuan Wang on 2019/11/21.
//  Copyright © 2019年 Diyuan Wang. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, ForumType) {
    vBulletin = 0,
    Discuz
};

@interface BBSTabBarController : UITabBarController

- (void)showLeftDrawer;

- (void)bringLeftDrawerToFront;

- (void)changeMessageUITabController:(ForumType)forumType;

@end
