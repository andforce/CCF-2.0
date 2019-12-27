//
//  Created by Diyuan Wang on 2019/11/21.
//  Copyright © 2019年 Diyuan Wang. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kForumTabBarControllerId @"ForumTabBarControllerId"

@interface UIStoryboard (Forum)

+ (UIStoryboard *)mainStoryboard;

- (void)changeRootViewControllerTo:(NSString *)identifier;

- (void)changeRootViewControllerToController:(UIViewController *)controller;

- (void)changeRootViewControllerTo:(NSString *)identifier withAnim:(UIViewAnimationOptions)anim;

- (void)changeRootViewControllerToController:(UIViewController *)controller withAnim:(UIViewAnimationOptions)anim;

- (UIViewController *)finControllerById:(NSString *)controllerId;

@end
