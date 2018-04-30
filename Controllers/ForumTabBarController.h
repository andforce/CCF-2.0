//
//  ForumTabBarController.h
//  DRL
//
//  Created by 迪远 王 on 16/5/21.
//  Copyright © 2016年 andforce. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ForumTabBarController : UITabBarController

- (void)showLeftDrawer;

- (void) bringLeftDrawerToFront;

- (void) changeMessageUITabController:(int) type;

@end
