//
//  UIStoryboard+Forum.h
//
//  Created by WDY on 16/1/12.
//  Copyright © 2016年 andforce. All rights reserved.
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
